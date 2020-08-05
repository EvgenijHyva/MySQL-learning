/* Пусть в таблице users поля created_at и updated_at оказались незаполненными. 
Заполните их текущими датой и временем.*/
update users set created_at = current_timestamp , updated_at = current_timestamp;

/*2 Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы типом 
 VARCHAR и в них долгое время помещались значения в формате "20.10.2017 8:10". Необходимо 
 преобразовать поля к типу DATETIME, сохранив введеные ранее значения. */
use shop;
-- после анализа строки, нужно обновить дату на формат "%d.%m.%Y %k:%i"
select str_to_date(updated_at, "%d.%m.%Y %k:%i") from users;
update users set updated_at = str_to_date(updated_at, "%d.%m.%Y %k:%i"), created_at = str_to_date(created_at, "%d.%m.%Y %k:%i" );
-- после обновления формата, можно обновить колонки в правильный тип datetime
alter table users modify created_at datetime;
alter table users modify updated_at datetime;

/*3 В таблице складских запасов storehouses_products в поле value могут встречаться самые разные 
 цифры: 0, если товар закончился и выше нуля, если на складе имеются запасы. Необходимо 
 отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value.
 Однако, нулевые запасы должны выводиться в конце, после всех записей. */
select value from storehouses_products order by value=0, value;

/* (по желанию) Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. 
 Месяцы заданы в виде списка английских названий ('may', 'august') */
select * from users where monthname(birthday_at) in ('august', 'may') ;

/* (по желанию) Из таблицы catalogs извлекаются записи при помощи запроса. SELECT * FROM 
 catalogs WHERE id IN (5, 1, 2); Отсортируйте записи в порядке, заданном в списке IN. */
SELECT * FROM catalogs WHERE id IN (5, 1, 2) order by field (id, 5, 1, 2);

-- Практическое задание теме “Агрегация данных”
/* 1 Подсчитайте средний возраст пользователей в таблице users */
select count(name) as 'group', group_concat(name) as 'names', year(now())-year(birthday_at) as age from users group by age;
select round(avg(year(now()) - year(birthday_at))) as 'users-average-age' from users;

/* 2 Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели.
 Следует учесть, что необходимы дни недели текущего года, а не года рождения. */
select count(name) as количество, group_concat(name, ' ', year(now())-year(birthday_at) +1) as 'имя + возраст', 
substring(date_format(concat(year(now()),'.',date_format(birthday_at, '%m.%d.')), '%W'), 1,3) as день 
from users group by день;

-- 3 (по желанию) Подсчитайте произведение чисел в столбце таблицы

