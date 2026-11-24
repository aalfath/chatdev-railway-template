# Changelog

Deployers read this before applying a Railway update. Breaking changes come first in each entry.

## 2026-11-24: ChatDev v2.2.0 (first release)

- ChatDev 2.x (DevAll) `v2.2.0`, upstream commit `3c72d860d2553f05129b7dff0fd4efdde5b01d2f`, built from source (upstream publishes no image).
- Two services: `web` (Caddy with a generated password, static Vue console, public) and `backend` (FastAPI workflow server, private, volume at `/data`).
- `POST /api/tools/local` (upload Python tools over HTTP) is blocked at the proxy, because it runs uploaded code in the backend.
