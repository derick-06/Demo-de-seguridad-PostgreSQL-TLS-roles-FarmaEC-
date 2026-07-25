# Imagen personalizada de PostgreSQL con soporte TLS habilitado
FROM postgres:16

# Copiamos los certificados generados previamente (ver README, Paso 1)
COPY certs/server.crt /var/lib/postgresql/server.crt
COPY certs/server.key /var/lib/postgresql/server.key

# PostgreSQL exige que la llave privada NO tenga permisos de grupo/otros,
# y que pertenezca al usuario "postgres" dentro del contenedor.
RUN chmod 600 /var/lib/postgresql/server.key \
    && chown postgres:postgres /var/lib/postgresql/server.crt /var/lib/postgresql/server.key

# Forzamos que TODAS las conexiones por TCP requieran SSL (no solo las locales).
# Esto se hace después de que el contenedor genere su pg_hba.conf por defecto,
# por eso lo aplicamos vía script de inicialización (ver init/00-forzar-ssl.sh)
