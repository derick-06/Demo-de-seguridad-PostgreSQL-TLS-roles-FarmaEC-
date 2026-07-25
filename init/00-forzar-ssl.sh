#!/bin/bash
# Este script corre automáticamente la primera vez que se crea el contenedor
# (PostgreSQL ejecuta todo lo que está en /docker-entrypoint-initdb.d/ en orden alfabético,
# por eso este archivo empieza con "00-" para que corra ANTES del SQL de roles).
#
# Objetivo: reemplazar el pg_hba.conf por defecto (que confía sin contraseña en
# conexiones desde 127.0.0.1) por uno que exige SIEMPRE cifrado (hostssl) Y
# contraseña (scram-sha-256), sin excepciones para localhost.

set -e

cat > "$PGDATA/pg_hba.conf" << 'HBA'
# TYPE    DATABASE        USER            ADDRESS                 METHOD
local     all             all                                     trust
hostssl   all             all             0.0.0.0/0               scram-sha-256
hostssl   all             all             ::0/0                   scram-sha-256
HBA

echo ">>> pg_hba.conf reemplazado: TODAS las conexiones TCP exigen SSL + contraseña."
cat "$PGDATA/pg_hba.conf"
