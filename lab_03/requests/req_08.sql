--8.
--Хранимая процедура доступа к метаданным.
--Выводит метаданные о таблице, такие как индентификатор базы, максимальное количество соединений к базе, 
--идентификатор владельца, возможность клонирования другими пользователями и последний системный индентификатор.
CREATE OR REPLACE PROCEDURE get_db_metadata(db_name VARCHAR(100))
AS
$code$
DECLARE
    db_id INTEGER;
    db_connlimit INTEGER;
    OWNER INTEGER;
    clone BOOLEAN;
    sysid INTEGER;
BEGIN
    SELECT pg.oid, pg.datconnlimit, pg.datdba, pg.datistemplate, pg.datlastsysoid
    FROM pg_database pg WHERE pg.datname = db_name
    INTO db_id, db_connlimit, owner, clone, sysid;
    RAISE NOTICE 'DB row identifier:                                %, ', db_id;
    RAISE NOTICE 'DB maximum number of concurrent connections:      % (-1 means no limit).', db_connlimit;
    RAISE NOTICE 'DB row indentifier of owner:                      %', owner;
    RAISE NOTICE 'DB ability to cloning by any user using createdb: %  (f-false, t-true)', clone;
    RAISE NOTICE 'DB last system OID:                               %', sysid;
END;
$code$
LANGUAGE PLPGSQL;

CALL get_db_metadata('lr_3');