--1. Инструкция SELECT, использующая предикат сравнения. 
--Получение списка пар песен с одинаковой длинностью
SELECT S1.id AS id_1, S1.title AS title_1, S1.duration AS duration_1,
       S2.id AS id_2, S2.title AS title_2, S2.duration AS duration_2
FROM (songs S1 JOIN songs AS S2 ON S1.duration = S2.duration)
WHERE S1.id < S2.id

--2. Инструкция SELECT, использующая предикат BETWEEN.
--Получение информации о музыкантах, которые родились в промежуток между 1995 и 2001 годом
SELECT P.surname, P.name, P.birth_year, M.creative_pseudonym
FROM persons P JOIN musicians M ON P.id = M.id
WHERE P.birth_year BETWEEN 1995 AND 2001
ORDER BY P.surname, P.name

--3. Инструкция SELECT, использующая предикат LIKE. 
--Получение информации о музыкантах, чей творческий псевдоним начинается с префикса 'ab'
SELECT P.id, P.surname, P.name, M.creative_pseudonym
FROM persons P JOIN musicians M ON P.id = M.id
WHERE M.creative_pseudonym LIKE 'ab%'
ORDER BY P.surname, P.name

--4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом.
--Получить список людей из музыкальной группы с идентификатором 123
SELECT P.surname, P.name, P.birth_year, 
       M.creative_pseudonym AS musician_pseudonym,
       G.creative_pseudonym AS group_pseudonym
FROM (persons P JOIN musicians M ON P.id = M.id) JOIN music_groups G ON M.music_group_id = G.id
WHERE M.music_group_id IN (SELECT music_group_id
                        FROM music_groups
                        WHERE music_group_id < 3)

--5. Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом. 
--Получить информацию о песнях, у которых есть видеоклип
SELECT S.id, S.title, S.video_clip_title
FROM songs S
WHERE NOT EXISTS(SELECT *
            FROM songs LEFT OUTER JOIN albums
                ON songs.album_id = albums.id
            WHERE S.video_clip_title is NULL)

--6. Инструкция SELECT, использующая предикат сравнения с квантором. 
--Получение информации о людях, которые родились позднее, чем все участники группы под номером 423
SELECT *
FROM persons
WHERE birth_year > ALL (SELECT persons.birth_year
                        FROM (persons JOIN musicians ON persons.id = musicians.id) 
                            JOIN music_groups ON music_groups.id = musicians.music_group_id
                        WHERE music_group_id = 320)

--7. Инструкция SELECT, использующая агрегатные функции в выражениях столбцов. 
--Получение информации об альбомах с дополнительным атрибутом, описывающим общую длительность альбома
SELECT albums.id, albums.title, SUM(songs.duration) AS "Total duration of album"
FROM songs JOIN albums ON songs.album_id = albums.id
GROUP BY albums.id
ORDER BY albums.id

--8. Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.
--Получение информации о людях, которые родились в тот год, 
--в который родился самый старших участник из группы под номером 123
SELECT id, surname, name, birth_year
FROM persons
WHERE persons.birth_year = (SELECT (MAX(persons.birth_year))
                            FROM (persons JOIN musicians ON persons.id = musicians.id)
                                JOIN music_groups ON musicians.music_group_id = music_groups.id
                            WHERE music_groups.id = 123)

--9. Инструкция SELECT, использующая простое выражение CASE. 
--Получение информации о песнях с дополнительным атрибутом, описывающим энергичность песни.
SELECT songs.id, songs.title,
    CASE genre
        WHEN 'rock' THEN 'This is very heavy music.'
        WHEN 'metal' THEN 'This is very heavy music.'
        WHEN 'alternative music' THEN 'This is very heavy music.'
        WHEN 'electronic music' THEN 'This is very energetic music.'
        WHEN 'folk' THEN 'This is very energetic music.'
        WHEN 'disco' THEN 'This is very energetic music.'
        WHEN 'hip-hop' THEN 'This is very energetic music.'
        WHEN 'serenade' THEN 'This if very romantin music.'
        WHEN 'romance' THEN 'This if very romantic music.'
        WHEN 'jazz' THEN 'This if very melodic music.'
        WHEN 'blues' THEN 'This if very melodic music.'
        ELSE 'This is just a good song'
    END AS "Rythm"
FROM songs

--10. Инструкция SELECT, использующая поисковое выражение CASE.
--Получение информации о песнях с дополнительным атрибутом, описывающим степень продолжительности песни.
SELECT id, title, 
    CASE 
        WHEN duration < 3.0 THEN 'Short song'
        WHEN duration < 6.0 THEN 'Usual song'
        WHEN duration < 9.0 THEN 'Long song'
        ELSE 'Very long song'
    END AS how_long
FROM songs

--11. Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT. 
--Создание временной таблицы, содержащей информацию о том, сколько человек представлено в каждой стране, и вывод результата

BEGIN;

CREATE TEMPORARY TABLE persons_n_countries (
    country VARCHAR(100),
    residents INTEGER
)ON COMMIT DROP;

INSERT INTO persons_n_countries (
SELECT country, COUNT(*) AS residents
FROM persons
GROUP BY country
ORDER BY residents DESC
);

SELECT * FROM persons_n_countries

COMMIT;

--12. Инструкция SELECT, использующая вложенные коррелированные подзапросы в качестве производных таблиц в предложении FROM. 
--Получение информации об альбомах с дополнительным полем, описывающем количество песен в альбоме
SELECT A.id, A.title AS album_title, S.num_of_songs
FROM albums A JOIN (SELECT album_id, COUNT(*) AS num_of_songs
                    FROM songs
                    GROUP BY album_id) AS S ON A.id = S.album_id
ORDER BY num_of_songs DESC

--13. Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3. 
--Группы, которые основались в год, в который было основано максимальное количество групп за все время
--В случае равенства выбирается первая запись
SELECT id, creative_pseudonym, year_of_foundation, year_of_breakup
FROM music_groups
WHERE year_of_foundation = (
            SELECT year_of_foundation
            FROM music_groups
            GROUP BY year_of_foundation
            HAVING COUNT(id) = (SELECT MAX(cnt)
                                FROM (SELECT COUNT(id) AS cnt
                                      FROM music_groups
                                      GROUP BY year_of_foundation) AS S
                               ) 
            LIMIT 1
           )

--14. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING. 
--Получение информации об альбомах с дополнительными атрибутами, 
--описывающими среднюю и максимальную продолжительность каждой песни
SELECT A.id, A.title, AVG(S.duration), MAX(S.duration)
FROM albums A JOIN songs S ON A.id = S.album_id
GROUP BY A.id

--15. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY и предложения HAVING. 
--Получение инфомации о альбомах с дополнительными атрибутами,
--описывающими среднюю и максимальную продолжительность каждой песни,
--при этом выбрать только те альбомы, у которых 
--тираж больше 50000 копий и максимальная продолжительность песни не больше 2 минут
SELECT A.id, A.title, A.copies, AVG(S.duration) AS avg_song_duration, MAX(S.duration) AS max_song_duration
FROM albums A JOIN songs S ON A.id = S.album_id
GROUP BY A.id
HAVING A.copies > 50000 AND MAX(S.duration) < 2.0
ORDER BY A.copies DESC, MAX(S.duration)

--16. Однострочная инструкция INSERT, выполняющая вставку в таблицу одной строки значений. 
--Вставка в таблицу с песнями записи новой песне.
INSERT INTO songs(title, duration, genre, video_clip_title, album_id)

VALUES('Detroit', 3.25, 'hip-hop', 'industry', 666)

--17. Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса. 
--Выборка из таблицы persons информации о женщинах из России, которые родились не позже 1990 года, 
--и вставка этих записей в ту же таблицу с измененными полями birth_year и name
INSERT INTO persons (name, surname, gender, birth_year, country)

SELECT 'Anna', surname, gender, birth_year + 25, country
FROM persons
WHERE country = 'Russian Federation' AND birth_year < 1990 and gender = 'f'

--18. Простая инструкция UPDATE. 
--Увеличение тиража в 1.7 раза у альбомов, вышедших в 2020 году
UPDATE albums
SET copies = copies * 1.7
WHERE release_year = 2020

--19. Инструкция UPDATE со скалярным подзапросом в предложении SET. 
--Выравнивание количества копий у всех альбомов, которые выпустились в 2020 году
UPDATE albums
SET copies = (SELECT AVG(copies)
              FROM albums
              WHERE release_year = 2000)
WHERE release_year = 2000

--20. Простая инструкция DELETE.
--Удаление сведений о людях, которые не являются музыкантами
DELETE
FROM persons
USING musicians
WHERE persons.id NOT IN (SELECT musicians.id from musicians)

--21. Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE. 
--Удаление сведений о музыкантах, чья группа уже распалась
DELETE
FROM musicians
WHERE music_group_id IN (SELECT id
                        FROM music_groups
                        WHERE year_of_breakup IS NOT NULL)

--22. Инструкция SELECT, использующая простое обобщенное табличное выражение(ОТВ)
--Создание временной таблицы, описывающей название альбома и количества песен в ней
--Выбор среднего значения количества песен в альбоме среди всех альбомов с помощью ОТВ
WITH CTE (album_title, num_of_songs) AS
          (SELECT A.title, COUNT(*)
           FROM albums A JOIN songs S ON A.id = S.album_id
           GROUP BY A.title)

SELECT AVG(num_of_songs) AS avg_num_of_songs_in_albums
FROM CTE

--23. Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение.
--Вычисление расстояния, на котором расположены соседние строки, описывающие человека из Кореи, 
-- причем расстояние принимает значение от 50 до 100
WITH RECURSIVE CTE (id, country, distance) AS
(
    SELECT id, country, 0 AS distance
    FROM persons
    WHERE country = 'Korea'

    UNION ALL

    SELECT P.id, P.country, distance + 1
    FROM persons P JOIN CTE ON P.id = CTE.id + 1 AND distance < 100
)

SELECT *
FROM CTE
WHERE country = 'Korea' AND distance > 50

--24. Оконные функции. Использование конструкций MIN/MAX/AVG OVER().
--Получение информации о музыкантах с дополнительным полем, описывающем средний уровень опыта по году рождения музыкантов
SELECT M.id, P.name, P.surname, P.birth_year,
       AVG(M.experience) OVER (PARTITION BY P.birth_year) AS avg_experience
FROM persons P JOIN musicians M ON P.id = M.id
ORDER BY avg_experience DESC

--25. Оконные функции для устранения дублей.
--Получение дублей на основе выделения мужчин и женщин в каждой стране, а затем удаление дублей.
SELECT RES.gender, RES.country
FROM
(SELECT P.gender, P.country, ROW_NUMBER() OVER (PARTITION BY P.gender, P.country) AS cnt
FROM persons P) RES
WHERE RES.cnt = 1