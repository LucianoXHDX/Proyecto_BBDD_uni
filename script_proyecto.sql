DROP DATABASE IF EXISTS ProyectoEventia;
CREATE DATABASE IF NOT EXISTS ProyectoEventia;
USE ProyectoEventia;

-- Empiezo a crear entidades con MR ya aplicado y normalizados
-- tabla participante
CREATE TABLE IF NOT EXISTS participante(
rut VARCHAR(12) PRIMARY KEY,
nombre varchar(40),
apellido varchar(40),
fecha_nac date,
email varchar(80),
telefono int,
direccion varchar(80)
);
-- tabla academico
CREATE TABLE IF NOT EXISTS academico(
rut VARCHAR(12) primary KEY,
departamento varchar(40),
universidad VARCHAR(80),
grado_academico varchar(40),
foreign key (rut) references participante(rut) 
);

-- tabla estudiante
CREATE TABLE IF NOT exists estudiante(
rut VARCHAR(12) PRIMARY KEY,
carrera VARCHAR(50),
departamento VARCHAR(40),
foreign key (rut) references participante(rut) 
);

-- tabla revisor
CREATE TABLE IF NOT EXISTS revisor(
rut VARCHAR(12) primary KEY,
annos_experenica INT,
FOREIGN KEY (rut) REFERENCES participante(rut)
);

-- tabala administrador
CREATE TABLE IF NOT EXISTS administrador(
rut VARCHAR(12) PRIMARY KEY,
estado boolean,
FOREIGN KEY (rut) REFERENCES participante(rut)
);

-- tabla ciudada
CREATE TABLE IF NOT EXISTS ciudad(
id_ciudad INT PRIMARY KEY,
nombre_ciudad VARCHAR(40),
region VARCHAR(40),
pais VARCHAR(40)
);


-- tabla sede
CREATE TABLE IF NOT EXISTS sede(
id_sede INT PRIMARY KEY,
id_ciudad INT,
nombre_sede VARCHAR(40),
direccion_sede VARCHAR(80),
FOREIGN KEY (id_ciudad) REFERENCES ciudad(id_ciudad)
);

-- tabla sala
CREATE TABLE IF NOT EXISTS sala(
id_sala INT PRIMARY KEY,
id_sede INT,
numero_sala INT,
aforo_sala INT,
FOREIGN KEY (id_sede) REFERENCES sede(id_sede)
);

-- tabla evento evento_academico

CREATE TABLE IF NOT EXISTS evento_academico(
id_evento INT PRIMARY KEY,
id_sede int,

nombre_evento VARCHAR(40),
descripcion_evento VARCHAR(200),
fecha_inicio DATE,
fecha_fin DATE,
rut_creador VARCHAR(12),
estado_evento VARCHAR(20) DEFAULT 'activo',
FOREIGN KEY(rut_creador) REFERENCES administrador(rut),
FOREIGN KEY (id_sede) REFERENCES sede(id_sede)
);

-- tabla tematica
CREATE TABLE IF NOT EXISTS tematica(
id_tematica INT PRIMARY KEY,
nombre_tematica VARCHAR(40),
descripcion_tematica VARCHAR(200)
);
-- tabla evento_tematica
CREATE TABLE IF NOT EXISTS evento_tematica(
id_evento INT ,
id_tematica INT ,
primary key(id_evento,id_tematica),
FOREIGN KEY (id_evento) REFERENCES evento_academico(id_evento),
FOREIGN KEY (id_tematica) REFERENCES tematica(id_tematica)
);

-- tabla  inscripcion
CREATE TABLE IF NOT EXISTS inscripcion(
id_inscripcion INT PRIMARY KEY,
rut_participante VARCHAR(12),
id_evento INT,
fecha_inscripcion DATE,
estado_inscripcion VARCHAR(20) DEFAULT 'pendiente',
rol_en_evento VARCHAR(20),
FOREIGN KEY (rut_participante) REFERENCES participante(rut),
FOREIGN KEY (id_evento) REFERENCES evento_academico(id_evento)
);


-- tabla pago
CREATE TABLE IF NOT EXISTS pago(
  id_pago INT PRIMARY KEY,
  id_inscripcion INT,
  monto DECIMAL(10,2),
  fecha_pago DATE,
  medio_pago VARCHAR(80),
  id_comprobante VARCHAR(100),
  estado_pago VARCHAR(20) DEFAULT 'pendiente',
  FOREIGN KEY (id_inscripcion) REFERENCES inscripcion(id_inscripcion)
);

-- tabla trabajo_academico
CREATE TABLE IF NOT EXISTS trabajo_academico(
id_trabajo INT PRIMARY KEY,
id_evento INT,
id_sala_presentacion INT,
nombre_trabajo VARCHAR(40),
descripcion VARCHAR(200),
fecha_presentacion DATE,
hora_presentacion TIME,
estado_revision VARCHAR(20) DEFAULT 'En revision',
FOREIGN KEY (id_evento) REFERENCES evento_academico(id_evento),
FOREIGN KEY (id_sala_presentacion) REFERENCES sala(id_sala)
);

-- tabla trabajo_tematica
CREATE TABLE trabajo_tematica(
  id_trabajo INT,
  id_tematica INT,
  PRIMARY KEY (id_trabajo, id_tematica),
  FOREIGN KEY (id_trabajo) REFERENCES trabajo_academico(id_trabajo),
  FOREIGN KEY (id_tematica) REFERENCES tematica(id_tematica)
);

-- tabla autoria
CREATE TABLE IF NOT EXISTS autoria(
id_trabajo INT ,
rut_autor VARCHAR(12) ,
PRIMARY KEY (id_trabajo, rut_autor),
FOREIGN KEY (id_trabajo) REFERENCES trabajo_academico(id_trabajo),
FOREIGN KEY (rut_autor) REFERENCES participante(rut)
);

-- tabla revision
CREATE TABLE IF NOT EXISTS revision(
id_trabajo INT,
rut_revisor VARCHAR(12),
originalidad INT,
pertinencia INT,
claridad INT,
puntacion_general INT,
comentarios_revision VARCHAR(200),
PRIMARY KEY (id_trabajo,rut_revisor),
FOREIGN KEY (id_trabajo) REFERENCES trabajo_academico(id_trabajo),
FOREIGN KEY (rut_revisor) REFERENCES revisor(rut)
);

-- tabla actividad
CREATE TABLE IF NOT EXISTS actividad(
id_actividad INT PRIMARY KEY,
id_evento INT,
id_sala INT,
nombre_actividad VARCHAR(40),
tipo_actividad VARCHAR(40),
descripcion_actividada VARCHAR(200),
fecha_actividad DATE,
hora_inicio TIME,
hora_fin TIME,
capacidad_maxima INT,
FOREIGN KEY (id_evento) REFERENCES evento_academico(id_evento),
FOREIGN KEY (id_sala) REFERENCES sala(id_sala)
);

-- tabla inscripcion_actividad
CREATE TABLE IF NOT EXISTS inscripcion_actividad(
id_inscripcion INT ,
id_actividad INT,
rut_participante VARCHAR(12),
hora_entrada TIME,
Hora_salida TIME,
fecha_inscripcion DATE,
asistencia_confirmada BOOLEAN DEFAULT FALSE,
PRIMARY KEY (id_actividad, rut_participante),
FOREIGN KEY (id_actividad) REFERENCES actividad(id_actividad),
FOREIGN KEY (rut_participante) REFERENCES participante(rut)
);


-- tabla certificado
CREATE TABLE IF NOT EXISTS certificado(
id_certificado INT PRIMARY KEY,
rut_certificado VARCHAR(12),
id_evento INT,
-- id_trabajo INT,
tipo_certificado VARCHAR(40),
descripcion_certificado VARCHAR(200),
FOREIGN KEY (rut_certificado) REFERENCES participante(rut),
FOREIGN KEY (id_evento) REFERENCES evento_academico(id_evento) -- ,
-- FOREIGN KEY (id_trabajo) REFERENCES trabajo(id_trabajo)
);

	-- TIPO DE CERTIFICAO PUEDE SER PARTICIPANTE O EXPOSITOR

-- tabla comite_o	rganizador
CREATE TABLE IF NOT EXISTS comite_organizador(
id_comite INT PRIMARY KEY,
id_evento INT,
nombre_comite VARCHAR(100),
descripcion_comite VARCHAR(200),
FOREIGN KEY (id_evento) REFERENCES evento_academico(id_evento)

);

-- tabla miembro_comite
CREATE TABLE IF NOT EXISTS miembro_comite(
id_comite INT ,
rut_participante_comite VARCHAR(12),
cargo_comite VARCHAR(40),
PRIMARY KEY (id_comite,rut_participante_comite),
FOREIGN KEY (id_comite) REFERENCES comite_organizador(id_comite),
FOREIGN KEY (rut_participante_comite) REFERENCES participante(rut)
);
-- seccion de procedimientos 



-- fin seccion de procedimientos


-- seccion de trigger 

-- trigger evitar solapamiento en salas 



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

    -- Si encuentra algun solapamiento rechaza la insercion con mensaje de error por pantalla
    IF solapamiento > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La sala ya tiene una actividad en ese horario, busque otro horario o sala';
    END IF;
    -- Si no hay conflicto permite la insercion
DELIMITER ;

-- trigger para un rol unico por evento

DELIMITER //
CREATE TRIGGER confirmacion_rol_unico
BEFORE INSERT ON inscripcion --O SEA ANTES QUE YO META UN DATO A LA INSCRIPCION
FOR EACH ROW
BEGIN 
    DECLARE rol_asignado INT;
    SELECT COUNT(*) INTO rol_asignado
    FROM inscripcion
    WHERE id_evento = NEW.id_evento
      AND rut_participante = NEW.rut_participante;
    
    IF rol_asignado > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El participante ya tiene un rol asignado en este evento, no puede tener mas de un rol por evento';
    END IF;
END//
DELIMITER ;

-- pago antes de confirmar inscripcion


-- certificado segun las condiciones de asistente o expositor


-- fin seccion de trigger



-- seccion vistas
-- vista para ver ranking de trabajos segun su puntacion general
CREATE VIEW ranking_trabajos AS 
select t.id_trabajo, t.nombre_trabajo, t.descripcion, t.fecha_presentacion, t.hora_presentacion, r.puntacion_general
from trabajo_academico t
join revision r on t.id_trabajo = r.id_trabajo
order by r.puntacion_general desc;

-- vista participantes por evento
CREATE VIEW participantes_por_evento AS
SELECT  eve.nombre_evento, p.rut, p.nombre, p.apellido, ins.rol_en_evento
FROM evento_academico eve
JOIN inscripcion ins ON eve.id_evento = ins.id_evento
JOIN participante p ON ins.rut_participante = p.rut
ORDER BY eve.nombre_evento, p.apellido;
-- trabajos pendientes de revision





-- fin seccion vistas

-- los datos de prueba estan mal hay que revisarlos 
-- ademas faltta mostrar los trigger  

/*
-- ingreso de datos de prueba
-- ciudad(id_ciudad, nombre_ciudad, region, pais)
INSERT INTO ciudad VALUES (1,'Santiago','Metropolitana','Chile');
INSERT INTO ciudad VALUES (2,'Valparaiso','Valparaiso','Chile');
INSERT INTO ciudad VALUES (3,'Concepcion','Biobio','Chile');
INSERT INTO ciudad VALUES (4,'Antofagasta','Antofagasta','Chile');
INSERT INTO ciudad VALUES (5,'Iquique','Tarapaca','Chile');

-- sede(id_sede, id_ciudad, nombre_sede, direccion_sede)
INSERT INTO sede VALUES (1,1,'Centro de Convenciones Santiago','Av. El Bosque 1234, Santiago');
INSERT INTO sede VALUES (2,2,'Hotel Valparaiso','Calle Principal 567, Valparaiso');
INSERT INTO sede VALUES (3,3,'Universidad de Concepcion','Av. Universidad 789, Concepcion');
INSERT INTO sede VALUES (4,4,'Centro Cultural Antofagasta','Calle Cultura 456, Antofagasta');
INSERT INTO sede VALUES (5,5,'Hotel Iquique','Calle Marina 321, Iquique');

-- sala(id_sala, id_sede, numero_sala, aforo_sala)
-- agrego 2 salas por sede, con diferentes aforos para tener variedad 
INSERT INTO sala VALUES (1,1,101,100);
INSERT INTO sala VALUES (2,1,102,150);
INSERT INTO sala VALUES (3,2,201,80);
INSERT INTO sala VALUES (4,2,202,120);
INSERT INTO sala VALUES (5,3,301,200);
INSERT INTO sala VALUES (6,3,302,250);
INSERT INTO sala VALUES (7,4,401,90);
INSERT INTO sala VALUES (8,4,402,110);
INSERT INTO sala VALUES (9,5,501,70);
INSERT INTO sala VALUES (10,5,502,130);

-- participante(rut, nombre, apellido, fecha_nac, email, telefono, direccion)
-- agrego 8 participantes 2 de cada tipo admin, revisor, estudiante y academico para tener variedad 
INSERT INTO participante VALUES ('12345678-9','Juan','Perez','1990-01-01','juan.perez@email.com','987654321','Calle Principal 123, Santiago');
INSERT INTO participante VALUES ('23456789-0','Maria','Gonzalez','1985-05-15','maria.gonzalez@email.com','912345678','Calle Secundaria 456, Valparaiso');	
INSERT INTO participante VALUES ('34567890-1','Carlos','Lopez','1992-09-30','carlos.lopez@email.com','923456789','Calle Tercera 789, Concepcion');	
INSERT INTO participante VALUES ('45678901-2','Ana','Martinez','1988-12-20','ana.martinez@email.com','934567890','Calle Cuarta 101, Iquique');
INSERT INTO participante VALUES ('56789012-3','Luis','Garcia','1995-03-10','luis.garcia@email.com','945678901','Calle Quinta 202, Arica'); 
INSERT INTO participante VALUES ('67890123-4','Sofia','Rodriguez','1991-07-25','sofia.rodriguez@email.com','956789012','Calle Sexta 303, Punta Arenas');  
INSERT INTO participante VALUES ('78901234-5','Diego','Fernandez','1987-11-05','diego.fernandez@email.com','967890123','Calle Septima 404, Valdivia');
INSERT INTO participante VALUES ('89012345-6','Laura','Gomez','1993-02-18','laura.gomez@email.com','978901234','Calle Octava 505, Osorno');


-- academico(rut, departamento, universidad, grado_academico)
INSERT INTO academico VALUES ('12345678-9','Informatica','Universidad de Chile','Doctor');
INSERT INTO academico VALUES ('23456789-0','Matematica','Universidad de Santiago de Chile','Magister');

-- estudiante(rut, carrera, departamento)
INSERT INTO estudiante VALUES ('34567890-1','Ingenieria Informatica','Informatica');
INSERT INTO estudiante VALUES ('45678901-2','Matematica Aplicada','Matematica');

-- revisor(rut, annos_experiencia)
INSERT INTO revisor VALUES ('56789012-3',5);
INSERT INTO revisor VALUES ('67890123-4',3);

-- administrador(rut, estado)
INSERT INTO administrador VALUES ('78901234-5',true);
INSERT INTO administrador VALUES ('89012345-6',true);

-- tematica(id_tematica, nombre_tematica, descripcion_tematica)
INSERT INTO tematica VALUES (1,'Inteligencia Artificial','Tematica relacionada con el desarrollo de sistemas inteligentes y aprendizaje automatico');
INSERT INTO tematica VALUES (2,'Ciencia de Datos','Tematica enfocada en el analisis de grandes volúmenes de datos y extracción de conocimiento');
INSERT INTO tematica VALUES (3,'Seguridad Informatica','Tematica que aborda la protección de sistemas y datos contra amenazas y ataques');
INSERT INTO tematica VALUES (4,'Desarrollo de Software','Tematica centrada en las metodologias y herramientas para la creación de software de calidad');	
INSERT INTO tematica VALUES (5,'Redes de Computadoras','Tematica que trata sobre la interconexión de sistemas y la comunicación de datos a través de redes');	

-- evento_academico(id_evento, id_sede, nombre_evento, descripcion_evento, fecha_inicio, fecha_fin, rut_creador)
INSERT INTO evento_academico VALUES (1,1,'Congreso de Informatica','Evento anual que reúne a expertos en informatica para discutir avances y tendencias en el campo','2024-10-01','2024-10-03','78901234-5');
INSERT INTO evento_academico VALUES (2,2,'Simposio de Ciencia de Datos','Evento dedicado a la presentación de investigaciones y aplicaciones en el campo de la ciencia de datos','2024-11-15','2024-11-17','89012345-6');
INSERT INTO evento_academico VALUES (3,3,'Jornada de Seguridad Informatica','Evento enfocado en la discusión de estrategias y tecnologías para mejorar la seguridad informática','2024-12-05','2024-12-07','78901234-5');
INSERT INTO evento_academico VALUES (4,4,'Taller de Desarrollo de Software','Evento práctico que ofrece capacitación en metodologías y herramientas para el desarrollo de software','2024-09-20','2024-09-22','89012345-6');
INSERT INTO evento_academico VALUES (5,5,'Conferencia de Redes de Computadoras','Evento que aborda los avances y desafíos en el campo de las redes de computadoras','2024-08-10','2024-08-12','78901234-5');	

-- agrego 5 eventos mas para tener variedad y poder probar mejor las consultas con mas datos son 2 por cada sede
INSERT INTO evento_academico VALUES (6,1,'Seminario de Inteligencia Artificial','Evento que explora las últimas tendencias y aplicaciones en inteligencia artificial','2024-10-15','2024-10-17','89012345-6');
INSERT INTO evento_academico VALUES (7,2,'Workshop de Ciencia de Datos','Evento práctico que ofrece capacitación en herramientas y técnicas de ciencia de datos','2024-11-20','2024-11-22','78901234-5');
INSERT INTO evento_academico VALUES (8,3,'Simposio de Seguridad Informatica','Evento que reúne a expertos para discutir los desafíos y soluciones en seguridad informática','2024-12-10','2024-12-12','89012345-6');
INSERT INTO evento_academico VALUES (9,4,'Jornada de Desarrollo de Software','Evento que presenta casos de estudio y mejores prácticas en el desarrollo de software','2024-09-25','2024-09-27','78901234-5');
INSERT INTO evento_academico VALUES (10,5,'Congreso de Redes de Computadoras','Evento que reúne a profesionales y académicos para discutir los avances en el campo de las redes de computadoras','2024-08-15','2024-08-17','89012345-6');

-- evento_tematica(id_evento, id_tematica) 
-- hay 15 datos ya que puede tener varias tematicas un mismo evento y asi tener variedad para probar mejor las consultas
INSERT INTO evento_tematica VALUES (1,1);
INSERT INTO evento_tematica VALUES (1,2);
INSERT INTO evento_tematica VALUES (2,2);
INSERT INTO evento_tematica VALUES (2,3);
INSERT INTO evento_tematica VALUES (3,3);
INSERT INTO evento_tematica VALUES (3,4);
INSERT INTO evento_tematica VALUES (4,4);
INSERT INTO evento_tematica VALUES (4,5);
INSERT INTO evento_tematica VALUES (5,5);
INSERT INTO evento_tematica VALUES (6,1);
INSERT INTO evento_tematica VALUES (7,2);
INSERT INTO evento_tematica VALUES (8,3);
INSERT INTO evento_tematica VALUES (9,4);
INSERT INTO evento_tematica VALUES (10,5);

-- inscripcion(id_inscripcion, rut_participante, id_evento, fecha_inscripcion, rol_en_evento)
INSERT INTO inscripcion VALUES (1,'12345678-9',1,'2024-09-01','Academico');
INSERT INTO inscripcion VALUES (2,'23456789-0',1,'2024-09-02','Academico');
INSERT INTO inscripcion VALUES (3,'34567890-1',2,'2024-10-01','Estudiante');
INSERT INTO inscripcion VALUES (4,'45678901-2',2,'2024-10-02','Estudiante');
INSERT INTO inscripcion VALUES (5,'56789012-3',3,'2024-11-01','revisor');
INSERT INTO inscripcion VALUES (6,'67890123-4',3,'2024-11-02','revisor');
INSERT INTO inscripcion VALUES (7,'78901234-5',4,'2024-08-01','admin');
INSERT INTO inscripcion VALUES (8,'89012345-6',4,'2024-08-02','admin');

-- pago(id_pago, id_inscripcion, monto, fecha_pago, medio_pago, id_comprobante)
INSERT INTO pago VALUES (1,1,100.000,'2024-09-05','Tarjeta de Credito','comprobante1.pdf');
INSERT INTO pago VALUES (2,2,100.000,'2024-09-06','Transferencia Bancaria','comprobante2.pdf');
INSERT INTO pago VALUES (3,3,50.000,'2024-10-05','Tarjeta de Credito','comprobante3.pdf');
INSERT INTO pago VALUES (4,4,50.000,'2024-10-06','Transferencia Bancaria','comprobante4.pdf');
INSERT INTO pago VALUES (5,5,10.000,'2024-11-05','Tarjeta de Credito','comprobante5.pdf');
INSERT INTO pago VALUES (6,6,10.000,'2024-11-06','Transferencia Bancaria','comprobante6.pdf');
INSERT INTO pago VALUES (7,7,10.000,'2024-08-05','Transferencia bancaria','comprobante7.pdf');
INSERT INTO pago VALUES (8,8,30.000,'2024-08-06','Transferencia bancaria','comprobante8.pdf');

-- trabajo_academico(id_trabajo, id_evento, id_sala_presentacion, nombre_trabajo, descripcion, fecha_presentacion, hora_presentacion)
INSERT INTO trabajo_academico VALUES (1,1,1,'Trabajo de Inteligencia Artificial','Descripcion del trabajo de inteligencia artificial','2024-10-02','10:00:00');
INSERT INTO trabajo_academico VALUES (2,1,2,'Trabajo de Ciencia de Datos','Descripcion del trabajo de ciencia de datos','2024-10-02','14:00:00');
INSERT INTO trabajo_academico VALUES (3,2,3,'Trabajo de Seguridad Informatica','Descripcion del trabajo de seguridad informatica','2024-11-16','10:00:00');
INSERT INTO trabajo_academico VALUES (4,2,4,'Trabajo de Desarrollo de Software','Descripcion del trabajo de desarrollo de software','2024-11-16','14:00:00');

-- trabajo_tematica(id_trabajo, id_tematica)
INSERT INTO trabajo_tematica VALUES (1,1);
INSERT INTO trabajo_tematica VALUES (2,2);
INSERT INTO trabajo_tematica VALUES (3,3);
INSERT INTO trabajo_tematica VALUES (4,4);

-- autoria(id_trabajo, rut_autor)
INSERT INTO autoria VALUES (1,'12345678-9');
INSERT INTO autoria VALUES (2,'23456789-0');
INSERT INTO autoria VALUES (3,'34567890-1');
INSERT INTO autoria VALUES (4,'45678901-2');
INSERT INTO autoria VALUES (1,'23456789-0');
INSERT INTO autoria VALUES (2,'34567890-1');

-- revision(id_trabajo, rut_revisor, originalidad, puntacion_general, comentarios_revision)
INSERT INTO revision VALUES (1,'56789012-3',8,9,'Buen trabajo, pero se podria mejorar la metodologia');
INSERT INTO revision VALUES (1,'67890123-4',7,8,'Interesante enfoque, pero falta profundidad en el analisis');
INSERT INTO revision VALUES (2,'56789012-3',9,10,'Excelente trabajo, muy original y bien presentado');
INSERT INTO revision VALUES (2,'67890123-4',8,9	,'Muy buen trabajo, aunque se podria mejorar la redaccion');
INSERT INTO revision VALUES (3,'56789012-3',6,7,'El trabajo es interesante, pero la originalidad es limitada');
INSERT INTO revision VALUES (3,'67890123-4',5,6,'El trabajo tiene potencial, pero necesita una revision profunda');
INSERT INTO revision VALUES (4,'56789012-3',7,8,'Buen trabajo, aunque la metodologia podria ser mas robusta');
INSERT INTO revision VALUES (4,'67890123-4',6,7,'El trabajo es aceptable, pero se podria mejorar la presentacion');

-- actividad(id_actividad, id_evento, id_sala, nombre_actividad, tipo_actividad, descripcion_actividada, fecha_actividad, hora_inicio, hora_fin, capacidad_maxima)
INSERT INTO actividad VALUES (1,1,1,'Taller de Inteligencia Artificial','Taller','Descripcion del taller de inteligencia artificial','2024-10-01','09:00:00','12:00:00',30);
INSERT INTO actividad VALUES (2,1,2,'Charla de Ciencia de Datos','Charla','taller de la charla de ciencia de datos','2024-10-01','13:00:00','14:00:00',100);
INSERT INTO actividad VALUES (3,2,3,'Panel de Seguridad Informatica','Panel','charla magistral del panel de seguridad informatica','2024-11-15','10:00:00','11:30:00',50);
INSERT INTO actividad VALUES (4,2,4,'Taller de Desarrollo de Software','Taller','charla magistral del taller de desarrollo de software','2024-11-15','14:00:00','17:00:00',30);
INSERT INTO actividad VALUES (5,3,5,'Conferencia de Redes de Computadoras','mesa redonda','Descripcion de la conferencia de redes de computadoras','2024-12-05','09:00:00','10:30:00',100);	
-- agrego 5 actividades mas para tener variedad y poder probar mejor las consultas con mas datos son 2 por cada evento
INSERT INTO actividad VALUES (6,1,1,'Mesa Redonda de Inteligencia Artificial','Mesa Redonda','Descripcion de la mesa redonda de inteligencia artificial','2024-10-02','15:00:00','16:30:00',50);
INSERT INTO actividad VALUES (7,2,3,'Charla de Ciencia de Datos Avanzada','taller','Descripcion de la charla de ciencia de datos avanzada','2024-11-16','11:30:00','12:30:00',100);
INSERT INTO actividad VALUES (8,3,5,'Taller de Seguridad Informatica','charl magistral','Descripcion del taller de seguridad informatica','2024-12-06','10:30:00','13:30:00',30);	
INSERT INTO actividad VALUES (9,4,4,'Panel de Desarrollo de Software','mesa redonda','Descripcion del panel de desarrollo de software','2024-09-26','14:00:00','15:30:00',50);
INSERT INTO actividad VALUES (10,5,5,'Charla de Redes de Computadoras','Charla magistral','Descripcion de la charla de redes de computadoras','2024-08-16','09:00:00','10:00:00',100);

-- inscripcion_actividad(id_inscripcion, id_actividad, rut_participante, hora_entrada, Hora_salida, fecha_inscripcion)
INSERT INTO inscripcion_actividad VALUES (1,1,'12345678-9','09:00:00','12:00:00','2025-09-15');
INSERT INTO inscripcion_actividad VALUES (2,2,'23456789-0','13:00:00','14:00:00','2025-09-16');
INSERT INTO inscripcion_actividad VALUES (3,3,'34567890-1','10:00:00','11:30:00','2025-10-15');
INSERT INTO inscripcion_actividad VALUES (4,4,'45678901-2','14:00:00','17:00:00','2025-10-16');
INSERT INTO inscripcion_actividad VALUES (5,5,'56789012-3','09:00:00','10:30:00','2025-11-15');
INSERT INTO inscripcion_actividad VALUES (6,6,'67890123-4','15:00:00','16:30:00','2025-10-17');
INSERT INTO inscripcion_actividad VALUES (7,7,'12345678-9','11:30:00','12:30:00','2025-10-18');	
INSERT INTO inscripcion_actividad VALUES (8,8,'23456789-0','10:30:00','13:30:00','2025-11-17');
INSERT INTO inscripcion_actividad VALUES (9,9,'34567890-1','14:00:00','15:30:00','2025-09-20');


-- certificado(id_certificado, rut_certificado, id_evento, tipo_certificado, descripcion_certificado)

INSERT INTO certificado VALUES (1,'12345678-9',1,'Expositor','Certificado de expositor para el evento de inteligencia artificial');
INSERT INTO certificado VALUES (2,'23456789-0',1,'Expositor','Certificado de expositor para el evento de inteligencia artificial');
INSERT INTO certificado VALUES (3,'34567890-1',2,'Expositor','Certificado de expositor para el evento de ciencia de datos');
INSERT INTO certificado VALUES (4,'45678901-2',2,'Expositor','Certificado de expositor para el evento de ciencia de datos');
INSERT INTO certificado VALUES (5,'56789012-3',3,'Participante','Certificado de participante para el evento de seguridad informatica');
INSERT INTO certificado VALUES (6,'67890123-4',3,'Participante','Certificado de participante para el evento de seguridad informatica');
INSERT INTO certificado VALUES (7,'78901234-5',4,'Participante','Certificado de participante para el evento de desarrollo de software');
INSERT INTO certificado VALUES (8,'89012345-6',4,'Participante','Certificado de participante para el evento de desarrollo de software');
INSERT INTO certificado VALUES (9,'12345678-9',6,'Expositor','Certificado de expositor para el seminario de inteligencia artificial');
INSERT INTO certificado VALUES (10,'23456789-0',6,'Expositor','Certificado de expositor para el seminario de inteligencia artificial');
INSERT INTO certificado VALUES (11,'34567890-1',7,'Expositor','Certificado de expositor para el workshop de ciencia de datos');
INSERT INTO certificado VALUES (12,'45678901-2',7,'Expositor','Certificado de expositor para el workshop de ciencia de datos');

-- comite_organizador(id_comite, id_evento, nombre_comite, descripcion_comite)
INSERT INTO comite_organizador VALUES (1,1,'Comite Organizador del Congreso de Informatica','Comite encargado de la organizacion del Congreso de Informatica');
INSERT INTO comite_organizador VALUES (2,2,'Comite Organizador del Simposio de Ciencia de Datos','Comite encargado de la organizacion del Simposio de Ciencia de Datos');
INSERT INTO comite_organizador VALUES (3,3,'Comite Organizador de la Jornada de Seguridad Informatica','Comite encargado de la organizacion de la Jornada de Seguridad Informatica');
INSERT INTO comite_organizador VALUES (4,4,'Comite Organizador del Taller de Desarrollo de Software','Comite encargado de la organizacion del Taller de Desarrollo de Software');
INSERT INTO comite_organizador VALUES (5,5,'Comite Organizador de la Conferencia de Redes de Computadoras','Comite encargado de la organizacion de la Conferencia de Redes de Computadoras');
INSERT INTO comite_organizador VALUES (6,6,'Comite Organizador del Seminario de Inteligencia Artificial','Comite encargado de la organizacion del Seminario de Inteligencia Artificial');
INSERT INTO comite_organizador VALUES (7,7,'Comite Organizador del Workshop de Ciencia de Datos','Comite encargado de la organizacion del Workshop de Ciencia de Datos');








-- miembro_comite(id_comite, rut_participante_comite, cargo_comite)
-- Solo académicos y administradores tienen sentido como miembros de comité
INSERT INTO miembro_comite VALUES (1, '78901234-5', 'Presidente');
INSERT INTO miembro_comite VALUES (1, '89012345-6', 'Secretario');
INSERT INTO miembro_comite VALUES (2, '78901234-5', 'Presidente');
INSERT INTO miembro_comite VALUES (2, '89012345-6', 'Secretario');
INSERT INTO miembro_comite VALUES (3, '78901234-5', 'Presidente');
INSERT INTO miembro_comite VALUES (3, '89012345-6', 'Secretario');














-- fin de ingresod de datos
*/
