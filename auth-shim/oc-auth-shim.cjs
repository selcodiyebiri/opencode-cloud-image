// oc-auth-shim.cjs
//
// Adds OpenCode server Basic Auth headers to localhost:4096 requests.
//
// Why: opencode-pilot (0.29.3) talks to the local OpenCode server API but does
// not send auth headers, while the server requires Basic Auth when
// OPENCODE_SERVER_USERNAME / OPENCODE_SERVER_PASSWORD are set. The pilot then
// concludes "No OpenCode server found" and skips every item.
//
// This shim is loaded via NODE_OPTIONS=--require for every Node process in the
// container; it only touches requests to the local OpenCode server port, so
// public traffic and MCP servers are unaffected. It lives in the container
// image, so upgrading opencode-pilot does not remove it.

const username = process.env.OPENCODE_SERVER_USERNAME;
const password = process.env.OPENCODE_SERVER_PASSWORD;
const targetPort = process.env.OC_AUTH_SHIM_PORT || "4096";
const localHosts = new Set(["127.0.0.1", "localhost", "::1"]);

if (username && password && typeof globalThis.fetch === "function") {
  const originalFetch = globalThis.fetch;
  const authHeader =
    "Basic " + Buffer.from(`${username}:${password}`).toString("base64");

  globalThis.fetch = function (input, init) {
    try {
      const url =
        typeof input === "string"
          ? new URL(input)
          : input instanceof URL
            ? input
            : new URL(input.url);
      if (localHosts.has(url.hostname) && url.port === targetPort) {
        const headers = new Headers(
          init && init.headers
            ? init.headers
            : input instanceof Request
              ? input.headers
              : undefined,
        );
        if (!headers.has("authorization")) {
          headers.set("authorization", authHeader);
        }
        init = { ...(init || {}), headers };
      }
    } catch {
      // ignore malformed inputs and fall through to the original fetch
    }
    return originalFetch.call(globalThis, input, init);
  };
}
