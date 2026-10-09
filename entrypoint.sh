#!/bin/bash
# Entrypoint for the Plaid MCP server (Umbrel/Brumble packaging).
# - Persists a per-install Fernet key for encrypting Plaid tokens at rest.
# - Loads operator secrets from /data/.env (created at setup time, never baked in).
# - Boots with safe defaults so the container starts before credentials exist.
set -e

# 1. Stable per-install key for encrypting Plaid access tokens at rest.
if [ ! -f /data/.token_enc_key ]; then
  python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())" > /data/.token_enc_key
  chmod 600 /data/.token_enc_key
fi
export TOKEN_ENC_KEY="$(cat /data/.token_enc_key)"

# 2. Operator-supplied secrets (Plaid keys, Google OAuth, BASE_URL).
if [ -f /data/.env ]; then
  set -a
  # shellcheck disable=SC1091
  . /data/.env
  set +a
fi

# 3. Defaults: the app hard-requires these env vars at import time, so default
#    them empty and let it boot unconfigured until /data/.env is filled in.
: "${PLAID_ENV:=production}"
: "${PLAID_CLIENT_ID:=}"
: "${PLAID_PRODUCTION_SECRET:=}"
: "${GOOGLE_CLIENT_ID:=}"
: "${GOOGLE_CLIENT_SECRET:=}"
: "${ALLOWED_EMAIL:=}"
: "${BASE_URL:=http://localhost:8080}"
: "${DATABASE_URL:=sqlite:////data/plaid_mcp.db}"
export PLAID_ENV PLAID_CLIENT_ID PLAID_PRODUCTION_SECRET \
       GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET ALLOWED_EMAIL \
       BASE_URL DATABASE_URL

exec uvicorn app:app --host 0.0.0.0 --port 8080
