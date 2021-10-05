--17. Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса. 
--Выборка из таблицы persons информации о женщинах из России, которые родились не позже 1990 года, 
--и вставка этих записей в ту же таблицу с измененными полями birth_year и name
INSERT INTO persons (name, surname, gender, birth_year, country)

SELECT 'Anna', surname, gender, birth_year + 25, country
FROM persons
WHERE country = 'Russian Federation' AND birth_year < 1990 and gender = 'f'