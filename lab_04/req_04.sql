--4.
--Хранимая процедура CLR.
--Обновляет тираж альбомов в соответствии с указанным коэффициентом.
CREATE OR REPLACE PROCEDURE update_copies(rate float)
AS
$code$
    query = f"UPDATE albums SET copies = copies * {rate};"
    result = plpy.execute(query)
$code$
LANGUAGE PLPYTHON3U;

CALL update_copies(2.3);