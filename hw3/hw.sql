use vk;

drop table if exists wallet;
create table wallet(
	wallet_id bigint unsigned not null primary key,
	wallet_holder_name varchar(100),
	amount decimal(4,2),
	refueled_at datetime default current_timestamp on update current_timestamp,
	foreign key (wallet_id) references users(id),
	index user_wallet(wallet_id, wallet_holder_name),
	index (amount)
) comment 'виртуальный кошелек пользователя';

drop table if exists subscriptions;
create table subscriptions(
	id bigint unsigned not null,
	name varchar(255),
	price decimal (4,2), 
	subscrited_start datetime default current_timestamp,
	subscription_end datetime,
	status enum ('expired', 'active'),
	foreign key (price) references wallet(amount),
	index (name)
) comment 'подписки';

drop table if exists user_notes;
create table user_notes(
	note_id bigint unsigned not null,
	title varchar(100),
	body text,
	created_at datetime default current_timestamp,
	updated_at datetime default current_timestamp on update current_timestamp,
	foreign key (note_id) references users(id),
	index (title)
) comment 'заметки пользователя';
