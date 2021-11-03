--5.
--Хранимая функция. 
--Обновляет тираж альбомов в соответствии с указанным коэффициентом.
CREATE OR REPLACE PROCEDURE update_copies(rate float)
AS
$code$
BEGIN
    UPDATE albums
    SET copies = copies * rate;
    COMMIT;
END;
$code$
LANGUAGE PLPGSQL;

CALL update_copies(2.3);