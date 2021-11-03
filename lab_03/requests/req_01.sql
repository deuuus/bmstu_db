--1.
--Скалярная функция.
--Возвращает количество лет активности для музыкальной группы, определяемой ее номером.
--Если группа еще активна, функция ворвращает NULL.
CREATE OR REPLACE FUNCTION activity_years(integer)
RETURNS INTEGER AS 
$code$
    SELECT year_of_breakup - year_of_foundation
    FROM music_groups
    WHERE music_groups.id = $1;
$code$
LANGUAGE SQL;

SELECT id, creative_pseudonym, 
year_of_foundation, year_of_breakup,
year_of_breakup - year_of_foundation AS "hand-calculated diff", activity_years(id) AS "func-calculated diff"
FROM music_groups
WHERE id <= 20