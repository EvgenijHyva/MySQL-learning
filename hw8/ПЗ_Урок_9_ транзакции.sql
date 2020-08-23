-- Практическое задание по теме “Транзакции, переменные, представления”
/* В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. Переместите запись id = 1 из таблицы 
shop.users в таблицу sample.users. Используйте транзакции. */ 

create database sample; -- создается база данных с нужной таблицей users;
use sample;
CREATE TABLE if not exists users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

use shop;
start transaction;
select * from users where id = 1; 
insert into sample.users(id, name, birthday_at, created_at, updated_at) select * from users where id = 1;
delete from users where id = 1;
select * from users; -- проверяем таблицу в shop
select * from sample.users; -- видим изменения в таблицах shop и sample
commit;

/* Создайте представление, которое выводит название name товарной позиции из таблицы products и соответствующее название 
каталога name из таблицы catalogs. */

select * from products;
select * from catalogs;
-- обьеденяем запросы
create view new_view (product_name, catalog_section, section_id) as 
select p.name, c.name, p.catalog_id from products as p join catalogs as c on p.catalog_id = c.id;
show tables; -- проверяем наличие новой таблицы new_view
select * from new_view;
drop view if exists new_view;

/* по желанию) Пусть имеется таблица с календарным полем created_at. В ней размещены разряженые календарные записи за август 
2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. Составьте запрос, который выводит полный список дат за август, 
выставляя в соседнем поле значение 1, если дата присутствует в исходном таблице и 0, если она отсутствует. */

use geekbrains;
drop table if exists august_table;
create table august_table(
	id int unsigned auto_increment primary key,
	name varchar(100),
	created_at date not null
);
insert into august_table(name, created_at) values 
(null,'2018-08-01'), (null, '2016-08-04'), (null, '2018-08-16'), (null, '2018-08-17');

select * from august_table;

create temporary table days(
	days int
);
insert  into days (days) values (0),(1),(2),(3),(4),(5),(6),(7),
(8),(9),(10),(11),(12),(13),(14),(15),(16),(17),(18),(19),(20),
(21),(22),(23),(24),(25),(26),(27),(28),(29),(30);
select * from days;
select date(date('2018-08-31')- interval days.days day) from days order by days;

select date(date('2018-08-31')- interval d.days day) as 'Дата', not isnull(a_t.created_at) as 'check', a_t.created_at
from days as d 
left join august_table as a_t
on date(date('2018-08-31')- interval d.days day) = a_t.created_at
order by 'Дата';

/* (по желанию) Пусть имеется любая таблица с календарным полем created_at. Создайте запрос, который удаляет устаревшие записи 
из таблицы, оставляя только 5 самых свежих записей. */ 
drop table if exists cal_table;
create table cal_table (
	id int unsigned auto_increment not null primary key,
	name varchar(100),
	created_at date not null 
);
insert into cal_table (created_at) values
('2020-03-02'),('2018-03-01'),('2018-03-03'),('2018-05-05'),('2018-03-07'),('2018-06-08'),('2019-03-01'),
('2015-08-01'),('2019-04-01'),('2016-03-11'),('2011-03-21'),('2018-08-21'),('2015-03-07'),('2018-03-01'),
('2011-03-01'),('2018-03-01'),('2018-03-01'),('2020-03-09'),('2018-12-07'),('2013-03-17'),('2010-07-07');
select * from cal_table order by created_at;

start transaction;
select count(*) from cal_table;
set @limiter := (select count(*) - 5 from cal_table);
select @limiter
-- динамический запрос
prepare del_rows from 'delete from cal_table order by created_at limit ?';
execute del_rows using @limiter;
select * from cal_table order by created_at; 
commit;
show tables;











