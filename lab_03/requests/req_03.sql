--3.
--Многооператорная табличная функция.
--Возвращает информацию о женщинах, которые входили в состав групп, 
--которые образовались в год создания самой ранней группы.
CREATE OR REPLACE FUNCTION get_women_from_yearliest_groups()
RETURNS TABLE
(
    name        VARCHAR(100),
    surname     VARCHAR(100), 
    age         integer, 
    gender      CHAR(1), 
    group_title VARCHAR(100),
    year        INTEGER
)
AS
$code$
DECLARE 
    min_year INTEGER;
BEGIN
    CREATE TEMP TABLE tmp
    (
        name        VARCHAR(100),
        surname     VARCHAR(100), 
        age         integer, 
        gender      CHAR(1), 
        group_title VARCHAR(100),
        year        INTEGER
    );

    SELECT MIN(year_of_foundation)
    INTO min_year
    FROM music_groups;

    INSERT INTO tmp (name, surname, age, gender, group_title, year)
    SELECT P.name, P.surname, 2021 - P.birth_year, P.gender, G.creative_pseudonym, G.year_of_foundation
    FROM (persons P JOIN musicians M ON P.id = M.id) JOIN music_groups G ON M.music_group_id = G.id
    WHERE year_of_foundation = min_year AND P.gender = 'f';

    RETURN QUERY
    SELECT * FROM tmp;
END;
$code$
LANGUAGE PLPGSQL;

--/*
SELECT * FROM get_people_from_yearliest_groups()
ORDER BY group_title, age;
--*/

/*
SELECT name, surname, (2021 - birth_year) AS "age", P.gender, G.creative_pseudonym AS "group title", G.year_of_foundation
FROM (persons P JOIN musicians M ON P.id = M.id) JOIN music_groups G ON M.music_group_id = G.id
WHERE G.year_of_foundation = (SELECT MIN(year_of_foundation) FROM music_groups) AND gender = 'f'
ORDER BY G.creative_pseudonym, age
*/