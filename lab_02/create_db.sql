CREATE DATABASE music;

\c music;  

CREATE TABLE music_groups(id SERIAL PRIMARY KEY,
                         creative_pseudonym varchar(100),
                         year_of_foundation INTEGER NOT NULL, 
                         year_of_breakup INTEGER DEFAULT NULL, 
                         record_label varchar(100)
);

CREATE TABLE persons(id SERIAL PRIMARY KEY,
                    name VARCHAR(100) NOT NULL,
                    surname VARCHAR(100) NOT NULL,
                    gender CHAR(1) NOT NULL,
                    birth_year INTEGER,
                    country VARCHAR(100)
                    CHECK (gender in ('f', 'm'))
                    CHECK (birth_year > 1900)
);

CREATE TABLE musicians(id SERIAL PRIMARY KEY,
                       creative_pseudonym VARCHAR(100),
                       experience INTEGER,
                       singing_voice VARCHAR(100),
                       instrument VARCHAR(100),
                       music_group_id INTEGER,
                       CHECK (experience > 0),
                       FOREIGN KEY (music_group_id) REFERENCES music_groups (id)
);

ALTER TABLE musicians
    ADD FOREIGN KEY (id) REFERENCES persons(id)
    ON DELETE CASCADE;

CREATE TABLE albums(id SERIAL PRIMARY KEY,
                    title VARCHAR(100) NOT NULL,
                    release_year INTEGER NOT NULL,
                    copies INTEGER,
                    CHECK (release_year > 1969),
                    CHECK (copies > 0)
);

CREATE TABLE songs(id SERIAL PRIMARY KEY,
                  title VARCHAR(100) NOT NULL,
                  duration FLOAT NOT NULL,
                  genre VARCHAR(100) NOT NULL,
                  video_clip_title VARCHAR(100),
                  album_id INTEGER,
                  FOREIGN KEY (album_id) REFERENCES albums (id)
);

CREATE TABLE music_unions(id SERIAL PRIMARY KEY,
                        music_group_id INTEGER,
                        song_id INTEGER,
                        FOREIGN KEY (music_group_id) REFERENCES music_groups (id),
                        FOREIGN KEY (song_id) REFERENCES songs (id)
);

COPY music_groups(creative_pseudonym, year_of_foundation, year_of_breakup, record_label) 
FROM '/home/polina/db/bmstu_db/lab_02/data/music_groups.txt' delimiter ',' csv NULL AS 'null';

COPY persons(name, surname, gender, birth_year, country) FROM
 '/home/polina/db/bmstu_db/lab_02/data/persons.txt' delimiter ',' csv;

COPY musicians(creative_pseudonym, experience, singing_voice, instrument, music_group_id) 
FROM '/home/polina/db/bmstu_db/lab_02/data/musicians.txt' delimiter ',' csv;

COPY albums(title, release_year, copies) 
FROM  '/home/polina/db/bmstu_db/lab_02/data/albums.txt' delimiter ',' csv;

COPY songs(title, duration, genre, video_clip_title, album_id) 
FROM  '/home/polina/db/bmstu_db/lab_02/data/songs.txt'  delimiter ',' csv NULL AS 'null';

COPY music_unions(music_group_id, song_id) 
FROM '/home/polina/db/bmstu_db/lab_02/data/music_unions.txt' WITH (FORMAT csv);