--23. Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение.
--Вычисление расстояния, на котором расположены соседние строки, описывающие человека из Кореи, 
-- причем расстояние принимает значение от 50 до 100
WITH RECURSIVE CTE (id, country, distance) AS
(
    SELECT id, country, 0 AS distance
    FROM persons
    WHERE country = 'Korea'

    UNION ALL

    SELECT P.id, P.country, distance + 1
    FROM persons P JOIN CTE ON P.id = CTE.id + 1 AND distance < 100
)

SELECT *
FROM CTE
WHERE country = 'Korea' AND distance > 50