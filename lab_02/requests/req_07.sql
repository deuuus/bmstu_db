--7. Инструкция SELECT, использующая агрегатные функции в выражениях столбцов. 
--Получение информации об альбомах с дополнительным атрибутом, описывающим общую длительность альбома
SELECT albums.id, albums.title, SUM(songs.duration) AS "Total duration of album"
FROM songs JOIN albums ON songs.album_id = albums.id
GROUP BY albums.id
ORDER BY albums.id