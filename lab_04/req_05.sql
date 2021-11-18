--5.
--Триггер CLR.
--Логирует информацию в отдельную таблицу при выполнении операций вставки/удаления/обновления в таблицу информации о людях.
CREATE TABLE _log
(
    operation   CHAR(1)    NOT NULL,
    date        TIMESTAMP  NOT NULL,
    table_name  TEXT       NOT NULL
);

CREATE OR REPLACE FUNCTION log_trigger()
RETURNS TRIGGER
AS
$code$
    from datetime import datetime
    operation = '?'
    if TD["event"] == "DELETE":
        operation = 'D'
    elif TD["event"] == "INSERT":
        operation = 'I'
    elif TD["event"] == "UPDATE":
        operation = 'U'
    plan = plpy.prepare("INSERT INTO _log SELECT $1, $2, $3", ["CHAR(1)", "TIMESTAMP", "TEXT"])
    plpy.execute(plan, [operation, datetime.now(), TD["table_name"] ])
$code$
LANGUAGE PLPYTHON3U;

CREATE TRIGGER loggin AFTER INSERT OR UPDATE OR DELETE ON persons
FOR ROW EXECUTE FUNCTION log_trigger();

DELETE FROM _log;

INSERT INTO persons(id,    name,     surname,    gender, birth_year, country)
VALUES             (6666, 'Polina', 'Sirotkina', 'f',    2001,       'Russian Federation');

UPDATE persons SET country = 'Canada' WHERE id = 6666;

DELETE FROM persons WHERE id = 6666;

SELECT *
FROM _log