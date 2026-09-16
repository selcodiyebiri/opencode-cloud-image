FROM smanx/opencode:latest

RUN apt-get update \
 && apt-get install -y --no-install-recommends git ca-certificates curl gnupg lsof procps \
 && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && npm install -g opencode-pilot@0.29.3 \
 && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends gh \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN node --version && npm --version && git --version && gh --version | head -1

RUN timeout 90 npx -y @modelcontextprotocol/server-filesystem /root >/dev/null 2>&1 || true; \
    timeout 90 npx -y @cyanheads/git-mcp-server >/dev/null 2>&1 || true; \
    timeout 90 npx -y @kazuph/mcp-fetch >/dev/null 2>&1 || true; \
    timeout 90 npx -y @modelcontextprotocol/server-sequential-thinking >/dev/null 2>&1 || true; \
    timeout 90 npx -y @upstash/context7-mcp >/dev/null 2>&1 || true; \
    echo "npx cache warmed"

COPY pilot/ /root/.config/opencode/pilot/
COPY auth-shim/oc-auth-shim.cjs /usr/local/lib/oc-auth-shim.cjs
ENV NODE_OPTIONS="--require /usr/local/lib/oc-auth-shim.cjs"
RUN ln -sfn /root/.local/share/opencode/xdg/opencode/opencode.json /root/.config/opencode/opencode.json \
 && ln -sfn /root/.local/share/opencode/xdg/opencode/opencode.jsonc /root/.config/opencode/opencode.jsonc \
 && ln -sfn /root/.local/share/opencode/pilot-data /root/.local/share/opencode-pilot \
 && ln -sfn /root/.local/share/opencode/pilot-data/poll-state.json /root/.config/opencode/pilot/poll-state.json
