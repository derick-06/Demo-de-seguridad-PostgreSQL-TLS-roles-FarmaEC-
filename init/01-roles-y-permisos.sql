-- =========================================================
-- FarmaEC - Demo de seguridad: usuarios, roles y privilegios
-- Tema 5: Seguridad, privacidad y cumplimiento normativo en SGBDD
-- =========================================================

-- -----------------------------------------------------
-- 1. Tablas de ejemplo (esquema simplificado de farmacia)
-- -----------------------------------------------------

CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio NUMERIC(10,2) NOT NULL,
    stock INT NOT NULL
);

CREATE TABLE ventas (
    id SERIAL PRIMARY KEY,
    producto_id INT REFERENCES productos(id),
    cantidad INT NOT NULL,
    fecha DATE DEFAULT CURRENT_DATE
);

-- Tabla SENSIBLE: datos de salud de pacientes.
-- Este es exactamente el tipo de dato que LOPDP (Ecuador) y GDPR consideran
-- "dato sensible" (salud) y que requiere controles de acceso reforzados.
CREATE TABLE recetas_medicas (
    id SERIAL PRIMARY KEY,
    paciente_nombre VARCHAR(100) NOT NULL,
    paciente_cedula VARCHAR(15) NOT NULL,
    medicamento VARCHAR(100) NOT NULL,
    diagnostico VARCHAR(200) NOT NULL,
    fecha DATE DEFAULT CURRENT_DATE
);

-- -----------------------------------------------------
-- 2. Datos de ejemplo
-- -----------------------------------------------------

INSERT INTO productos (nombre, precio, stock) VALUES
 ('Paracetamol 500mg', 1.50, 200),
 ('Amoxicilina 250mg', 3.20, 80),
 ('Loratadina 10mg', 2.10, 120);

INSERT INTO ventas (producto_id, cantidad) VALUES (1, 5), (2, 2);

INSERT INTO recetas_medicas (paciente_nombre, paciente_cedula, medicamento, diagnostico) VALUES
 ('Maria Lopez', '1312345678', 'Amoxicilina 250mg', 'Infeccion respiratoria'),
 ('Carlos Mera', '1398765432', 'Loratadina 10mg', 'Rinitis alergica');

-- -----------------------------------------------------
-- 3. Roles (principio de minimo privilegio)
-- -----------------------------------------------------

-- Rol administrador del esquema de farmacia (NO es superusuario de Postgres,
-- solo tiene control total sobre las tablas de la aplicacion)
CREATE ROLE admin_farmacia LOGIN PASSWORD 'AdminFarma2026!';
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin_farmacia;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin_farmacia;

-- Rol farmaceutico: necesita despachar recetas (leerlas) y gestionar
-- inventario/ventas, pero NO necesita borrar ni modificar el historial clinico.
CREATE ROLE farmaceutico LOGIN PASSWORD 'Farma2026!';
GRANT SELECT, INSERT, UPDATE ON productos, ventas TO farmaceutico;
GRANT SELECT ON recetas_medicas TO farmaceutico;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO farmaceutico;

-- Rol analista de marketing: solo necesita ver catalogo y ventas para
-- reportes comerciales. NO tiene ninguna razon legitima para ver datos
-- de salud de pacientes -> por eso NO se le otorga ningun privilegio
-- sobre recetas_medicas. Este es el usuario que usaremos para demostrar
-- el bloqueo de acceso a la tabla sensible.
CREATE ROLE analista_marketing LOGIN PASSWORD 'Marketing2026!';
GRANT SELECT ON productos, ventas TO analista_marketing;
-- (Intencionalmente no hay ningun GRANT sobre recetas_medicas para este rol)
