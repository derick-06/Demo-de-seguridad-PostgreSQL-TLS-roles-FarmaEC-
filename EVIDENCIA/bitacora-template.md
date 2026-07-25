# Bitácora de ejecución - Demo de Seguridad SGBDD (PostgreSQL)
**Grupo:** 5
**Fecha de ejecución:** 18/06/2026
**Integrante que ejecutó la demo:** Derick Pazmiño

| Paso | Comando ejecutado | Resultado esperado | Resultado obtenido |
|------|--------------------|---------------------|----------------------|
| 1. Generar certificados | `docker run --rm -v ${PWD}/certs:/certs alpine/openssl req -x509 ...` | Se generan `server.crt` y `server.key` | | 
| 2. Levantar contenedor | `docker compose up --build -d` | Contenedor `farmaec_pg_seguro` corriendo | | 
| 3. Conexión sin TLS | `psql "...sslmode=disable"` | Error: no encryption / conexión rechazada | | 
| 4. Conexión con TLS | `psql "...sslmode=require"` + `\conninfo` | Muestra `SSL connection (protocol TLSv1.3...)` | | 
| 5. Lectura autorizada | `SELECT * FROM recetas_medicas;` como `farmaceutico` | Devuelve filas | | 
| 6. Lectura NO autorizada | `SELECT * FROM recetas_medicas;` como `analista_marketing` | `ERROR: permission denied for table recetas_medicas` | | 
| 7. Revisión de logs/auditoría | `docker logs farmaec_pg_seguro --tail 50` | Se ven líneas de conexión y el error de permisos | | 

## Observaciones del equipo
Hay que tener docker desktop ejecutandose para poder proceder con los comandos, sino no funciona.
