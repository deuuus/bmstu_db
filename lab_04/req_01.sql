--1.
--Определяемая пользователем скалярная функция CLR.
--Возвращает количество лет активности для музыкальной группы, определяемой ее номером.
CREATE OR REPLACE FUNCTION activity_years(group_id int)
RETURNS INTEGER AS 
$code$
    query = f"select year_of_foundation, year_of_breakup from music_groups where id = {group_id};"
    result = plpy.execute(query)
    if result[0]['year_of_breakup'] is None:
        return 2021 - result[0]['year_of_foundation']
    return result[0]['year_of_breakup'] - result[0]['year_of_foundation']
$code$
LANGUAGE PLPYTHON3U;

SELECT id, creative_pseudonym, year_of_foundation, year_of_breakup, activity_years(id)
FROM music_groups
WHERE id < 20 