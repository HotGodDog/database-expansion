do $$
begin

    -- Очистка для повторного запуска

    begin

        drop table if exists dim_measurement_units          cascade;
        drop table if exists dim_base_measurement_units     cascade;
        drop table if exists dim_measurement_units_groups   cascade;
        drop table if exists dim_vendors                    cascade;
        drop table if exists dim_vendor_groups              cascade;
        drop table if exists dim_products                   cascade;
        drop table if exists dim_product_groups             cascade;
        drop table if exists dim_storages                   cascade;
        drop table if exists dim_storage_operation_types    cascade;
        drop table if exists dim_companies                  cascade;
        drop table if exists dim_employees                  cascade;


        drop sequence if exists seq_dim_measurement_units          cascade;
        drop sequence if exists seq_dim_base_measurement_units     cascade;
        drop sequence if exists seq_dim_measurement_units_groups   cascade;
        drop sequence if exists seq_dim_vendors                    cascade;
        drop sequence if exists seq_dim_vendor_groups              cascade;
        drop sequence if exists seq_dim_products                   cascade;
        drop sequence if exists seq_dim_product_groups             cascade;
        drop sequence if exists seq_dim_storages                   cascade;
        drop sequence if exists seq_dim_storage_operation_types    cascade;
        drop sequence if exists seq_dim_companies                  cascade;
        drop sequence if exists seq_dim_employees                  cascade;
    
    end;



    -- Создание измерений

    begin

        -- Счётчики внутренних кодов
        create sequence seq_dim_measurement_units;
        create sequence seq_dim_base_measurement_units;
        create sequence seq_dim_measurement_units_groups;
        create sequence seq_dim_vendors;
        create sequence seq_dim_vendor_groups;
        create sequence seq_dim_products;
        create sequence seq_dim_product_groups;
        create sequence seq_dim_storages;
        create sequence seq_dim_storage_operation_types;
        create sequence seq_dim_companies;
        create sequence seq_dim_employees;

        comment on sequence seq_dim_measurement_units           is 'Счётчик внутренних кодов единиц измерения';
        comment on sequence seq_dim_base_measurement_units      is 'Счётчик внутренних кодов базовых единиц измерения';
        comment on sequence seq_dim_measurement_units_groups    is 'Счётчик внутренних кодов групп единиц измерения';
        comment on sequence seq_dim_vendors                     is 'Счётчик внутренних кодов поставщиков';
        comment on sequence seq_dim_vendor_groups               is 'Счётчик внутренних кодов групп поставщиков';
        comment on sequence seq_dim_products                    is 'Счётчик внутренних кодов продуктов';
        comment on sequence seq_dim_product_groups              is 'Счётчик внутренних кодов групп продуктов';
        comment on sequence seq_dim_storages                    is 'Счётчик внутренних кодов складов';
        comment on sequence seq_dim_storage_operation_types     is 'Счётчик внутренних кодов типов складских операций';
        comment on sequence seq_dim_companies                   is 'Счётчик внутренних кодов компаний';
        comment on sequence seq_dim_employees                   is 'Счётчик внутренних кодов сотрудников';


        -- Единицы измерения
        create table dim_measurement_units
        (
            id          bigint default nextval('public.seq_dim_measurement_units') not null,
            external_id bigint,
            name        text not null,
            factor      numeric(12,3) not null,
            date_add    timestamp default now()
        );
        alter sequence seq_dim_measurement_units owned by dim_measurement_units.id;
        comment on table dim_measurement_units              is 'Ресурс: единицы измерения';
        comment on column dim_measurement_units.id          is 'Код единицы измерения';
        comment on column dim_measurement_units.external_id is 'Код единицы измерения в исходной базе MSSQL';
        comment on column dim_measurement_units.name        is 'Название единицы измерения';
        comment on column dim_measurement_units.factor      is 'Коэффициент пересчёта в базовую единицу';
        comment on column dim_measurement_units.date_add    is 'Дата добавления записи';

        -- Базовые единицы измерения
        create table dim_base_measurement_units
        (
            id          bigint default nextval('public.seq_dim_base_measurement_units') not null,
            external_id bigint,
            name        text not null,
            short_name  text,
            group_id    integer,
            date_add    timestamp default now()
        );
        alter sequence seq_dim_base_measurement_units owned by dim_base_measurement_units.id;
        comment on table dim_base_measurement_units                 is 'Ресурс: базовые единицы измерения';
        comment on column dim_base_measurement_units.id             is 'Код базовой единицы';
        comment on column dim_base_measurement_units.external_id    is 'Код базовой единицы измерения в исходной базе MSSQL';
        comment on column dim_base_measurement_units.name           is 'Название базовой единицы измерения';
        comment on column dim_base_measurement_units.short_name     is 'Краткое обозначение базовой единицы измерения';
        comment on column dim_base_measurement_units.group_id       is 'Внешний код группы единиц измерения';
        comment on column dim_base_measurement_units.date_add       is 'Дата добавления записи';

        -- Группы единиц измерения
        create table dim_measurement_units_groups
        (
            id          bigint default nextval('public.seq_dim_measurement_units_groups') not null,
            external_id bigint,
            name        text not null,
            date_add    timestamp default now()
        );
        alter sequence seq_dim_measurement_units_groups owned by dim_measurement_units_groups.id;
        comment on table dim_measurement_units_groups               is 'Ресурс: группы единиц измерения';
        comment on column dim_measurement_units_groups.id           is 'Код группы единиц измерения';
        comment on column dim_measurement_units_groups.external_id  is 'Код группы единиц измерения в исходной базе MSSQL';
        comment on column dim_measurement_units_groups.name         is 'Название группы единиц измерения';
        comment on column dim_measurement_units_groups.date_add     is 'Дата добавления записи';


        -- Поставщики
        create table dim_vendors
        (
            id          bigint default nextval('public.seq_dim_vendors') not null,
            external_id bigint,
            name        text not null,
            clientgroup integer,
            date_add    timestamp default now()
        );
        alter sequence seq_dim_vendors owned by dim_vendors.id;
        comment on table dim_vendors                is 'Ресурс: поставщики';
        comment on column dim_vendors.id            is 'Код поставщика';
        comment on column dim_vendors.external_id   is 'Код поставщика в исходной базе MSSQL';
        comment on column dim_vendors.name          is 'Название поставщика';
        comment on column dim_vendors.clientgroup   is 'Внешний код группы поставщиков';
        comment on column dim_vendors.date_add      is 'Дата добавления записи';

        -- Группы поставщиков
        create table dim_vendor_groups
        (
            id          bigint default nextval('public.seq_dim_vendor_groups') not null,
            external_id bigint,
            name        text not null,
            date_add    timestamp default now()
        );
        alter sequence seq_dim_vendor_groups owned by dim_vendor_groups.id;
        comment on table dim_vendor_groups              is 'Ресурс: группы поставщиков';
        comment on column dim_vendor_groups.id          is 'Код группы поставщиков';
        comment on column dim_vendor_groups.external_id is 'Код группы поставщиков в исходной базе MSSQL';
        comment on column dim_vendor_groups.name        is 'Название группы поставщиков';
        comment on column dim_vendor_groups.date_add    is 'Дата добавления записи';


        -- Продукты
        create table dim_products
        (
            id          bigint default nextval('public.seq_dim_products') not null,
            external_id bigint,
            name        text not null,
            category_id integer,
            date_add    timestamp default now()
        );
        alter sequence seq_dim_products owned by dim_products.id;
        comment on table dim_products               is 'Ресурс: продукты';
        comment on column dim_products.id           is 'Код продукта';
        comment on column dim_products.external_id  is 'Код продукта в исходной базе MSSQL';
        comment on column dim_products.name         is 'Название продукта';
        comment on column dim_products.category_id  is 'Внешний код группы продуктов';
        comment on column dim_products.date_add     is 'Дата добавления записи';

        -- Группы продуктов
        create table dim_product_groups
        (
            id          bigint default nextval('public.seq_dim_product_groups') not null,
            external_id bigint,
            name        text not null,
            date_add    timestamp default now()
        );
        alter sequence seq_dim_product_groups owned by dim_product_groups.id;
        comment on table dim_product_groups                 is 'Ресурс: группы продуктов';
        comment on column dim_product_groups.id             is 'Код группы продуктов';
        comment on column dim_product_groups.external_id    is 'Код группы продуктов в исходной базе MSSQL';
        comment on column dim_product_groups.name           is 'Название группы продуктов';
        comment on column dim_product_groups.date_add       is 'Дата добавления записи';


        -- Склады
        create table dim_storages
        (
            id          bigint default nextval('public.seq_dim_storages') not null,
            external_id bigint,
            name        text not null,
            company_id  integer,
            date_add    timestamp default now()
        );
        alter sequence seq_dim_storages owned by dim_storages.id;
        comment on table dim_storages               is 'Ресурс: склады';
        comment on column dim_storages.id           is 'Код склада';
        comment on column dim_storages.external_id  is 'Код склада в исходной базе MSSQL';
        comment on column dim_storages.name         is 'Название склада';
        comment on column dim_storages.company_id   is 'Внешний код компании, которой принадлежит склад';
        comment on column dim_storages.date_add     is 'Дата добавления записи';

        -- Типы складских операций
        create table dim_storage_operation_types
        (
            id          bigint default nextval('public.seq_dim_storage_operation_types') not null,
            external_id bigint,
            name        text not null,
            factor      integer not null,
            date_add    timestamp default now()
        );
        alter sequence seq_dim_storage_operation_types owned by dim_storage_operation_types.id;
        comment on table dim_storage_operation_types                is 'Ресурс: типы складских операций';
        comment on column dim_storage_operation_types.id            is 'Код типа операции';
        comment on column dim_storage_operation_types.external_id   is 'Код типа операции в исходной базе MSSQL';
        comment on column dim_storage_operation_types.name          is 'Название типа складской операции';
        comment on column dim_storage_operation_types.factor        is 'Коэффициент влияния операции на остаток';
        comment on column dim_storage_operation_types.date_add      is 'Дата добавления записи';

        -- Компании
        create table dim_companies
        (
            id          bigint default nextval('public.seq_dim_companies') not null,
            external_id bigint,
            name        text not null,
            short_name  text,
            date_add    timestamp default now()
        );
        alter sequence seq_dim_companies owned by dim_companies.id;
        comment on table dim_companies              is 'Ресурс: компании';
        comment on column dim_companies.id          is 'Код компании';
        comment on column dim_companies.external_id is 'Код компании в исходной базе MSSQL';
        comment on column dim_companies.name        is 'Полное название компании';
        comment on column dim_companies.short_name  is 'Краткое название компании';
        comment on column dim_companies.date_add    is 'Дата добавления записи';


        -- Сотрудники
        create table dim_employees
        (
            id              bigint default nextval('public.seq_dim_employees') not null,
            external_id     bigint,
            firstname       text,
            middlename      text,
            lastname        text,
            date_add        timestamp default now()
        );
        alter sequence seq_dim_employees owned by dim_employees.id;
        comment on table dim_employees                  is 'Ресурс: сотрудники';
        comment on column dim_employees.id              is 'Код сотрудника';
        comment on column dim_employees.external_id     is 'Код сотрудника в исходной базе MSSQL';
        comment on column dim_employees.firstname       is 'Имя сотрудника';
        comment on column dim_employees.middlename      is 'Отчество сотрудника';
        comment on column dim_employees.lastname        is 'Фамилия сотрудника';
        comment on column dim_employees.date_add        is 'Дата добавления записи';


        exception when others then
            raise notice 'Ошибка при создании таблиц ресурсов: %', SQLERRM;
            raise; 
    end;



    -- Ключи

    begin

        -- Первичные ключи
        alter table dim_measurement_units_groups add constraint pk_dim_measurement_units_groups primary key (id);
        comment on constraint pk_dim_measurement_units_groups on dim_measurement_units_groups is 'Первичный ключ группы единиц измерения';

        alter table dim_base_measurement_units add constraint pk_dim_base_measurement_units primary key (id);
        comment on constraint pk_dim_base_measurement_units on dim_base_measurement_units is 'Первичный ключ базовой единицы измерения';

        alter table dim_measurement_units add constraint pk_dim_measurement_units primary key (id);
        comment on constraint pk_dim_measurement_units on dim_measurement_units is 'Первичный ключ единицы измерения';

        alter table dim_vendor_groups add constraint pk_dim_vendor_groups primary key (id);
        comment on constraint pk_dim_vendor_groups on dim_vendor_groups is 'Первичный ключ группы поставщиков';

        alter table dim_vendors add constraint pk_dim_vendors primary key (id);
        comment on constraint pk_dim_vendors on dim_vendors is 'Первичный ключ поставщика';

        alter table dim_product_groups add constraint pk_dim_product_groups primary key (id);
        comment on constraint pk_dim_product_groups on dim_product_groups is 'Первичный ключ группы продуктов';

        alter table dim_products add constraint pk_dim_products primary key (id);
        comment on constraint pk_dim_products on dim_products is 'Первичный ключ продукта';

        alter table dim_companies add constraint pk_dim_companies primary key (id);
        comment on constraint pk_dim_companies on dim_companies is 'Первичный ключ компании';

        alter table dim_storages add constraint pk_dim_storages primary key (id);
        comment on constraint pk_dim_storages on dim_storages is 'Первичный ключ склада';

        alter table dim_storage_operation_types add constraint pk_dim_storage_operation_types primary key (id);
        comment on constraint pk_dim_storage_operation_types on dim_storage_operation_types is 'Первичный ключ типа складской операции';

        alter table dim_employees add constraint pk_dim_employees primary key (id);
        comment on constraint pk_dim_employees on dim_employees is 'Первичный ключ сотрудника';


        exception when others then
            raise notice 'Ошибка при создании ключей: %', SQLERRM;
            raise; 
    end;

end $$;
