--1.
--Из таблиц базы данных, созданной в первой лабораторной работе, извлечь данные в JSON.
\o persons.json
SELECT ROW_TO_JSON(persons) FROM persons;

\o musicians.json
SELECT ROW_TO_JSON(musicians) FROM musicians;

\o songs.json
SELECT ROW_TO_JSON(songs) FROM songs;

\o albums.json
SELECT ROW_TO_JSON(albums) FROM albums;

\o music_groups.json
SELECT ROW_TO_JSON(music_groups) FROM music_groups;

\o music_unions.json
SELECT ROW_TO_JSON(music_unions) FROM music_unions;
