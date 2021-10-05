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