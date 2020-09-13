/* Проект интернет-магазина и шиномонтажа.
 * описание разбито на таблицы
 * Магазин выполнает как закупку, так и продажу запчастей и колес
 * также является мастерской со своим персоналом.
 */

drop database if exists Project_shop;
create database Project_shop;
use Project_shop;



drop table if exists shop_catalog;
create table shop_catalog (
	id int unsigned not null auto_increment primary key COMMENT 'ID разделов', 
	name varchar(100) not null unique COMMENT 'название разделов'
) comment 'каталог товаров магазина';


drop table if exists products;
create table products (
	product_id bigint unsigned not null auto_increment primary key comment 'ID родукта',
	catalog_id int unsigned not null comment 'ID каталога',
	product_name varchar(100) not null comment 'название продукта',
	description varchar(255) comment 'описание доп.информации продукта',
	product_price decimal(11,2) comment 'цена продукта для клиента',
	created_at datetime default current_timestamp comment 'дата добавления',
	updated_at datetime default current_timestamp on update current_timestamp comment 'дата обновления',
	foreign key (catalog_id) references Project_shop.shop_catalog(id) on update cascade on delete restrict,
	index(product_name)
) comment 'товары';

drop table if exists discounts; 
create table discounts(
	category_id int unsigned not null comment 'ID каталога',
 	product_id  bigint unsigned not null comment 'ID родукта',
	discount_name varchar(50) default null comment 'название акций',
	`discount %` tinyint default null comment 'скидка в процентах',
	starts_at datetime comment 'начало акции',
	ends_at datetime comment 'окончание акции',
	foreign key (product_id) references Project_shop.products(product_id) on update cascade on delete restrict,
	foreign key (category_id) references Project_shop.products(catalog_id) on update cascade on delete restrict
) comment 'акции';

drop table if exists clients;
create table clients (
	client_id bigint unsigned not null auto_increment primary key COMMENT 'ID клиента (выдается автоматически)',
	firstname varchar(50) not null comment 'Имя (обязательно)',
	lastname varchar(50) not null comment 'Фамилия (обязательно)',
	address varchar(100) default null comment 'адрес (не обязателен)',
	email varchar(100) default null unique comment 'email (не обязателен)',
	phone bigint unsigned default null unique comment 'телефон не обзательно',
	client_type enum('new', 'regular', 'privileged', 'company') default 'new' comment 'тип клиентов магазина',
	`date` date default null comment 'дата (не обязательно)',
	index client_full_name (firstname, lastname)
) comment 'клиенты магазина';

drop table if exists providers;
create table providers (
	provider_id bigint unsigned not null auto_increment primary key,
	provider_name varchar(255) comment 'имя постовщика',
	product_type varchar(100) comment 'тип поставляемой продукции',
	product_description varchar(255) default null comment 'описание постовляемых товаров', 
	provider_country varchar(50) comment 'страна производителя',
	addet_at datetime default current_timestamp comment 'дата добавления'
) comment 'поставщики продукции';

drop table if exists external_orders;
create table external_orders (
	order_id bigint unsigned not null auto_increment primary key,
	client_id bigint unsigned not null,
	product_name varchar(100) not null comment 'название продукта',
	ordered_at datetime default current_timestamp comment 'дата заказа',
	delivered_at datetime comment 'дата доставки заказа',
	total_price decimal(11,2) comment 'общая цена заказа',
	foreign key (client_id) references Project_shop.clients(client_id) on update cascade on delete restrict,
	foreign key (product_name) references Project_shop.products(product_name) on update cascade on delete restrict
) comment 'заказы частных клиентов';

drop table if exists internal_orders;
create table internal_orders (
	order_id bigint unsigned not null auto_increment primary key,
	provider_id bigint unsigned not null comment 'ID постовщика', 
	product_id bigint unsigned not null comment 'ID ппродукта',
	ordered_at datetime default current_timestamp comment 'дата заказа',
	delivered_at date comment 'дата доставки заказа',
	total_price decimal(11,2) comment 'общая цена заказа',
	foreign key (provider_id) references Project_shop.providers(provider_id) on update cascade on delete restrict,
	foreign key (product_id) references Project_shop.products(product_id) on update cascade on delete restrict
) comment 'внутренние заказы компании';

drop table if exists staff;
create table staff( 
	staff_id bigint unsigned not null auto_increment primary key  comment 'ID персонала',
	firstname varchar(100) not null  comment 'имя',
	lastname varchar(100) not null  comment 'фамилия', 
	`position` varchar(100) not null  comment 'должность сотрудника',
	is_active enum ('true', 'false') default 'true'  comment 'сотрудник (работает / не работает)', 
	is_manager enum ('true', 'false') default 'false' comment 'права менеджера (да / нет)',
	started_at datetime default current_timestamp comment 'начал работать', 
	finished_at date default null comment 'закончил работать',
	index (lastname),
	index (firstname)
) comment 'рабочий персонал';

drop table if exists staff_account;
create table staff_account (
	staff_id bigint unsigned not null primary key comment 'ID рабочего',
	photo_id int comment 'ID фотографии',
	firstname varchar(100) not null  comment 'имя',
	lastname varchar(100) not null  comment 'фамилия',
	birthday_at date not null comment 'дата рождения',
	gender CHAR(1) comment 'пол',
	full_address varchar(255) not null  comment 'полный адрес',
	zip_code int unsigned not null  comment 'почтовый номер',
	city varchar(100) not null  comment 'город проживания',
	foreign key (staff_id) references Project_shop.staff(staff_id) on update cascade on delete restrict,
	foreign key (firstname) references Project_shop.staff(firstname) on update restrict on delete restrict,
	foreign key (lastname) references Project_shop.staff(lastname) on update restrict on delete restrict
) comment 'рабочие аккаунты';

drop table if exists holidays;
create table holidays (
	worker_id bigint unsigned not null primary key comment 'ID рабочего',
	worker_name varchar(100) not null  comment 'имя',
	worker_lastname varchar(100) not null comment 'фамилия',
	at_holiday enum ('true', 'false') default 'false' comment 'находится в отпуске (да / нет)',
	days tinyint unsigned default null comment 'колличество дней',
	started_at date default null comment 'начало отпуска',
	finished_at date comment 'окончание отпуска', 
	foreign key (worker_id) references Project_shop.staff(staff_id) on update cascade on delete restrict,
	foreign key (worker_name) references Project_shop.staff(firstname) on update cascade on delete restrict,
	foreign key (worker_lastname) references Project_shop.staff(lastname) on update cascade on delete restrict
) comment 'отпуска';

drop table if exists jobs;
create table jobs (
	job_id bigint unsigned not null primary key comment 'ID сервиса',
	job_description text not null comment 'описание сервиса',
	used_spare_parts text not null comment 'используемые запчасти',
	job_status enum('done','in process', 'waiting for spare parts', 'not started') default 'not started' comment 'состояние работы (сделано, в процессе, ожидание запчастей, не начато)',
	started_at datetime default current_timestamp comment 'сервис начат',
	updated_at datetime default current_timestamp on update current_timestamp comment 'обновление статуса сервиса',
	worker_id bigint unsigned not null comment 'ID работника',
	customer_id bigint unsigned not null comment 'ID клиента', 
	customer_phone bigint unsigned default null unique comment 'телефон клиента',
	foreign key (worker_id) references Project_shop.staff(staff_id),
	foreign key (customer_id) references Project_shop.clients(client_id),
	foreign key (customer_phone) references Project_shop.clients(phone)
) comment 'Сервисные работы';











