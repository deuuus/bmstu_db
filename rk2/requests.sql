--Инструкция SELECT, использующая предикат IN с вложенным подзапросом.
--Запрос выводит записи вида <кличка животного, ФИО хозяина, адрес хозяина, телефон хозяина> для тех хозяинов, чей номер телефона, представленный в 
--виде строки, больше (по лексикографическому порядку), чем 555.
SELECT A.name AS "animal name", OL.fio AS "owner fio", OL.address, OL.phone
FROM (links_ao L JOIN owners O ON L.owner_id = O.id) OL JOIN animals A ON OL.animal_id = A.id
WHERE owner_id IN (SELECT id FROM owners WHERE phone > '555');

--Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY и предложения HAVING.
--Запрос выводит записи вида <порода животного, количество животных такой породы, представленных в базе> для тех животных, которых существует ровно двое в базе с такой породой.
SELECT breed, COUNT(*)
FROM animals
GROUP BY breed
HAVING COUNT(*) = 2;

--Инструкция SELECT, использующая предикат сравнения с квантором.
--Запрос выводит записи вида <ФИО владельца, адрес, телефон> для тех владельцев,
--чей номер телефона, представленный в виде строки, больше (по лексикографическому порядку) номера телефона любого из владельцев, у которых есть ровно 2 животных.
SELECT fio, address, phone
FROM owners
WHERE phone > ANY(SELECT phone FROM 
                    (SELECT owner_id FROM (animals A JOIN links_ao L ON A.id = L.animal_id) AL 
                    JOIN owners O ON O.id = AL.owner_id GROUP BY owner_id HAVING COUNT(*) = 2) S
                    JOIN owners O ON O.id = S.owner_id);


--Создать хранимую процедуру с входным параметром, которая выводит имена хранимых процедур,
--созданных с параметром WITH RECOMPILE, в тексте которых на языке SQL встречается строка,
--задаваемая параметром процедуры. Созданную хранимую процедуру протестировать.
--(В postgresql нет параметра WITH RECOMPILE).
CREATE OR REPLACE PROCEDURE get_procedures(string varchar)
AS
$code$
DECLARE
    rec record;
BEGIN
    FOR rec IN
        SELECT proname
        FROM pg_proc
        WHERE prosrc like '%' || string || '%'
        LOOP
        RAISE NOTICE 'procedure name = %s\n', rec.proname;
        END LOOP;
END;
$code$
LANGUAGE PLPGSQL;

CALL get_procedures('sun');
CALL get_procedures('string');
CALL get_procedures('aaa');
CALL get_procedures('upper');
CALL get_procedures('get');