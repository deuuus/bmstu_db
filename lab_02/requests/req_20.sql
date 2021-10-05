--20. Простая инструкция DELETE.
--Удаление сведений о людях, которые не являются музыкантами
DELETE
FROM persons
USING musicians
WHERE persons.id NOT IN (SELECT musicians.id from musicians)