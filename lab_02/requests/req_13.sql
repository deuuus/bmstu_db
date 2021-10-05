--13. Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3. 
--Группы, которые основались в год, в который было основано максимальное количество групп за все время
--В случае равенства выбирается первая запись
SELECT id, creative_pseudonym, year_of_foundation, year_of_breakup
FROM music_groups
WHERE year_of_foundation = (
            SELECT year_of_foundation
            FROM music_groups
            GROUP BY year_of_foundation
            HAVING COUNT(id) = (SELECT MAX(cnt)
                                FROM (SELECT COUNT(id) AS cnt
                                      FROM music_groups
                                      GROUP BY year_of_foundation) AS S
                               ) 
            LIMIT 1
           )