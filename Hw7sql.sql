/* 1. Составьте список пользователей users, которые осуществили хотя бы один заказ orders 
 * в интернет магазине.*/
use shop;
-- добавим внешний ключ в таблицу orders (user_id) 
alter table orders 
change user_id user_id bigint unsigned not null,
add constraint fk_user_id
foreign key (user_id) references users(id);

-- после обновим таблицу orders пользователями
insert into orders (user_id) values 
((select id from users where name like '%сандр')), ((select id from users where name like '_ван')),
((select id from users where name like '%са%')), ((select id from users where name = 'Мария'))

-- список пользователей которые осуществивили хотябы 1 заказ:
select u.name, u.id as user_id , u.birthday_at, count(o.user_id) as Total_orders
from users as u
right join orders as o 
on o.user_id = u.id
group by o.user_id 
order by Total_orders desc; 

/* 2. Выведите список товаров products и разделов catalogs, который соответствует товару. */
-- список товаров по разделу товара процессоры: 
select p.name, c.name 
from products as p 
join catalogs as c 
on p.catalog_id = c.id 
where c.name like '%оцессор%';


/* 3. (по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities 
 (label, name). Поля from, to и label содержат английские названия городов, поле name — русское.
 Выведите список рейсов flights с русскими названиями городов. */
-- создаем БД 
drop database if exists air;
create database air;
use air;
create table if not exists fligths (
	flights_id serial,
	¨From¨ varchar(100) not null, 
	¨To¨ varchar(100) not null,
	index rout_from (¨From¨,¨To¨),
	index rout_to (¨To¨,¨From¨)
) comment 'полеты';
create table if not exists cities (
	citi_id serial,
	label varchar(100) not null primary key,
	name varchar(100) not null
) comment 'города';
-- заполняем таблицу
insert into fligths (¨From¨,¨To¨) values 
( 'moscow', 'omsk'),('novgorod','kazan'),('irkutsk', 'moscow'),('omsk','irkutsk'),('moscow','kazan');
insert into cities (label, name) values 
('moscow','Москва'),('irkutsk','Иркутск'),('novgorod','Новгород'),('kazan','Казань'),('omsk','Омск');

-- Теперь можно вывести список рейсов с русскими названиями городов:
-- с вложенными запросами:
select fligths.flights_id as Flight_id, 
(select cities.name from cities where cities.label = fligths.¨From¨) as 'From', 
(select cities.name from cities where cities.label = fligths.¨To¨) as 'To' from fligths
order by flights_id 
