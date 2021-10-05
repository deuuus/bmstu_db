--18. Простая инструкция UPDATE. 
--Увеличение тиража в 1.7 раза у альбомов, вышедших в 2020 году
UPDATE albums
SET copies = copies * 1.7
WHERE release_year = 2020