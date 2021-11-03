--6.
--Хранимая процедура с рекурсивным ОТВ.
--Выводит путь от текущего места в таблице информации о людях к первой записи в таблице о человеке с той же фамилией.
CREATE OR REPLACE PROCEDURE find_first_in_table_by_surname(person_id integer)
AS
$code$
DECLARE
    first_id       INTEGER;
    family_surname VARCHAR(100);
    cur_id         INTEGER;
BEGIN
    SELECT surname
    INTO family_surname
    FROM persons P
    WHERE P.id = person_id;

    SELECT MAX(P.id)
    INTO cur_id
    FROM persons P
    WHERE P.surname = family_surname AND P.id < person_id;

    IF cur_id IS NULL THEN
        RAISE NOTICE 'You are at the begining of the namesakes table.';
    ELSE
        RAISE NOTICE 'Keep going through table.';
        CALL find_first_in_table_by_surname(cur_id);
    END IF;
END;
$code$
LANGUAGE PLPGSQL;

CALL find_first_in_table_by_surname(2136);

SELECT *
FROM persons
WHERE surname = (SELECT surname FROM persons WHERE id = 1820);