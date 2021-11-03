from mimesis import Person, Address, Datetime
from mimesis.enums import Gender
from faker import Faker
from random import randint
import random
import requests

address = Address()
fake = Faker()
gender = [Gender.FEMALE, Gender.MALE, "f", "m"]

#generate random words
word_site = "https://www.mit.edu/~ecprice/wordlist.10000"
response = requests.get(word_site)
words = response.content.splitlines()
random.shuffle(words)

singing_voices = ['soprano', 'mezzo-soprano', 'contralto', 'tenor', 'baritone', 'bass']
instruments = ['violin', 'guitar', 'drums', 'synthesizer', 'pipe', ]
genre = ['folk', 'country', 'jazz', 'blues', 'hip-hop', 'rock', 'pop', 'electronic music',
         'metal', 'serenade', 'romance', 'disco', 'alternative music']

class person():
    def __init__(self, key, birth_year):
        index = randint(0, 1)
        p = Person('en')
        name, surname = p.full_name(gender=gender[index]).split()
        self.key = key
        self.name = name
        self.surname = surname
        self.gender = gender[2 + index]
        self.birth_year = birth_year
        self.country = fake.country()

class musician():
    def __init__(self, key, gender, experience, music_group_id):
        random.shuffle(words)
        self.key = key
        self.experience = experience
        self.creative_pseudonym = str(words[randint(0, 9999)])[2:-1]
        offset = 0 if gender == "female" else 3
        self.singing_voice = singing_voices[offset + randint(0, 2)]
        self.instrument = instruments[randint(0, len(instruments) - 1)]
        self.music_group_id = music_group_id

class music_group():
    def __init__(self, key):
        random.shuffle(words)
        record_label = ""
        for j in range(randint(1, 5)):
            pos = randint(0, 9999)
            record_label += str(words[pos])[2:-1] + " "
        self.key = key
        self.creative_pseudonym = str(words[randint(0, 9999)])[2:-1]
        self.record_label = record_label
        self.year_of_foundation = randint(1970, 2020)
        year_of_breakup = randint(self.year_of_foundation + 1, 2021)
        i = randint(0, 1)
        self.year_of_breakup = [year_of_breakup, 2050][i]

class music_union():
    def __init__(self, key, music_group_id, song_id):
        self.key = key
        self.music_group_id = music_group_id
        self.song_id = song_id

class song():
    def __init__(self, key, album_id):
        random.shuffle(words)
        title = ""
        for j in range(randint(1, 5)):
            pos = randint(0, 9999)
            title += str(words[pos])[2:-1] + " "
        video_clip_title = ""
        for j in range(randint(1, 5)):
            pos = randint(0, 9999)
            video_clip_title += str(words[pos])[2:-1] + " "
        self.key = key
        self.title = title
        self.duration = float(str(randint(1, 10)) + "." + str(randint(0, 59)))
        self.genre = genre[randint(0, len(genre) - 1)]
        f = randint(0, 1)
        self.video_clip_title = [video_clip_title, 'null'][f]
        self.album_id = album_id

class album():
    def __init__(self, key, release_year):
        random.shuffle(words)
        title = ""
        for j in range(randint(1, 5)):
            pos = randint(0, 9999)
            title += str(words[pos])[2:-1] + " "
        self.key = key
        self.title = title
        self.release_year = release_year
        self.copies = randint(1, 100000)

LEN_GROUPS = 500
LEN_UNIONS = 1000
LEN_SONGS = 5000
LEN_PERSONS = 3000
LEN_MUSICIANS = LEN_PERSONS
LEN_ALBUMS = 2000

#Создаю рандомно группы
music_groups = [music_group(i + 1) for i in range(LEN_GROUPS)]

#Массив для связки какой человек(он же музыкант) к какой группе принадлежит
group_keys = []

#Создаю людей, особенность - они должны родиться как минимум за 15 лет до создания группы, в которую они определились
persons = []
for i in range(LEN_PERSONS):
    index = randint(0, LEN_GROUPS-1)
    group = music_groups[index]
    group_keys.append(index)
    p = person(i + 1, randint(1950, group.year_of_foundation - 15))
    persons.append(p)

#Создаю музыкантов на основе людей и групп-связок
musicians = []
for i in range(LEN_MUSICIANS):
    p = persons[i]
    g = music_groups[group_keys[i]]
    experience = 2021 - randint(p.birth_year + 10, g.year_of_foundation)
    m = musician(i + 1, p.gender, experience, g.key)
    musicians.append(m)


def check_dup(unions, group_id, song_id):
    for u in unions:
        if u.song_id == song_id and u.music_group_id == group_id:
            return True
    return False

def check_range(unions, group_id : int, song_id):
    global music_groups
    groups_in_union = []
    for u in unions:
        if u.song_id == song_id:
            groups_in_union.append(u.music_group_id-1)

    if groups_in_union:

        yf = max([music_groups[key].year_of_foundation] for key in groups_in_union)[0]
        yb = min([music_groups[key].year_of_breakup] for key in groups_in_union)[0]

        if yf <= group_id <= yb:
            return True

        return False

    return True

def find_key(unions, song_id):
    for u in unions:
        if u.song_id == song_id:
            return u.key
    return None

#Создаю музыкальные объединения
#Все группы в объединении должны иметь общий временной отрезок
music_unions = []
key = 1
for i in range(LEN_UNIONS):
    group_id = randint(1, LEN_GROUPS)
    song_id = randint(1, LEN_SONGS)

    #Не должно быть дупликатов и должен быть один временной промежуток
    while (check_dup(music_unions, group_id, song_id) == True) or (check_range(music_unions, group_id, song_id) == False):
        group_id = randint(1, LEN_GROUPS)
        song_id = randint(1, LEN_SONGS)

    i = find_key(music_unions, song_id)
    if i is None:
        i = key
        key += 1

    m = music_union(i, group_id, song_id)
    music_unions.append(m)


albums = []
for i in range(LEN_ALBUMS):
    union_key = randint(1, LEN_UNIONS)

    groups_in_union = []
    for union in music_unions:
        if union.key == union_key:
            groups_in_union.append(union.music_group_id-1)

    a1 = max([music_groups[key].year_of_foundation for key in groups_in_union])

    #a2 = min([music_groups[key].year_of_breakup for key in groups_in_union])
    a2 = 2021
    for key in groups_in_union:
        if music_groups[key].year_of_breakup <= 2021:
            if a2 > music_groups[key].year_of_breakup:
                a2 = music_groups[key].year_of_breakup

    print(a1, a2)
    release_year = randint(a1, a2)
    a = album(i + 1, release_year)
    albums.append(a)

songs = []
for i in range(LEN_SONGS):
    album_id = randint(1, LEN_ALBUMS)
    s = song(i + 1, album_id)
    songs.append(s)

for i in range(LEN_GROUPS):
    if music_groups[i].year_of_breakup == 2050:
        music_groups[i].year_of_breakup = 'null'

f = open("data/persons.txt", "w")
for person in persons:
    line = "{0},{1},{2},{3},{4}\n".format(person.name,
                                              person.surname,
                                              person.gender,
                                              person.birth_year,
                                              person.country)
    f.write(line)
f.close()

f = open("data/musicians.txt", "w")
for musician in musicians:
    line = "{0},{1},{2},{3},{4}\n".format(musician.creative_pseudonym,
                                          musician.experience,
                                          musician.singing_voice,
                                          musician.instrument,
                                          musician.music_group_id)
    f.write(line)
f.close()

f = open("data/music_groups.txt", "w")
for group in music_groups:
    line = "{0},{1},{2},{3}\n".format(group.creative_pseudonym,
                                      group.year_of_foundation,
                                      group.year_of_breakup,
                                      group.record_label)
    f.write(line)
f.close()

f = open("data/songs.txt", "w")
for song in songs:
    line = "{0},{1},{2},{3},{4}\n".format(song.title,
                                                          song.duration,
                                                          song.genre,
                                                          song.video_clip_title,
                                                          song.album_id)
    f.write(line)
f.close()

f = open("data/albums.txt", "w")
for album in albums:
    line = "{0},{1},{2}\n".format(album.title, album.release_year, album.copies)
    f.write(line)
f.close()

f = open("data/music_unions.txt", "w")
for union in music_unions:
    line = "{0},{1}\n".format(union.music_group_id, union.song_id)
    f.write(line)
f.close()