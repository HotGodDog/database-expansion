do $$
begin

    -- Добавляю ошибки 

    begin

        -- Очистка для повторного запуска
        drop table if exists errors_types   cascade;
        drop table if exists errors_report  cascade;

        -- Счётчики
        create sequence errors_types_seq    start with 1;
        create sequence errors_report_seq   start with 1;

        comment on sequence errors_types_seq    is 'Счётчик id справочника ошибок';
        comment on sequence errors_report_seq   is 'Счётчик id ошибок';


        -- Справочник ошибок
        create table errors_types
        (
            id          integer default nextval('errors_types_seq') not null,
            name        character varying(50) not null,
            description character varying(255) not null
        );
        alter sequence errors_types_seq owned by errors_types.id;
        comment on table    errors_types                is 'Справочник ошибок';
        comment on column   errors_types.id             is 'Уникальный код';
        comment on column   errors_types.name           is 'Наименование ошибки';
        comment on column   errors_types.description    is 'Описание ошибки';

        -- Ошибки
        create table errors_report
        (
            id                          integer default nextval('errors_report_seq') not null,
            measurement_error_id        integer not null,
            measurement_input_param_id  integer not null
        );
        alter sequence errors_report_seq owned by errors_report.id;
        comment on table    errors_report                               is 'Ошибки';
        comment on column   errors_report.id                            is 'Уникальный код';
        comment on column   errors_report.measurement_error_id          is 'Код ошибки';
        comment on column   errors_report.measurement_input_param_id    is 'Код входного параметра';


        -- Первичные ключи
        alter table errors_types add constraint pk_errors_types primary key (id);
        comment on constraint pk_errors_types on errors_types is 'Первичный ключ справочника ошибок';

        alter table errors_report add constraint pk_errors_report primary key (id);
        comment on constraint pk_errors_report on errors_report is 'Первичный ключ ошибок';

        -- Внешние ключи
        alter table errors_report add constraint fk_error_type
            foreign key (measurement_error_id) references errors_types(id);
        comment on constraint fk_error_type on errors_report is 'Связь ошибка - тип ошибки';

        alter table errors_report add constraint fk_error_input_param
            foreign key (measurement_input_param_id) references measurement_input_params(id);
        comment on constraint fk_error_input_param on errors_report is 'Связь ошибка - параметр';

        exception when others then
            raise notice 'Ошибка при добавлении структуры ошибок: %', SQLERRM;
            raise;
    end;



    -- Заполняем данные

    begin

        insert into errors_types(id, name, description) values
            (1, 'WRONG EQUIPMENT TYPE', 'Тип оборудования должен быть 1 (ДМК) или 2 (ВР)'),
            (2, 'WRONG HEIGHT',         'Высота должна быть не null'),
            (3, 'WRONG TEMPERATURE',   'Температура должна быть не null и в диапазоне -58..58'),
            (4, 'WRONG PRESSURE',       'Давление должно быть не null и в диапазоне 500..900'),
            (5, 'WRONG WIND DIRECTION', 'Направление ветра должно быть не null и в диапазоне 00..59'),
            (6, 'WRONG WIND SPEED',     'Скорость ветра должна быть не null и в диапазоне 0..15'),
            (7, 'WRONG BULLET DRIFT',   'Дальность сноса пули должна быть не null и в диапазоне 0..150');
        
        perform setval('errors_types_seq', (select max(id) from errors_types));

        exception when others then
            raise notice 'Ошибка при заполнении данных: %', SQLERRM;
            raise; 
    end;



    -- Тип данных список параметров

    begin

        drop type if exists parameters_list_type cascade;

        create type parameters_list_type as
        (
            equipment_id    integer,
            height          integer,
            temperature     numeric,
            pressure        integer,
            wind_direction  integer,
            wind_speed      integer,
            bullet_drift    integer
        );
        comment on type parameters_list_type                    is 'Список параметров';
        comment on column parameters_list_type.equipment_id     is 'Тип оборудования';
        comment on column parameters_list_type.height           is 'Высота метеопоста';
        comment on column parameters_list_type.temperature      is 'Температура';
        comment on column parameters_list_type.pressure         is 'Давление';
        comment on column parameters_list_type.wind_direction   is 'Направление ветра';
        comment on column parameters_list_type.wind_speed       is 'Скорость ветра';
        comment on column parameters_list_type.bullet_drift     is 'Дальность сноса пуль';

        exception when others then
            raise notice 'Ошибка при создании типа данных список параметров: %', SQLERRM;
            raise; 
    end;



    -- Функция проверки

    begin
        create or replace function parmeters_checking(params parameters_list_type)
            returns text
            language 'plpgsql'
        as $BODY$
        declare
            v_errors text;
        begin

            with error_checks as 
            (
                select 1 as error_type_id, (
                    params.equipment_id is null 
                    or params.equipment_id not in (1, 2)
                ) as has_error
                union all

                select 2, params.height is null
                union all

                select 3, (
                    params.temperature is null
                    or params.temperature < -58
                    or params.temperature > 58
                )
                union all

                select 4, (
                    params.pressure is null
                    or params.pressure < 500
                    or params.pressure > 900
                )
                union all

                select 5, (
                    params.wind_direction is null
                    or params.wind_direction < 0
                    or params.wind_direction > 59
                )
                union all

                select 6, (
                    params.equipment_id = 1
                    and (
                        params.wind_speed is null 
                        or params.wind_speed < 0 
                        or params.wind_speed > 15)
                )
                union all

                select 7, (
                    params.equipment_id = 2
                    and (
                        params.bullet_drift is null 
                        or params.bullet_drift < 0 
                        or params.bullet_drift > 150)
                )        
            )
            select string_agg(et.description, '; ') into v_errors
            from error_checks as ec
            join errors_types as et on et.id = ec.error_type_id
            where ec.has_error;

            return v_errors;

        end;
        $BODY$;

        comment on function parmeters_checking(parameters_list_type) is 'Возращает список ошибок';

        exception when others then
            raise notice 'Ошибка при создании функции проверки: %', SQLERRM;
            raise; 
    end;

end;
$$;
