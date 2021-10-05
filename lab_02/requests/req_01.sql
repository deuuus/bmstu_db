--1. Инструкция SELECT, использующая предикат сравнения. 
--Получение списка пар песен с одинаковой длинностью
SELECT S1.id AS id_1, S1.title AS title_1, S1.duration AS duration_1,
       S2.id AS id_2, S2.title AS title_2, S2.duration AS duration_2
FROM (songs S1 JOIN songs AS S2 ON S1.duration = S2.duration)
WHERE S1.id < S2.id