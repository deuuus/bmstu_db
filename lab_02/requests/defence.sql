--Защита лабораторной 06.10.2021
--Вывести все песни в жанре метал, написанные женщинами
WITH female_groups (id, creative_pseudonym) AS
(
    SELECT *
    FROM music_groups G
    WHERE G.id NOT IN 
        (SELECT G.id
        FROM (musicians M JOIN persons P ON M.id = P.id) MP JOIN music_groups G ON MP.music_group_id = G.id
        WHERE MP.gender = 'm')
)

SELECT S.title
FROM (female_groups G JOIN music_unions U ON G.id = U.music_group_id) GU JOIN songs S On GU.song_id = S.id
WHERE S.genre = 'metal'