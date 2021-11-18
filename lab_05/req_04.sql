--1. Извлечь JSON фрагмент из JSON документа.
SELECT json_data->'fio' AS FIO
FROM json_tbl;

--2. Извлечь значения конкретных узлов или атрибутов JSON документа.
SELECT json_data->'fio'->'surname' AS surname
FROM json_tbl;


--3. Выполнить проверку существования узла или атрибута.
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


--4. Изменить JSON документ.
SELECT * FROM json_tbl;
UPDATE json_tbl SET json_data = json_data || '{"is_musician" : "t"}';
SELECT * FROM json_tbl;

--5. Разделить JSON документ на несколько строк по узлам
WITH tmp AS (
    SELECT jsonb_array_elements((concat('[','[', json_data->'fio', '],', json_data->'birth_year', ']'))::jsonb)
    FROM json_tbl
)
SELECT * FROM tmp;