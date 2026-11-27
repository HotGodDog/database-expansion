do $$
begin

    -- Очистка для повторного запуска

    begin

        drop table if exists fact_purchases cascade;
        drop sequence if exists seq_fact_purchases cascade;

    end;



    -- Создание таблицы фактов

    begin

        create sequence seq_fact_purchases;
        comment on sequence seq_fact_purchases is 'Счётчик внутренних кодов фактов закупки';

        create table fact_purchases
        (
            id                  bigint default nextval('public.seq_fact_purchases') not null,
            product_id          bigint not null,
            measurement_unit_id bigint not null,
            product_group_id    bigint not null,
            vendor_id           bigint not null,
            quantity            numeric(18,4) not null,
            amount              numeric(18,2) not null,
            date_add            timestamp default now(),
            time_id             bigint not null
        );
        alter sequence seq_fact_purchases owned by fact_purchases.id;
        comment on table fact_purchases                         is 'Факт: закупка продукции (поступление на склад)';
        comment on column fact_purchases.id                     is 'Код факта закупки';
        comment on column fact_purchases.product_id             is 'Код номенклатуры (ресурс dim_products)';
        comment on column fact_purchases.measurement_unit_id    is 'Код единицы измерения (ресурс dim_measurement_units, базовые единицы)';
        comment on column fact_purchases.product_group_id       is 'Код группы номенклатуры (ресурс dim_product_groups)';
        comment on column fact_purchases.vendor_id              is 'Код поставщика (ресурс dim_vendors)';
        comment on column fact_purchases.quantity               is 'Количество закупленного товара в базовой единице измерения';
        comment on column fact_purchases.amount                 is 'Сумма закупки';
        comment on column fact_purchases.date_add               is 'Дата вставки записи';
        comment on column fact_purchases.time_id                is 'Код временного отрезка — месяца закупки (ресурс dim_time)';


        exception when others then
            raise notice 'Ошибка при создании таблицы фактов закупки: %', SQLERRM;
            raise;
    end;



 -- Ключи, связи с ресурсами

    begin

        alter table fact_purchases add constraint pk_fact_purchases primary key (id);
        comment on constraint pk_fact_purchases on fact_purchases is 'Первичный ключ факта закупки';

        alter table fact_purchases add constraint fk_fact_purchases_product
            foreign key (product_id) references dim_products (id);
        comment on constraint fk_fact_purchases_product on fact_purchases is 'Связь факта закупки с ресурсом номенклатуры';

        alter table fact_purchases add constraint fk_fact_purchases_measurement_unit
            foreign key (measurement_unit_id) references dim_measurement_units (id);
        comment on constraint fk_fact_purchases_measurement_unit on fact_purchases is 'Связь факта закупки с ресурсом единиц измерения';

        alter table fact_purchases add constraint fk_fact_purchases_product_group
            foreign key (product_group_id) references dim_product_groups (id);
        comment on constraint fk_fact_purchases_product_group on fact_purchases is 'Связь факта закупки с ресурсом групп номенклатуры';

        alter table fact_purchases add constraint fk_fact_purchases_vendor
            foreign key (vendor_id) references dim_vendors (id);
        comment on constraint fk_fact_purchases_vendor on fact_purchases is 'Связь факта закупки с ресурсом поставщиков';

        alter table fact_purchases add constraint fk_fact_purchases_time
            foreign key (time_id) references dim_time (id);
        comment on constraint fk_fact_purchases_time on fact_purchases is 'Связь факта закупки с ресурсом времени';


        exception when others then
            raise notice 'Ошибка при создании ключей и связей фактов закупки: %', SQLERRM;
            raise;
    end;

end $$;