# opencode-cloud-image

Container image for the OpenCode cloud instance on Zeabur.

Base: `smanx/opencode` (OpenCode Web) plus:

- Node.js 22 (npm / npx) - required by the npx-based MCP servers
- git
- GitHub CLI (gh)
- opencode-pilot (for issue-driven automation)

Workspace rules come from the private `opencode-workspace` repository at
runtime (`XDG_CONFIG_HOME` under the persistent data volume); no secrets or
personal configuration are baked into this image.

Published (public) to GHCR:

```text
ghcr.io/selcodiyebiri/opencode-cloud:latest
```
