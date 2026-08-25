#!/bin/sh
set -e

DOMAIN="${BRIDGE_DOMAIN:?Set BRIDGE_DOMAIN (e.g. tg-api.example.com)}"
BEHIND_PROXY="${BEHIND_PROXY:-1}"

if [ -n "${ALLOW_IRAN_IP:-}" ]; then
    export ALLOW_BLOCK="allow ${ALLOW_IRAN_IP}; deny all;"
else
    export ALLOW_BLOCK=""
fi

if [ "$BEHIND_PROXY" = "1" ] || [ "$BEHIND_PROXY" = "true" ]; then
    envsubst '${ALLOW_BLOCK}' \
        < /etc/nginx/nginx-http.conf.template \
        > /etc/nginx/conf.d/default.conf
    exec nginx -g "daemon off;"
fi

LE_CERT="/etc/letsencrypt/live/${DOMAIN}/fullchain.pem"
LE_KEY="/etc/letsencrypt/live/${DOMAIN}/privkey.pem"
DUMMY_DIR="/etc/nginx/ssl"
DUMMY_CERT="${DUMMY_DIR}/dummy.crt"
DUMMY_KEY="${DUMMY_DIR}/dummy.key"

mkdir -p "$DUMMY_DIR" /var/www/certbot

if [ ! -f "$DUMMY_CERT" ] || [ ! -f "$DUMMY_KEY" ]; then
    openssl req -x509 -nodes -newkey rsa:2048 -days 7 \
        -keyout "$DUMMY_KEY" -out "$DUMMY_CERT" \
        -subj "/CN=${DOMAIN}" >/dev/null 2>&1
fi

if [ -f "$LE_CERT" ] && [ -f "$LE_KEY" ]; then
    export SSL_CERT="$LE_CERT"
    export SSL_KEY="$LE_KEY"
else
    export SSL_CERT="$DUMMY_CERT"
    export SSL_KEY="$DUMMY_KEY"
    echo "No Let's Encrypt cert for ${DOMAIN} yet; using a temporary self-signed cert."
    echo "Issue a cert, then: docker compose restart nginx"
fi

envsubst '${BRIDGE_DOMAIN} ${SSL_CERT} ${SSL_KEY} ${ALLOW_BLOCK}' \
    < /etc/nginx/nginx.conf.template \
    > /etc/nginx/conf.d/default.conf

exec nginx -g "daemon off;"
