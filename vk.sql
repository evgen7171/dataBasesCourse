
drop database if exists vk;
create database vk;
use vk;

drop table if exists users;
create table users(
	-- serial - bigint unsigned not null auto_increment unique 
	id serial primary key, 
	firstname VARCHAR(100),
	lastname VARCHAR(100)  comment 'Фамиль',
	email VARCHAR(120) unique,
	password_hash VARCHAR(100),
	-- phone varchar(120)
	phone bigint,
	
	-- первичные ключи
	-- индексы
	-- внешние ключи

	-- index users_phone_idx(phone),
	index (phone),
	index (firstname, lastname) -- для быстрого поиска людей по ФИО
);

drop table if exists `profiles`;
create table `profiles`(
	user_id serial primary key,
	gender CHAR(1),
	birthday DATE,
	photo_id BIGINT unsigned null,
	created_at DATETIME default now()
);

alter table `profiles`
	add constraint fk_user_id
	foreign key (user_id) references users(id)
	on update cascade -- поведение на update
	on delete restrict -- поведение на delete
	
	-- cascade - автоматически будем обновлять при изменении в главной таблице ..будем из зависимой таблицы
	-- restrict (по умолчанию) - при удалении сначала будет делаться проверка на связь в зависимой таблице - запрет будет..
	-- set null - при удалении..будут в зависимой устанавливаться в null
	-- set default ...
;

drop table if exists messages;
create table messages(
	id serial primary key,
	from_user_id BIGINT unsigned not null,
	to_user_id BIGINT unsigned not null,
	body TEXT,
	created_at DATETIME default now(),
	
	index (from_user_id), -- index создается для первичного ключа
	index (to_user_id),
	foreign key (from_user_id) references users(id), -- чтобы кто не является пользователем не смог написать сообщение
	foreign key (to_user_id) references users(id)
);

drop table if exists friend_requests;
create table friend_requests(
	initiator_user_id BIGINT unsigned not null,
	target_user_id BIGINT unsigned not null,
	status ENUM('requested', 'approved', 'declined', 'unfriended'),
	requested_at DATETIME default now(),
	updated_at DATETIME,
	
	primary key (initiator_user_id, target_user_id), -- составной первичный ключ, чтобы не было одинаковых пар значений ..
	index (initiator_user_id),
	index (target_user_id),
	foreign key (initiator_user_id) references users(id),
	foreign key (target_user_id) references users(id)
);

drop table if exists communities;
create table communities(
	id serial primary key,
	name VARCHAR(150),
	
	index (name)
);

-- 1 x 1
-- 1 x M -- user-messages
-- M x M -- users-communities

drop table if exists users_communities;
create table users_communities(
	user_id BIGINT unsigned not null,
	community_id BIGINT unsigned not null,
	
	primary key (user_id, community_id), -- составной первичный ключ
	foreign key (user_id) references users(id),
	foreign key (community_id) references communities(id)
);

drop table if exists media_types;
create table media_types(
	id serial primary key,
	name VARCHAR(150),
	created_at DATETIME default now()
);


drop table if exists media;
create table media(
 id serial primary key,
 media_type_id BIGINT unsigned not null,
 user_id BIGINT unsigned not null,
 body TEXT,
 filname VARCHAR(255),
 `size` INT,
 metadata JSON,
 created_at DATETIME default now(),
 updated_at DATETIME default current_timestamp on update current_timestamp,
	
 -- primary key (id) -- так тоже можно
 index(user_id),
 foreign key (user_id) references users(id),
 foreign key (media_type_id) references media_types(id)
);

drop table if exists photo_albums;
create table photo_albums(
 id serial primary key,
 name VARCHAR(150),
 user_id BIGINT unsigned not null,
	
 foreign key (user_id) references users(id)
);

drop table if exists photos;
create table photos(
 id serial primary key,
 album_id BIGINT unsigned not null,
 media_id BIGINT unsigned not null,
	
 foreign key (album_id) references photo_albums(id),
 foreign key (media_id) references media(id)
);

drop table if exists notes;
create table notes(
	id serial primary key,	
	user_id BIGINT unsigned not null,
	community_id BIGINT unsigned not null,
	
	body TEXT,
    `size` INT,
    metadata JSON,
    created_at DATETIME default now(),
    updated_at DATETIME default current_timestamp on update current_timestamp,

	index(user_id),
	index(community_id),
	
	foreign key (user_id) references users(id),
 	foreign key (community_id) references communities(id)
);

drop table if exists comments;
create table comments(
	id serial primary key,
	note_id BIGINT unsigned not null,
	
	body TEXT,
    `size` INT,
    metadata JSON,
    created_at DATETIME default now(),
    updated_at DATETIME default current_timestamp on update current_timestamp,

    index(note_id),
	
    foreign key (note_id) references notes(id)
);

drop table if exists music;
create table music(
	id serial primary key,
	name VARCHAR(150), 
	`size` INT,
	metadata JSON,
	created_at DATETIME default now(),
	index(id)
);

drop table if exists playlist;
create table playlist(
	user_id BIGINT unsigned not null,
	track_id BIGINT unsigned not null,

	primary key (user_id, track_id),
    foreign key (track_id) references music(id),
    foreign key (user_id) references users(id)
);

drop table if exists likes;
create table likes(
 id serial primary key,
 media_id BIGINT unsigned not null,
 photo_id BIGINT unsigned not null,
 note_id BIGINT unsigned not null,
 comment_id BIGINT unsigned not null,
 profile_id BIGINT unsigned not null,
 created_at DATETIME default now(),
	
	-- primary key(user_id, media_id)
	
	FOREIGN KEY (photo_id) REFERENCES photos(id),
	FOREIGN KEY (media_id) REFERENCES media(id),
	FOREIGN KEY (comment_id) REFERENCES comments(id),
	FOREIGN KEY (note_id) REFERENCES notes(id),
	FOREIGN KEY (profile_id) REFERENCES profiles(user_id)
);

insert users (
firstname,
lastname,
email,
password_hash,
phone
) values (
'evgenij',
'popov',
'rostovg@r.ru',
'fdlgjkdjg',
345346536
);
