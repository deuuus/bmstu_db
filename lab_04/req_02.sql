--2.
--Пользовательская агрегатная функция CLR.
--Возвращает суммарную длительность песен в минутах и секундах для каждого альбома.
CREATE OR REPLACE FUNCTION album_duration(album_id int)
RETURNS REAL AS 
$code$
    query = f"select SUM(duration) from songs S JOIN albums A ON A.id = S.album_id group by A.id having A.id = {album_id};"
    result = plpy.execute(query)
    return result[0]["sum"]
$code$
LANGUAGE PLPYTHON3U;

SELECT id, title, album_duration(id)
FROM albums
WHERE id < 20