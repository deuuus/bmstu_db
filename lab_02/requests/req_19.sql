--19. Инструкция UPDATE со скалярным подзапросом в предложении SET. 
--Выравнивание количества копий у всех альбомов, которые выпустились в 2020 году
UPDATE albums
SET copies = (SELECT AVG(copies)
              FROM albums
              WHERE release_year = 2000)
WHERE release_year = 2000