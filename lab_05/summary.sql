--1.
--Из таблиц базы данных, созданной в первой лабораторной работе, извлечь данные в JSON.
\o persons.json
SELECT ROW_TO_JSON(persons) FROM persons;

\o musicians.json
SELECT ROW_TO_JSON(musicians) FROM musicians;

\o songs.json
SELECT ROW_TO_JSON(songs) FROM songs;

\o albums.json
SELECT ROW_TO_JSON(albums) FROM albums;

\o music_groups.json
SELECT ROW_TO_JSON(music_groups) FROM music_groups;

\o music_unions.json
SELECT ROW_TO_JSON(music_unions) FROM music_unions;

--2.
--Выполнить загрузку и сохранение JSON файла в таблицу.
--Созданная таблица после всех манипуляций должна соответствовать таблице базы данных, созданной в первой лабораторной работе.
DROP TABLE IF EXISTS json_data;
CREATE TABLE json_data
(
    data json
);

\COPY json_data from 'albums.json';

DROP TABLE IF EXISTS json_albums;
CREATE TABLE json_albums(id SERIAL PRIMARY KEY,
                    title VARCHAR(100) NOT NULL,
                    release_year INTEGER NOT NULL,
                    copies INTEGER,
                    CHECK (release_year > 1969),
                    CHECK (copies > 0)
);

INSERT INTO json_albums(title, release_year, copies)
SELECT data->>'title', (data->>'release_year')::INTEGER, (data->>'copies')::INTEGER
FROM json_data;

DROP TABLE json_data;

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

--4.1.
--Извлечь JSON фрагмент из JSON документа.
SELECT json_data->'fio' AS FIO
FROM json_tbl;

--4.2. 
--Извлечь значения конкретных узлов или атрибутов JSON документа.
SELECT json_data->'fio'->'surname' AS surname
FROM json_tbl;

--4.3. 
--Выполнить проверку существования узла или атрибута.
DROP FUNCTION check_key_exists(json, text);
CREATE OR REPLACE FUNCTION check_key_exists(json_data jsonb, key text)
RETURNS TEXT
AS 
$code$
BEGIN
    IF json_data->key IS NOT NULL THEN
        RETURN 'True';
    ELSIF json_data->'fio'->key IS NOT NULL THEN
        RETURN 'True';
    ELSE
        RETURN 'False';
    END IF;
END;
$code$
LANGUAGE PLPGSQL;

SELECT check_key_exists(json_data, 'fio') AS "FIO EXISTS", 
       check_key_exists(json_data, 'birth_year') AS "BIRTH YEAR EXISTS",
       check_key_exists(json_data, 'name') AS "NAME EXISTS",
       check_key_exists(json_data, 'surname') AS "SURNAME EXISTS",
       json_data
FROM json_tbl;

--4.4.
--Изменить JSON документ.
SELECT * FROM json_tbl;
UPDATE json_tbl SET json_data = json_data || '{"is_musician" : "t"}';
SELECT * FROM json_tbl;

--4.5.
--Разделить JSON документ на несколько строк по узлам.
WITH tmp AS (
    SELECT jsonb_array_elements((concat('[','[', json_data->'fio', '],', json_data->'birth_year', ']'))::jsonb)
    FROM json_tbl
)
SELECT * FROM tmp;