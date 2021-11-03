--9.
--Триггер AFTER.
--Логирует информацию в отдельную таблицу при выполнении операций вставки/удаления/обновления в таблицу информации о людях.
CREATE TABLE _log
(
    operation  CHAR(1)    NOT NULL,
    date       TIMESTAMP  NOT NULL,
    userid     TEXT       NOT NULL
);

CREATE OR REPLACE FUNCTION log_trigger()
RETURNS TRIGGER
AS
$code$
BEGIN
    IF    (TG_OP = 'DELETE') THEN
        INSERT INTO _log SELECT 'D', now(), user;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO _log SELECT 'U', now(), user;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO _log SELECT 'I', now(), user;
    END IF;
    RETURN NULL;
END;
$code$
LANGUAGE PLPGSQL;

CREATE TRIGGER logging AFTER INSERT OR UPDATE OR DELETE ON persons
FOR ROW EXECUTE FUNCTION log_trigger();

DELETE FROM _log;

INSERT INTO persons(id,    name,     surname,    gender, birth_year, country)
VALUES             (6666, 'Polina', 'Sirotkina', 'f',    2001,       'Russian Federation');
UPDATE persons SET country = 'Canada' WHERE id = 6666;
DELETE FROM persons WHERE id = 6666;

SELECT *
FROM _log