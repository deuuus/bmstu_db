--4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом.
--Получить список людей из музыкальной группы с идентификатором 123
SELECT P.surname, P.name, P.birth_year, 
       M.creative_pseudonym AS musician_pseudonym,
       G.creative_pseudonym AS group_pseudonym
FROM (persons P JOIN musicians M ON P.id = M.id) JOIN music_groups G ON M.music_group_id = G.id
WHERE M.music_group_id IN (SELECT music_group_id
                        FROM music_groups
                        WHERE music_group_id = 123)