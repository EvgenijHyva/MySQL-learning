/* 2. Создайте базу данных example, разместите в ней таблицу users, 
 * состоящую из двух столбцов, числового id и строкового name.*/

create database if not exists example;
use example;
create table if not exists users (
	id int unsigned, 
	name varchar(255)
);
-- проверка:
show tables; 
describe users;

