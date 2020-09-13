-- скрипты характерных выборок (включающие группировки, JOIN'ы, вложенные таблицы);
use project_shop;

-- запрос: вся сделаная работа и работники которые ее выполнили.
select j.job_id, j.job_description, st1.staff_id as Employee_id, concat(st1.lastname,' ' ,st1.firstname) as Employee
from jobs as j
join staff st1 
on st1.staff_id = j.worker_id  
where j.job_status = 'done';

-- запрос на товары со скидкой больше 15 процентов:
select p.product_name,p.product_price from products p 
join discounts d 
on d.category_id = p.catalog_id 
where d.`discount %` > 15; 

-- Внутренние заказы больше 1500 после 2015 по убыванию.
select io.order_id,io.total_price, io.provider_id, io.ordered_at , p2.provider_name from internal_orders io
join providers p2 on p2.provider_id = io.provider_id 
where io.total_price > 1500 and year(io.ordered_at) > 2015 order by io.total_price desc;

-- обьеденение запросов на выполнение работ находящихся в статусе (in process, not started) для клиентов с флагом priority
(select concat(c.firstname, ' ' , c.lastname ) as 'Priority-client', j.job_status, concat(s2.firstname, ' ' ,s2.lastname ) as worker, j.started_at, j.updated_at 
from clients c
join jobs j on c.client_id = j.customer_id 
join staff s2 on s2.staff_id = j.worker_id 
where j.job_status like 'in process' limit 5)
union 
(select concat(c.firstname, ' ' , c.lastname ) as 'Priority-client', j.job_status, concat(s2.firstname, ' ' ,s2.lastname ) as worker, j.started_at, j.updated_at 
from clients c
join jobs j on c.client_id = j.customer_id 
join staff s2 on s2.staff_id = j.worker_id 
where j.job_status like 'not started' limit 5);

-- узнаем количество товаров и их ID в каждом разделе каталога сортированых по имени каталога
select p.catalog_id, sc.name as catalog_name, count(*) as quantity, group_concat(p.product_id) as products_ids 
from products p
join shop_catalog sc 
on sc.id = p.catalog_id 
group by p.catalog_id
order by quantity asc; 

-- количество персонала
select s.is_active, count(s.staff_id ) as persons from staff s 
group by is_active;

-- _________________________________________________________________________________________________________________________________________________________________

-- представления (минимум 2)

-- Приоритетные работы с оценкой цены запчастей
create or replace 
view Priority_jobs_with_spareparts_prices as 
select concat(c.firstname, ' ' , c.lastname ) as 'Priority-client', j.job_status, concat(s2.firstname, ' ' ,s2.lastname ) as worker, j.started_at, j.updated_at , eo.total_price 
from clients c
join jobs j on c.client_id = j.customer_id 
join staff s2 on s2.staff_id = j.worker_id 
join external_orders eo on eo.client_id = c.client_id 
where j.job_status like 'in process' and total_price > 3000;

-- Доставленные заказы для клиентов по дате доставки
create or replace view Delivered_orders as
select eo.order_id, eo.product_name, eo.delivered_at, concat(c.firstname, ' ', c.lastname, ' Tel.', c.phone ) as customer from external_orders eo
join clients c on c.client_id = eo.client_id 
order by eo.delivered_at desc limit 15;

-- список готовых работ с описанием для обзвона клиентов
create or replace algorithm = temptable
view Ready_for_client as 
select c.email, c.phone, concat(c.firstname,' ', c.lastname ) as Client, j.job_description, j.updated_at from clients c 
join jobs j on j.customer_id = c.client_id 
where j.job_status = 'done'

-- _____________________________________________________________________________________________________________________________________________________________________

-- хранимые процедуры / триггеры

-- обновление цены при добавлении значения скидки в таблицу скидок
-- Процедура создает таблицу с информацией добавленых скидок на товары одновременно обновляя цену на товар.

drop procedure if exists price_discount_update;
delimiter // 
create procedure price_discount_update (in discount_value tinyint, product_id bigint)
begin 
	if discount_value < 101 then 
	start transaction;
	update products set product_price = product_price * (100-discount_value)/100  where product_id = product_id;
	create table if not exists discounts_id 
	( product_id bigint not null, `discounts %` tinyint not null, discount_end datetime not null) comment 'дополнительная таблица для ведения учета';
	insert into discounts_id values (product_id, discount_value,(select ends_at from discounts where product_id = product_id limit 1));
	commit;
	else 
		rollback;
		signal sqlstate '45000' 
		set message_text  = 'Обновление отмененно. скида больше 100%';
	end if;
	select 'Обновление успешно, в таблице обновилась информация';
end// -- проверка ниже
/*
	select product_price from products where product_id = 1;
	call price_discount_update(144, 1); -- проценты, ID продукта
	select product_price from products where product_id = 1;
 	call price_discount_update(1, 1);
*/

-- тригер на insert запрос 
drop trigger if exists discount_check_insertion;
delimiter // 
create trigger discount_check_insertion before insert 
on discounts
for each row 
begin 
	if new.ends_at is null then
		signal sqlstate '45000' 
		set message_text  = 'Обновление отмененно. Укажите окончание скидки';
	end if;
end// -- проверка ниже
-- insert into discounts values(1,1,'testdiscount',13, now(),null)


-- триггер на обновление 
drop trigger if exists check_finished_at_for_staff;
DELIMITER //
CREATE TRIGGER check_finished_at_for_staff before update
ON staff 
FOR EACH ROW
begin 
	if (new.finished_at is null and new.is_active = 'false') then 
		set new.finished_at = current_date();
	end if;
end//
/* проверка
	select finished_at, is_active from staff;
	update staff set finished_at = null;
	select finished_at, is_active from staff; 
*/



