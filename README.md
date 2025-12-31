# luci-app-nauta

Aplicación **LuCI para OpenWrt** que permite autenticación automática en el portal cautivo **Nauta ETECSA** (`secure.etecsa.net`) con verificación de conectividad, autologin por cron y control desde la interfaz web.

Pensado para **routers de bajos recursos**, **BusyBox/ash**, y redes donde el acceso a Internet depende de un portal cautivo.

---

## Dispositivos comunes soportados

- Nanostations M2, M5 todas las versiones
- TP Link pharos CPE510 todas las versiones
- MicroTiks de recursos bajos
- Dispositivos LEDE antiguos

---

## Características

- Login automático al portal cautivo de ETECSA
- Verificación de conectividad por `ping`
- Espera activa hasta que `secure.etecsa.net` esté disponible
- Autologin configurable mediante `cron`
- Control desde LuCI vía RPC (`rpcd`)
- Compatible con BusyBox (`wget`, `ash`)
- No depende de `curl` completo
- Logs visibles con `logread`

---

## Requisitos

- OpenWrt 21.02 o superior
- Paquetes mínimos:
  ```sh
  opkg install luci-base wget
  ```

---

## Licencia

MIT
