/* ii Написать скрипт, возвращающий список имен (только firstname) 
 * пользователей без повторений в алфавитном порядке */
use vk;
select distinct firstname
from users
order by firstname desc;

/* iii Написать скрипт, отмечающий несовершеннолетних пользователей как 
 * неактивных (поле is_active = false). Предварительно добавить такое поле
 * в таблицу profiles со значением по умолчанию = true (или 1) */
use vk;
alter table profiles drop is_active; 
alter table profiles add column is_active bool default true not null;

update profiles set is_active = false 
where ((year(current_date)-year(birthday)) < 18);
-- проверка:
select user_id, birthday, CURRENT_DATE as today, (year(current_date)-year(birthday)) 
as age, is_active from profiles order by is_active = false, age ASC; 
-- сортирует по 2 столбцам

/*iv. Написать скрипт, удаляющий сообщения «из будущего» (дата больше сегодняшней) */
use vk; 
delete from messages where created_at > current_date;
-- проверка 
select created_at from messages where created_at > current_date;
-- вывод будет пустой после удаления