--12. Инструкция SELECT, использующая вложенные коррелированные подзапросы в качестве производных таблиц в предложении FROM. 
--Получение информации об альбомах с дополнительным полем, описывающем количество песен в альбоме
SELECT A.id, A.title AS album_title, S.num_of_songs
FROM albums A JOIN (SELECT album_id, COUNT(*) AS num_of_songs
                    FROM songs
                    GROUP BY album_id) AS S ON A.id = S.album_id
ORDER BY num_of_songs DESC