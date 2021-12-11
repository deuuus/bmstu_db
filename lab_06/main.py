import psycopg2

con = psycopg2.connect(
    database="music", 
    user="postgres", 
    password="qpzfka111", 
    host="0.0.0.0", 
    port="5433"
)

print("Подключение к базе данных произошло успешно.")

def choose_action():
    print()
    print("1) Выполнить скалярный запрос.")
    print("2) Выполнить запрос с несколькими соединениями (JOIN).")
    print("3) Выполнить запрос с ОТВ и оконными функциями.")
    print("4) Выполнить запрос к метаданным.")
    print("5) Вызвать скалярную функцию из ЛР3.")
    print("6) Вызвать многооператорную функцию из ЛР3.")
    print("7) Вызвать хранимую процедуру из ЛР3.")
    print("8) Вызвать системную функцию или процедуру.")
    print("9) Создать таблицу в базе данных, соответствующую тематике БД.")
    print("10) Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT или COPY.")
    print("11) Защита: вывести все песни музыканта по его имени")
    print("12) Выход.")
    print()
    print("Ваш ответ: ", end="")
    return int(input())

cur = con.cursor()
action = choose_action()
while (action != 12):

    if action == 1:
      cur.execute("select avg(duration) as avg from songs")
      rows = cur.fetchall()
      print()
      print("Запрос выводит среднюю продолжительность песни среди всех песен из базы.")
      print("Результат запроса: ", "%.2f минут" % rows[0][0])
      con.commit()

    if action == 2:
      cur.execute("select name, surname, creative_pseudonym, singing_voice from persons P join musicians M on P.id = M.id where P.id <= 10")
      rows = cur.fetchall()
      print()
      print("Запрос выводит записи вида <Имя, Фамилия, Творческий псевдоним, певческий голос> для первых 10 музыкантов из базы.")
      print("Результат запроса: ")
      print()
      for row in rows:
        print("Имя: {:10} Фамилия: {:10} Творческий псевдоним: {:10} Певческий голос: {:10}".format(row[0], row[1], row[2], row[3]))
      con.commit()
    
    if action == 3:
      print()
      print("Запрос выводит для первых 20 музыкантов из базы записи вида <>ид-р музыканта, опыт, возраст, средний опыт среди возрастной группы>.")
      print()
      cur.execute("with cte(m_id, experience, age) as (select M.id, M.experience, 2021 - P.birth_year from musicians M join persons P on M.id = P.id where P.id < 20) "
                  "select m_id, experience, age, AVG(experience) OVER(PARTITION BY age) from cte;")
      rows = cur.fetchall()
      for row in rows:
        print("Ид-р музыканта: {:5} Опыт {:5} Возраст: {:5}  Средний опыт среди возрастной группы: {:5}".format(row[0], row[1], row[2], int(row[3])))
      con.commit()
      pass

    if action == 4:
      cur.execute("select pg.oid, pg.datconnlimit, pg.datdba from pg_database pg where pg.datname = 'music';")
      rows = cur.fetchall()
      print()
      print("Запрос выводит запись вида <DB row id, DB max connections, Owner id> для базы.")
      print("Результат запроса: ")
      for row in rows:
        print("DB row id: ", row[0], ", DB max connections: ", row[1], ", Owner id: ", row[2], sep="")
      con.commit()

    if action == 5:
      cur.execute("select id, activity_years(id) as a from music_groups where id < 5;")
      rows = cur.fetchall()
      print()
      print("Запрос выводит количество лет активности для музыкальной группы, определяемой ее номером,  для первых 4 групп из базы.")
      print("Результат запроса: ")
      print()
      for row in rows:
        print("music_group id: {:10} activity years: {:10}".format(row[0], row[1]))
      con.commit()

    if action == 6:
      cur.execute("select * from get_women_from_yearliest_groups() order by group_title, age;")
      rows = cur.fetchall()
      print()
      print("Запрос выводит информацию о женщинах, которые входили в состав групп, которые образовались в год создания самой ранней группы.")
      print("Результат запроса: ")
      for row in rows:
        print("Имя: {:10} Фамилия: {:10} Возраст: {:10} Пол: {:10} Название группы: {:10} Год создания группы: {:10}".format(row[0], row[1], row[2], row[3], row[4], row[5]))
      con.commit()

    if action == 7:
      cur.execute("call update_copies(1.01);")
      print()
      print("Запрос обновляет тираж альбомов в соответствии с указанным коэффициентом.")
      print("Запрос выполнен.")
      con.commit()

    if action == 8:
      cur.execute("SELECT * FROM version();")
      rows = cur.fetchall()
      print()
      print("Запрос выводит информацию о версии PostgreSQL.")
      print("Результат запроса: ", rows[0][0], sep='')
      con.commit()    

    if action == 9:
      cur.execute("drop table music_orders; create table music_orders(id serial primary key, name varchar not null, buyer_id integer not null, date timestamp not null,"
                  "foreign key (buyer_id) references persons(id));")
      print()
      print("Запрос создает таблицу покупок в музыкальном магазине с полями <название товара, ид-р покупателя, дата покупки>.")
      print("Таблица создана.")
      con.commit()

    if action == 10:
      cur.execute("delete from music_orders; "
                  "insert into music_orders(name, buyer_id, date) values('mediator', 5, '2021-09-03');"
                  "insert into music_orders(name, buyer_id, date) values('piano', 7, '2021-08-03');"
                  "insert into music_orders(name, buyer_id, date) values('headphones', 10, '2021-07-03');"
                  "insert into music_orders(name, buyer_id, date) values('microphone', 2, '2021-06-03');"
                  "insert into music_orders(name, buyer_id, date) values('guitar', 5, '2021-05-03');")
      print()
      print("Произведена вставка значений в таблицу music_orders. Таблица:")
      print()
      con.commit()
      cur.execute("select * from music_orders;")
      rows = cur.fetchall()
      for row in rows:
        print("Название товара: {:10} Ид-р покупателя: {:5} Дата покупки: {:10}".format(row[1], row[2], str(row[3])))
      con.commit()

    if action == 11:
      cur.execute('WITH CTE AS'
                '('
                '  SELECT U.song_id, G.id AS "g_id"'
                '  FROM music_groups G JOIN music_unions U ON G.id = U.music_group_id'
                '),'
                'ms AS'
                '('
                '    SELECT M.id AS "m_id", CTE.song_id'
                '    FROM CTE JOIN musicians M ON CTE.g_id = M.music_group_id'
                '    WHERE M.id = 5'
                ') '
                'SELECT name, surname, S.title '
                'FROM (ms JOIN persons P ON ms.m_id = P.id) MP JOIN songs S ON MP.song_id = S.id;')
      rows = cur.fetchall()
      for row in rows:
        print("Имя: {:10} Фамилия: {:5} Название песни: {:10}".format(row[0], row[1], row[2]))
      con.commit()
              

    action = choose_action()

con.close()