/* Практическое задание по теме “Операторы, фильтрация, сортировка и ограничение
”Агрегация данных”. Работа с БД vk и данными, которые генерировали ранее: */
use vk;
/* 1.Пусть задан некоторый пользователь. Из всех пользователей соц. сети найдите человека, 
который больше всех общался с выбранным пользователем.*/
-- выбираем целевого пользователя - 1
select from_user_id as Person_id,
(select concat(firstname,' ', lastname) from users where id = messages.from_user_id) as Person,
 to_user_id as Target_id, 
(count(from_user_id)) as totalmessages
from messages 
where to_user_id = 1   -- целевой пользователь
group by from_user_id
order by totalmessages desc
limit 1;  -- ограничевание выборки 

-- 2.Подсчитать общее количество лайков, которые получили пользователи младше 10 лет..
use vk;

select 
count(media_id) as likes_total, 
 -- возраст пользователя младше 10 лет:
(select timestampdiff(year, birthday, now()) as age from profiles where user_id = likes.media_id having age < 10 ) as User_age,
(select concat(firstname, ' ', lastname) from users where media_id = users.id) as User_full_name -- имя пользователя младше 10 лет
from likes 
where media_id in (select user_id from profiles where timestampdiff(year, birthday, now()) < 10 ) -- пользователи младше 10 лет
group by media_id;


-- 3.Определить кто больше поставил лайков (всего): мужчины или женщины.
select media_id as content_id, count(user_id) as likes_total,  
case(select gender from profiles where user_id = likes.user_id) 
		when 'm' then 'mans'
		when 'f' then 'womans'
	end as 'gender',
group_concat(user_id) as Likes_from_users_id
from likes
group by media_id 


