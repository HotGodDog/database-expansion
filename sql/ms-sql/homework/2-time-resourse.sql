do $$
begin

    -- Создание таблицы ресурса время

    begin
        drop table if exists dim_time cascade;
        drop sequence if exists seq_dim_time cascade;

        create sequence seq_dim_time;
        comment on sequence seq_dim_time is 'Счётчик внутренних кодов временных периодов';

        create table dim_time
        (
            id              bigint default nextval('public.seq_dim_time') not null,
            month_start     date not null,
            month_end       date not null,
            month_name      text not null,
            year            integer not null,
            quarter_number  integer not null,
            quarter_name    text not null
        );
        alter sequence seq_dim_time owned by dim_time.id;
        comment on table dim_time                   is 'Ресурс: время';
        comment on column dim_time.id               is 'Внутренний код временного периода';
        comment on column dim_time.month_start      is 'Дата начала месяца';
        comment on column dim_time.month_end        is 'Дата окончания месяца';
        comment on column dim_time.month_name       is 'Название месяца';
        comment on column dim_time.year             is 'Год';
        comment on column dim_time.quarter_number   is 'Номер квартала';
        comment on column dim_time.quarter_name     is 'Название квартала';


        exception when others then
            raise notice 'Ошибка при создании таблицы времени: %', SQLERRM;
            raise; 
    end;



    -- Ключи и ограничения

    begin

        alter table dim_time add constraint pk_dim_time primary key (id);
        comment on constraint pk_dim_time on dim_time is 'Первичный ключ временного периода';

        alter table dim_time add constraint uq_dim_time_month_start unique (month_start);
        comment on constraint uq_dim_time_month_start on dim_time is 'Уникальность месяца в ресурсе времени';

        alter table dim_time add constraint chk_dim_time_quarter_number check (quarter_number between 1 and 4);
        comment on constraint chk_dim_time_quarter_number on dim_time is 'Номер квартала должен быть от 1 до 4';

        alter table dim_time add constraint chk_dim_time_month_dates check (month_end >= month_start);
        comment on constraint chk_dim_time_month_dates on dim_time is 'Дата окончания месяца не может быть раньше даты начала';


        exception when others then
            raise notice 'Ошибка при создании ключей и ограничений: %', SQLERRM;
            raise; 
    end;



    -- Заполнение данными с 2000г. по 2026г. включительно 

    begin

        insert into dim_time(
            month_start,
            month_end,
            month_name,
            year,
            quarter_number,
            quarter_name
        )
        select
            month_start::date,
            (month_start + interval '1 month' - interval '1 day')::date,
            case extract(month from month_start)
                when 1  then 'Январь'
                when 2  then 'Февраль'
                when 3  then 'Март'
                when 4  then 'Апрель'
                when 5  then 'Май'
                when 6  then 'Июнь'
                when 7  then 'Июль'
                when 8  then 'Август'
                when 9  then 'Сентябрь'
                when 10 then 'Октябрь'
                when 11 then 'Ноябрь'
                when 12 then 'Декабрь'
            end,
            extract(year from month_start)::integer,
            extract(quarter from month_start)::integer,
            extract(quarter from month_start)::integer || ' квартал'
        from generate_series(
            date '2000-01-01',
            date '2026-12-31',
            interval '1 month'
        ) as month_start
        order by month_start;


        exception when others then
            raise notice 'Ошибка при заполнении данными: %', SQLERRM;
            raise;
    end;

end $$;
