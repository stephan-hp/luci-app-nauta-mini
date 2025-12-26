m = Map("nauta", "🌐 Nauta Autologin",
    "Este servicio permite iniciar sesión automáticamente en el portal cautivo de ETECSA " ..
    "(secure.etecsa.net).<br/><br/>" ..
    "🔁 <b>Funcionamiento:</b> un script ligero se ejecuta cada cierto tiempo usando <i>cron</i>. " ..
    "Si detecta que no hay Internet, intenta iniciar sesión de forma automática.<br/><br/>" ..
    "⚠️ Ideal para routers con poca memoria (4 MB). No usa curl ni bash."
)

s = m:section(TypedSection, "auth", "🔐 Credenciales Nauta")
s.anonymous = true
s.addremove = false

-- Usuario
u = s:option(Value, "username", "👤 Usuario")
u.placeholder = "usuario@nauta.com.cu"
u.description =
    "Introduce tu usuario de Nauta. Puedes usar <b>@nauta.com.cu</b> o <b>@nauta.co.cu</b> " ..
    "si lo deseas, pero <b>no es obligatorio</b>."

-- Contraseña
p = s:option(Value, "password", "🔑 Contraseña")
p.password = true
p.description =
    "Contraseña asociada a tu cuenta Nauta. Se almacena localmente en el router."

-- Autologin
a = s:option(Flag, "autologin", "🔄 Autologin")
a.default = a.disabled
a.rmempty = false
a.description =
    "Cuando está activado, el router intentará conectarse automáticamente a Internet " ..
    "cada cierto tiempo si la conexión se cae."

return m
