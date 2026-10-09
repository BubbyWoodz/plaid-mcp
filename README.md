# plaid-mcp (Brumble packaging)

Self-hosted [Plaid MCP server](https://github.com/lukew0824/plaid-mcp-server)
(upstream commit `e21196d`, 2026-09-16) packaged as a Docker image for Umbrel
via the Brumble app store.

It exposes bank accounts, balances, transactions, merchants, and spending
totals over **remote MCP (Streamable HTTP)** at `/mcp`, protected by OAuth 2.1
with Google sign-in and an email allowlist. Plaid access tokens stay encrypted
on your own server.

**No upstream code changes** — this repo only adds the Docker packaging
(`Dockerfile`, `entrypoint.sh`, this workflow). Upstream `src/` is vendored so
builds are reproducible.

## Image

`ghcr.io/bubbywoodz/plaid-mcp:latest` — built by
[.github/workflows/docker.yml](.github/workflows/docker.yml) on every push to
`main`. The Brumble store package (`bubbywoodz-plaid-mcp`) pins the image by
digest.

## First-time setup (on the Umbrel)

The container boots unconfigured; fill in `/data/.env` inside the app data dir,
then restart the app:

```env
PLAID_ENV=production
PLAID_CLIENT_ID=<from dashboard.plaid.com>
PLAID_PRODUCTION_SECRET=<from dashboard.plaid.com>
GOOGLE_CLIENT_ID=<from Google Cloud Console>
GOOGLE_CLIENT_SECRET=<from Google Cloud Console>
ALLOWED_EMAIL=<your Google email — only this address can sign in>
BASE_URL=<public https URL of this server, no trailing slash>
```

Then:

1. Register `BASE_URL/auth/google/callback` as an authorized redirect URI in the
   Google Cloud OAuth client.
2. Open `BASE_URL` in a browser, sign in with the allowlisted Google account.
3. Connect your bank at `BASE_URL/plaid/link` (Plaid Link).
4. In Poke: **New Integration → MCP**, Server URL `BASE_URL/mcp`. Poke
   auto-detects the OAuth flow; sign in with the same Google account.

`TOKEN_ENC_KEY` (encrypts Plaid tokens at rest) is generated automatically on
first boot and persisted at `/data/.token_enc_key` — never share it.
