-- Второй скрипт миграции

-- Очистка
drop table if exists military_ranks;
drop table if exists base_units;
drop table if exists units;
drop table if exists params_type;
drop table if exists employees;
drop table if exists measurment_types;
drop table if exists measurment_input_params;
drop table if exists measurment_baths;

-- 1. Справочники

-- 1.1. Справочник должностей
create table military_ranks
(
	id 			integer,
	description character varying(255)
);

comment on table military_ranks is 'Справочник должностей';
comment on column military_ranks.id is 'Уникальный код';
comment on column military_ranks.description is 'Описание';

-- Заполняем данные
insert into military_ranks(id, description)
values(1,'Рядовой'),(2,'Лейтенант');

-- 1.2. Справочник базовых единиц измерения
create table base_units
(
	id			integer,
	name		character varying(50) not null
);

comment on table base_units is 'Справочник базовых единиц измерения';
comment on column base_units.id is 'Уникальный код';
comment on column base_units.name is 'Наименование';

-- Заполняем данные
insert into base_units (id, name)
values	(1, 'м'),
		(2, '°C'),
		(3, 'мм рт. ст.'), 
	  	(4, '°'),
		(5, 'м/с');

-- 1.3. Справочник единиц измерения
create table units
(
	id 				integer,
	base_unit_id 	integer not null,
	coefficient		numeric(12,6) default 1 not null,
	name			character varying(50) not null,
	description 	character varying(255) not null
);

comment on table units is 'Справочник единиц измерения';
comment on column units.id is 'Уникальный код';
comment on column units.base_unit_id is 'Уникальный код базовой единицы измерения';
comment on column units.coefficient is 'Коэффициент пересчета к базовой единице';
comment on column units.name is 'Наименование';
comment on column units.description is 'Описание';

insert into units (id, base_unit_id, coefficient, name, description)
values	(1, 1, 1, 'м', 'метры'),
		(2, 2, 1, '°C', 'градусы Цельсия'),	
		(3, 3, 1, 'мм рт. ст.', 'милиметры ртутного столба'),
		(4, 4, 1, '°', 'градусы'),
		(5, 5, 1, 'м/с', 'метры в секунду'),
		(6, 1, 0.3048, 'фут', 'футы'),
		(7, 1, 1000, 'км', 'километры'),
		(8, 1, 1609.344, 'ми', 'мили'),
		(9, 3, 0.750062, 'гПа', 'гектопаскали'),
		(10, 3, 760, 'атм', 'атмосферы'),
		(11, 4, 57.29578, 'рад', 'радианы'),
		(12, 5, 0.277778, 'км/ч', 'километры в час'),
		(13, 5, 0.3048, 'фут/с', 'футы в секунду'),
		(14, 5, 0.514444, 'уз', 'узлы'),
		(15, 5, 1000, 'км/с', 'километры в секунду');


-- 1.4. Справочник типов параметров
create table params_type
(
	id          integer,
	unit_id     integer not null,
	name        character varying(50) not null
);

comment on table params_type is 'Справочник типов параметров';
comment on column params_type.id is 'Уникальный код';
comment on column params_type.unit_id is 'Уникальный код единицы измерения';
comment on column params_type.name is 'Наименование';

insert into params_type (id, unit_id, name)
values	(1, 1, 'Высота метеопоста'),
		(2, 2, 'Температура воздуха'),
		(3, 3, 'Атмосферное давление'),
		(4, 4, 'Направление ветра'),
		(5, 5, 'Скорость ветра');



-- 2. Пользователя
create table employees
(
    id integer,
	name text,
	birthday timestamp ,
	military_rank_id integer
);

comment on table employees is 'Пользователи';
comment on column employees.id is 'Уникальный код';
comment on column employees.name is 'Наименование';
comment on column employees.birthday is 'Дата рождения';
comment on column employees.military_rank_id is 'Уникальный код должности';

-- Заполняем данные
insert into employees(id, name, birthday,military_rank_id )  
values(1, 'Воловиков Александр Сергеевич','1978-06-24', 2);

-- 3. Устройства для измерения
create table measurment_types
(
   id integer,
   short_name  character varying(50),
   description text 
);

comment on table measurment_types is 'Измерительное оборудование';
comment on column measurment_types.id is 'Уникальный код';
comment on column measurment_types.short_name is 'Краткое наименование';
comment on column measurment_types.description is 'Описание';

-- Заполняем данные
insert into measurment_types(id, short_name, description)
values(1, 'ДМК', 'Десантный метео комплекс'),
(2,'ВР','Ветровое ружье');


-- 3. Таблица с параметрами
create table measurment_input_params
(
    id 					integer not null,
	measurment_bath_id 	integer not null,
	param_type_id 		integer not null,
	value				numeric(8,2) default 0 not null
);

comment on table measurment_input_params is 'Таблица с параметрами';
comment on column measurment_input_params.id is 'Уникальный код';
comment on column measurment_input_params.measurment_bath_id is 'Уникальный код пачки';
comment on column measurment_input_params.param_type_id is 'Уникальный код типа параметра';
comment on column measurment_input_params.value is 'Значение параметра';

-- Заполняем данные
insert into measurment_input_params (id, measurment_bath_id, param_type_id, value)
values	(1, 1, 1, 100),
		(2, 1, 2, 12),
		(3, 1, 3, 34),
		(4, 1, 4, 0.2),
		(5, 1, 5, 45);

-- Создание новых данных — DML
insert into measurment_input_params (id, measurment_bath_id, param_type_id, value)
values	(6, 2, 1, 150),
		(7, 2, 2, 15),
		(8, 2, 3, 740),
		(9, 2, 4, 270);

-- Удаление ошибочных данных — DML
delete from measurment_input_params
where id = 9;

insert into measurment_input_params (id, measurment_bath_id, param_type_id, value)
values (9, 2, 4, 280);



-- 4. Таблица с историей
create table measurment_baths
(
	id integer ,
	employee_id integer,
	measurment_type_id integer,
	started timestamp default now()
);

comment on table measurment_baths is 'Пачки';
comment on column measurment_baths.employee_id is 'Уникальный код пользователя';
comment on column measurment_baths.measurment_type_id is 'Уникальный код оборудования';
comment on column measurment_baths.started is 'Дата измерения';

-- Заполняем данные
insert into measurment_baths(id, employee_id, measurment_type_id, started)
values(1, 1, 1, '2026-09-01'),(2,1,2, '2026-09-02');

---------------------------------------------------
-- Итоговый запрос
---------------------------------------------------

select
	measurment_baths.started                        as "Дата измерения",
	measurment_baths.id                             as "Номер пачки",
	employees.name                                  as "ФИО сотрудника",
	params_type.name || ' (' || units.name || ')'   as "Наименование параметра и ед. измерения",
	measurment_input_params.value                   as "Значение"
from 	measurment_baths, measurment_input_params, measurment_types,
		employees, military_ranks, base_units, units, params_type
where
        -- Связь пачка - пользователи
	    employees.id = measurment_baths.employee_id
		-- Связь должность - пользователь
	and employees.military_rank_id = military_ranks.id
	   	-- Связь пачка - тип оборудования
	and measurment_types.id = measurment_baths.measurment_type_id
	  	-- Связь пачка - параметры
	and measurment_input_params.measurment_bath_id = measurment_baths.id
	  	-- Связь параметры - типы параметров
	and params_type.id = measurment_input_params.param_type_id
	   	-- Связь типы параметров - единицы измерения
	and units.id = params_type.unit_id
	   	-- Связь единицы измерения - базовые единицы измерения
	and units.base_unit_id = base_units.id;