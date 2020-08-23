/* Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. С 6:00 до 
12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", с 18:00 до
00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи". */
use shop;
select time(now());

-- так как на моем сервере переменная была выключена нельзя было использовать not deterministic в функции
show variables like 'log_bin_trus%';
set global log_bin_trust_function_creators = 1; 

drop function if exists hello;
delimiter // 
create function hello()
returns tinytext not deterministic
begin
	declare h time;
	set h = time(now());
	case
		when h between '00:00:01' and '06:00:00' then 
		return 'Доброй ночи';
		when h between '06:00:01' and '12:00:00' then 
		return 'Доброе утро';
		when h between '12:00:01' and '18:00:00' then 
		return 'Добрый день';
		when h between '18:00:01' and '00:00:00' then 
		return 'Добрый вечер';
	end case;
end//

select hello(), now();

/* В таблице products есть два текстовых поля: name с названием товара и description с его описанием. Допустимо присутствие обоих 
полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. Используя триггеры, добейтесь
того, чтобы одно из этих полей или оба поля были заполнены. При попытке присвоить полям NULL-значение необходимо отменить операцию. */

select name, description from products; 
drop trigger if exists cancel_insertion;
delimiter //
create trigger cancel_insertion before insert on products
for each row
begin 
	if new.name is null and new.description is null then 
		signal sqlstate '45000'
		set message_text = 'Insertion canceled, fields name and description is empty';
	end if;
end//

drop trigger if exists cancel_update;
delimiter //
create trigger cancel_update before update on products
for each row 
begin 
	if new.name is null and new.description is null then 
		signal sqlstate '45000'
		set message_text = 'Update canceled, field name and description is empry';
	end if;
end//

show triggers;
insert into products (name, description) values ('test', null);
insert into products (name, description) values (null, null);
delete from products where name = 'test';

start transaction; -- пробую обновить с помощью транзакции
update products set name = null where id = 2; -- успешно обновилось
update products set name = null, set description = null where id = 1; -- так как 2 поля установлены в null срабатывает триггер
select * from products; 
rollback; 
select * from products;


/* (по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. Числами Фибоначчи называется 
последовательность в которой число равно сумме двух предыдущих чисел. Вызов функции FIBONACCI(10) должен возвращать число 55. */
-- функция Бине
drop function if exists fibonacci;
delimiter //
create function fibonacci (num int)
returns bigint deterministic
begin
	declare n double;
	set num = sqrt(5);
	return (pow((1+n) / 2.0, num) + pow((1-n) / 2.0, num)) / n;
end//

select fibonacci(10);





















