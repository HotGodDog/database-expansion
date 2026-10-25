do $$
begin

    -- Создаю структуру для хранения констант

    begin

        -- Очистка для повторного запуска
        drop table if exists meteo_constants cascade;

        -- Счётчик
        create sequence meteo_constants_seq start with 1;

        comment on sequence meteo_constants_seq is 'Счётчик id констант';

        -- Таблица для констант
        create table meteo_constants
        (
            id              integer default nextval('meteo_constants_seq') not null,
            name            character varying(50) unique not null,
            constant_value  numeric not null,
            description     character varying(255) not null
        );
        alter sequence meteo_constants_seq owned by meteo_constants.id;
        comment on table    meteo_constants                 is 'Таблица констант';
        comment on column   meteo_constants.id              is 'Уникальный код константы';
        comment on column   meteo_constants.name            is 'Уникальное наименование константы';
        comment on column   meteo_constants.constant_value  is 'Значение константы';
        comment on column   meteo_constants.description     is 'Описание константы';

        -- Первичный ключ
        alter table meteo_constants add constraint pk_meteo_constants primary key (id);
        comment on constraint pk_meteo_constants on meteo_constants is 'Первичный ключ констант';

        exception when others then
            raise notice 'Ошибка при создании структуры констант: %', SQLERRM;
            raise; 

    end;



    -- Заполняю таблицу констант

    begin

        insert into meteo_constants (name, constant_value, description) values
            ('BASE_PRESSURE',               750,    'Базовое атмосферное давление'),
            ('BASE_VIRTUAL_TEMPERATURE',    15.9,   'Базовая виртуальная температура'),
            ('NEGATIVE_PRESSURE_CODE',      500,    'Негативное атмосферное давление'),
            ('NEGATIVE_TEMPERATURE_CODE',   50,     'Негативная виртуальная температура');

        perform setval('meteo_constants_seq', (select max(id) from meteo_constants));

        exception when others then
            raise notice 'Ошибка при заполнении данных: %', SQLERRM;
            raise; 
    end;



    -- Функция для получения констант

    begin

        create or replace function get_meteo_constant(p_name character varying)
            returns numeric
            language 'plpgsql'
        as $BODY$
        declare
            v_constant_value numeric;
        begin

            select constant_value into v_constant_value
            from meteo_constants
            where name = p_name;

            if v_constant_value is null then
                raise exception 'Константа с именем "%" не найдена', p_name;
            end if;

            return v_constant_value;

        end;
        $BODY$;

        comment on function get_meteo_constant(character varying) is 'Функция для получения констант';

        exception when others then
            raise notice 'Ошибка при создании функции для получения констант: %', SQLERRM;
            raise; 
    end;



    -- Функция для перевода даты в ДДЧЧМ

    begin

        create or replace function format_meteo_datetime(p_date timestamp)
            returns text
            language 'plpgsql'
        as $BODY$
        declare
            v_date text;
        begin

            v_date := to_char(p_date, 'DDHH24') || floor((extract(minute from p_date) / 10))::text;

            return v_date;

        end;
        $BODY$;

        comment on function format_meteo_datetime(timestamp) is 'Функция для перевода даты в ДДЧЧМ';

        exception when others then
            raise notice 'Ошибка при создании функции для перевода даты в ДДЧЧМ: %', SQLERRM;
            raise; 
    end;



    -- Функция для перевода высоты метеопоста в ВВВВ

    begin

        create or replace function format_meteo_height(p_height integer)
            returns text
            language 'plpgsql'
        as $BODY$
        declare
            v_height text;
        begin

            v_height := lpad(p_height::text, 4, '0');

            return v_height;

        end;
        $BODY$;

        comment on function format_meteo_height(integer) is 'Функция для перевода высоты метеопоста в ВВВВ';

        exception when others then
            raise notice 'Ошибка при создании функции для перевода высоты метеопоста в ВВВВ: %', SQLERRM;
            raise; 
    end;



    -- Функция для форматирования отклонения давления

    begin

        create or replace function format_meteo_pressure(p_pressure integer)
            returns text
            language 'plpgsql'
        as $BODY$
        declare
            v_temp integer;
            v_pressure text;
        begin
            v_temp := p_pressure - get_meteo_constant('BASE_PRESSURE');

            if v_temp >= 0 then
                v_pressure := lpad(v_temp::text, 3, '0');
            else
                v_pressure := lpad((get_meteo_constant('NEGATIVE_PRESSURE_CODE') - v_temp)::text, 3, '0');
            end if;

            return v_pressure;

        end;
        $BODY$;

        comment on function format_meteo_pressure(integer) is 'Функция для форматирования отклонения давления';

        exception when others then
            raise notice 'Ошибка при создании функции для форматирования отклонения давления: %', SQLERRM;
            raise; 
    end;



    -- Функция форматирования отклонения температуры

    begin

        create or replace function format_meteo_temperature(p_temperature numeric)
            returns text
            language 'plpgsql'
        as $BODY$
        declare
            v_virtual_correction numeric;
            v_temp integer;
            v_temperature text;
        begin
            v_virtual_correction := calc_interpolated(p_temperature, get_interpolation_params(p_temperature));

            v_temp := round(p_temperature + v_virtual_correction - get_meteo_constant('BASE_VIRTUAL_TEMPERATURE'));

            if v_temp >= 0 then
                v_temperature := lpad(v_temp::text, 2, '0');
            else
                v_temperature := lpad((get_meteo_constant('NEGATIVE_TEMPERATURE_CODE') - v_temp)::text, 2, '0');
            end if;

            return v_temperature;

        end;
        $BODY$;

        comment on function format_meteo_temperature(numeric) is 'Функция форматирования отклонения температуры';

        exception when others then
            raise notice 'Ошибка при создании функции для форматирования отклонения температуры: %', SQLERRM;
            raise; 
    end;



    -- Функция объединения давления и температуры в одну строку

    begin

        create or replace function format_meteo_pressure_temperature(p_pressure integer, p_temperature numeric)
            returns text
            language 'plpgsql'
        as $BODY$
        begin

            return format_meteo_pressure(p_pressure) || format_meteo_temperature(p_temperature);

        end;
        $BODY$;

        comment on function format_meteo_pressure_temperature(integer, numeric) is 'Функция объединения давления и температуры в одну строку';

        exception when others then
            raise notice 'Ошибка при создании функции объединения давления и температуры в одну строку: %', SQLERRM;
            raise;
    end;

end;
$$;