--3.
--Создать таблицу, в которой будет атрибут(-ы) с типом JSON, или добавить атрибут с типом JSON к уже существующей таблице.
--Заполнить атрибут правдоподобными данными с помощью команд INSERT или UPDATE.
DROP TABLE IF EXISTS json_tbl;
CREATE TABLE json_tbl
(
    json_data jsonb,
    country VARCHAR(100)
);

INSERT INTO json_tbl (json_data, country)
VALUES ('{"fio" : {"name" : "Polina", "surname" : "Sirotkina"}, "birth_year" : 2001}', 'Russian Federation'),
       ('{"fio" : {"name" : "Ivan", "surname" : "Petrov"}, "birth_year" : 2003}', 'Russian Federation'),
       ('{"fio" : {"name" : "Petr", "surname" : "Ivanov"}, "birth_year" : 2005}', 'Russian Federation');

SELECT *
FROM json_tbl;