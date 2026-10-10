# ELITE ACCESS BCN · App compartida (base preparada)

Incluye una app web adaptable a móvil, inicio de sesión por Supabase Auth, sincronización de un estado operativo entre dispositivos, partes de incidencia, fichajes, rondas GPS manuales, servicios, directorio local, CSV/JSON e impresión.

## Lo que ya viene preparado
- Interfaz de inicio de sesión (sin registro público).
- Código de conexión a Supabase Auth y a la tabla `app_state`.
- Actualización en tiempo real entre dispositivos autenticados.
- Políticas RLS: solo usuarios añadidos a `company_members` pueden leer/escribir los datos.
- No requiere pagar un servidor propio en el plan gratuito si el uso queda dentro de los límites vigentes.

## Configuración necesaria una sola vez
**No está conectada todavía a una base de datos real**, porque hay que crear el proyecto en tu cuenta Supabase y copiar sus claves. No compartas nunca la clave `service_role`.

1. Entra en https://supabase.com y crea un proyecto gratuito. Guarda la contraseña de la base de datos en un lugar seguro.
2. En Project Settings / API (o Connect), copia la URL del proyecto y la clave pública `anon`/publishable.
3. Edita `app/config.js`: reemplaza `https://TU_PROYECTO.supabase.co` y `TU_CLAVE_PUBLICA_ANON`.
4. En Supabase > SQL Editor, ejecuta todo el archivo `app/supabase-schema.sql`.
5. En Authentication, invita/crea tu usuario administrador. Copia su UUID desde Authentication > Users.
6. En SQL Editor ejecuta `insert into public.company_members(user_id, role) values ('PEGA-AQUI-EL-UUID', 'admin');`.
7. Invita cada trabajador desde Authentication y añade su UUID a `company_members` con rol `employee`. No actives el registro abierto.
8. Publica los archivos de `app/` en una carpeta `app/` de la rama `main` de tu repositorio GitHub. Mantén los archivos `config.js`, `index.html`, `manifest.webmanifest` y `sw.js` juntos.
9. URL esperada de GitHub Pages: https://elite-access-bcn.github.io/elite-access-bcn/app/

## Antes de uso real
La aplicación sincroniza un documento JSON compartido, por lo que los cambios de diferentes empleados se guardan en una misma estructura. Para un uso profesional con varios empleados registrando a la vez, conviene evolucionar a tablas separadas con permisos por rol, auditoría, copias de seguridad y reglas de conservación. No es un sistema de fichaje certificado ni sustituye las obligaciones laborales o de protección de datos. Prueba con datos ficticios antes de cargar datos reales. El GPS solo se registra bajo acción y permiso del usuario; no hay rastreo en segundo plano.
