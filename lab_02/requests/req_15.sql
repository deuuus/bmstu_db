--15. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY и предложения HAVING. 
--Получение инфомации о альбомах с дополнительными атрибутами,
--описывающими среднюю и максимальную продолжительность каждой песни,
--при этом выбрать только те альбомы, у которых 
--тираж больше 50000 копий и максимальная продолжительность песни не больше 2 минут
SELECT A.id, A.title, A.copies, AVG(S.duration) AS avg_song_duration, MAX(S.duration) AS max_song_duration
FROM albums A JOIN songs S ON A.id = S.album_id
GROUP BY A.id
HAVING A.copies > 50000 AND MAX(S.duration) < 2.0
ORDER BY A.copies DESC, MAX(S.duration)