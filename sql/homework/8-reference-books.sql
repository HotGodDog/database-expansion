do $$
begin

    -- Создание справочника стандартных высот

    begin

        drop table if exists standard_heights cascade;

        create table standard_heights
        (
            height integer not null
        );
        comment on table standard_heights           is 'Справочник стандартных высот';
        comment on column standard_heights.height   is 'Стандартная высота бюллетеня';

        alter table standard_heights add constraint pk_standard_heights primary key (height);
        comment on constraint pk_standard_heights on standard_heights is 'Первичный ключ справочника стандартных высот';

        insert into standard_heights (height) values (200), (400), (800), (1200), (1600), (2000), (2400), (3000), (4000);

        exception when others then
            raise notice 'Ошибка при создании справочника стандартных высот: %', SQLERRM;
            raise;

    end;



    -- Создание таблицы расчёта среднего отклонения температуры воздуха

    begin

        drop table if exists calc_temperature_deviation cascade;

        create sequence calc_temperature_deviation_seq start with 1;
        comment on sequence calc_temperature_deviation_seq is 'Счётчик для таблицы расчёта среднего отклонения температуры воздуха';

        create table calc_temperature_deviation
        (
            id          integer default nextval('calc_temperature_deviation_seq') not null,
            height      integer not null,
            delta_t0    integer not null,
            deviation   integer not null
        );
        alter sequence calc_temperature_deviation_seq owned by calc_temperature_deviation.id;
        comment on table    calc_temperature_deviation              is 'Таблица расчёта среднего отклонения температуры воздуха';
        comment on column   calc_temperature_deviation.id           is 'Идентификатор записи';
        comment on column   calc_temperature_deviation.height       is 'Высота бюллетеня';
        comment on column   calc_temperature_deviation.delta_t0     is 'Отклонение приземной виртуальной температуры';
        comment on column   calc_temperature_deviation.deviation    is 'Среднее отклонение температуры';

        alter table calc_temperature_deviation add constraint pk_calc_temperature_deviation primary key (id);
        comment on constraint pk_calc_temperature_deviation on calc_temperature_deviation
            is 'Первичный ключ таблицы расчёта среднего отклонения температуры воздуха';

        alter table calc_temperature_deviation add constraint uq_calc_temperature_deviation_height unique (height, delta_t0);
        comment on constraint uq_calc_temperature_deviation_height on calc_temperature_deviation
            is 'Ограничение на уникальность пары высота + отклонение температуры';

        alter table calc_temperature_deviation add constraint fk_calc_temperature_deviation_height foreign key (height) references standard_heights (height);
        comment on constraint fk_calc_temperature_deviation_height on calc_temperature_deviation
            is 'Связь таблицы расчёта среднего отклонения температуры со справочником стандартных высот';

        alter table calc_temperature_deviation add constraint ck_calc_temperature_deviation_delta_t0 check (delta_t0 between -50 and 50 and delta_t0 <> 0);
        comment on constraint ck_calc_temperature_deviation_delta_t0 on calc_temperature_deviation
            is 'Ограничение на отклонение приземной виртуальной температуры (от -50 до 50, кроме 0)';

        alter table calc_temperature_deviation add constraint ck_calc_temperature_deviation_deviation check (deviation between -50 and 50);
        comment on constraint ck_calc_temperature_deviation_deviation on calc_temperature_deviation
            is 'Ограничение на среднее отклонение температуры (от -50 до 50)';

        exception when others then
            raise notice 'Ошибка при создании таблицы расчёта среднего отклонения температуры воздуха: %', SQLERRM;
            raise;
    end;



    -- Создание таблиц расчёта скорости среднего ветра и отклонения направления ветра

    begin

        drop table if exists calc_wind                  cascade;
        drop table if exists calc_wind_direction_delta  cascade;

        create sequence calc_wind_seq                   start with 1;
        create sequence calc_wind_direction_delta_seq   start with 1;

        comment on sequence calc_wind_seq                   is 'Счётчик для таблицы расчёта скорости среднего ветра';
        comment on sequence calc_wind_direction_delta_seq   is 'Счётчик для таблицы расчёта отклонения направления ветра';

        create table calc_wind
        (
            id              integer default nextval('calc_wind_seq') not null,
            equipment_id    integer not null,
            height          integer not null,
            input_value     integer not null,
            wind_speed      integer not null
        );
        alter sequence calc_wind_seq owned by calc_wind.id;
        comment on table calc_wind                  is 'Таблица расчёта скорости среднего ветра';
        comment on column calc_wind.id              is 'Идентификатор записи';
        comment on column calc_wind.equipment_id    is 'Идентификатор оборудования';
        comment on column calc_wind.height          is 'Высота бюллетеня';
        comment on column calc_wind.input_value     is 'Скорость приземного ветра (ДМК) / дальность сноса пуль (ВР)';
        comment on column calc_wind.wind_speed      is 'Скорость среднего ветра';

        create table calc_wind_direction_delta
        (
            id              integer default nextval('calc_wind_direction_delta_seq') not null,
            equipment_id    integer not null,
            height          integer not null,
            direction_delta integer not null
        );
        alter sequence calc_wind_direction_delta_seq owned by calc_wind_direction_delta.id;
        comment on table calc_wind_direction_delta                  is 'Таблица расчёта отклонения направления ветра';
        comment on column calc_wind_direction_delta.id              is 'Идентификатор записи';
        comment on column calc_wind_direction_delta.equipment_id    is 'Идентификатор оборудования';
        comment on column calc_wind_direction_delta.height          is 'Высота бюллетеня';
        comment on column calc_wind_direction_delta.direction_delta is 'Отклонение направления ветра';

        -- Первичные ключи
        alter table calc_wind add constraint pk_calc_wind primary key (id);
        comment on constraint pk_calc_wind on calc_wind
            is 'Первичный ключ таблицы расчёта скорости среднего ветра';

        alter table calc_wind_direction_delta add constraint pk_calc_wind_direction_delta primary key (id);
        comment on constraint pk_calc_wind_direction_delta on calc_wind_direction_delta
            is 'Первичный ключ таблицы расчёта отклонения направления ветра';

        -- Ограничения уникальности
        alter table calc_wind add constraint uq_calc_wind_equipment_height_input unique (equipment_id, height, input_value);
        comment on constraint uq_calc_wind_equipment_height_input on calc_wind
            is 'Ограничение на уникальность оборудования, высоты и входного значения';

        alter table calc_wind_direction_delta add constraint uq_calc_wind_direction_delta_equipment_height unique (equipment_id, height);
        comment on constraint uq_calc_wind_direction_delta_equipment_height on calc_wind_direction_delta
            is 'Ограничение на уникальность оборудования и высоты';

        -- Ограничения CHECK
        alter table calc_wind add constraint ck_calc_wind_input_value check (
            (equipment_id = 1 and input_value between 3 and 15) or
            (equipment_id = 2 and input_value between 40 and 150));
        comment on constraint ck_calc_wind_input_value on calc_wind
            is 'Ограничение на входное значение: скорость ветра 3-15 м/с для оборудования 1, дальность сноса 40-150 м для оборудования 2';

        alter table calc_wind add constraint ck_calc_wind_wind_speed check (wind_speed between 1 and 50);
        comment on constraint ck_calc_wind_wind_speed on calc_wind
            is 'Ограничение на скорость среднего ветра (от 1 до 50 м/с)';

        alter table calc_wind_direction_delta add constraint ck_calc_wind_direction_delta_direction_delta check (direction_delta between 0 and 5);
        comment on constraint ck_calc_wind_direction_delta_direction_delta on calc_wind_direction_delta
            is 'Ограничение на отклонение направления ветра (от 0 до 5)';

        -- Внешние ключи
        alter table calc_wind add constraint fk_calc_wind_height foreign key (height) references standard_heights (height);
        comment on constraint fk_calc_wind_height on calc_wind
            is 'Связь таблицы расчёта скорости среднего ветра со справочником стандартных высот';

        alter table calc_wind_direction_delta add constraint fk_calc_wind_direction_delta_height foreign key (height) references standard_heights (height);
        comment on constraint fk_calc_wind_direction_delta_height on calc_wind_direction_delta
            is 'Связь таблицы расчёта отклонения направления ветра со справочником стандартных высот';

        alter table calc_wind add constraint fk_calc_wind_equipment foreign key (equipment_id) references measurement_equipment (id);
        comment on constraint fk_calc_wind_equipment on calc_wind
            is 'Связь таблицы расчёта скорости среднего ветра с таблицей оборудования';

        alter table calc_wind_direction_delta add constraint fk_calc_wind_direction_delta_equipment foreign key (equipment_id) references measurement_equipment (id);
        comment on constraint fk_calc_wind_direction_delta_equipment on calc_wind_direction_delta
            is 'Связь таблицы расчёта отклонения направления ветра с таблицей оборудования';

        exception when others then
            raise notice 'Ошибка при создании таблиц расчёта скорости среднего ветра и отклонения направления ветра: %', SQLERRM;
            raise;

    end;



    -- Заполнение таблицы расчёта среднего отклонения температуры воздуха
    -- Блок сгенерирован ИИ на основе данных из таблицы 2 из AlgoritmDmk.md и AlgoritmBp.md

    begin

        insert into calc_temperature_deviation (height, delta_t0, deviation)
        select 200, v.delta_t0, v.deviation
        from (values
            (-1, -1),
            (1, 1),
            (-2, -2),
            (2, 2),
            (-3, -3),
            (3, 3),
            (-4, -4),
            (4, 4),
            (-5, -5),
            (5, 5),
            (-6, -6),
            (6, 6),
            (-7, -7),
            (7, 7),
            (-8, -8),
            (8, 8),
            (-9, -8),
            (9, 9),
            (-10, -9),
            (10, 10),
            (-20, -20),
            (20, 20),
            (-30, -29),
            (30, 30),
            (-40, -39),
            (-50, -49)
        ) as v (delta_t0, deviation);

        insert into calc_temperature_deviation (height, delta_t0, deviation)
        select 400, v.delta_t0, v.deviation
        from (values
            (-1, -1),
            (1, 1),
            (-2, -2),
            (2, 2),
            (-3, -3),
            (3, 3),
            (-4, -4),
            (4, 4),
            (-5, -5),
            (5, 5),
            (-6, -6),
            (6, 6),
            (-7, -6),
            (7, 7),
            (-8, -7),
            (8, 8),
            (-9, -8),
            (9, 9),
            (-10, -9),
            (10, 10),
            (-20, -19),
            (20, 20),
            (-30, -29),
            (30, 30),
            (-40, -38),
            (-50, -48)
        ) as v (delta_t0, deviation);

        insert into calc_temperature_deviation (height, delta_t0, deviation)
        select 800, v.delta_t0, v.deviation
        from (values
            (-1, -1),
            (1, 1),
            (-2, -2),
            (2, 2),
            (-3, -3),
            (3, 3),
            (-4, -4),
            (4, 4),
            (-5, -5),
            (5, 5),
            (-6, -6),
            (6, 6),
            (-7, -6),
            (7, 7),
            (-8, -7),
            (8, 8),
            (-9, -7),
            (9, 9),
            (-10, -8),
            (10, 10),
            (-20, -18),
            (20, 20),
            (-30, -28),
            (30, 30),
            (-40, -37),
            (-50, -46)
        ) as v (delta_t0, deviation);

        insert into calc_temperature_deviation (height, delta_t0, deviation)
        select 1200, v.delta_t0, v.deviation
        from (values
            (-1, -1),
            (1, 1),
            (-2, -2),
            (2, 2),
            (-3, -3),
            (3, 3),
            (-4, -4),
            (4, 4),
            (-5, -4),
            (5, 5),
            (-6, -5),
            (6, 6),
            (-7, -5),
            (7, 7),
            (-8, -6),
            (8, 8),
            (-9, -7),
            (9, 9),
            (-10, -8),
            (10, 10),
            (-20, -17),
            (20, 20),
            (-30, -26),
            (30, 30),
            (-40, -35),
            (-50, -44)
        ) as v (delta_t0, deviation);

        insert into calc_temperature_deviation (height, delta_t0, deviation)
        select 1600, v.delta_t0, v.deviation
        from (values
            (-1, -1),
            (1, 1),
            (-2, -2),
            (2, 2),
            (-3, -3),
            (3, 3),
            (-4, -3),
            (4, 4),
            (-5, -4),
            (5, 5),
            (-6, -4),
            (6, 6),
            (-7, -5),
            (7, 7),
            (-8, -6),
            (8, 8),
            (-9, -7),
            (9, 9),
            (-10, -7),
            (10, 10),
            (-20, -17),
            (20, 20),
            (-30, -25),
            (30, 30),
            (-40, -34),
            (-50, -42)
        ) as v (delta_t0, deviation);

        insert into calc_temperature_deviation (height, delta_t0, deviation)
        select 2000, v.delta_t0, v.deviation
        from (values
            (-1, -1),
            (1, 1),
            (-2, -2),
            (2, 2),
            (-3, -3),
            (3, 3),
            (-4, -3),
            (4, 4),
            (-5, -4),
            (5, 5),
            (-6, -4),
            (6, 6),
            (-7, -5),
            (7, 7),
            (-8, -6),
            (8, 8),
            (-9, -6),
            (9, 9),
            (-10, -7),
            (10, 10),
            (-20, -16),
            (20, 20),
            (-30, -24),
            (30, 30),
            (-40, -32),
            (-50, -40)
        ) as v (delta_t0, deviation);

        insert into calc_temperature_deviation (height, delta_t0, deviation)
        select 2400, v.delta_t0, v.deviation
        from (values
            (-1, -1),
            (1, 1),
            (-2, -2),
            (2, 2),
            (-3, -2),
            (3, 3),
            (-4, -3),
            (4, 4),
            (-5, -4),
            (5, 5),
            (-6, -4),
            (6, 6),
            (-7, -5),
            (7, 7),
            (-8, -5),
            (8, 8),
            (-9, -6),
            (9, 9),
            (-10, -7),
            (10, 10),
            (-20, -15),
            (20, 20),
            (-30, -23),
            (30, 30),
            (-40, -31),
            (-50, -38)
        ) as v (delta_t0, deviation);

        insert into calc_temperature_deviation (height, delta_t0, deviation)
        select 3000, v.delta_t0, v.deviation
        from (values
            (-1, -1),
            (1, 1),
            (-2, -2),
            (2, 2),
            (-3, -2),
            (3, 3),
            (-4, -3),
            (4, 4),
            (-5, -4),
            (5, 5),
            (-6, -4),
            (6, 6),
            (-7, -4),
            (7, 7),
            (-8, -5),
            (8, 8),
            (-9, -5),
            (9, 9),
            (-10, -6),
            (10, 10),
            (-20, -15),
            (20, 20),
            (-30, -22),
            (30, 30),
            (-40, -30),
            (-50, -37)
        ) as v (delta_t0, deviation);

        insert into calc_temperature_deviation (height, delta_t0, deviation)
        select 4000, v.delta_t0, v.deviation
        from (values
            (-1, -1),
            (1, 1),
            (-2, -2),
            (2, 2),
            (-3, -2),
            (3, 3),
            (-4, -3),
            (4, 4),
            (-5, -4),
            (5, 5),
            (-6, -4),
            (6, 6),
            (-7, -4),
            (7, 7),
            (-8, -4),
            (8, 8),
            (-9, -5),
            (9, 9),
            (-10, -6),
            (10, 10),
            (-20, -14),
            (20, 20),
            (-30, -20),
            (30, 30),
            (-40, -27),
            (-50, -34)
        ) as v (delta_t0, deviation);

        perform setval('calc_temperature_deviation_seq', (select max(id) from calc_temperature_deviation));

        exception when others then
            raise notice 'Ошибка при заполнении таблицы расчёта среднего отклонения температуры воздуха: %', SQLERRM;
            raise;

    end;



    -- Заполнение таблиц расчёта скорости среднего ветра и отклонения направления ветра
    -- Блок сгенерирован ИИ на основе данных из таблицы 3 из AlgoritmDmk.md и AlgoritmBp.md

    begin

        insert into calc_wind (equipment_id, height, input_value, wind_speed)
        select 1, 200, v.input_value, v.wind_speed
        from (values
            (3, 4),
            (4, 6),
            (5, 8),
            (6, 9),
            (7, 10),
            (8, 12),
            (9, 14),
            (10, 15),
            (11, 16),
            (12, 18),
            (13, 20),
            (14, 21),
            (15, 22)
        ) as v (input_value, wind_speed);

        insert into calc_wind (equipment_id, height, input_value, wind_speed)
        select 1, 400, v.input_value, v.wind_speed
        from (values
            (3, 5),
            (4, 7),
            (5, 10),
            (6, 11),
            (7, 12),
            (8, 14),
            (9, 17),
            (10, 18),
            (11, 20),
            (12, 22),
            (13, 23),
            (14, 25),
            (15, 27)
        ) as v (input_value, wind_speed);

        insert into calc_wind (equipment_id, height, input_value, wind_speed)
        select 1, 800, v.input_value, v.wind_speed
        from (values
            (3, 5),
            (4, 8),
            (5, 10),
            (6, 11),
            (7, 13),
            (8, 15),
            (9, 18),
            (10, 19),
            (11, 21),
            (12, 23),
            (13, 25),
            (14, 27),
            (15, 28)
        ) as v (input_value, wind_speed);

        insert into calc_wind (equipment_id, height, input_value, wind_speed)
        select 1, 1200, v.input_value, v.wind_speed
        from (values
            (3, 5),
            (4, 8),
            (5, 11),
            (6, 12),
            (7, 13),
            (8, 16),
            (9, 19),
            (10, 20),
            (11, 22),
            (12, 24),
            (13, 26),
            (14, 28),
            (15, 30)
        ) as v (input_value, wind_speed);

        insert into calc_wind (equipment_id, height, input_value, wind_speed)
        select 1, 1600, v.input_value, v.wind_speed
        from (values
            (3, 6),
            (4, 8),
            (5, 11),
            (6, 13),
            (7, 14),
            (8, 17),
            (9, 20),
            (10, 21),
            (11, 23),
            (12, 25),
            (13, 27),
            (14, 29),
            (15, 32)
        ) as v (input_value, wind_speed);

        insert into calc_wind (equipment_id, height, input_value, wind_speed)
        select 1, 2000, v.input_value, v.wind_speed
        from (values
            (3, 6),
            (4, 9),
            (5, 11),
            (6, 13),
            (7, 14),
            (8, 17),
            (9, 20),
            (10, 21),
            (11, 24),
            (12, 26),
            (13, 28),
            (14, 30),
            (15, 32)
        ) as v (input_value, wind_speed);

        insert into calc_wind (equipment_id, height, input_value, wind_speed)
        select 1, 2400, v.input_value, v.wind_speed
        from (values
            (3, 6),
            (4, 9),
            (5, 12),
            (6, 14),
            (7, 15),
            (8, 18),
            (9, 21),
            (10, 22),
            (11, 25),
            (12, 27),
            (13, 29),
            (14, 32),
            (15, 34)
        ) as v (input_value, wind_speed);

        insert into calc_wind (equipment_id, height, input_value, wind_speed)
        select 1, 3000, v.input_value, v.wind_speed
        from (values
            (3, 6),
            (4, 9),
            (5, 12),
            (6, 14),
            (7, 15),
            (8, 18),
            (9, 21),
            (10, 23),
            (11, 25),
            (12, 28),
            (13, 30),
            (14, 32),
            (15, 36)
        ) as v (input_value, wind_speed);

        insert into calc_wind (equipment_id, height, input_value, wind_speed)
        select 1, 4000, v.input_value, v.wind_speed
        from (values
            (3, 6),
            (4, 10),
            (5, 12),
            (6, 14),
            (7, 16),
            (8, 19),
            (9, 22),
            (10, 24),
            (11, 26),
            (12, 29),
            (13, 32),
            (14, 34),
            (15, 36)
        ) as v (input_value, wind_speed);

        insert into calc_wind (equipment_id, height, input_value, wind_speed)
        select 2, 200, v.input_value, v.wind_speed
        from (values
            (40, 3),
            (50, 4),
            (60, 5),
            (70, 6),
            (80, 7),
            (90, 7),
            (100, 8),
            (110, 9),
            (120, 10),
            (130, 11),
            (140, 12),
            (150, 12)
        ) as v (input_value, wind_speed);

        insert into calc_wind (equipment_id, height, input_value, wind_speed)
        select 2, 400, v.input_value, v.wind_speed
        from (values
            (40, 4),
            (50, 5),
            (60, 6),
            (70, 7),
            (80, 8),
            (90, 9),
            (100, 10),
            (110, 11),
            (120, 12),
            (130, 13),
            (140, 14),
            (150, 15)
        ) as v (input_value, wind_speed);

        insert into calc_wind (equipment_id, height, input_value, wind_speed)
        select 2, 800, v.input_value, v.wind_speed
        from (values
            (40, 4),
            (50, 5),
            (60, 6),
            (70, 7),
            (80, 8),
            (90, 9),
            (100, 10),
            (110, 11),
            (120, 13),
            (130, 14),
            (140, 15),
            (150, 16)
        ) as v (input_value, wind_speed);

        insert into calc_wind (equipment_id, height, input_value, wind_speed)
        select 2, 1200, v.input_value, v.wind_speed
        from (values
            (40, 4),
            (50, 5),
            (60, 7),
            (70, 8),
            (80, 8),
            (90, 9),
            (100, 11),
            (110, 12),
            (120, 13),
            (130, 15),
            (140, 15),
            (150, 16)
        ) as v (input_value, wind_speed);

        insert into calc_wind (equipment_id, height, input_value, wind_speed)
        select 2, 1600, v.input_value, v.wind_speed
        from (values
            (40, 4),
            (50, 6),
            (60, 7),
            (70, 8),
            (80, 9),
            (90, 10),
            (100, 11),
            (110, 13),
            (120, 14),
            (130, 15),
            (140, 17),
            (150, 17)
        ) as v (input_value, wind_speed);

        insert into calc_wind (equipment_id, height, input_value, wind_speed)
        select 2, 2000, v.input_value, v.wind_speed
        from (values
            (40, 4),
            (50, 6),
            (60, 7),
            (70, 8),
            (80, 9),
            (90, 10),
            (100, 11),
            (110, 13),
            (120, 14),
            (130, 16),
            (140, 17),
            (150, 18)
        ) as v (input_value, wind_speed);

        insert into calc_wind (equipment_id, height, input_value, wind_speed)
        select 2, 2400, v.input_value, v.wind_speed
        from (values
            (40, 4),
            (50, 6),
            (60, 8),
            (70, 9),
            (80, 9),
            (90, 10),
            (100, 12),
            (110, 14),
            (120, 15),
            (130, 16),
            (140, 18),
            (150, 19)
        ) as v (input_value, wind_speed);

        insert into calc_wind (equipment_id, height, input_value, wind_speed)
        select 2, 3000, v.input_value, v.wind_speed
        from (values
            (40, 5),
            (50, 6),
            (60, 8),
            (70, 9),
            (80, 10),
            (90, 11),
            (100, 12),
            (110, 14),
            (120, 15),
            (130, 17),
            (140, 18),
            (150, 19)
        ) as v (input_value, wind_speed);

        insert into calc_wind (equipment_id, height, input_value, wind_speed)
        select 2, 4000, v.input_value, v.wind_speed
        from (values
            (40, 5),
            (50, 6),
            (60, 8),
            (70, 9),
            (80, 10),
            (90, 11),
            (100, 12),
            (110, 14),
            (120, 16),
            (130, 18),
            (140, 19),
            (150, 20)
        ) as v (input_value, wind_speed);

        perform setval('calc_wind_seq', (select max(id) from calc_wind));

        insert into calc_wind_direction_delta (equipment_id, height, direction_delta)
        select 1, v.height, v.direction_delta
        from (values
            (200, 1),
            (400, 2),
            (800, 3),
            (1200, 3),
            (1600, 4),
            (2000, 4),
            (2400, 4),
            (3000, 5),
            (4000, 5)
        ) as v (height, direction_delta);

        insert into calc_wind_direction_delta (equipment_id, height, direction_delta)
        select 2, v.height, v.direction_delta
        from (values
            (200, 0),
            (400, 1),
            (800, 2),
            (1200, 2),
            (1600, 3),
            (2000, 3),
            (2400, 3),
            (3000, 4),
            (4000, 4)
        ) as v (height, direction_delta);

        perform setval('calc_wind_direction_delta_seq', (select max(id) from calc_wind_direction_delta));

        exception when others then
            raise notice 'Ошибка при заполнении таблиц расчёта ветра: %', SQLERRM;
            raise;

    end;

end $$;
