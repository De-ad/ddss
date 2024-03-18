--  запросы для инициализации модели

create type user_status as enum ('exists', 'deleted');
create type game_status as enum ('not-started', 'started', 'finished');
create type request_status as enum ('on-review', 'rejected', 'approved');
create type game_format as enum ('online', 'offline');
create type character_status as enum ('free', 'busy');

create table if not exists users (
    id serial primary key,
    login varchar(32) not null,
    name varchar(128) not null,
    password varchar(128) not null,
    karma integer default 0 not null,
    timezone text,
    telegram_tag varchar(32),
    vk_tag varchar(32),
    current_status user_status not null
);

create table if not exists friendships (
    sender_user_id integer references users (id) on delete restrict on update cascade,
    receiver_user_id integer references users (id) on delete restrict on update cascade,
    current_status request_status not null,
    primary key (sender_user_id, receiver_user_id)
);

create table if not exists reviews (
    reviewer_user_id integer references users (id) on delete restrict on update cascade,
    recipient_user_id integer references users (id) on delete restrict on update cascade,
    content text,
    date timestamp not null,
    rating smallint not null,
    primary key (reviewer_user_id, recipient_user_id),
    constraint valid_rating check (rating >= 0 and rating <= 5)
);

create table if not exists roles (
    id serial primary key,
    name varchar(32) not null
);

create table if not exists user_roles (
    user_id integer references users (id) on delete restrict on update cascade,
    role_id integer references roles (id) on delete cascade on update cascade,
    primary key (user_id, role_id)
);

create table if not exists game_systems (
    id serial primary key,
    name varchar(32) not null
);

create table if not exists games (
    id serial primary key,
    name varchar(32) not null,
    game_system_id integer references game_systems (id) on delete restrict on update cascade, 
    picture bytea,
    master_id integer references users (id) on delete restrict on update cascade,
    creation_date timestamp not null,
    current_status game_status not null,
    finish_date timestamp,
    description text, 
    constraint valid_dates check (finish_date >= creation_date)
);

create table if not exists tags (
    id serial primary key,
    name varchar(32) not null
);

create table if not exists games_tags (
    game_id integer references games (id) on delete restrict on update cascade,
    tag_id integer references tags (id) on delete cascade on update cascade,
    primary key (game_id, tag_id)
);

create table if not exists characters (
    id serial primary key,
    game_system_id integer references game_systems (id) on delete restrict on update cascade, 
    user_id integer references users (id) on delete restrict on update cascade,
    current_status character_status not null, 
    stats bytea not null
);

create table if not exists lobbies (
    id serial primary key,
    game_id integer references games (id) on delete restrict on update cascade unique,
    format game_format 
);

create table if not exists lobby_requests (
    id serial primary key,
    lobby_id integer references lobbies (id) on delete restrict on update cascade,
    character_id integer references characters (id) on delete cascade on update cascade,
    current_status request_status
);
