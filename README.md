# Demo de Seguridad en PostgreSQL (TLS + Roles) - FarmaEC

En esta carpeta simulamos el sistema de una cadena de farmacias para demostrar que un usuario
sin permisos no puede leer datos sensibles, y que la conexión va siempre cifrada.

## Antes de cada sesión: abrimos Docker Desktop 

Antes de tocar la terminal, abrimos la app **Docker Desktop**. Sin esto abierto, ningún comando de Docker va a funcionar.

Para confirmar que está listo, escribimos:

```
docker ps
```

Si muestra una tabla (aunque esté vacía) y no un error, podemos seguir.

## Paso 1 — Generar el certificado (solo lo haremos la primera vez)

Esto crea el "candado" que cifra la conexión.

```
mkdir certs
```

```
docker run --rm -v "${PWD}/certs:/certs" alpine/openssl req -x509 -newkey rsa:2048 -nodes -keyout /certs/server.key -out /certs/server.crt -days 365 -subj "/CN=localhost"
```

Copiamos ese comando completo de una sola vez, `${PWD}` se llena solo con nuestra carpeta actual.

Si por algun motivo llega a fallar la ruta, usamos directamente nuestra ruta real:

```
docker run --rm -v "C:\Users\Windows\Desktop\demo-postgres-seguridad\certs:/certs" alpine/openssl req -x509 -newkey rsa:2048 -nodes -keyout /certs/server.key -out /certs/server.crt -days 365 -subj "/CN=localhost"
```

**Confirmar:** escribimos `dir certs` y deberíamos ver `server.crt` y `server.key`.

## Paso 2 — Levantar el contenedor

```
docker compose up --build -d
```

**Confirmar:** escribimos `docker ps`, debe aparecer `farmaec_pg_seguro` con estado `Up`.

> **Nota:** los scripts de `init/` solo se ejecutan la primera vez que se crean los datos.
> Si en algún momento corregimos algo dentro de la carpeta `init/` después de ya haber
> levantado el contenedor una vez, necesitamos borrar los datos viejos antes de volver a
> levantarlo: `docker compose down -v` y luego repetir `docker compose up --build -d`.

## Paso 3 — Comprobar que el cifrado es obligatorio

Sin cifrado (debe fallar):

```
docker exec -it farmaec_pg_seguro psql "host=127.0.0.1 port=5432 dbname=farmaec user=farmaceutico sslmode=disable"
```

**Aquí NO nos va a pedir contraseña.** El servidor corta la conexión de inmediato, antes de
llegar a esa parte, y nos devuelve directo a PowerShell. Esperado: error mencionando
"no encryption". Esa línea de error es el resultado esperado.

Con cifrado (debe funcionar):

```
docker exec -it farmaec_pg_seguro psql "host=127.0.0.1 port=5432 dbname=farmaec user=farmaceutico sslmode=require"
```

Aquí sí nos va a pedir contraseña, con una línea como `Password for user farmaceutico:`.
Escribimos `Farma2026!` y presionamos Enter (no se ve nada mientras escribimos, es normal por un tema de seguridad).

Ya dentro (la línea de comandos ahora dice `farmaec=>`), escribimos:

```
\conninfo
```

Debe decir algo como "SSL connection (protocol TLSv1.3...)".

> **Nota:** los comandos como `\conninfo` y `\q` usan barra invertida (`\`), no barra normal (`/`).
> Si escribimos `/q` en vez de `\q`, psql va a marcar error de sintaxis.

## Paso 4 — Usuario CON permiso (control positivo)

Seguimos conectados como `farmaceutico`. Escribimos:

```
SELECT * FROM recetas_medicas;
```

Debe mostrar filas sin error (sí tiene permiso). Salimos con:

```
\q
```

## Paso 5 — Usuario SIN permiso

```
docker exec -it farmaec_pg_seguro psql "host=127.0.0.1 port=5432 dbname=farmaec user=analista_marketing sslmode=require"
```

Nos pedirá `Password for user analista_marketing:`. Escribimos `Marketing2026!` y Enter. Ya dentro:

```
SELECT * FROM recetas_medicas;
```

Esperado:

```
ERROR:  permission denied for table recetas_medicas
```

Salimos con `\q`.

## Paso 6 — Ver evidencia de auditoría

```
docker logs farmaec_pg_seguro --tail 50
```

## Paso 7 — Apagar todo

```
docker compose down
```
