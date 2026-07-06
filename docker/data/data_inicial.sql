-- Crear las tablas
create table medicina(
    id int primary key,
    nombre varchar(100) not null,
    farmaceutica varchar(100)
);

create table proveedor(
    ruc varchar(13) primary key,
    nombre varchar(100) not null,
    email varchar(50) not null
);

create table proveedor_medicina(
    proveedor_ruc varchar(13),
    medicina_id int,
    lote_minimo int,
    precio_unitario decimal(15,2),
    primary key (proveedor_ruc, medicina_id),
    constraint fk_proveedor_ruc
       foreign key (proveedor_ruc)
       references proveedor(ruc),
    constraint fk_medicina_id
       foreign key (medicina_id)
       references medicina(id)
);

create table usuario (
    id int auto_increment primary key,
    nombre varchar(100) not null,
    email varchar(30) not null unique
);

-- Cargar datos
insert into usuario (nombre, email) values 
('Víctor', 'victor_m@g.com'),
('María', 'maria_m@t.com'),
('Lorena', 'lorena_m@d.com');

insert into medicina (id, nombre, farmaceutica) values
(1, 'Paracetamol', 'Bayer'),
(2, 'Ibuprofeno', 'Pfizer'),
(3, 'Amoxicilina', 'Roche'),
(4, 'Aspirina', 'Bayer'),
(5, 'Omeprazol', 'Novartis'),
(6, 'Metformina', 'Merck'),
(7, 'Loratadina', 'Sanofi'),
(8, 'Azitromicina', 'Pfizer'),
(9, 'Diclofenaco', 'Novartis'),
(10, 'Salbutamol', 'GSK'),
(11, 'Insulina', 'Novo Nordisk'),
(12, 'Enalapril', 'Merck'),
(13, 'Losartán', 'Pfizer'),
(14, 'Simvastatina', 'Roche'),
(15, 'Clonazepam', 'Roche'),
(16, 'Fluoxetina', 'Lilly'),
(17, 'Ciprofloxacino', 'Bayer'),
(18, 'Ketorolaco', 'Syntex'),
(19, 'Naproxeno', 'Bayer'),
(20, 'Prednisona', 'Pfizer');

insert into proveedor (ruc, nombre, email) values
('1790011111001', 'Distribuidora FarmaPlus', 'ventas1@farma.com'),
('1790011111002', 'MedicGlobal', 'contacto@medicg.com'),
('1790011111003', 'Salud Total', 'info@saludtotal.com'),
('1790011111004', 'Distribuciones Omega', 'ventas@omega.com'),
('1790011111005', 'Farmacenter', 'soporte@farmacenter.com'),
('1790011111006', 'BioPharma', 'ventas@biopharma.com'),
('1790011111007', 'MedicalSupplies', 'info@medsup.com'),
('1790011111008', 'Distribuidora Andina', 'andina@dist.com'),
('1790011111009', 'FarmaEcuador', 'contacto@farmaec.com'),
('1790011111010', 'Proveeduría Médica', 'ventas@provmed.com');

insert into proveedor_medicina
(proveedor_ruc, medicina_id, lote_minimo, precio_unitario) values

('1790011111001',1,50,1.20),
('1790011111001',2,40,1.50),
('1790011111001',3,30,2.10),
('1790011111001',4,50,0.90),
('1790011111001',5,20,3.50),

('1790011111002',6,25,2.80),
('1790011111002',7,30,1.70),
('1790011111002',8,20,4.50),
('1790011111002',9,40,1.60),
('1790011111002',10,20,5.00),

('1790011111003',11,15,12.00),
('1790011111003',12,30,1.20),
('1790011111003',13,30,1.50),
('1790011111003',14,20,2.40),
('1790011111003',15,10,3.60),

('1790011111004',16,25,2.90),
('1790011111004',17,20,4.00),
('1790011111004',18,30,1.80),
('1790011111004',19,40,1.50),
('1790011111004',20,20,2.70),

('1790011111005',1,60,1.10),
('1790011111005',2,50,1.40),
('1790011111005',3,40,2.20),
('1790011111005',6,30,2.70),
('1790011111005',7,25,1.60),

('1790011111006',8,20,4.40),
('1790011111006',9,35,1.70),
('1790011111006',10,20,5.10),
('1790011111006',11,15,11.80),
('1790011111006',12,30,1.30),

('1790011111007',13,25,1.60),
('1790011111007',14,20,2.50),
('1790011111007',15,10,3.80),
('1790011111007',16,30,3.00),
('1790011111007',17,20,4.20),

('1790011111008',18,30,1.90),
('1790011111008',19,40,1.60),
('1790011111008',20,20,2.80),
('1790011111008',1,50,1.25),
('1790011111008',2,40,1.55),

('1790011111009',3,35,2.15),
('1790011111009',4,60,0.95),
('1790011111009',5,25,3.60),
('1790011111009',6,30,2.85),
('1790011111009',7,30,1.75),

('1790011111010',8,20,4.60),
('1790011111010',9,35,1.65),
('1790011111010',10,25,5.20),
('1790011111010',11,15,12.20),
('1790011111010',12,30,1.35);

