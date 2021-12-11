DROP DATABASE  IF EXISTS rk2;

CREATE DATABASE rk2;

\c rk2;

CREATE TABLE animals
(
    id SERIAL PRIMARY KEY,
    kind VARCHAR NOT NULL,
    breed VARCHAR NOT NULL,
    name VARCHAR NOT NULL
);

CREATE TABLE owners
(
    id SERIAL PRIMARY KEY,
    fio VARCHAR NOT NULL,
    address VARCHAR NOT NULL,
    phone VARCHAR NOT NULL
);

CREATE TABLE cures
(
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    simptome VARCHAR NOT NULL,
    analysis VARCHAR NOT NULL
);

CREATE TABLE links_ac
(
    id SERIAL PRIMARY KEY,
    animal_id INTEGER NOT NULL,
    cure_id INTEGER NOT NULL,
    FOREIGN KEY (animal_id) REFERENCES animals(id),
    FOREIGN KEY (cure_id) REFERENCES cures(id)
);

CREATE TABLE links_ao
(
    id SERIAL PRIMARY KEY,
    animal_id INTEGER NOT NULL,
    owner_id INTEGER NOT NULL,
    FOREIGN KEY (animal_id) REFERENCES animals(id),
    FOREIGN KEY (owner_id) REFERENCES owners(id)
);

INSERT INTO animals(kind, breed, name)
VALUES
('kind 1', 'breed 1', 'name 1'),
('kind 2', 'breed 2', 'name 2'),
('kind 3', 'breed 1', 'name 3'),
('kind 4', 'breed 2', 'name 1'),
('kind 5', 'breed 3', 'name 2'),
('kind 6', 'breed 4', 'name 4'),
('kind 7', 'breed 3', 'name 5'),
('kind 8', 'breed 4', 'name 6'),
('kind 9', 'breed 5', 'name 7'),
('kind 10', 'breed 6', 'name 8');

INSERT INTO owners(fio, address, phone)
VALUES
('n1 s1', 'a1', '111'),
('n2 s1', 'a2', '222'),
('n3 s1', 'a3', '333'),
('n1 s2', 'a4', '444'),
('n1 s3', 'a5', '555'),
('n4 s4', 'a6', '666'),
('n5 s5', 'a7', '777'),
('n6 s1', 'a8', '888'),
('n7 s1', 'a9', '999'),
('n1 s5', 'a1', '123');

INSERT INTO cures(name, simptome, analysis)
VALUES
('n1', 's1', 'a1'),
('n2', 's2', 'a2'),
('n3', 's3', 'a3'),
('n4', 's4', 'a4'),
('n5', 's5', 'a5'),
('n6', 's1', 'a6'),
('n7', 's2', 'a7'),
('n8', 's3', 'a8'),
('n9', 's4', 'a9'),
('n10', 's5', 'a10');

INSERT INTO links_ac(animal_id, cure_id)
VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(1, 5),
(2, 7),
(3, 9);

INSERT INTO links_ao(animal_id, owner_id)
VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(4, 2),
(5, 4),
(6, 6);