--21. Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE. 
--Удаление сведений о музыкантах, чья группа уже распалась
DELETE
FROM musicians
WHERE music_group_id IN (SELECT id
                        FROM music_groups
                        WHERE year_of_breakup IS NOT NULL)