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