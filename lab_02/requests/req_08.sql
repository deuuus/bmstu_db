--8. Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.
--Получение информации о людях, которые родились в тот год, 
--в который родился самый старших участник из группы под номером 123
SELECT id, surname, name, birth_year
FROM persons
WHERE persons.birth_year = (SELECT (MAX(persons.birth_year))
                            FROM (persons JOIN musicians ON persons.id = musicians.id)
                                JOIN music_groups ON musicians.music_group_id = music_groups.id
                            WHERE music_groups.id = 123)