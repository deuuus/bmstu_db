--2.
-- Выполнить загрузку и сохранение JSON файла в таблицу.
-- Созданная таблица после всех манипуляций должна соответствовать таблице базы данных, созданной в первой лабораторной работе.
DROP TABLE IF EXISTS json_data;
CREATE TABLE json_data
(
    data json
);

\COPY json_data from 'albums.json';

DROP TABLE IF EXISTS json_albums;
CREATE TABLE json_albums(id SERIAL PRIMARY KEY,
                    title VARCHAR(100) NOT NULL,
                    release_year INTEGER NOT NULL,
                    copies INTEGER,
                    CHECK (release_year > 1969),
                    CHECK (copies > 0)
);

INSERT INTO json_albums(title, release_year, copies)
SELECT data->>'title', (data->>'release_year')::INTEGER, (data->>'copies')::INTEGER
FROM json_data;

DROP TABLE json_data;