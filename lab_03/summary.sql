\c lr_3;
--1.
--Скалярная функция.
--Возвращает количество лет активности для музыкальной группы, определяемой ее номером.
--Если группа еще активна, функция ворвращает NULL.
CREATE OR REPLACE FUNCTION activity_years(integer)
RETURNS INTEGER AS 
$code$
    SELECT year_of_breakup - year_of_foundation
    FROM music_groups
    WHERE music_groups.id = $1;
$code$
LANGUAGE SQL;

--2.
--Подставляемая табличная функция.
--Возвращает таблицу вида (имя, фамилия, возраст, пол, название группы) 
--для тех людей, чьи группы распались, и которые проживают в Японии.
CREATE OR REPLACE FUNCTION get_japanese_from_breakup_groups()
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
    SELECT P.name, P.surname, P.country, 2021 - P.birth_year, P.gender, G.creative_pseudonym
    FROM (persons P JOIN musicians M ON P.id = M.id) JOIN music_groups G ON M.music_group_id = G.id
    WHERE country like 'Japan' AND year_of_breakup IS NOT NULL
$code$
LANGUAGE SQL;

--3.
--Многооператорная табличная функция.
--Возвращает информацию о людях, которые входили в состав групп, 
--которые образовались в год создания самой ранней группы.
CREATE OR REPLACE FUNCTION get_women_from_yearliest_groups()
RETURNS TABLE
(
    name        VARCHAR(100),
    surname     VARCHAR(100), 
    age         integer, 
    gender      CHAR(1), 
    group_title VARCHAR(100),
    year        INTEGER
)
AS
$code$
DECLARE 
    min_year INTEGER;
BEGIN
    CREATE TEMP TABLE tmp
    (
        name        VARCHAR(100),
        surname     VARCHAR(100), 
        age         integer, 
        gender      CHAR(1), 
        group_title VARCHAR(100),
        year        INTEGER
    );

    SELECT MIN(year_of_foundation)
    INTO min_year
    FROM music_groups;

    INSERT INTO tmp (name, surname, age, gender, group_title, year)
    SELECT P.name, P.surname, 2021 - P.birth_year, P.gender, G.creative_pseudonym, G.year_of_foundation
    FROM (persons P JOIN musicians M ON P.id = M.id) JOIN music_groups G ON M.music_group_id = G.id
    WHERE year_of_foundation = min_year AND P.gender = 'f';

    RETURN QUERY
    SELECT * FROM tmp;
END;
$code$
LANGUAGE PLPGSQL;

--4.
--Функция с рекурсивным ОТВ.
--Можно ли найти относительно строки с информацией о человеке А в таблице строку о человеке В, 
--при том что он из одной страны, за N шагов.
--Вовзращает таблицу со всеми такими людьми типа В.
CREATE OR REPLACE FUNCTION get_nbh(person_id INTEGER, dist INTEGER)
RETURNS TABLE 
(
    nbh_id       INTEGER,
    nbh_name     VARCHAR(100),
    nbh_surname  VARCHAR(100),
    age          INTEGER,
    gender       CHAR(1),
    dist_country VARCHAR(100),
    lvl          INTEGER
)
AS
$code$
DECLARE 
    person_country VARCHAR(100);
BEGIN
    SELECT country
    INTO person_country
    FROM persons
    WHERE persons.id = person_id;

    RETURN QUERY

    WITH RECURSIVE CTE (id, nbh_country, distance) AS
    (
        SELECT id, country, 0 AS distance
        FROM persons
        WHERE country = person_country AND id = person_id

        UNION ALL

        SELECT P.id, P.country, distance + 1
        FROM persons P JOIN CTE ON P.id = CTE.id + 1 AND distance < dist
    )

    SELECT CTE.id, P.name, P.surname, 2021 - P.birth_year, P.gender, nbh_country, distance 
    FROM CTE JOIN persons P ON CTE.id = P.id
    WHERE nbh_country = person_country;
END;
$code$
LANGUAGE PLPGSQL;

--5.
--Хранимая процедура с одним параметром.
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
            RAISE NOTICE '"%" album with id % have % copies and was released in %.', rec.title, rec.id, res.copies, rec.release_year;
        END IF;
        EXIT WHEN NOT FOUND;
    END LOOP;
    CLOSE _cursor;
END;
$code$
LANGUAGE PLPGSQL;

--8.
--Хранимая процедура доступа к метаданным.
--Выводит метаданные о базе данных, такие как индентификатор базы, максимальное количество соединений к базе, 
--идентификатор владельца, возможность клонирования базы другими пользователями и последний системный индентификатор.
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

--10.
--Триггер INSTEAD OF.
--При вставке информации о музыкальной группе проверяет корректность дат формирования и распада.
CREATE OR REPLACE FUNCTION insert_music_group()
RETURNS TRIGGER
AS
$code$
BEGIN
    IF NEW.year_of_foundation > 2021 THEN
        RAISE EXCEPTION 'Year of foundation is more then current year (2021). Insertion into music_groups aborted.';
        RETURN NULL;
    ELSIF NEW.year_of_foundation < 1900 THEN
        RAISE EXCEPTION 'Year of foundation is less than 1900. Insertion into music_groups aborted.';
        RETURN NULL;
    ELSIF NEW.year_of_breakup IS NOT NULL AND NEW.year_of_breakup > 2021 THEN
        RAISE EXCEPTION 'Year of breakup is more then current year (2021). Insertion into music_groups aborted.';
        RETURN NULL;
    ELSIF NEW.year_of_breakup IS NOT NULL AND NEW.year_of_breakup < NEW.year_of_foundation THEN
        RAISE EXCEPTION 'Year of breakup is less than year of foundation. Insertion into music_groups aborted.';
        RETURN NULL;
    ELSE
        INSERT INTO music_groups(id, creative_pseudonym, year_of_foundation, year_of_breakup, record_label)
        VALUES (NEW.id, NEW.creative_pseudonym, NEW.year_of_foundation, NEW.year_of_breakup, NEW.record_label);
        RETURN NEW;
    END IF;
END;
$code$
LANGUAGE PLPGSQL;

CREATE VIEW music_groups_view AS
SELECT *
FROM music_groups
WHERE id < 10;

CREATE TRIGGER check_group INSTEAD OF INSERT ON music_groups_view
FOR ROW EXECUTE FUNCTION insert_music_group();