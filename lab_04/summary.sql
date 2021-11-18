--1.
--Определяемая пользователем скалярная функция CLR.
--Возвращает количество лет активности для музыкальной группы, определяемой ее номером.
CREATE OR REPLACE FUNCTION activity_years(group_id int)
RETURNS INTEGER AS 
$code$
    query = f"select year_of_foundation, year_of_breakup from music_groups where id = {group_id};"
    result = plpy.execute(query)
    if result[0]['year_of_breakup'] is None:
        return 2021 - result[0]['year_of_foundation']
    return result[0]['year_of_breakup'] - result[0]['year_of_foundation']
$code$
LANGUAGE PLPYTHON3U;

SELECT id, creative_pseudonym, year_of_foundation, year_of_breakup, activity_years(id)
FROM music_groups
WHERE id < 20 

--2.
--Пользовательская агрегатная функция CLR.
--Возвращает суммарную длительность песен в минутах и секундах для каждого альбома.
CREATE OR REPLACE FUNCTION album_duration(album_id int)
RETURNS REAL AS 
$code$
    query = f"select SUM(duration) from songs S JOIN albums A ON A.id = S.album_id group by A.id having A.id = {album_id};"
    result = plpy.execute(query)
    return result[0]["sum"]
$code$
LANGUAGE PLPYTHON3U;

SELECT id, title, album_duration(id)
FROM albums
WHERE id < 20;

--3.
--Определяемая пользователем табличная функция CLR.
--Возвращает таблицу вида (имя, фамилия, возраст, пол, название группы) 
--для тех людей, чьи группы распались, и которые проживают в России.
CREATE OR REPLACE FUNCTION get_russians_from_breakup_groups()
RETURNS TABLE 
(
    name        VARCHAR(100),
    surname     VARCHAR(100), 
    country     VARCHAR(100),
    age         integer, 
    gender      CHAR(1), 
    group_title VARCHAR(100)
)
AS
$code$
    query =  "select name, surname, country, 2021 - birth_year AS age, gender, G.creative_pseudonym AS group_title "
    query += "from (persons P JOIN musicians M ON P.id = M.id) JOIN music_groups G ON M.music_group_id = G.id "
    query += "where country = 'Russian Federation' AND year_of_breakup IS NOT NULL"
    result = plpy.execute(query)
    return result
$code$
LANGUAGE PLPYTHON3U;

SELECT *
FROM get_russians_from_breakup_groups()

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

CREATE TRIGGER logging AFTER INSERT OR UPDATE OR DELETE ON persons
FOR ROW EXECUTE FUNCTION log_trigger();

DELETE FROM _log;
INSERT INTO persons(id,    name,     surname,    gender, birth_year, country)
VALUES             (6666, 'Polina', 'Sirotkina', 'f',    2001,       'Russian Federation');
UPDATE persons SET country = 'Canada' WHERE id = 6666;
DELETE FROM persons WHERE id = 6666;

SELECT *
FROM _log;

--6.
--Определяемый пользователем тип данных CLR. 
--Новый тип данных определяет полное имя, содержащее имя и фамилию человека.
CREATE TYPE full_name 
AS
(
    name VARCHAR,
    surname VARCHAR
);

CREATE OR REPLACE FUNCTION set_full_name(name VARCHAR, surname VARCHAR)
RETURNS full_name
AS
$code$
    return [name, surname]
$code$
LANGUAGE PLPYTHON3U;

SELECT * 
FROM set_full_name('Polina', 'Sirotkina');