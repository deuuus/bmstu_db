--6. Инструкция SELECT, использующая предикат сравнения с квантором. 
--Получение информации о людях, которые родились позднее, чем все участники группы под номером 423
SELECT *
FROM persons
WHERE birth_year > ALL (SELECT persons.birth_year
                        FROM (persons JOIN musicians ON persons.id = musicians.id) 
                            JOIN music_groups ON music_groups.id = musicians.music_group_id
                        WHERE music_group_id = 320)