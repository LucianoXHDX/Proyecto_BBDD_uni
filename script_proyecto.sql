-- ============================================================================
-- PROYECTO EVENTIA - BASE DE DATOS PARA GESTIÓN DE EVENTOS ACADÉMICOS
-- ============================================================================
-- Versión: 2.0 (Normalizada BCNF con ajustes)
-- Autor: Equipo de Diseño de Base de Datos
-- ============================================================================

DROP DATABASE IF EXISTS ProyectoEventia;
CREATE DATABASE IF NOT EXISTS ProyectoEventia;
USE ProyectoEventia;

-- ============================================================================
-- SECCIÓN 1: ENTIDADES BASE (PARTICIPANTES Y ROLES)
-- ============================================================================

-- tabla participante (entidad base para todos los roles)
CREATE TABLE IF NOT EXISTS participante(
    rut VARCHAR(12) PRIMARY KEY,
    nombre VARCHAR(40) NOT NULL,
    apellido VARCHAR(40) NOT NULL,
    fecha_nac DATE,
    email VARCHAR(80) UNIQUE,
    telefono VARCHAR(20),
    direccion VARCHAR(80)
);

-- tabla universidad (NUEVA - normalización)
CREATE TABLE IF NOT EXISTS universidad(
    id_universidad INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(80) NOT NULL,
    pais VARCHAR(40) DEFAULT 'Chile'
);

-- tabla departamento (NUEVA - normalización)
CREATE TABLE IF NOT EXISTS departamento(
    id_departamento INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(40) NOT NULL,
    id_universidad INT,
    FOREIGN KEY (id_universidad) REFERENCES universidad(id_universidad),
    UNIQUE(nombre, id_universidad)
);

-- tabla carrera (NUEVA - normalización)
CREATE TABLE IF NOT EXISTS carrera(
    id_carrera INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    id_departamento INT,
    FOREIGN KEY (id_departamento) REFERENCES departamento(id_departamento),
    UNIQUE(nombre, id_departamento)
);

-- tabla academico
CREATE TABLE IF NOT EXISTS academico(
    rut VARCHAR(12) PRIMARY KEY,
    id_departamento INT,
    grado_academico VARCHAR(40),
    FOREIGN KEY (rut) REFERENCES participante(rut),
    FOREIGN KEY (id_departamento) REFERENCES departamento(id_departamento)
);

-- tabla estudiante
CREATE TABLE IF NOT EXISTS estudiante(
    rut VARCHAR(12) PRIMARY KEY,
    id_carrera INT,
    FOREIGN KEY (rut) REFERENCES participante(rut),
    FOREIGN KEY (id_carrera) REFERENCES carrera(id_carrera)
);

-- tabla revisor (con universidad opcional para externos)
CREATE TABLE IF NOT EXISTS revisor(
    rut VARCHAR(12) PRIMARY KEY,
    annos_experiencia INT,
    id_universidad INT NULL,
    FOREIGN KEY (rut) REFERENCES participante(rut),
    FOREIGN KEY (id_universidad) REFERENCES universidad(id_universidad)
);

-- tabla administrador (con universidad opcional para externos)
CREATE TABLE IF NOT EXISTS administrador(
    rut VARCHAR(12) PRIMARY KEY,
    estado BOOLEAN DEFAULT TRUE,
    id_universidad INT NULL,
    FOREIGN KEY (rut) REFERENCES participante(rut),
    FOREIGN KEY (id_universidad) REFERENCES universidad(id_universidad)
);

-- ============================================================================
-- SECCIÓN 2: ENTIDADES GEOGRÁFICAS Y DE INFRAESTRUCTURA
-- ============================================================================

-- tabla ciudad (region y pais como atributos - scope local)
CREATE TABLE IF NOT EXISTS ciudad(
    id_ciudad INT PRIMARY KEY AUTO_INCREMENT,
    nombre_ciudad VARCHAR(40) NOT NULL,
    region VARCHAR(40),
    pais VARCHAR(40) DEFAULT 'Chile'
);

-- tabla sede
CREATE TABLE IF NOT EXISTS sede(
    id_sede INT PRIMARY KEY AUTO_INCREMENT,
    id_ciudad INT,
    nombre_sede VARCHAR(40) NOT NULL,
    direccion_sede VARCHAR(80),
    cantidad_salas_sede INT,
    aforo_sede INT,
    FOREIGN KEY (id_ciudad) REFERENCES ciudad(id_ciudad),
    UNIQUE(id_ciudad, nombre_sede)
);

-- tabla sala
CREATE TABLE IF NOT EXISTS sala(
    id_sala INT PRIMARY KEY AUTO_INCREMENT,
    id_sede INT,
    numero_sala VARCHAR(10),
    aforo_sala INT,
    FOREIGN KEY (id_sede) REFERENCES sede(id_sede),
    UNIQUE(id_sede, numero_sala)
);

-- ============================================================================
-- SECCIÓN 3: ENTIDADES DE EVENTOS Y TEMÁTICAS
-- ============================================================================

-- tabla evento_academico
CREATE TABLE IF NOT EXISTS evento_academico(
    id_evento INT PRIMARY KEY AUTO_INCREMENT,
    id_sede INT,
    nombre_evento VARCHAR(100) NOT NULL,
    descripcion_evento VARCHAR(500),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    rut_creador VARCHAR(12),
    estado_evento VARCHAR(20) DEFAULT 'activo',
    FOREIGN KEY (rut_creador) REFERENCES administrador(rut),
    FOREIGN KEY (id_sede) REFERENCES sede(id_sede),
    CHECK (fecha_fin >= fecha_inicio)
);

-- tabla tematica
CREATE TABLE IF NOT EXISTS tematica(
    id_tematica INT PRIMARY KEY AUTO_INCREMENT,
    nombre_tematica VARCHAR(40) NOT NULL UNIQUE,
    descripcion_tematica VARCHAR(200)
);

-- tabla evento_tematica (relación M:N)
CREATE TABLE IF NOT EXISTS evento_tematica(
    id_evento INT,
    id_tematica INT,
    PRIMARY KEY(id_evento, id_tematica),
    FOREIGN KEY (id_evento) REFERENCES evento_academico(id_evento),
    FOREIGN KEY (id_tematica) REFERENCES tematica(id_tematica)
);

-- ============================================================================
-- SECCIÓN 4: INSCRIPCIÓN Y PAGO
-- ============================================================================

-- tabla inscripcion (surrogate PK + UNIQUE para regla de negocio)
CREATE TABLE IF NOT EXISTS inscripcion(
    id_inscripcion INT PRIMARY KEY AUTO_INCREMENT,
    rut_participante VARCHAR(12),
    id_evento INT,
    fecha_inscripcion DATE NOT NULL,
    estado_inscripcion VARCHAR(20) DEFAULT 'pendiente',
    rol_en_evento VARCHAR(20),
    FOREIGN KEY (rut_participante) REFERENCES participante(rut),
    FOREIGN KEY (id_evento) REFERENCES evento_academico(id_evento),
    UNIQUE(rut_participante, id_evento)
);

-- tabla pago
CREATE TABLE IF NOT EXISTS pago(
    id_pago INT PRIMARY KEY AUTO_INCREMENT,
    id_inscripcion INT,
    monto DECIMAL(10,2) NOT NULL,
    fecha_pago DATE,
    medio_pago VARCHAR(40),
    id_comprobante VARCHAR(100) UNIQUE,
    estado_pago VARCHAR(20) DEFAULT 'pendiente',
    FOREIGN KEY (id_inscripcion) REFERENCES inscripcion(id_inscripcion)
);

-- ============================================================================
-- SECCIÓN 5: TRABAJOS ACADÉMICOS Y REVISIÓN
-- ============================================================================

-- tabla trabajo_academico
CREATE TABLE IF NOT EXISTS trabajo_academico(
    id_trabajo INT PRIMARY KEY AUTO_INCREMENT,
    id_evento INT,
    id_sala_presentacion INT,
    nombre_trabajo VARCHAR(100) NOT NULL,
    descripcion VARCHAR(500),
    fecha_presentacion DATE,
    hora_presentacion TIME,
    estado_revision VARCHAR(20) DEFAULT 'En revision',
    FOREIGN KEY (id_evento) REFERENCES evento_academico(id_evento),
    FOREIGN KEY (id_sala_presentacion) REFERENCES sala(id_sala)
);

-- tabla trabajo_tematica (relación M:N)
CREATE TABLE IF NOT EXISTS trabajo_tematica(
    id_trabajo INT,
    id_tematica INT,
    PRIMARY KEY (id_trabajo, id_tematica),
    FOREIGN KEY (id_trabajo) REFERENCES trabajo_academico(id_trabajo),
    FOREIGN KEY (id_tematica) REFERENCES tematica(id_tematica)
);

-- tabla autoria (relación M:N)
CREATE TABLE IF NOT EXISTS autoria(
    id_trabajo INT,
    rut_autor VARCHAR(12),
    PRIMARY KEY (id_trabajo, rut_autor),
    FOREIGN KEY (id_trabajo) REFERENCES trabajo_academico(id_trabajo),
    FOREIGN KEY (rut_autor) REFERENCES participante(rut)
);

-- tabla revision (puntacion_general calculada por trigger)
CREATE TABLE IF NOT EXISTS revision(
    id_trabajo INT,
    rut_revisor VARCHAR(12),
    originalidad INT CHECK (originalidad BETWEEN 1 AND 10),
    pertinencia INT CHECK (pertinencia BETWEEN 1 AND 10),
    claridad INT CHECK (claridad BETWEEN 1 AND 10),
    puntacion_general INT,
    comentarios_revision VARCHAR(500),
    PRIMARY KEY (id_trabajo, rut_revisor),
    FOREIGN KEY (id_trabajo) REFERENCES trabajo_academico(id_trabajo),
    FOREIGN KEY (rut_revisor) REFERENCES revisor(rut)
);

-- ============================================================================
-- SECCIÓN 6: ACTIVIDADES Y ASISTENCIA
-- ============================================================================

-- tabla actividad (con sala específica)
CREATE TABLE IF NOT EXISTS actividad(
    id_actividad INT PRIMARY KEY AUTO_INCREMENT,
    id_evento INT,
    id_sala INT,
    nombre_actividad VARCHAR(100) NOT NULL,
    tipo_actividad VARCHAR(40),
    descripcion_actividad VARCHAR(500),
    fecha_actividad DATE,
    hora_inicio TIME,
    hora_fin TIME,
    capacidad_maxima INT,
    FOREIGN KEY (id_evento) REFERENCES evento_academico(id_evento),
    FOREIGN KEY (id_sala) REFERENCES sala(id_sala),
    CHECK (hora_fin > hora_inicio)
);

-- tabla inscripcion_actividad (vinculada a inscripcion padre - Opción A)
CREATE TABLE IF NOT EXISTS inscripcion_actividad(
    id_inscripcion INT,
    id_actividad INT,
    rut_participante VARCHAR(12),
    hora_entrada TIME,
    hora_salida TIME,
    fecha_inscripcion DATE,
    asistencia_confirmada BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (id_inscripcion, id_actividad),
    FOREIGN KEY (id_inscripcion) REFERENCES inscripcion(id_inscripcion),
    FOREIGN KEY (id_actividad) REFERENCES actividad(id_actividad),
    FOREIGN KEY (rut_participante) REFERENCES participante(rut)
);

-- ============================================================================
-- SECCIÓN 7: CERTIFICADOS Y COMITÉ
-- ============================================================================

-- tabla certificado (tabla única con discriminador - Opción A)
CREATE TABLE IF NOT EXISTS certificado(
    id_certificado INT PRIMARY KEY AUTO_INCREMENT,
    rut_certificado VARCHAR(12),
    id_evento INT,
    id_trabajo INT NULL,
    tipo_certificado VARCHAR(40) NOT NULL,
    descripcion_certificado VARCHAR(500),
    fecha_emision DATE,
    codigo_verificacion VARCHAR(50) UNIQUE,
    FOREIGN KEY (rut_certificado) REFERENCES participante(rut),
    FOREIGN KEY (id_evento) REFERENCES evento_academico(id_evento),
    FOREIGN KEY (id_trabajo) REFERENCES trabajo_academico(id_trabajo),
    CHECK (
        (tipo_certificado = 'asistencia' AND id_trabajo IS NULL) OR
        (tipo_certificado = 'presentacion' AND id_trabajo IS NOT NULL)
    )
);

-- tabla comite_organizador
CREATE TABLE IF NOT EXISTS comite_organizador(
    id_comite INT PRIMARY KEY AUTO_INCREMENT,
    id_evento INT,
    nombre_comite VARCHAR(100) NOT NULL,
    descripcion_comite VARCHAR(500),
    FOREIGN KEY (id_evento) REFERENCES evento_academico(id_evento),
    UNIQUE(id_evento)
);

-- tabla miembro_comite
CREATE TABLE IF NOT EXISTS miembro_comite(
    id_comite INT,
    rut_participante_comite VARCHAR(12),
    cargo_comite VARCHAR(40),
    PRIMARY KEY (id_comite, rut_participante_comite),
    FOREIGN KEY (id_comite) REFERENCES comite_organizador(id_comite),
    FOREIGN KEY (rut_participante_comite) REFERENCES participante(rut)
);

-- ============================================================================
-- SECCIÓN 8: TRIGGERS
-- ============================================================================

-- Trigger 1: Evitar solapamiento de salas en actividades
DELIMITER //
CREATE TRIGGER evitar_solapamiento_sala
BEFORE INSERT ON actividad
FOR EACH ROW
BEGIN
    DECLARE solapamiento INT;
    
    SELECT COUNT(*) INTO solapamiento
    FROM actividad
    WHERE id_sala = NEW.id_sala
      AND fecha_actividad = NEW.fecha_actividad
      AND NEW.hora_inicio < hora_fin
      AND NEW.hora_fin > hora_inicio;
    
    IF solapamiento > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La sala ya tiene una actividad en ese horario, busque otro horario o sala';
    END IF;
END//
DELIMITER ;

-- Trigger 2: Confirmar rol único por evento (un participante, un rol por evento)
DELIMITER //
CREATE TRIGGER confirmacion_rol_unico
BEFORE INSERT ON inscripcion
FOR EACH ROW
BEGIN 
    DECLARE rol_asignado INT;
    
    SELECT COUNT(*) INTO rol_asignado
    FROM inscripcion
    WHERE id_evento = NEW.id_evento
      AND rut_participante = NEW.rut_participante;
    
    IF rol_asignado > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El participante ya tiene un rol asignado en este evento, no puede tener más de un rol por evento';
    END IF;
END//
DELIMITER ;

-- Trigger 3: Calcular puntación general en revisión (desnormalización controlada)
DELIMITER //
CREATE TRIGGER calcular_puntacion_general
BEFORE INSERT ON revision
FOR EACH ROW
BEGIN
    SET NEW.puntacion_general = ROUND((NEW.originalidad + NEW.pertinencia + NEW.claridad) / 3.0);
END//
DELIMITER ;

-- Trigger 4: Actualizar puntación general si se modifica una revisión
DELIMITER //
CREATE TRIGGER actualizar_puntacion_general
BEFORE UPDATE ON revision
FOR EACH ROW
BEGIN
    SET NEW.puntacion_general = ROUND((NEW.originalidad + NEW.pertinencia + NEW.claridad) / 3.0);
END//
DELIMITER ;

-- ============================================================================
-- SECCIÓN 9: VISTAS
-- ============================================================================

-- Vista 1: Ranking de trabajos según puntación general
CREATE OR REPLACE VIEW ranking_trabajos AS 
SELECT 
    t.id_trabajo, 
    t.nombre_trabajo, 
    t.descripcion, 
    t.fecha_presentacion, 
    t.hora_presentacion, 
    t.estado_revision,
    AVG(r.puntacion_general) AS puntacion_promedio,
    COUNT(r.rut_revisor) AS cantidad_revisores
FROM trabajo_academico t
JOIN revision r ON t.id_trabajo = r.id_trabajo
GROUP BY t.id_trabajo
ORDER BY puntacion_promedio DESC;

-- Vista 2: Participantes por evento con detalles
CREATE OR REPLACE VIEW participantes_por_evento AS
SELECT  
    eve.id_evento,
    eve.nombre_evento, 
    p.rut, 
    p.nombre, 
    p.apellido, 
    p.email,
    ins.rol_en_evento,
    ins.estado_inscripcion
FROM evento_academico eve
JOIN inscripcion ins ON eve.id_evento = ins.id_evento
JOIN participante p ON ins.rut_participante = p.rut
ORDER BY eve.nombre_evento, p.apellido;

-- Vista 3: Trabajos pendientes de revisión
CREATE OR REPLACE VIEW trabajos_pendientes_revision AS
SELECT 
    t.id_trabajo,
    t.nombre_trabajo,
    e.nombre_evento,
    t.estado_revision,
    COUNT(r.rut_revisor) AS revisiones_completadas
FROM trabajo_academico t
JOIN evento_academico e ON t.id_evento = e.id_evento
LEFT JOIN revision r ON t.id_trabajo = r.id_trabajo
WHERE t.estado_revision = 'En revision'
GROUP BY t.id_trabajo
ORDER BY e.nombre_evento, t.nombre_trabajo;

-- Vista 4: Asistencia por actividad
CREATE OR REPLACE VIEW asistencia_por_actividad AS
SELECT 
    a.id_actividad,
    a.nombre_actividad,
    a.tipo_actividad,
    a.fecha_actividad,
    COUNT(ia.rut_participante) AS inscritos,
    SUM(CASE WHEN ia.asistencia_confirmada = TRUE THEN 1 ELSE 0 END) AS asistentes_reales,
    a.capacidad_maxima
FROM actividad a
LEFT JOIN inscripcion_actividad ia ON a.id_actividad = ia.id_actividad
GROUP BY a.id_actividad
ORDER BY a.fecha_actividad;

-- Vista 5: Certificados emitidos
CREATE OR REPLACE VIEW certificados_emitidos AS
SELECT 
    c.id_certificado,
    c.tipo_certificado,
    p.nombre,
    p.apellido,
    e.nombre_evento,
    c.fecha_emision,
    c.codigo_verificacion
FROM certificado c
JOIN participante p ON c.rut_certificado = p.rut
JOIN evento_academico e ON c.id_evento = e.id_evento
ORDER BY c.fecha_emision DESC;

-- ============================================================================
-- SECCIÓN 10: DATOS DE PRUEBA
-- ============================================================================
/*
-- Universidad
INSERT INTO universidad VALUES 
(1, 'Universidad de Chile', 'Chile'),
(2, 'Universidad de Santiago de Chile', 'Chile'),
(3, 'Universidad de Concepción', 'Chile'),
(4, 'Universidad Católica', 'Chile');

-- Departamento
INSERT INTO departamento VALUES 
(1, 'Informática', 1),
(2, 'Matemática', 1),
(3, 'Ingeniería', 2),
(4, 'Ciencias', 3);

-- Carrera
INSERT INTO carrera VALUES 
(1, 'Ingeniería Informática', 1),
(2, 'Matemática Aplicada', 2),
(3, 'Ingeniería Civil', 3),
(4, 'Ciencia de Datos', 1);

-- Ciudad
INSERT INTO ciudad VALUES 
(1, 'Santiago', 'Metropolitana', 'Chile'),
(2, 'Valparaíso', 'Valparaíso', 'Chile'),
(3, 'Concepción', 'Biobío', 'Chile'),
(4, 'Antofagasta', 'Antofagasta', 'Chile'),
(5, 'Iquique', 'Tarapacá', 'Chile');

-- Sede
INSERT INTO sede VALUES 
(1, 1, 'Centro de Convenciones Santiago', 'Av. El Bosque 1234, Santiago'),
(2, 2, 'Hotel Valparaíso', 'Calle Principal 567, Valparaíso'),
(3, 3, 'Universidad de Concepción', 'Av. Universidad 789, Concepción'),
(4, 4, 'Centro Cultural Antofagasta', 'Calle Cultura 456, Antofagasta'),
(5, 5, 'Hotel Iquique', 'Calle Marina 321, Iquique');

-- Sala (2 salas por sede)
INSERT INTO sala VALUES 
(1, 1, '101', 100),
(2, 1, '102', 150),
(3, 2, '201', 80),
(4, 2, '202', 120),
(5, 3, '301', 200),
(6, 3, '302', 250),
(7, 4, '401', 90),
(8, 4, '402', 110),
(9, 5, '501', 70),
(10, 5, '502', 130);

-- Participante (8 participantes, 2 de cada tipo)
INSERT INTO participante VALUES 
('12345678-9', 'Juan', 'Pérez', '1990-01-01', 'juan.perez@email.com', '987654321', 'Calle Principal 123, Santiago'),
('23456789-0', 'María', 'González', '1985-05-15', 'maria.gonzalez@email.com', '912345678', 'Calle Secundaria 456, Valparaíso'),
('34567890-1', 'Carlos', 'López', '1992-09-30', 'carlos.lopez@email.com', '923456789', 'Calle Tercera 789, Concepción'),
('45678901-2', 'Ana', 'Martínez', '1988-12-20', 'ana.martinez@email.com', '934567890', 'Calle Cuarta 101, Iquique'),
('56789012-3', 'Luis', 'García', '1995-03-10', 'luis.garcia@email.com', '945678901', 'Calle Quinta 202, Arica'),
('67890123-4', 'Sofía', 'Rodríguez', '1991-07-25', 'sofia.rodriguez@email.com', '956789012', 'Calle Sexta 303, Punta Arenas'),
('78901234-5', 'Diego', 'Fernández', '1987-11-05', 'diego.fernandez@email.com', '967890123', 'Calle Séptima 404, Valdivia'),
('89012345-6', 'Laura', 'Gómez', '1993-02-18', 'laura.gomez@email.com', '978901234', 'Calle Octava 505, Osorno');

-- Académico
INSERT INTO academico VALUES 
('12345678-9', 1, 'Doctor'),
('23456789-0', 2, 'Magíster');

-- Estudiante
INSERT INTO estudiante VALUES 
('34567890-1', 1),
('45678901-2', 2);

-- Revisor
INSERT INTO revisor VALUES 
('56789012-3', 5, 1),
('67890123-4', 3, NULL);

-- Administrador
INSERT INTO administrador VALUES 
('78901234-5', TRUE, 1),
('89012345-6', TRUE, NULL);

-- Temática
INSERT INTO tematica VALUES 
(1, 'Inteligencia Artificial', 'Temática relacionada con el desarrollo de sistemas inteligentes y aprendizaje automático'),
(2, 'Ciencia de Datos', 'Temática enfocada en el análisis de grandes volúmenes de datos y extracción de conocimiento'),
(3, 'Seguridad Informática', 'Temática que aborda la protección de sistemas y datos contra amenazas y ataques'),
(4, 'Desarrollo de Software', 'Temática centrada en las metodologías y herramientas para la creación de software de calidad'),
(5, 'Redes de Computadoras', 'Temática que trata sobre la interconexión de sistemas y la comunicación de datos a través de redes');

-- Evento Académico
INSERT INTO evento_academico VALUES 
(1, 1, 'Congreso de Informática', 'Evento anual que reúne a expertos en informática', '2024-10-01', '2024-10-03', '78901234-5', 'activo'),
(2, 2, 'Simposio de Ciencia de Datos', 'Evento dedicado a la presentación de investigaciones en ciencia de datos', '2024-11-15', '2024-11-17', '89012345-6', 'activo'),
(3, 3, 'Jornada de Seguridad Informática', 'Evento enfocado en estrategias y tecnologías de seguridad', '2024-12-05', '2024-12-07', '78901234-5', 'activo'),
(4, 4, 'Taller de Desarrollo de Software', 'Evento práctico de capacitación en desarrollo', '2024-09-20', '2024-09-22', '89012345-6', 'activo'),
(5, 5, 'Conferencia de Redes', 'Evento sobre avances en redes de computadoras', '2024-08-10', '2024-08-12', '78901234-5', 'activo');

-- Evento Temática
INSERT INTO evento_tematica VALUES 
(1, 1), (1, 2), (2, 2), (2, 3), (3, 3), (3, 4), (4, 4), (4, 5), (5, 5);

-- Inscripción
INSERT INTO inscripcion VALUES 
(1, '12345678-9', 1, '2024-09-01', 'confirmada', 'autor'),
(2, '23456789-0', 1, '2024-09-02', 'confirmada', 'autor'),
(3, '34567890-1', 2, '2024-10-01', 'confirmada', 'asistente'),
(4, '45678901-2', 2, '2024-10-02', 'confirmada', 'asistente'),
(5, '56789012-3', 3, '2024-11-01', 'confirmada', 'revisor'),
(6, '67890123-4', 3, '2024-11-02', 'confirmada', 'revisor'),
(7, '78901234-5', 4, '2024-08-01', 'confirmada', 'organizador'),
(8, '89012345-6', 4, '2024-08-02', 'confirmada', 'organizador');

-- Pago (formato decimal correcto)
INSERT INTO pago VALUES 
(1, 1, 100000.00, '2024-09-05', 'Tarjeta de Crédito', 'COMP-001', 'validado'),
(2, 2, 100000.00, '2024-09-06', 'Transferencia', 'COMP-002', 'validado'),
(3, 3, 50000.00, '2024-10-05', 'Tarjeta de Crédito', 'COMP-003', 'validado'),
(4, 4, 50000.00, '2024-10-06', 'Transferencia', 'COMP-004', 'validado'),
(5, 5, 10000.00, '2024-11-05', 'Tarjeta de Crédito', 'COMP-005', 'validado'),
(6, 6, 10000.00, '2024-11-06', 'Transferencia', 'COMP-006', 'validado'),
(7, 7, 10000.00, '2024-08-05', 'Transferencia', 'COMP-007', 'validado'),
(8, 8, 30000.00, '2024-08-06', 'Transferencia', 'COMP-008', 'validado');

-- Trabajo Académico
INSERT INTO trabajo_academico VALUES 
(1, 1, 1, 'Trabajo de IA', 'Descripción del trabajo de IA', '2024-10-02', '10:00:00', 'aceptado'),
(2, 1, 2, 'Trabajo de Data Science', 'Descripción del trabajo de DS', '2024-10-02', '14:00:00', 'aceptado'),
(3, 2, 3, 'Trabajo de Seguridad', 'Descripción del trabajo de seguridad', '2024-11-16', '10:00:00', 'aceptado'),
(4, 2, 4, 'Trabajo de DevSoft', 'Descripción del trabajo de desarrollo', '2024-11-16', '14:00:00', 'aceptado');

-- Trabajo Temática
INSERT INTO trabajo_tematica VALUES 
(1, 1), (2, 2), (3, 3), (4, 4);

-- Autoría
INSERT INTO autoria VALUES 
(1, '12345678-9'), (2, '23456789-0'), (3, '34567890-1'), (4, '45678901-2'),
(1, '23456789-0'), (2, '34567890-1');

-- Revisión (puntacion_general calculada por trigger)
INSERT INTO revision VALUES 
(1, '56789012-3', 8, 9, 7, NULL, 'Buen trabajo, mejorar metodología'),
(1, '67890123-4', 7, 8, 8, NULL, 'Interesante, falta profundidad'),
(2, '56789012-3', 9, 10, 9, NULL, 'Excelente trabajo'),
(2, '67890123-4', 8, 9, 8, NULL, 'Muy buen trabajo'),
(3, '56789012-3', 6, 7, 7, NULL, 'Interesante, originalidad limitada'),
(3, '67890123-4', 5, 6, 6, NULL, 'Necesita revisión profunda'),
(4, '56789012-3', 7, 8, 7, NULL, 'Metodología más robusta'),
(4, '67890123-4', 6, 7, 7, NULL, 'Mejorar presentación');

-- Actividad
INSERT INTO actividad VALUES 
(1, 1, 1, 'Taller de IA', 'Taller', 'Descripción del taller', '2024-10-01', '09:00:00', '12:00:00', 30),
(2, 1, 2, 'Charla de Data Science', 'Charla', 'Charla sobre DS', '2024-10-01', '13:00:00', '14:00:00', 100),
(3, 2, 3, 'Panel de Seguridad', 'Panel', 'Panel magistral', '2024-11-15', '10:00:00', '11:30:00', 50),
(4, 2, 4, 'Taller de DevSoft', 'Taller', 'Taller práctico', '2024-11-15', '14:00:00', '17:00:00', 30),
(5, 3, 5, 'Conferencia de Redes', 'Mesa Redonda', 'Conferencia principal', '2024-12-05', '09:00:00', '10:30:00', 100);

-- Inscripción Actividad
INSERT INTO inscripcion_actividad VALUES 
(1, 1, '12345678-9', '09:00:00', '12:00:00', '2024-09-15', TRUE),
(2, 2, '23456789-0', '13:00:00', '14:00:00', '2024-09-16', TRUE),
(3, 3, '34567890-1', '10:00:00', '11:30:00', '2024-10-15', TRUE),
(4, 4, '45678901-2', '14:00:00', '17:00:00', '2024-10-16', TRUE),
(5, 5, '56789012-3', '09:00:00', '10:30:00', '2024-11-15', TRUE);

-- Certificado
INSERT INTO certificado VALUES 
(1, '12345678-9', 1, 1, 'presentacion', 'Certificado de expositor', '2024-10-04', 'CERT-001'),
(2, '23456789-0', 1, 2, 'presentacion', 'Certificado de expositor', '2024-10-04', 'CERT-002'),
(3, '34567890-1', 2, NULL, 'asistencia', 'Certificado de participante', '2024-11-18', 'CERT-003'),
(4, '45678901-2', 2, NULL, 'asistencia', 'Certificado de participante', '2024-11-18', 'CERT-004'),
(5, '56789012-3', 3, NULL, 'asistencia', 'Certificado de participante', '2024-12-08', 'CERT-005'),
(6, '67890123-4', 3, NULL, 'asistencia', 'Certificado de participante', '2024-12-08', 'CERT-006');

-- Comité Organizador
INSERT INTO comite_organizador VALUES 
(1, 1, 'Comité Congreso Informática', 'Organización del congreso'),
(2, 2, 'Comité Simposio Data', 'Organización del simposio'),
(3, 3, 'Comité Seguridad', 'Organización de la jornada'),
(4, 4, 'Comité Taller Dev', 'Organización del taller'),
(5, 5, 'Comité Redes', 'Organización de la conferencia');

-- Miembro Comité
INSERT INTO miembro_comite VALUES 
(1, '78901234-5', 'Presidente'),
(1, '89012345-6', 'Secretario'),
(2, '78901234-5', 'Presidente'),
(2, '89012345-6', 'Secretario'),
(3, '78901234-5', 'Presidente'),
(3, '89012345-6', 'Secretario');

-- ============================================================================
-- SECCIÓN 11: CONSULTAS DE VERIFICACIÓN
-- ============================================================================

-- Verificar tablas creadas
-- SHOW TABLES;

-- Verificar triggers
-- SHOW TRIGGERS FROM ProyectoEventia;

-- Verificar vistas
-- SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- Probar vista de ranking
-- SELECT * FROM ranking_trabajos LIMIT 5;

-- Probar vista de participantes
-- SELECT * FROM participantes_por_evento WHERE id_evento = 1;

-- Probar vista de trabajos pendientes
-- SELECT * FROM trabajos_pendientes_revision;

-- Probar vista de asistencia
-- SELECT * FROM asistencia_por_actividad;

-- Probar vista de certificados
-- SELECT * FROM certificados_emitidos;

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================