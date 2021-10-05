--2. Инструкция SELECT, использующая предикат BETWEEN.
--Получение информации о музыкантах, которые родились в промежуток между 1995 и 2001 годом
SELECT P.surname, P.name, P.birth_year, M.creative_pseudonym
FROM persons P JOIN musicians M ON P.id = M.id
WHERE P.birth_year BETWEEN 1995 AND 2001
ORDER BY P.surname, P.name