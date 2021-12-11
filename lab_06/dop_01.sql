CREATE DATABASE dop;

\c dop;

DROP TABLE Table1;
DROP TABLE Table2;

CREATE TABLE Table1
(
    id              INTEGER,
    var1            VARCHAR,
    valid_from_dttm DATE,
    valid_to_dttm   DATE
);

CREATE TABLE Table2
(
    id              INTEGER,
    var2            VARCHAR,
    valid_from_dttm DATE,
    valid_to_dttm   DATE
);

DELETE FROM Table1;
DELETE FROM Table2;

INSERT INTO Table1 
(id, var1, valid_from_dttm, valid_to_dttm)
VALUES 
(1, 'A №1', '2021-01-01', '2021-01-15'),
(1, 'A №2', '2021-01-16', '2021-02-04'),
(1, 'A №3', '2021-02-05', '2021-04-01'),
(2, 'B №1', '2021-01-01', '2021-01-04'),
(2, 'B №2', '2021-01-05', '2021-03-01');

INSERT INTO Table2 
(id, var2, valid_from_dttm, valid_to_dttm)
VALUES 
(1, 'A №1', '2021-01-01', '2021-01-27'),
(1, 'A №2', '2021-01-28', '2021-04-01'),
(2, 'B №1', '2021-01-01', '2021-03-01');

SELECT *
FROM Table1;
SELECT *
FROM Table2;

WITH dates_from AS 
(
  SELECT id, valid_from_dttm FROM Table1
  UNION
  SELECT id, valid_from_dttm FROM Table2
),
dates_to AS 
(
  SELECT id, valid_to_dttm FROM Table1
  UNION
  SELECT id, valid_to_dttm FROM Table2
),
intervals AS 
(
    SELECT df.id, valid_from_dttm, MIN(valid_to_dttm) AS valid_to_dttm
FROM dates_from df JOIN dates_to dt ON df.id = dt.id AND df.valid_from_dttm < valid_to_dttm
GROUP BY df.id, valid_from_dttm
ORDER BY valid_from_dttm
)
SELECT i.id,
       t1.var1, t2.var2,
       i.valid_from_dttm, i.valid_to_dttm
FROM intervals i
JOIN Table1 t1 ON t1.id = i.id AND t1.valid_from_dttm <= i.valid_to_dttm and t1.valid_to_dttm >= i.valid_from_dttm
JOIN Table2 t2 ON t2.id = i.id AND t2.valid_from_dttm <= i.valid_to_dttm and t2.valid_to_dttm >= i.valid_from_dttm
ORDER BY i.id, i.valid_from_dttm