--24. Оконные функции. Использование конструкций MIN/MAX/AVG OVER().
--Получение информации о музыкантах с дополнительным полем, описывающем средний уровень опыта по году рождения музыкантов
SELECT M.id, P.name, P.surname, P.birth_year,
       AVG(M.experience) OVER (PARTITION BY P.birth_year) AS avg_experience
FROM persons P JOIN musicians M ON P.id = M.id
ORDER BY avg_experience DESC