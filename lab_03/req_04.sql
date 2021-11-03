--4.
--Функция с рекурсивным ОТВ.
--Можно ли найти относительно строки с информацией о человеке А в таблице строку о человеке В, 
--при том что он из одной страны, за N шагов.
--Вовзращает таблицу со всеми такими людьми типа В.
CREATE OR REPLACE FUNCTION get_nbh(person_id INTEGER, dist INTEGER)
RETURNS TABLE 
(
    nbh_id       INTEGER,
    nbh_name     VARCHAR(100),
    nbh_surname  VARCHAR(100),
    age          INTEGER,
    gender       CHAR(1),
    dist_country VARCHAR(100),
    lvl          INTEGER
)
AS
$code$
DECLARE 
    person_country VARCHAR(100);
BEGIN
    SELECT country
    INTO person_country
    FROM persons
    WHERE persons.id = person_id;

    RETURN QUERY

    WITH RECURSIVE CTE (id, nbh_country, distance) AS
    (
        SELECT id, country, 0 AS distance
        FROM persons
        WHERE country = person_country AND id = person_id

        UNION ALL

        SELECT P.id, P.country, distance + 1
        FROM persons P JOIN CTE ON P.id = CTE.id + 1 AND distance < dist
    )

    SELECT CTE.id, P.name, P.surname, 2021 - P.birth_year, P.gender, nbh_country, distance 
    FROM CTE JOIN persons P ON CTE.id = P.id
    WHERE nbh_country = person_country;
END;
$code$
LANGUAGE PLPGSQL;

--/*
SELECT *
FROM get_nbh(138, 1000)
--*/

/*
SELECT id, name, surname, (2021-birth_year) AS "age", gender, country
FROM persons P
WHERE country = (SELECT country FROM persons WHERE id = 138) AND id BETWEEN 138 AND 1138
*/