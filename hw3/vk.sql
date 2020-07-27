-- соц.сеть vk База Данных

drop database if exists vk;
create database vk;
use vk; 

create table users(
	id bigint unsigned not null auto_increment primary key, 
	firstname varchar(100) comment 'имя пользователя',
	lastname varchar(100) comment 'фамилия пользователя',
	email varchar(100) unique,
	password_hash varchar(100), 
	phone bigint unsigned unique,
	index id_user(lastname, firstname)	
) comment 'пользователи';

-- 1 to 1 
drop table if exists ´profiles´;
create table ´profiles´( 
	user_id bigint unsigned not null primary key,
	gender char(1),
	hometown varchar(100),
	created_at datetime default now()
) ;
-- с помощью alter table можно добавить внешний ключ profiles к  например:
alter table ´profiles´ add constraint fk_profiles_user_id
foreign key (user_id) references users(id) 
on update cascade
on delete restrict;
-- добавим колонку birthday
alter table ´profiles´ add column birthday date;
-- потом переименовали ради теста
alter table ´profiles´ rename column birthday to date_of_birth;
-- можно так же и удалить колонку
alter table ´profiles´ drop column date_of_birth;
-- возвращаем все как было (можно было просто закоментить, но как то пох): 
alter table ´profiles´ add column birthday date;

-- 1 to M
/* напр. сообщения, индивидуальные сообщения для начала:
 * пользователь - пользователь: id --> зависимость отправитель 1 ко многим 
 * между user - messages*/
drop table if exists messages;
create table messages( 
	id serial, -- у сообщений есть свой собственный номер
	-- нужно хранить и отправителя и получателя
	from_user_id bigint unsigned not null, --  отправитль, должен повторять поведение id колонки users
	to_user_id bigint unsigned not null, -- получатель, и такое же поведение
	body text comment 'тело сообщения', 
	created_at datetime default now() comment 'дата создания сообщений',
	-- так же их надо снабдить внешними ключами эти 2 поля
	foreign key (from_user_id) references users(id),
	foreign key (to_user_id) references users(id)
);

drop table if exists friend_requests;
create table friend_requests (
	-- здесь так же понадобятся id пользователей:
	initiator_user_id bigint unsigned not null comment 'от кого', 
	target_user_id bigint unsigned not null comment 'кому',
	created_at datetime default now() comment 'когда было отправлен запрос',
	updated_at datetime on update current_timestamp comment 'обновление изменений',
	-- так же внешние ключи:
	foreign key (initiator_user_id) references users(id),
	foreign key (target_user_id) references users(id),
	primary key (initiator_user_id, target_user_id),
	-- check(initiator_user_id != target_user_id) comment 'исключает запрос самому себе', 
	-- тип данных для статуса:
	status enum('requested', 'approved', 'unfruended', 'declined')
	
);
-- поле check запишем через alter table:
alter table friend_requests
add check(initiator_user_id <> target_user_id);

-- community таблица

drop table if exists communities;
create table communities(
	id serial, 
	name varchar(200) comment 'название community',
	admin_user_id bigint unsigned not null comment 'информация о админе', -- для внешнего ключа
	foreign key (admin_user_id) references users(id),
-- так как скорее всего будет поиск происходить по имени то можно его проиндексировать
	index (name)
);

-- M to M
drop table if exists users_communities;
create table users_communities( 
	user_id bigint unsigned not null,
	community_id bigint unsigned not null,
	foreign key (community_id) references communities(id),
	foreign key (user_id) references users(id),
	primary key (user_id, community_id) -- что бы не дублировать информацию о принадлежности к сообществу
) comment 'для храниния информации пользователей в групах';

-- таблица контент-пользователей:
drop table if exists media_types;
create table media_types ( 
	id serial,
	name varchar(255)
) comment 'для учебных целей табличка с типами контанта';

drop table if exists media;
create table media(
	id serial,
	user_id bigint unsigned not null comment 'идентификатор пользователя создавшего контент',
	foreign key (user_id) references users(id),
	body text, 
	-- file blob, -- для хранения контента(видео, фото, музыка) в массиве байтов, однако затратно по памяти.
	-- будем хранить путь к файлу в колонке, но сам файл будет хранится например на другом серваке.
	filename varchar(255) comment 'название файла контента',
	metadata JSON comment 'метаданные файла', -- так как метаданные бывают разные сложно их разбить на таблички.
	-- media_type enum ('text', 'video', 'music', 'image') comment 'тип контента', -- для учебных целей будет создана табличка с типами
	-- вместо media_type enum будет ссылочка в таблицу (внешний ключ)
	media_type_id bigint unsigned not null, 
	foreign key (media_type_id) references media_types(id), -- внешний ключ
	created_at datetime default now()
);

drop table if exists likes;
create table likes (
	id serial,
	user_id bigint unsigned not null, -- пользователь поставивший лайк
	media_id bigint unsigned not null, -- запись которую лайкнули
	created_at datetime default now(),
	foreign key (media_id) references media(id),
	foreign key (user_id) references users(id)
) comment 'лайки к контенту';




