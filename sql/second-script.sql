-- Второй скрипт миграции
-- 2026-09-29

-- 1. Справочники

-- 1.1. Справочник базовых единиц измерения
create table base_units
(
	id			integer,
	name		character varying(50) not null
);

comment on table base_units is 'Справочник базовых единиц измерения';
comment on column base_units.id is 'Уникальный код';
comment on column base_units.name is 'Наименование';

insert into base_units (id, name)
values	(1, 'м'),
		(2, '°C'),
		(3, 'мм рт. ст.'),
	  	(4, '°'),
		(5, 'м/с');

-- 1.2. Справочник единиц измерения
create table units
(
	id 				integer,
	base_unit_id 	integer not null,
	name			character varying(50) not null
);

comment on table units is 'Справочник единиц измерения';
comment on column units.id is 'Уникальный код';
comment on column units.base_unit_id is 'Уникальный код базовой единицы измерения';
comment on column units.name is 'Наименование';

insert into units (id, base_unit_id, name)
values	(1, 1, 'м'),
		(2, 2, '°C'),
		(3, 3, 'мм рт. ст.'),
		(4, 4, '°'),
		(5, 5, 'м/с'),
		(6, 1, 'фут'),
		(7, 1, 'км'),
		(8, 3, 'гПа'),
		(9, 4, 'рад'),
		(10, 5, 'км/ч'),
		(11, 5, 'уз');

-- 1.3. Справочник типов параметров
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

-- 2. Изменение таблицы параметры: связка с новыми справочниками
alter table measurment_input_params
	add column param_type_id integer;

alter table measurment_input_params
	add column value numeric(8,2) default 0 not null;

-- 3. Перенос старых данных в новую структуру
update measurment_input_params
set param_type_id = 1, value = height;

insert into measurment_input_params (id, measurment_bath_id, param_type_id, value)
select id * 10 + 2, measurment_bath_id, 2, temperature
from measurment_input_params
where param_type_id = 1;

insert into measurment_input_params (id, measurment_bath_id, param_type_id, value)
select id * 10 + 3, measurment_bath_id, 3, pressure
from measurment_input_params
where param_type_id = 1;

insert into measurment_input_params (id, measurment_bath_id, param_type_id, value)
select id * 10 + 4, measurment_bath_id, 4, wind_direction
from measurment_input_params
where param_type_id = 1;

insert into measurment_input_params (id, measurment_bath_id, param_type_id, value)
select id * 10 + 5, measurment_bath_id, 5, wind_speed
from measurment_input_params
where param_type_id = 1;

-- 4. Исправление опечатки первого скрипта
--    emploee_id -> employee_id
alter table measurment_baths
	add column employee_id integer;

update measurment_baths
set employee_id = emploee_id;

alter table measurment_baths
	drop column emploee_id;

-- 5. Старые структуры удаляем DDL командами
alter table measurment_input_params drop column height;
alter table measurment_input_params drop column temperature;
alter table measurment_input_params drop column pressure;
alter table measurment_input_params drop column wind_direction;
alter table measurment_input_params drop column wind_speed;

-- 6. Создание и удаление новых данных
insert into measurment_input_params (id, measurment_bath_id, param_type_id, value)
values	(21, 2, 1, 150),
		(22, 2, 2, 15),
		(23, 2, 3, 740),
		(24, 2, 4, 270);

-- Удаление ошибочной строки
delete from measurment_input_params
where id = 24;

-- Создание корректного значения
insert into measurment_input_params (id, measurment_bath_id, param_type_id, value)
values (24, 2, 4, 280);

-- 7. Итоговый запрос
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
