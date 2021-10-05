--22. Инструкция SELECT, использующая простое обобщенное табличное выражение(ОТВ)
--Создание временной таблицы, описывающей название альбома и количества песен в ней
--Выбор среднего значения количества песен в альбоме среди всех альбомов с помощью ОТВ
WITH CTE (album_title, num_of_songs) AS
          (SELECT A.title, COUNT(*)
           FROM albums A JOIN songs S ON A.id = S.album_id
           GROUP BY A.title)

SELECT AVG(num_of_songs) AS avg_num_of_songs_in_albums
FROM CTE