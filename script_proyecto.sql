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
nombre_evento VARCHAR(40),
descripcion_evento VARCHAR(200),
fecha_inicio DATE,
fecha_fin DATE,
rut_creador VARCHAR(12),
FOREIGN KEY(rut_creador) REFERENCES administrador(rut)
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

-- tabla pago
CREATE TABLE IF NOT EXISTS pago(
id_pago INT PRIMARY KEY,
monto INT,
fecha_pago DATE,
medio_pago VARCHAR(20),
rut_inscripcion VARCHAR(12),
FOREIGN KEY (rut_inscripcion) REFERENCES participante(rut)
);

-- tabla  inscripcion
CREATE TABLE IF NOT EXISTS inscripcion(
id_inscripcion INT PRIMARY KEY,
rut_participante VARCHAR(12),
id_evento INT,
fecha_inscripcion DATE,
id_pago INT,
rol_en_evento VARCHAR(10),
FOREIGN KEY (rut_participante) REFERENCES participante(rut),
FOREIGN KEY (id_evento) REFERENCES evento_academico(id_evento),
FOREIGN KEY (id_pago) REFERENCES pago(id_pago)
);

-- tabla trabajo_academico
CREATE TABLE IF NOT EXISTS trabajo_academico(
id_trabajo INT PRIMARY KEY,
id_evento INT,
id_tematica INT,
id_sala INT,
nombre_trabajo VARCHAR(40),
descripcion VARCHAR(200),
fecha_presentacion DATE,
sala_presentacion VARCHAR(10),
hora_presentacion TIME,
FOREIGN KEY (id_evento) REFERENCES evento_academico(id_evento),
FOREIGN KEY (id_tematica) REFERENCES tematica(id_tematica),
FOREIGN KEY (id_sala) REFERENCES sala(id_sala)
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
id_revisor INT ,
id_trabajo INT,
rut_revisor VARCHAR(12),
originalidad INT,
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
id_inscripcion INT PRIMARY KEY,
id_actividad INT,
rut_participante VARCHAR(12),
fecha_inscripcion DATE,
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
nombre_comite VARCHAR(50),
descripcion_comite VARCHAR(200),
FOREIGN KEY (id_evento) REFERENCES evento_academico(id_evento)

);

-- tabla miembro_comite
CREATE TABLE IF NOT EXISTS miembro_comite(
id_comite INT ,
rut_participante_comite VARCHAR(12),
cargo_comite VARCHAR(40),
PRIMARY KEY (id_comite,rut_participante_comite),
FOREIGN KEY (rut_participante_comite) REFERENCES participante(rut)
);





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








