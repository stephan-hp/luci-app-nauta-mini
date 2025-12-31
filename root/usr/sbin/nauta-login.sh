#!/bin/sh

CONFIG="etecsa"
SECTION="nauta"

LOGIN_IP="secure.etecsa.net:8443"

# Leer configuración de Luci
USER="$(uci get $CONFIG.$SECTION.username 2>/dev/null)"
PASS="$(uci get $CONFIG.$SECTION.password 2>/dev/null)"
PING_HOST="$(uci get $CONFIG.$SECTION.pinghost 2>/dev/null)"
AUTOLOGIN="$(uci get $CONFIG.$SECTION.autologin 2>/dev/null)"
CHECK_INTERVAL="$(uci get $CONFIG.$SECTION.check_interval 2>/dev/null)"
MAX_RETRIES="$(uci get $CONFIG.$SECTION.max_retries 2>/dev/null)"

check_internet() {
	ping -c 1 -W 2 "$PING_HOST" >/dev/null 2>&1
	return $?
}

# default values
[ -z "$CHECK_INTERVAL" ] && CHECK_INTERVAL=15
[ -z "$MAX_RETRIES" ] && MAX_RETRIES=5
[ -z "$AUTOLOGIN" ] && AUTOLOGIN=0
[ -z "$PING_HOST" ] && PING_HOST="visuales.uclv.cu"

echo "[*] Verificando si estamos conectados a Internet..."

if check_internet; then
    echo "[✓] Conectado a Internet, no es necesario iniciar sesión."
	exit 0
else
    echo "[!] No hay conexión a Internet."
fi

echo "[*] Verificando conectividad con $LOGIN_IP..."

while true; do
    if ping -c 1 -W 2 "$LOGIN_IP" >/dev/null 2>&1; then
        echo "[✓] $LOGIN_IP responde, procediendo..."
        break
    else
        echo "[!] $LOGIN_IP no responde. Reintentando en $CHECK_INTERVAL s..."
        sleep $CHECK_INTERVAL
    fi
done

URL="https://secure.etecsa.net:8443/"
TMP="/tmp/etecsa_raw.html"
NORM="/tmp/etecsa_norm.html"
REDIR="/tmp/etecsa_redirect.html"
URLPOST="https://secure.etecsa.net:8443//LoginServlet"

echo "[*] Descargando portal cautivo..."

wget --no-check-certificate -qO "$TMP" "$URL"

[ ! -s "$TMP" ] && {
    echo "[!] ERROR: No se pudo descargar la página"
    exit 1
}

# Extraer CSRFHW (primer input válido)
CSRFHW=$(sed -n "s/.*name=['\"]CSRFHW['\"].*value=['\"]\([^'\"]*\).*/\1/p" "$TMP" | head -n 1)
echo "[✓] CSRFHW = $CSRFHW"

# Normalizar HTML para awk
sed '
s/></>\n</g
s/<input/\n<input/g
s/<\/form>//g
s/'"'"'"/"/g
' "$TMP" > "$NORM"

echo "[...] HTML normalizado"

awk '
/<input/ && /name="/ {
    name=""; type="text"; value=""

    if (match($0,/name="[^"]+"/))
        name=substr($0,RSTART+6,RLENGTH-7)

    if (match($0,/type="[^"]+"/))
        type=substr($0,RSTART+6,RLENGTH-7)

    if (match($0,/value="[^"]*"/))
        value=substr($0,RSTART+7,RLENGTH-8)

    printf " %-15s | %-10s | %s\n", name, type, value
}
' "$NORM"
rm -f "$TMP" "$NORM"
echo "Iniciando sesión con usuario $USER..."

POSTDATA="username=$USER&password=$PASS&CSRFHW=$CSRFHW"

for field in wlanuserip wlanacname wlanmac firsturl ssid usertype gotopage successpage loggerId lang; do
    val=$(grep -o "name=\"$field\"[^>]*value=\"[^\"]*\"" "$TMP" 2>/dev/null | sed 's/.*value="\([^"]*\)".*/\1/')
    POSTDATA="$POSTDATA&$field=$(echo "$val" | sed 's/ /%20/g')"
done

(
  wget --no-check-certificate -qO "$REDIR" \
    --post-data "$POSTDATA" "$URLPOST" &
) &

echo "[✓] Datos enviados, esperando respuesta..."
sleep 5

if check_internet; then
	echo "[✓] Conexión a Internet establecida."
else
	echo "[!] ERROR: No se pudo establecer conexión a Internet."
	exit 1
fi