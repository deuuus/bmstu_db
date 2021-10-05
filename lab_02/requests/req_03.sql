--3. Инструкция SELECT, использующая предикат LIKE. 
--Получение информации о музыкантах, чей творческий псевдоним начинается с префикса 'ab'
SELECT P.id, P.surname, P.name, M.creative_pseudonym
FROM persons P JOIN musicians M ON P.id = M.id
WHERE M.creative_pseudonym LIKE 'ab%'
ORDER BY P.surname, P.name