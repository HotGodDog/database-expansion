-- ТРАНЗАКЦИЯ 1. Структура таблиц и счётчики (sequence)

begin;

-- Очистка для повторного запуска
drop table if exists military_positions          cascade;
drop table if exists employees                   cascade;
drop table if exists measurement_equipment       cascade;
drop table if exists base_units                  cascade;
drop table if exists units                       cascade;
drop table if exists measurement_parameter_types cascade;
drop table if exists measurement_batchs          cascade;
drop table if exists measurement_input_params    cascade;

-- Счётчики
create sequence military_positions_seq          start with 1;
create sequence employees_seq                   start with 1;
create sequence measurement_equipment_seq       start with 1;
create sequence base_units_seq                  start with 1;
create sequence units_seq                       start with 1;
create sequence measurement_parameter_types_seq start with 1;
create sequence measurement_batchs_seq          start with 1;
create sequence measurement_input_params_seq    start with 1;

-- 1. Справочник должностей
create table military_positions
(
    id          integer default nextval('military_positions_seq') not null,
    description character varying(255) not null
);
alter sequence military_positions_seq owned by military_positions.id;
comment on table military_positions is 'Справочник должностей';
comment on column military_positions.id is 'Уникальный код';

-- 2. Пользователи
create table employees
(
    id                   integer default nextval('employees_seq') not null,
    name                 text not null,
    military_position_id integer
);
alter sequence employees_seq owned by employees.id;
comment on table employees is 'Пользователи';

-- 3. Измерительное оборудование
create table measurement_equipment
(
    id          integer default nextval('measurement_equipment_seq') not null,
    short_name  character varying(50) not null,
    description text
);
alter sequence measurement_equipment_seq owned by measurement_equipment.id;
comment on table measurement_equipment is 'Измерительное оборудование';

-- 4. Базовые единицы измерения
create table base_units
(
    id   integer default nextval('base_units_seq') not null,
    name text not null
);
alter sequence base_units_seq owned by base_units.id;
comment on table base_units is 'Базовые единицы измерения';

-- 5. Единицы измерения
create table units
(
    id             integer default nextval('units_seq') not null,
    name           text not null,
    base_unit_id   integer,
    convert_factor numeric(12,6)
);
alter sequence units_seq owned by units.id;
comment on table units is 'Единицы измерения';

-- 6. Справочник типов параметров
create table measurement_parameter_types
(
    id                       integer default nextval('measurement_parameter_types_seq') not null,
    name                     text not null,
    unit_id                  integer,
    measurement_equipment_id integer
);
alter sequence measurement_parameter_types_seq owned by measurement_parameter_types.id;
comment on table measurement_parameter_types is 'Справочник типов параметров';

-- 7. Пачки измерений
create table measurement_batchs
(
    id                       integer default nextval('measurement_batchs_seq') not null,
    employee_id              integer,
    measurement_equipment_id integer,
    started                  timestamp default now()
);
alter sequence measurement_batchs_seq owned by measurement_batchs.id;
comment on table measurement_batchs is 'Пачки измерений';

-- 8. Входные параметры измерений
create table measurement_input_params
(
    id                              integer default nextval('measurement_input_params_seq') not null,
    measurement_batch_id            integer,
    measurement_parameter_type_id   integer,
    measurement_value               numeric(10,2) default 0
);
alter sequence measurement_input_params_seq owned by measurement_input_params.id;
comment on table measurement_input_params is 'Входные параметры измерений';

commit;



-- ТРАНЗАКЦИЯ 2. Тестовые данные

begin;

-- Справочники
insert into military_positions(id, description) values
    (1, 'Рядовой'), (2, 'Лейтенант'), (3, 'Сержант');

insert into measurement_equipment(id, short_name, description) values
    (1, 'ДМК', 'Десантный метео комплект'),
    (2, 'ВР',  'Ветровое ружье');

insert into base_units(id, name) values
    (1, 'Метр'),
    (2, 'Градус Цельсия'),
    (3, 'Паскаль'),
    (4, 'Градус'),
    (5, 'Метр в секунду');

insert into units(id, name, base_unit_id, convert_factor) values
    (1, 'Километр',                     1,  1000),
    (2, 'Градус Цельсия',               2,  1),
    (3, 'Паскаль',                      3,  1),
    (4, 'Метр',                         1,  1),
    (5, 'Миллиметры ртутного столба',   3,  133.322),
    (6, 'Метр в секунду',               5,  1),
    (7, 'Большое деление угломера',     4,  6),
    (8, 'Градус',                       4,  1)

-- Типы параметров:
-- скорость ветра - только ДМК, дальность сноса пуль - только ВР
insert into measurement_parameter_types(id, name, unit_id, measurement_equipment_id) values
    (1, 'Высота метеопоста',    4,  null),
    (2, 'Температура',          2,  null),
    (3, 'Давление',             5,  null),
    (4, 'Направление ветра',    7,  null),
    (5, 'Скорость ветра',       6,  1),
    (6, 'Дальность сноса пуль', 4,  2);

-- Синхронизируем счётчики после вставки с явными id
select setval('military_positions_seq',          (select max(id) from military_positions));
select setval('measurement_equipment_seq',       (select max(id) from measurement_equipment));
select setval('base_units_seq',                  (select max(id) from base_units));
select setval('units_seq',                       (select max(id) from units));
select setval('measurement_parameter_types_seq', (select max(id) from measurement_parameter_types));

-- Пользователи (id выдаёт счётчик)
insert into employees(name, military_position_id) values
    ('Петров Дмитрий Олегович',    2),
    ('Смирнов Андрей Николаевич',  1),
    ('Кузнецов Игорь Павлович',    3);

-- 10 пачек ДМК (пользователь 2 - Смирнов), сентябрь, утренние измерения
insert into measurement_batchs(employee_id, measurement_equipment_id, started) values
    (2, 1, '2026-09-01 06:30'), (2, 1, '2026-09-02 06:50'),
    (2, 1, '2026-09-03 07:10'), (2, 1, '2026-09-04 07:30'),
    (2, 1, '2026-09-05 07:50'), (2, 1, '2026-09-06 08:10'),
    (2, 1, '2026-09-07 08:30'), (2, 1, '2026-09-08 08:50'),
    (2, 1, '2026-09-09 09:10'), (2, 1, '2026-09-10 09:30');

-- 10 пачек ВР (пользователь 3 - Кузнецов), сентябрь, дневные измерения
insert into measurement_batchs(employee_id, measurement_equipment_id, started) values
    (3, 2, '2026-09-11 12:00'), (3, 2, '2026-09-12 12:20'),
    (3, 2, '2026-09-13 12:40'), (3, 2, '2026-09-14 13:00'),
    (3, 2, '2026-09-15 13:20'), (3, 2, '2026-09-16 13:40'),
    (3, 2, '2026-09-17 14:00'), (3, 2, '2026-09-18 12:15'),
    (3, 2, '2026-09-19 12:35'), (3, 2, '2026-09-20 12:55');

-- Высота (тип 1): 127..190 м
insert into measurement_input_params(measurement_batch_id, measurement_parameter_type_id, measurement_value)
select id, 1, 120 + id * 7 from measurement_batchs where id between 1 and 10;

-- Температура (тип 2): 5.8..22 °C
insert into measurement_input_params(measurement_batch_id, measurement_parameter_type_id, measurement_value)
select id, 2, 4 + id * 1.8 from measurement_batchs where id between 1 and 10;

-- Давление (тип 3): 757..775 мм рт. ст., целые значения по ТЗ
insert into measurement_input_params(measurement_batch_id, measurement_parameter_type_id, measurement_value)
select id, 3, 755 + id * 2 from measurement_batchs where id between 1 and 10;

-- Направление ветра (тип 4), ДМК: 0..59
insert into measurement_input_params(measurement_batch_id, measurement_parameter_type_id, measurement_value)
select id, 4, (id * 11) % 60 from measurement_batchs where id between 1 and 10;

-- Скорость ветра (тип 5), ДМК: 3..10 м/с
insert into measurement_input_params(measurement_batch_id, measurement_parameter_type_id, measurement_value)
select id, 5, 2 + (id % 8) from measurement_batchs where id between 1 and 10;

-- Направление ветра (тип 4), ВР: 0..59
insert into measurement_input_params(measurement_batch_id, measurement_parameter_type_id, measurement_value)
select id, 4, (id * 7) % 60 from measurement_batchs where id between 11 and 20;

-- Скорость ветра (тип 5), ВР: 3..11 м/с
insert into measurement_input_params(measurement_batch_id, measurement_parameter_type_id, measurement_value)
select id, 5, 3 + (id % 9) from measurement_batchs where id between 11 and 20;

-- Дальность сноса пуль (тип 6), ВР: 10..100 м
insert into measurement_input_params(measurement_batch_id, measurement_parameter_type_id, measurement_value)
select id, 6, 10 * (id - 10) from measurement_batchs where id between 11 and 20;

commit;



-- ТРАНЗАКЦИЯ 3. Связи и ограничения

begin;

-- Первичные ключи
alter table military_positions          add constraint pk_military_positions          primary key (id);
alter table employees                   add constraint pk_employees                   primary key (id);
alter table measurement_equipment       add constraint pk_measurement_equipment       primary key (id);
alter table base_units                  add constraint pk_base_units                  primary key (id);
alter table units                       add constraint pk_units                       primary key (id);
alter table measurement_parameter_types add constraint pk_measurement_parameter_types primary key (id);
alter table measurement_batchs          add constraint pk_measurement_batchs          primary key (id);
alter table measurement_input_params    add constraint pk_measurement_input_params    primary key (id);

-- Внешние ключи
alter table employees add constraint fk_employees_position
    foreign key (military_position_id) references military_positions(id);

alter table units add constraint fk_units_base_unit
    foreign key (base_unit_id) references base_units(id);

alter table measurement_parameter_types add constraint fk_param_types_unit
    foreign key (unit_id) references units(id);
alter table measurement_parameter_types add constraint fk_param_types_equipment
    foreign key (measurement_equipment_id) references measurement_equipment(id);

alter table measurement_batchs add constraint fk_batchs_employee
    foreign key (employee_id) references employees(id);
alter table measurement_batchs add constraint fk_batchs_equipment
    foreign key (measurement_equipment_id) references measurement_equipment(id);

alter table measurement_input_params add constraint fk_params_batch
    foreign key (measurement_batch_id) references measurement_batchs(id);
alter table measurement_input_params add constraint fk_params_type
    foreign key (measurement_parameter_type_id) references measurement_parameter_types(id);

-- Уникальность краткого наименования оборудования
alter table measurement_equipment add constraint uq_equipment_short_name unique (short_name);

-- CHECK по диапазонам из ТЗ:
-- температура -58..58
-- давление 500..900
-- направление 00..59
-- скорость ветра 0..15
-- дальность сноса пуль 0..150
alter table measurement_input_params add constraint chk_measurement_value_range check (
    case measurement_parameter_type_id
        when 1 then true
        when 2 then measurement_value between -58 and 58
        when 3 then measurement_value between 500 and 900
        when 4 then measurement_value between 0 and 59
        when 5 then measurement_value between 0 and 15
        when 6 then measurement_value between 0 and 150
        else false
    end
);

commit;