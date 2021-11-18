--3.
--Определяемая пользователем табличная функция CLR.
--Возвращает таблицу вида (имя, фамилия, возраст, пол, название группы) 
--для тех людей, чьи группы распались, и которые проживают в России.
CREATE OR REPLACE FUNCTION get_russians_from_breakup_groups()
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
    query =  "select name, surname, country, 2021 - birth_year AS age, gender, G.creative_pseudonym AS group_title "
    query += "from (persons P JOIN musicians M ON P.id = M.id) JOIN music_groups G ON M.music_group_id = G.id "
    query += "where country = 'Russian Federation' AND year_of_breakup IS NOT NULL"
    result = plpy.execute(query)
    return result
$code$
LANGUAGE PLPYTHON3U;

SELECT *
FROM get_russians_from_breakup_groups()