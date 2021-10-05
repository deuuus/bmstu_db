--25. Оконные функции для устранения дублей.
--Получение дублей на основе выделения мужчин и женщин в каждой стране, а затем удаление дублей.
SELECT RES.gender, RES.country
FROM
(SELECT P.gender, P.country, ROW_NUMBER() OVER (PARTITION BY P.gender, P.country) AS cnt
FROM persons P) RES
WHERE RES.cnt = 1