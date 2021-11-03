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

INSERT INTO music_groups_view(id, creative_pseudonym, year_of_foundation, year_of_breakup, record_label)
VALUES                       (6666, 'Polina', 2001, 2041, 'Polina');

DELETE FROM music_groups WHERE id = 6666;