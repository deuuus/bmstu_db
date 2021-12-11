WITH CTE AS
(
    SELECT U.song_id, G.id AS "g_id"
    FROM music_groups G JOIN music_unions U ON G.id = U.music_group_id
),
ms AS 
(
    SELECT M.id AS "m_id", CTE.song_id
    FROM CTE JOIN musicians M ON CTE.g_id = M.music_group_id
    WHERE M.id = 5
)
SELECT name, surname, S.title
FROM (ms JOIN persons P ON ms.m_id = P.id) MP JOIN songs S ON MP.song_id = S.id