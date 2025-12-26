#!/bin/sh

USER="$(uci get nauta.@auth[0].username 2>/dev/null)"
PASS="$(uci get nauta.@auth[0].password 2>/dev/null)"
AUTO="$(uci get nauta.@auth[0].autologin 2>/dev/null)"

# limpiar espacios en blanco como trim
USER="$(echo -n "$USER" | tr -d '[:space:]')"
PASS="$(echo -n "$PASS" | tr -d '[:space:]')"

# ¿Auto login habilitado?

[ "$AUTO" != "1" ] && exit 0
[ -z "$USER" ] && exit 1
[ -z "$PASS" ] && exit 1

# ¿Internet activo? (Reemplazar en caso necesario)
# ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1 && exit 0
ping -c 1 -W 2 181.225.254.2 >/dev/null 2>&1 && exit 0 # Ping a visuales


# Login Nauta
wget --no-check-certificate -q \
  --post-data="username=$USER&password=$PASS" \
  -O /dev/null \
  https://secure.etecsa.net:8443/LoginServlet
