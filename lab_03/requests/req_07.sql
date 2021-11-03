--7.
--Хранимая процедура с курсором.
--Выводит информацию об альбомах указанного года выпуска и с тиражом, большим указанного числа.
CREATE OR REPLACE PROCEDURE fetch_albums_by_copies(tagret_year INTEGER, target_copies INTEGER)
AS
$code$
DECLARE
    rec RECORD;
    _cursor CURSOR FOR 
        SELECT A.id, A.title, A.release_year, A.copies
        FROM albums A
        WHERE A.release_year = $1 AND A.copies > $2;
BEGIN
    OPEN _cursor;
    LOOP
        FETCH _cursor INTO rec;
        IF rec IS NOT NULL THEN
            RAISE NOTICE '"%" album with id % have % copies and was released in %.', rec.title, rec.id, rec.copies, rec.release_year;
        END IF;
        EXIT WHEN NOT FOUND;
    END LOOP;
    CLOSE _cursor;
END;
$code$
LANGUAGE PLPGSQL;

CALL fetch_albums_by_copies(2018, 200000);

SELECT id, title, copies, release_year
FROM albums
WHERE release_year = 2018 AND copies > 200000;