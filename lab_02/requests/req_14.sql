--14. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING. 
--Получение информации об альбомах с дополнительными атрибутами, 
--описывающими среднюю и максимальную продолжительность каждой песни
SELECT A.id, A.title, AVG(S.duration), MAX(S.duration)
FROM albums A JOIN songs S ON A.id = S.album_id
GROUP BY A.id