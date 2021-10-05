--10. Инструкция SELECT, использующая поисковое выражение CASE.
--Получение информации о песнях с дополнительным атрибутом, описывающим степень продолжительности песни.
SELECT id, title, 
    CASE 
        WHEN duration < 3.0 THEN 'Short song'
        WHEN duration < 6.0 THEN 'Usual song'
        WHEN duration < 9.0 THEN 'Long song'
        ELSE 'Very long song'
    END AS how_long
FROM songs