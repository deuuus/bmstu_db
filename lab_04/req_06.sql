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
FROM set_full_name('Polina', 'Sirotkina')