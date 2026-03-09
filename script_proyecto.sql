DROP DATABASE IF EXISTS ProyectoEventia;
CREATE DATABASE IF NOT EXISTS ProyectoEventia;
USE ProyectoEventia;

-- -------------------
-- 1. creacion de tablas

-- participante(rut, nombre, apellido, fecha_nac, email, telefono, direccion)
CREATE TABLE IF NOT EXISTS participante(
    rut VARCHAR(12) PRIMARY KEY,
    nombre VARCHAR(40) NOT NULL,
    apellido VARCHAR(40) NOT NULL,
    fecha_nac DATE,
    email VARCHAR(80) UNIQUE,
    telefono VARCHAR(20),
    direccion VARCHAR(80)
);

-- tabla universidad(id_universidad,nombre,pais)
CREATE TABLE IF NOT EXISTS universidad(
    id_universidad INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(80) NOT NULL,
    pais VARCHAR(40)
);

-- tabla departamento(id_departamento,nombre,id_idniversidd)
CREATE TABLE IF NOT EXISTS departamento(
    id_departamento INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(40) NOT NULL,
    id_universidad INT,
    FOREIGN KEY (id_universidad) REFERENCES universidad(id_universidad)
);

-- tabla carrera(id_carrera,nombre,id_departamento)
CREATE TABLE IF NOT EXISTS carrera(
    id_carrera INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    id_departamento INT,
    FOREIGN KEY (id_departamento) REFERENCES departamento(id_departamento)
);

-- tabla academico(rut,id_departamento,grado_academico)
CREATE TABLE IF NOT EXISTS academico(
    rut VARCHAR(12) PRIMARY KEY,
    id_departamento INT,
    grado_academico VARCHAR(40),
    FOREIGN KEY (rut) REFERENCES participante(rut),
    FOREIGN KEY (id_departamento) REFERENCES departamento(id_departamento)
);

-- tabla estudiante(rut,id_carrera)
CREATE TABLE IF NOT EXISTS estudiante(
    rut VARCHAR(12) PRIMARY KEY,
    id_carrera INT,
    FOREIGN KEY (rut) REFERENCES participante(rut),
    FOREIGN KEY (id_carrera) REFERENCES carrera(id_carrera)
);

-- tabla revisor(rut, annos_experencia,id_universidad)
CREATE TABLE IF NOT EXISTS revisor(
    rut VARCHAR(12) PRIMARY KEY,
    annos_experiencia INT,
    id_universidad INT, -- 
    FOREIGN KEY (rut) REFERENCES participante(rut),
    FOREIGN KEY (id_universidad) REFERENCES universidad(id_universidad)
);

-- tabla administrador(rut,estado,id_universidad)
CREATE TABLE IF NOT EXISTS administrador(
    rut VARCHAR(12) PRIMARY KEY,
    estado BOOLEAN DEFAULT TRUE, -- estado referencia a que si esta activo
    id_universidad INT,
    FOREIGN KEY (rut) REFERENCES participante(rut),
    FOREIGN KEY (id_universidad) REFERENCES universidad(id_universidad)
);


-- tabla ciudad(id_ciudad,nombre_ciudad,region,pais)
CREATE TABLE IF NOT EXISTS ciudad(
    id_ciudad INT PRIMARY KEY AUTO_INCREMENT,
    nombre_ciudad VARCHAR(40) NOT NULL,
    region VARCHAR(40),
    pais VARCHAR(40) DEFAULT 'Chile'
);

-- tabla sede(id_sede,id_ciudad,nombre_sede,direccion_sede,cantidad_salas_sede,aforo_sede)
CREATE TABLE IF NOT EXISTS sede(
    id_sede INT PRIMARY KEY AUTO_INCREMENT,
    id_ciudad INT,
    nombre_sede VARCHAR(40) NOT NULL,
    direccion_sede VARCHAR(80) NOT NULL, -- las direcciones las deberíamos cambiar a formato como 'calle' 'número', o lo dejamos así nomas?
    cantidad_salas_sede INT, -- con un trigger se definirá esto?
    aforo_sede INT,			-- esto también?
    FOREIGN KEY (id_ciudad) REFERENCES ciudad(id_ciudad)
);

-- tabla sala(id_sala,id_sede,numero_sala,aforo_sala)
CREATE TABLE IF NOT EXISTS sala(
    id_sala INT PRIMARY KEY AUTO_INCREMENT,
    id_sede INT,
    numero_sala VARCHAR(10),
    aforo_sala INT,
    FOREIGN KEY (id_sede) REFERENCES sede(id_sede)
);


-- tabla evento_academico(id_evento, id_sede, nombre_evento, descripcion_evento, fecha_inicio, fecha_fin, rut_creador, estado_evento)
CREATE TABLE IF NOT EXISTS evento_academico(
    id_evento INT PRIMARY KEY AUTO_INCREMENT,
    id_sede INT,
    nombre_evento VARCHAR(100) NOT NULL,
    descripcion_evento VARCHAR(500),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL, -- si lo quitamos por flojera nomas?
    rut_creador VARCHAR(12),
    estado_evento VARCHAR(20) DEFAULT 'activo',
    FOREIGN KEY (rut_creador) REFERENCES administrador(rut),
    FOREIGN KEY (id_sede) REFERENCES sede(id_sede)
);

-- tabla tematica(id_tematica,nombre_tematica,descripcion_tematica)
CREATE TABLE IF NOT EXISTS tematica(
    id_tematica INT PRIMARY KEY AUTO_INCREMENT,
    nombre_tematica VARCHAR(40) NOT NULL UNIQUE,
    descripcion_tematica VARCHAR(200)
);

-- tabla evento_tematica(id_evento,id_tematica)
-- tabla intermedia
CREATE TABLE IF NOT EXISTS evento_tematica(
    id_evento INT,
    id_tematica INT,
    PRIMARY KEY(id_evento, id_tematica),
    FOREIGN KEY (id_evento) REFERENCES evento_academico(id_evento),
    FOREIGN KEY (id_tematica) REFERENCES tematica(id_tematica)
);

-- tabla inscripcion(id_inscripcion, rut_estudiante, id_evento, fecha_inscripcion, estado_inscripcion, rol_en_evento)
CREATE TABLE IF NOT EXISTS inscripcion(
    id_inscripcion INT PRIMARY KEY AUTO_INCREMENT,
    rut_participante VARCHAR(12),
    id_evento INT,
    fecha_inscripcion DATE NOT NULL,
    estado_inscripcion VARCHAR(20) DEFAULT 'pendiente',
    rol_en_evento VARCHAR(20),
    FOREIGN KEY (rut_participante) REFERENCES participante(rut),
    FOREIGN KEY (id_evento) REFERENCES evento_academico(id_evento)
);

-- tabla pago(id_pago,id_inscripcion,monto,fecha_pago,medio_pago,id_comprobante,estado_pago)
CREATE TABLE IF NOT EXISTS pago(
    id_pago INT PRIMARY KEY AUTO_INCREMENT,
    id_inscripcion INT,
    monto INT,
    fecha_pago DATE,
    medio_pago VARCHAR(40),
    id_comprobante VARCHAR(100) UNIQUE, 
    estado_pago VARCHAR(20) DEFAULT 'pendiente',
    FOREIGN KEY (id_inscripcion) REFERENCES inscripcion(id_inscripcion)
);
   


-- tabla trabajo_academico(id_trabajo PK, id_evento, id_sala_presentacion, nombre_trabajo, descripcion, fecha_presentacion, estado_revision)
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

-- tabla trabajo_tematica(id_trabajo,id_tematica)
CREATE TABLE IF NOT EXISTS trabajo_tematica(
    id_trabajo INT,
    id_tematica INT,
    PRIMARY KEY (id_trabajo, id_tematica),
    FOREIGN KEY (id_trabajo) REFERENCES trabajo_academico(id_trabajo),
    FOREIGN KEY (id_tematica) REFERENCES tematica(id_tematica)
);

-- tabla autoria(id_trabajo,rut_autor)
CREATE TABLE IF NOT EXISTS autoria(
    id_trabajo INT,
    rut_autor VARCHAR(12),
    PRIMARY KEY (id_trabajo, rut_autor),
    FOREIGN KEY (id_trabajo) REFERENCES trabajo_academico(id_trabajo),
    FOREIGN KEY (rut_autor) REFERENCES participante(rut)
);

-- tabla revision (puntacion_general calculada por trigger)
-- revision(id_trabajo, rut_revisor, originalidad, pertinencia, claridad, puntuacion_general, comentarios_revision)
CREATE TABLE IF NOT EXISTS revision(
    id_trabajo INT,
    rut_revisor VARCHAR(12),
    originalidad DECIMAL(3,1),
    pertinencia DECIMAL(3,1),
    claridad DECIMAL(3,1), -- nota decimal entre 1 a 7
    puntuacion_general DECIMAL, -- promedio entre las puntuaciones del criterio
    comentarios_revision VARCHAR(500),
    PRIMARY KEY (id_trabajo, rut_revisor),
    FOREIGN KEY (id_trabajo) REFERENCES trabajo_academico(id_trabajo),
    FOREIGN KEY (rut_revisor) REFERENCES revisor(rut)
);


-- tabla actividad(id_actividad,id_evento,id_sala,nombre_actividad,tipo_actividad,descripcion_actividad,fecha_actividad,hora_inicio,hora_fin)
CREATE TABLE IF NOT EXISTS actividad(
    id_actividad INT PRIMARY KEY AUTO_INCREMENT,
    id_evento INT,
    id_sala INT,
    nombre_actividad VARCHAR(100) NOT NULL,
    tipo_actividad VARCHAR(40),
    descripcion_actividad VARCHAR(500),
    fecha_actividad DATE,
    hora_inicio TIME,
    hora_fin TIME, 	-- sacar la hora de salida también?
    FOREIGN KEY (id_evento) REFERENCES evento_academico(id_evento),
    FOREIGN KEY (id_sala) REFERENCES sala(id_sala)
);

-- tabla inscripcion_actividad(id_inscripcion,id_activiad,rut_participante,hora_entrada,hora_salida,fecha_inscripcion,asistencia_confrimada)
CREATE TABLE IF NOT EXISTS inscripcion_actividad(
    id_inscripcion INT,
    id_actividad INT,
    rut_participante VARCHAR(12),
    hora_entrada TIME,
    hora_salida TIME,		
    fecha_inscripcion DATE,
    asistencia_confirmada BOOLEAN DEFAULT FALSE, -- partimos que nadie asistio
    PRIMARY KEY (id_inscripcion, id_actividad),
    FOREIGN KEY (id_inscripcion) REFERENCES inscripcion(id_inscripcion),
    FOREIGN KEY (id_actividad) REFERENCES actividad(id_actividad),
    FOREIGN KEY (rut_participante) REFERENCES participante(rut)
);



-- tabla certificado(id_certificado,rut_certificado,id_evento,id_trabajo,ripo_certificado,descripcion_certificado,fecha_emision)
CREATE TABLE IF NOT EXISTS certificado(
    id_certificado INT PRIMARY KEY AUTO_INCREMENT,
    rut_certificado VARCHAR(12),
    id_evento INT,
    id_trabajo INT NULL,
    tipo_certificado VARCHAR(40) NOT NULL,
    descripcion_certificado VARCHAR(500),
    fecha_emision DATE,
    FOREIGN KEY (rut_certificado) REFERENCES participante(rut),
    FOREIGN KEY (id_evento) REFERENCES evento_academico(id_evento),
    FOREIGN KEY (id_trabajo) REFERENCES trabajo_academico(id_trabajo)
);

-- tabla comite_organizador(id_comite,id_evento_nombre_comite,descripcion_comite)
CREATE TABLE IF NOT EXISTS comite_organizador(
    id_comite INT PRIMARY KEY AUTO_INCREMENT,
    id_evento INT,
    nombre_comite VARCHAR(100) NOT NULL,
    descripcion_comite VARCHAR(500),
    FOREIGN KEY (id_evento) REFERENCES evento_academico(id_evento)
);

-- tabla miembro_comite(id_comite,rut_participante_comite,cargo_comite)
CREATE TABLE IF NOT EXISTS miembro_comite(
    id_comite INT,
    rut_participante_comite VARCHAR(12),
    cargo_comite VARCHAR(40),
    PRIMARY KEY (id_comite, rut_participante_comite),
    FOREIGN KEY (id_comite) REFERENCES comite_organizador(id_comite),
    FOREIGN KEY (rut_participante_comite) REFERENCES participante(rut)
);
-- ----------------------------
-- 2. triggers

-- Trigger 1: evitar solapamiento de salas en actividades
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
    -- si encuentra algun solapamiento rechaza la inscripcion con mensaje de error por pantalla
    
    IF solapamiento > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La sala ya tiene una actividad en ese horario, busque otro horario o sala';
    END IF;
END//
DELIMITER ;

-- Trigger 2: confirmar rol unico por evento 
DELIMITER //
CREATE TRIGGER confirmacion_rol_unico
BEFORE INSERT ON inscripcion -- antes que se meta un dato a la inscripción
FOR EACH ROW
BEGIN 
    DECLARE rol_asignado INT;
    
    SELECT COUNT(*) INTO rol_asignado	
    FROM inscripcion
    WHERE id_evento = NEW.id_evento
      AND rut_participante = NEW.rut_participante;
    
    IF rol_asignado > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El participante ya tiene un rol asignado en este evento, no puede tener más de un rol por evento o ya fue ingresado';
    END IF;
END//
DELIMITER ;

-- Trigger 3: Calcular puntación general en revisión
-- revision(id_trabajo, rut_revisor, originalidad, pertinencia, claridad, puntuacion_general, comentarios_revision)
DELIMITER //
CREATE TRIGGER calcular_puntuacion_general
BEFORE INSERT ON revision
FOR EACH ROW
BEGIN
    SET NEW.puntuacion_general = ((NEW.originalidad + NEW.pertinencia + NEW.claridad) / 3.0);
END//
DELIMITER ;

-- Trigger 4: Evitar sobrecupo 
DELIMITER // 


CREATE TRIGGER evitar_sobrecupo
BEFORE INSERT ON inscripcion_actividad
FOR EACH ROW 
BEGIN
    DECLARE v_aforo int;
    DECLARE v_inscrito int;
    DECLARE v_id_sala int;
-- con eso seleciono la sala de la actividad que estoy intentando ingresar
    select id_sala into v_id_sala
    from actividad
    WHERE id_actividad = NEW.id_actividad;

-- ya tengo la sala ahora debo buscar el aforo

    SELECT aforo_sala into v_aforo
    from sala
    where id_sala=v_id_sala;

-- ahora en v_aforo tengo la cant de personas, solo debo contar la cant de personas que estan inscritas


    SELECT COUNT(*) into v_inscrito
    from inscripcion_actividad
    WHERE id_actividad=new.id_actividad;


    IF v_inscrito >= v_aforo THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La actividad ha alcanzado su capacidad máxima, no hay cupos disponibles';
    END IF;


END //
DELIMITER ;
-- --------------------------------------
-- 3. vistas

-- vista 1: Ranking de trabajos según puntación general, se usan las tablas:
	-- trabajo_academico(id_trabajo PK, id_evento, id_sala_presentacion, nombre_trabajo, descripcion, fecha_presentacion, estado_revision)
	-- revision(id_trabajo, rut_revisor, originalidad, pertinencia, claridad, puntuacion_general, comentarios_revision)
CREATE VIEW ranking_trabajos AS
SELECT t.id_trabajo, t.id_evento, t.nombre_trabajo, t.descripcion, t.fecha_presentacion, r.puntuacion_general
FROM trabajo_academico t
JOIN revision r ON t.id_trabajo = r.id_trabajo
ORDER BY r.puntuacion_general DESC;
-- vista 2: Participantes por evento con detalles
-- participante(rut, nombre, apellido, fecha_nac, email, telefono, direccion)
-- inscripcion(id_inscripcion, rut_estudiante, id_evento, fecha_inscripcion, estado_inscripcion, rol_en_evento)
-- evento_academico(id_evento, id_sede, nombre_evento, descripcion_evento, fecha_inicio, fecha_fin, rut_creador, estado_evento)
CREATE VIEW participantes_por_evento AS
SELECT  
    eve.id_evento, eve.nombre_evento, p.rut,  p.nombre,  p.apellido,  p.email, ins.rol_en_evento, ins.estado_inscripcion
FROM evento_academico eve
JOIN inscripcion ins ON eve.id_evento = ins.id_evento
JOIN participante p ON ins.rut_participante = p.rut
ORDER BY eve.nombre_evento, p.apellido;

-- vista 3: Trabajos pendientes de revisión
-- trabajo_academico(id_trabajo PK, id_evento, id_sala_presentacion, nombre_trabajo, descripcion, fecha_presentacion, estado_revision)
-- evento_academico(id_evento, id_sede, nombre_evento, descripcion_evento, fecha_inicio, fecha_fin, rut_creador, estado_evento)
-- revision(id_trabajo, rut_revisor, originalidad, pertinencia, claridad, puntuacion_general, comentarios_revision)
CREATE VIEW trabajos_pendientes_revision AS
SELECT 
    t.id_trabajo, t.nombre_trabajo, e.id_evento ,e.nombre_evento, r.rut_revisor AS revisor, t.estado_revision
FROM trabajo_academico t
JOIN evento_academico e ON t.id_evento = e.id_evento
JOIN revision r ON t.id_trabajo = r.id_trabajo
WHERE t.estado_revision = 'En revision'
ORDER BY e.nombre_evento, t.nombre_trabajo;



-- vista 4: Certificados emitidos
-- certificado(id_certificado, rut_certificado
-- evento_academico(id_evento, id_sede, nombre_evento, descripcion_evento, fecha_inicio, fecha_fin, rut_creador, estado_evento)
-- participante(rut, nombre, apellido, fecha_nac, email, telefono, direccion)
CREATE VIEW certificados_emitidos AS
SELECT 
    c.id_certificado, c.tipo_certificado, p.nombre, p.apellido, e.nombre_evento, c.fecha_emision
FROM certificado c
JOIN participante p ON c.rut_certificado = p.rut
JOIN evento_academico e ON c.id_evento = e.id_evento
ORDER BY c.fecha_emision DESC;

-- -----------------------------------
-- 4. procedimientos 

-- procedimiento 1: actualizar datos personales 
DELIMITER //
create procedure actualizar_participante(
    in p_rut varchar(12),
    in p_nombre varchar(40),
    in p_apellido varchar(40),
    in p_email varchar(80),
    in p_telefono varchar(20),
    in p_direccion varchar(80)
)
BEGIN 
    update participante
    set nombre=p_nombre,
        apellido=p_apellido,
        email=p_email,
        telefono=p_telefono,
        direccion=p_direccion
    where rut=p_rut;

    select 'los datos personales del usuario fueron actualizados' as mensaje;

end //
DELIMITER ;

-- para usarla debe ser asi CALL actualizar_participante(aca los datos dle participante)


-- procedimeinto 2: registrar entrada o salida de un participante
DELIMITER //
CREATE PROCEDURE registrar_entrada_salida(
    IN p_rut VARCHAR(12),
    IN p_id_actividad INT,
    IN p_tipo VARCHAR(10) -- entrada o salida
)
BEGIN
    DECLARE v_id_inscripcion INT;

    -- primero buscar el id_inscripcion

    SELECT id_inscripcion INTO v_id_inscripcion
    FROM inscripcion
    WHERE rut_participante = p_rut;

    IF p_tipo = 'entrada' THEN          
        UPDATE inscripcion_actividad
        SET hora_entrada = TIME(NOW())  
        WHERE id_inscripcion = v_id_inscripcion
          AND id_actividad = p_id_actividad;

    ELSEIF p_tipo = 'salida' THEN       
        UPDATE inscripcion_actividad
        SET hora_salida = TIME(NOW()),  
            asistencia_confirmada = TRUE
        WHERE id_inscripcion = v_id_inscripcion
          AND id_actividad = p_id_actividad;
    END IF;

    SELECT 'Registro exitoso' AS mensaje;
END //
DELIMITER ;


-- procedimeinto 3: validar el pago
DELIMITER //
CREATE PROCEDURE validar_pago(
    IN p_id_pago INT
)
BEGIN
    DECLARE v_estado_pago VARCHAR(20);
    DECLARE v_id_inscripcion INT;

    
    SELECT estado_pago, id_inscripcion INTO v_estado_pago, v_id_inscripcion
    FROM pago
    WHERE id_pago = p_id_pago;

   
    if v_estado_pago = 'validado' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El pago ya fue validado anteriormente';
    END IF;

    
    update pago
    SET estado_pago = 'validado'
    WHERE id_pago = p_id_pago;

    
    update inscripcion
    SET estado_inscripcion = 'confirmada'
    WHERE id_inscripcion = v_id_inscripcion;

    select 'pago validado e inscripcion confirmada con exito' AS mensaje;
END //
DELIMITER ;

-- ------------------------------------
-- 5. datos de prueba 

-- ciudad(id_ciudad,nombre_ciudad,region,pais)
INSERT INTO ciudad VALUES 
(1, 'Santiago', 'Metropolitana', 'Chile'),
(2,'puerto Montt','los rios','Chile'),
(3,'osorno','los lagos','Chile'),
(4,'putre','arica','Chile'),
(5,'coquimbo','coquimbo','chile');


-- universidad(id_universidad,nombre,pais)
INSERT INTO universidad VALUES 
(1, 'USACH', 'Chile'),
(2,'UC','Chile'),
(3,'PUCV','Chile'),
(4,'UDD','Chile'),
(5,'UA','Chile');

-- departamento(id_departamento,nombre,id_idniversidd)
INSERT INTO departamento VALUES 
(1, 'Depto Ingeniería', 1),
(2,'Depto de fisica',2),
(3,'Facultad de periodismo',3),
(4,'Facultad de biotecnologia',4),
(5,'Facultad de economia',5),
(6,'Depto de economia',1); -- repito la universidad para tener variedad

-- carrera(id_carrera,nombre,id_departamento)
INSERT INTO carrera VALUES 
(1, 'Ing. Ejecución Informática', 1),
(2,'Licenciatura en física',2),
(3,'Periodismo',3),
(4,'Biotecnología',4),
(5,'Economía',5),
(6,'Economía',6); -- repito el departamento para tener variedad

-- Participantes(rut, nombre, apellido, fecha_nac, email, telefono, direccion)
INSERT INTO participante VALUES
('20444683-0', 'Emilio', 'Poblete', '2000-06-27', 'emilio.poblete@usach.cl', '+56912345678', 'calle1'), -- estudiante
('8573283-4', 'Sebastián', 'Reyes', '1961-05-01', 'sebastian.reyes@usach.cl', '+56987654321', 'calle2'), -- académico
('9666240-1', 'Esteban', 'Bichon', '1965-02-12', 'esteban.bichon@usach.cl', '+56911223344', 'calle3'), -- revisor
('12421578-3', 'Griselda', 'Ramos', '1972-05-04', 'griselda.ramos@usach.cl', '+56955667788', 'calle4'), -- admim
('12312312-3', 'Estefanía', 'Presi', '1970-03-12', 'estefania.presi@comite.cl', '+56932132112', 'calle5' ), --   miembro comite

-- agrego 2 de cada uno para tener variedad en los datos
('18555432-1', 'Patricio', 'Casas', '1993-03-15', 'patricio.casas@email.cl', '+56911112222', 'calle6'), -- estudiante
('19666543-2', 'Gaston', 'Reyes', '1998-08-22', 'gaston.reyes@email.cl', '+56922223333', 'calle7'), -- academico
('20777654-3', 'Francisca', 'Martinez', '2000-11-30', 'francisca.martinez@email.cl', '+56933334444', 'calle8'), -- revisor
('15888765-4', 'juan carlos', 'bodoque', '1988-05-10', 'juan.carlos.bodoque@email.cl', '+56944445555', 'calle9'), -- admin
('9999876-5', 'juan', 'martinez', '1964-12-08', 'juan.martinez@email.cl', '+56955556666', 'calle10'), -- miebro comite
-- mas participantes para tener variedad en los datos
('11111111-1', 'Carlos', 'Mendoza', '1995-03-15', 'carlos.mendoza@usach.cl', '+56911111111', 'calle11'),
('22222222-2', 'Ana', 'Torres', '1998-07-22', 'ana.torres@usach.cl', '+56922222222', 'calle12'),
('33333333-3', 'Pedro', 'Soto', '1990-11-05', 'pedro.soto@usach.cl', '+56933333333', 'calle13'),
('44444444-4', 'Laura', 'Vega', '1985-09-18', 'laura.vega@usach.cl', '+56944444444', 'calle14'),
('55555555-5', 'Diego', 'Mora', '2001-01-30', 'diego.mora@usach.cl', '+56955555555', 'calle15');

-- estudiante(rut,id_carrera)
INSERT INTO estudiante VALUES 
('20444683-0', 1),
('18555432-1',2);

-- academico(rut,id_departamento,grado_academico)
INSERT INTO academico VALUES
('8573283-4', 1, 'Doctor'),
('19666543-2',2, 'magister');

-- revisor(rut, annos_experencia,id_universidad)
INSERT INTO revisor VALUES
 ('9666240-1', 15, 1),
 ('20777654-3',20,3);  

-- administrador(rut,estado,id_universidad)
INSERT INTO administrador VALUES
 ('12421578-3', TRUE, 1),
 ('15888765-4', TRUE,4);

-- sede(id_sede,id_ciudad,nombre_sede,direccion_sede,cantidad_salas_sede,aforo_sede)
INSERT INTO sede VALUES 
(1, 1, 'DIINF', 'santiago #9170125 ', 5, 500),
(2,2,'la cuna del conocimeinto','villa siempre alegre #912',20,100),
(3,3,'auditorio uc','calle el manzano #1212',1,20);-- este usare de prueba para el trigger

-- sala(id_sala,id_sede,numero_sala,aforo_sala)
INSERT INTO sala VALUES 
(1, 1, 'A-101', 100),
(2, 1, 'A-102', 150),
(3, 1, 'B-201', 80),
(4,2,'EAO 12',10),
(5,3,'uc 10',1);

-- evento_academico (id_evento, id_sede, nombre_evento, descripcion_evento, fecha_inicio, fecha_fin, rut_creador, estado_evento)
INSERT INTO evento_academico VALUES 
(1, 1, 'Ciberseguridad y otros', 'Descripción evento', '2026-05-12', '2026-05-13', '12421578-3', 'activo'),
(2,2,'redes computacionales mediante pythn','Se busca enseñar tecnicas avanzadas de programcaion','2026-03-12', '2026-04-13', '12421578-3', 'activo'),
(3,3,'construcion de modelos embebidos',' se intenta presentar un modelo avanzado','2026-03-12','2026-05-03','12421578-3','activo');

-- tematicas(id_tematica,nombre_tematica,descripcion_tematica)
INSERT INTO tematica VALUES
(1, 'Ciberseguridad', 'Descripción'),
(2, 'redes computacionales', 'Descripción'),
(3, 'Inteligencia Artificial', 'Descripción');

-- evento tematicas(id_evento,id_tematica)
INSERT INTO evento_tematica VALUES 
(1, 1), 
(1, 2),
(2, 2),
(3, 3);

-- inscripciones(id_inscripcion, rut_estudiante, id_evento, fecha_inscripcion, estado_inscripcion, rol_en_evento)
INSERT INTO inscripcion VALUES 
(1, '20444683-0', 1, '2026-04-01', 'confirmada', 'autor'),
(2, '8573283-4', 1, '2026-04-02', 'confirmada', 'academico'),
(3, '9666240-1', 1, '2026-04-03', 'confirmada', 'revisor'),
(4, '12421578-3', 1, '2026-04-01', 'confirmada', 'organizador'),
-- inscripciones asistentes
(5, '18555432-1', 1, '2026-04-15', 'confirmada', 'asistente'),  -- Patricio Casas
(6, '19666543-2', 1, '2026-04-16', 'confirmada', 'asistente'),  -- Gaston Reyes
(7, '20777654-3', 1, '2026-04-17', 'pendiente', 'asistente'),   -- Francisca Martinez
(8, '15888765-4', 1, '2026-04-18', 'confirmada', 'asistente'),  -- juan carlos bodoque
(9, '9999876-5', 1, '2026-04-19', 'confirmada', 'asistente'),  -- juan martinez

(10, '11111111-1', 1, '2026-04-20', 'confirmada', 'asistente'), -- Carlos Mendoza
(11, '22222222-2', 1, '2026-04-21', 'confirmada', 'asistente'), -- Ana Torres
(12, '33333333-3', 1, '2026-04-22', 'pendiente',  'asistente'), -- Pedro Soto aún no paga
(13, '44444444-4', 1, '2026-04-23', 'confirmada', 'asistente'),  -- Laura Vega
(14, '55555555-5', 1, '2026-04-24', 'confirmada', 'asistente'),  -- Diego Mora

-- datos para que falle el trigger
(16, '11111111-1', 3, '2026-04-25', 'confirmada', 'asistente'),
(17, '22222222-2', 3, '2026-04-25', 'confirmada', 'asistente'),
(18, '33333333-3', 3, '2026-04-25', 'confirmada', 'asistente');



-- Pagos(id_pago,id_inscripcion,monto,fecha_pago,medio_pago,id_comprobante,estado_pago)
INSERT INTO pago VALUES 
(1, 1, 15000, '2026-04-05', 'Transferencia', '1', 'pendiente'), -- Emilio aún no paga
(2, 2, 15000, '2026-04-02', 'Exento', '2', 'validado'),
(3, 3, 15000, '2026-04-03', 'Exento', '3', 'validado'),
(4, 4, 15000, '2026-04-01', 'Exento', '4', 'validado'),

-- pagos asistentes
(5, 5, 15000, '2026-04-20', 'Transferencia', '5', 'validado'),
(6, 6, 15000, '2026-04-21', 'Tarjeta', '6', 'validado'),
(7, 7, 15000, '2026-04-22', 'Efectivo', '7', 'pendiente'),  -- Francisca aún no paga
(8, 8, 15000, '2026-04-23', 'Transferencia', '8', 'validado'),
(9, 9, 15000, '2026-04-24', 'Tarjeta', '9', 'validado'),

(10, 10, 15000, '2026-04-20', 'Transferencia', '10', 'validado'),
(11, 11, 15000, '2026-04-21', 'Tarjeta',       '11', 'validado'),
(12, 12, 15000, '2026-04-22', 'Efectivo',       '12', 'pendiente'), -- pedro aun no paga
(13, 13, 15000, '2026-04-23', 'Transferencia', '13', 'validado'),
(14, 14, 15000, '2026-04-24', 'Tarjeta',       '14', 'validado');


-- trabajos(id_trabajo PK, id_evento, id_sala_presentacion, nombre_trabajo, descripcion, fecha_presentacion, estado_revision)
INSERT INTO trabajo_academico VALUES 
(1, 1, 1, 'Vulnerabilidad de datos personales', 'Descripcion vulnerabilidades', '2026-05-12', '10:00:00', 'En revision'),
(2, 1, 2, 'Ciberseguridad', 'Descripcion Ciberseguridad', '2026-05-12', '14:00:00', 'En revision'),
(3, 1, 3, 'Inteligencia Artificial', 'Descripcion IA',          '2026-05-13', '09:00:00', 'En revision'),
(4, 1, 1, 'Redes Neuronales',        'Descripcion redes',       '2026-05-13', '11:00:00', 'Aprobado'),
(5, 1, 2, 'Seguridad en la Nube',    'Descripcion nube',        '2026-05-13', '14:00:00', 'En revision'),
(6, 1, 3, 'Machine Learning',        'Descripcion ML',          '2026-05-13', '16:00:00', 'Aprobado');

-- trabajo_tematica(id_trabajo,id_tematica)
INSERT INTO trabajo_tematica VALUES 
(1, 1), 
(1, 2), 
(2, 1),
(3, 1),
(3, 2),
(4, 1),
(5, 1),
(6, 2);

-- autoria(id_trabajo,rut_autor)
INSERT INTO autoria VALUES 
(1, '20444683-0'),
(2, '20444683-0'),
(2, '8573283-4'),
(3, '20444683-0'),  -- Emilio autor de trabajo 3
(3, '8573283-4'),   -- Sebastian coautor trabajo 3
(4, '8573283-4'),   -- Sebastian autor trabajo 4
(5, '20444683-0'),  -- Emilio autor trabajo 5
(6, '8573283-4');   -- Sebastian autor trabajo 6

-- revisiones (el trigger calcula el promedio)
-- revisiones(id_trabajo, rut_revisor, originalidad, pertinencia, claridad, puntuacion_general, comentarios_revision)
INSERT INTO revision VALUES 
(1, '9666240-1', 6.1, 4.8, 5.4, NULL, 'Faltan correcciones'),
(2, '9666240-1', 7.0, 6.3, 7.0, NULL, 'Excelente'),
(3, '9666240-1', 5.0, 4.5, 5.5, NULL, 'Necesita mejoras'),
(4, '9666240-1', 7.0, 7.0, 6.5, NULL, 'Muy buen trabajo'),
(5, '9666240-1', 4.0, 5.0, 4.5, NULL, 'Revisar referencias'),
(6, '9666240-1', 6.5, 7.0, 6.0, NULL, 'Excelente enfoque');

-- actividades (id_actividad,id_evento,id_sala,nombre_actividad,tipo_actividad,descripcion_actividad,fecha_actividad,hora_inicio,hora_fin)
INSERT INTO actividad VALUES 
(1, 1, 1, 'Taller de Ciberseguridad', 'Taller', 'Introducción a ciberseguridad', '2026-05-12', '09:00:00', '11:00:00'),
(2, 1, 2, 'Presentación vulnerabilidad de datos', 'Presentación', 'Descripcion presentación', '2026-05-12', '11:30:00', '12:30:00'),
(3, 1, 3, 'Panel de infromática ', 'Panel', 'Informática moderna', '2026-05-12', '15:00:00', '16:30:00'),
(4, 1, 1, 'Taller de Python', 'Taller', 'Introduccion a Python', '2026-05-13', '09:00:00', '11:00:00'),
(5, 1, 2, 'Panel de IA', 'Panel', 'Discusion sobre IA', '2026-05-13', '11:30:00', '13:00:00'),
(6, 1, 3, 'Mesa redonda ML', 'Mesa redonda','Tendencias en ML', '2026-05-13', '15:00:00', '16:30:00'),
(8, 3, 5, 'Taller embebidos', 'Taller', 'Desc prueba', '2026-05-01', '09:00:00', '11:00:00');


-- inscripciones a actividades (id_inscripcion,id_activiad,rut_participante,hora_entrada,hora_salida,fecha_inscripcion,asistencia_confrimada)
INSERT INTO inscripcion_actividad VALUES 
(1, 1, '20444683-0', NULL, NULL, '2026-04-10', FALSE), -- false porque van a presentar
(1, 2, '20444683-0', NULL, NULL, '2026-04-10', FALSE),
(2, 1, '8573283-4', NULL, NULL, '2026-04-11', FALSE),
(2, 3, '8573283-4', NULL, NULL, '2026-04-11', FALSE),
(3, 2, '9666240-1', NULL, NULL, '2026-04-12', FALSE),
(4, 1, '12421578-3', NULL, NULL, '2026-04-10', FALSE),
-- inscripciones actividad asistentes
-- patricio casas
(5, 1, '18555432-1', '09:00:00', '11:00:00', '2026-04-15', TRUE), -- actividad 1 / taller
(5, 2, '18555432-1', '11:30:00', '12:30:00', '2026-04-15', TRUE), -- actividad 2 / presentación trabajo 1 'Otros'
-- gastón reyes
(6, 3, '19666543-2', '15:00:00', '16:30:00', '2026-04-16', TRUE), -- actividad 3 / Panel trabajo 2 'Ciberseguridad'
-- francisca martinez (no ha pagado)
(7, 1, '20777654-3', NULL, NULL, '2026-04-17', FALSE),  -- actividad 1 / taller (aun no termina)
(7, 2, '20777654-3', NULL, NULL, '2026-04-17', FALSE), -- actividad 2 / panel, (aun no termina)
-- juan carlos bodoque
(8, 1, '15888765-4', '09:00:00', '11:00:00', '2026-04-18', TRUE), -- actividad 1
(8, 2, '15888765-4', '11:30:00', '12:30:00', '2026-04-18', TRUE), -- actividad 2
(8, 3, '15888765-4', '15:00:00', '16:30:00', '2026-04-18', TRUE), -- actividad 3

(9, 2, '9999876-5', '11:30:00', '12:30:00', '2026-04-19', TRUE), -- actividad 2 / presentación trabajo 1 'Otros'
(10, 4, '11111111-1', '09:00:00', '11:00:00', '2026-04-20', TRUE),  -- Carlos taller python
(10, 5, '11111111-1', '11:30:00', '13:00:00', '2026-04-20', TRUE),  -- Carlos panel IA
(11, 4, '22222222-2', '09:00:00', '11:00:00', '2026-04-21', TRUE),  -- Ana taller python
(11, 6, '22222222-2', '15:00:00', '16:30:00', '2026-04-21', TRUE),  -- Ana mesa redonda
(13, 5, '44444444-4', '11:30:00', '13:00:00', '2026-04-23', TRUE),  -- Laura panel IA
(13, 6, '44444444-4', '15:00:00', '16:30:00', '2026-04-23', TRUE),  -- Laura mesa redonda
(14, 4, '55555555-5', '09:00:00', '11:00:00', '2026-04-24', TRUE),  -- Diego taller python
(14, 6, '55555555-5', NULL, NULL, '2026-04-24', FALSE);             -- Diego mesa redonda (no asistio)


-- certificados(id_certificado,rut_certificado,id_evento,id_trabajo,ripo_certificado,descripcion_certificado,fecha_emision)
INSERT INTO certificado VALUES 
(1, '8573283-4', 1, NULL, 'asistencia', 'Certificado asistencia académico', '2026-05-14'),
(2, '9666240-1', 1, NULL, 'asistencia', 'Certificado asistencia revisor', '2026-05-14');

-- comité(id_comite,id_evento_nombre_comite,descripcion_comite)
INSERT INTO comite_organizador VALUES 
(1, 1, 'Comité Ciberseguridad', 'Organización del evento');

-- miembro comité(id_comite,rut_participante_comite,cargo_comite)
INSERT INTO miembro_comite VALUES 
(1, '12312312-3', 'Presidente');

-- ----------------------------
-- 6. Prueba Triggers
-- evitar_solamiento_sala

INSERT INTO actividad VALUES (100, 1, 1, 'charla ciberseguridad', 'Charla', 'Descripcion', '2026-05-14', '09:00:00', '11:00:00'); -- lo acepta

INSERT INTO actividad VALUES (101, 1, 1, 'Charla python', 'Charla', 'Descripcion', '2026-05-14', '10:00:00', '12:00:00'); -- lo rechaza por solapamiento

-- confirmacion_rol_unico
INSERT INTO inscripcion VALUES (15, '33333333-3', 2, '2026-04-25', 'pendiente', 'administrador'); -- lo acepta

INSERT INTO inscripcion VALUES (16, '33333333-3', 2, '2026-04-25', 'pendiente', 'profesor'); -- lo rechaza por rol unico


-- calular_puntacion_general
INSERT INTO revision VALUES (4, '20777654-3', 6.0, 5.0, 7.0, NULL, 'Buena revision'); -- agregamos una revision al trabajo 4

SELECT * FROM revision WHERE id_trabajo = 4 AND rut_revisor = '20777654-3'; -- la puntuacion general debe ser 6.0

-- evitar_sobrecupo
-- acepta la primera persona
INSERT INTO inscripcion_actividad VALUES (16, 8, '11111111-1', NULL, NULL, '2026-04-25', FALSE);
-- segunda persona (debe fallar, sala llena)
INSERT INTO inscripcion_actividad VALUES (17, 8, '22222222-2', NULL, NULL, '2026-04-25', FALSE);

-- --------------------
-- 7. prueba procedimeinto
-- actualizar participante
SELECT * FROM participante WHERE rut = '20444683-0';
-- actualizamos los datos
CALL actualizar_participante('20444683-0', 'Emilio', 'Poblete', 'emilio.nuevo@usach.cl', '+56999999999', 'Estacion Central 123');
-- verificamos los datos
SELECT * FROM participante WHERE rut = '20444683-0';


-- registrar entrada o solida
-- verificamos antes
SELECT * FROM inscripcion_actividad WHERE id_inscripcion = 1 AND id_actividad = 1;
-- registrar entrada
CALL registrar_entrada_salida('20444683-0', 1, 'entrada');
-- registrar salida
CALL registrar_entrada_salida('20444683-0', 1, 'salida');
-- ver estado despues
SELECT * FROM inscripcion_actividad WHERE id_inscripcion = 1 AND id_actividad = 1;

-- validar pago 
SELECT * FROM pago WHERE id_pago = 1;
SELECT * FROM inscripcion WHERE id_inscripcion = 1;
CALL validar_pago(1);
-- ver estado despues, pago debe ser 'validado' e inscripcion 'confirmada'
SELECT * FROM pago WHERE id_pago = 1;
SELECT * FROM inscripcion WHERE id_inscripcion = 1;
-- caso error: intentar validar el mismo pago de nuevo
CALL validar_pago(1);
call validar_pago(7); -- tambien falta pagar

-- -----------------------------
-- 8. Prueba vistas
-- prueba vista ranking

SELECT * FROM ranking_trabajos WHERE id_evento = 1; -- el ranking de los trabajos de vista

-- prueba ver participantes en evento
SELECT * FROM participantes_por_evento WHERE id_evento = 1;
-- para ver trabajos pendientes por tematica
SELECT * FROM trabajos_pendientes_revision WHERE id_evento = 1;

-- ------------------
-- 9. Consultas simples
-- saber cant de salas en sede
select e.id_evento, e.nombre_evento,s.nombre_sede,s.cantidad_salas_sede
from evento_academico e
join sede s on s.id_sede=e.id_sede
WHERE e.id_evento= 1;

-- saber cantidad de aforo que tiene un evento
SELECT e.id_evento, e.nombre_evento, SUM(sa.aforo_sala) AS aforo_total
FROM evento_academico e
JOIN sede s ON s.id_sede = e.id_sede
JOIN sala sa ON sa.id_sede = s.id_sede
WHERE e.id_evento = 1
GROUP BY e.id_evento, e.nombre_evento;

-- saber cantidad de participantes inscritos en un evento
SELECT e.id_evento, e.nombre_evento, COUNT(DISTINCT i.rut_participante) AS cantidad_participantes
FROM evento_academico e
JOIN inscripcion i ON i.id_evento = e.id_evento 
WHERE e.id_evento = 1
GROUP BY e.id_evento, e.nombre_evento;  

-- saber cantidad de trabajos presentados en un evento
SELECT e.id_evento, e.nombre_evento, COUNT(DISTINCT t.id_trabajo) AS cantidad_trabajos
FROM evento_academico e
JOIN trabajo_academico t ON t.id_evento = e.id_evento
WHERE e.id_evento = 1
GROUP BY e.id_evento, e.nombre_evento;  
