--2.
--Подставляемая табличная функция.
--Возвращает таблицу вида (имя, фамилия, возраст, пол, название группы) 
--для тех людей, чьи группы распались, и которые проживают в Японии.
CREATE OR REPLACE FUNCTION get_japanese_from_breakup_groups()
RETURNS TABLE 
(
    name        VARCHAR(100),
    surname     VARCHAR(100), 
    country     VARCHAR(100),
    age         integer, 
    gender      CHAR(1), 
    group_title VARCHAR(100)
)
AS
$code$
    SELECT P.name, P.surname, P.country, 2021 - P.birth_year, P.gender, G.creative_pseudonym
    FROM (persons P JOIN musicians M ON P.id = M.id) JOIN music_groups G ON M.music_group_id = G.id
    WHERE country like 'Japan' AND year_of_breakup IS NOT NULL
$code$
LANGUAGE SQL;

--/*
SELECT *
FROM get_japanese_from_breakup_groups()
ORDER BY age
--*/

/*
SELECT name, surname, country, (2021 - birth_year) AS "age", gender, G.creative_pseudonym AS "group_title", year_of_foundation, year_of_breakup
FROM (persons P JOIN musicians M ON P.id = M.id) JOIN music_groups G ON M.music_group_id = G.id
WHERE country like 'Japan' 
ORDER BY age
*/