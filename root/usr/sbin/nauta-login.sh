#!/bin/sh

CONFIG="etecsa"
SECTION="nauta"

TARGET_URL="https://secure.etecsa.net:8443/LoginServlet"
LOGIN_PAGE="https://secure.etecsa.net:8443/"

# Leer configuración
USER="$(uci get $CONFIG.$SECTION.username 2>/dev/null)"
PASS="$(uci get $CONFIG.$SECTION.password 2>/dev/null)"
PING_HOST="$(uci get $CONFIG.$SECTION.pinghost 2>/dev/null)"
AUTOLOGIN="$(uci get $CONFIG.$SECTION.autologin 2>/dev/null)"

[ -z "$PING_HOST" ] && PING_HOST="visuales.uclv.cu"

# -------- funciones --------

check_internet() {
	wget -q --timeout=8 --spider "http://$PING_HOST" >/dev/null 2>&1
}

get_csrf() {
	wget -qO- --no-check-certificate "$LOGIN_PAGE" \
	| sed -n 's/.*name="CSRFHW" value="\([^"]*\)".*/\1/p'
}

do_login() {
	CSRF="$(get_csrf)"

	[ -z "$CSRF" ] && echo "❌ No se pudo obtener CSRF" && exit 1

	wget -qO- --no-check-certificate \
		--header="Content-Type: application/x-www-form-urlencoded" \
		--post-data="\
wlanuserip=&\
wlanacname=&\
wlanmac=&\
firsturl=notFound.jsp&\
ssid=&\
usertype=&\
gotopage=%2Fnauta_etecsa%2FLoginURL%2Fpc_login.jsp&\
successpage=%2Fnauta_etecsa%2FOnlineURL%2Fpc_index.jsp&\
loggerId=$(date +%s)&\
lang=es_ES&\
username=$USER&\
password=$PASS&\
CSRFHW=$CSRF" \
	"$TARGET_URL" >/dev/null
}

# -------- ejecución --------

case "$1" in
	status)
		if check_internet; then
			echo "online"
		else
			echo "offline"
		fi
		;;
	connect)
		check_internet && exit 0
		[ -z "$USER" -o -z "$PASS" ] && exit 1
		do_login
		sleep 3
		check_internet && echo "online" || echo "offline"
		;;
esac
