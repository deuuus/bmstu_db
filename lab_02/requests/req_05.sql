--5. Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом. 
--Получить информацию о песнях, у которых есть видеоклип
SELECT S.id, S.title, S.video_clip_title
FROM songs S
WHERE NOT EXISTS(SELECT *
            FROM songs LEFT OUTER JOIN albums
                ON songs.album_id = albums.id
            WHERE S.video_clip_title is NULL)