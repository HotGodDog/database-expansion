-- Единицы измерения
select id, sizeid as name, portionrate as factor from [size]

select 'insert into dim_measurement_units(external_id, name, factor ) values ('
    + cast(id as varchar(max)) + ','
    + isnull('''' + [sizeid] + '''', 'null') + ','
    + isnull(cast(portionrate as varchar(max)), 'null') + ');'
    as [sql]
 from [size]


 -- Базовые единицы измерения
select ID as id, Description as name, ShortName as short_name, GroupID as group_id from [bm_classifierSizes]

select 'insert into dim_base_measurement_units(external_id, name, short_name, group_id ) values ('
    + cast(ID as varchar(max)) + ','
    + isnull('''' + [Description] + '''', 'null') + ','
    + isnull('''' + [ShortName] + '''', 'null') + ','
    + isnull(cast(GroupID as varchar(max)), 'null') + ');'
    as [sql]
 from [bm_classifierSizes]


-- Группы единиц измерений
select ID as id, Description as name from [bm_classifierSizesGroup]

select 'insert into dim_measurement_units_groups(external_id, name ) values ('
    + cast(ID as varchar(max)) + ','
    + isnull('''' + [Description] + '''', 'null') + ');'
    as [sql]
 from [bm_classifierSizesGroup]



-- Поставщики
select id, clientid as name, clientgroup from [vendors]

select 'insert into dim_vendors(external_id, name, clientgroup ) values ('
    + cast(id as varchar(max)) + ','
    + isnull('''' + [clientid] + '''', 'null') + ','
    + isnull(cast(clientgroup as varchar(max)), 'null') + ');'
    as [sql]
 from [vendors]


-- Группы поставщиков
select vendorgroupid as id, description as name from [vendorgroup]

select 'insert into dim_vendor_groups(external_id, name ) values ('
    + cast(vendorgroupid as varchar(max)) + ','
    + isnull('''' + [description] + '''', 'null') + ');'
    as [sql]
 from [vendorgroup]



-- Продукты
select id, description as name, CategoryID as category_id from [product]

select 'insert into dim_products(external_id, name, category_id ) values ('
    + cast(id as varchar(max)) + ','
    + isnull('''' + [description] + '''', 'null') + ','
    + isnull(cast(CategoryID as varchar(max)), 'null') + ');'
    as [sql]
 from [product]


 -- Группы продуктов
select id, description as name from [category]

select 'insert into dim_product_groups(external_id, name ) values ('
    + cast(id as varchar(max)) + ','
    + isnull('''' + [description] + '''', 'null') + ');'
    as [sql]
 from [category]



 -- Склады
select id, description as name, CompanyID as company_id from [storages]

select 'insert into dim_storages(external_id, name, company_id ) values ('
    + cast(id as varchar(max)) + ','
    + isnull('''' + [description] + '''', 'null') + ','
    + isnull(cast(CompanyID as varchar(max)), 'null') + ');'
    as [sql]
 from [storages]


 -- Типы складских операций
select ID as id, Description as name, Factor as factor from [bm_StorageOperationsType]

select 'insert into dim_storage_operation_types(external_id, name, factor ) values ('
    + cast(ID as varchar(max)) + ','
    + isnull('''' + [Description] + '''', 'null') + ','
    + isnull(cast(Factor as varchar(max)), 'null') + ');'
    as [sql]
 from [bm_StorageOperationsType]


 -- Компании
select ID as id, CompanyName as name, ShortName as short_name from [bm_Companies]

select 'insert into dim_companies(external_id, name, short_name ) values ('
    + cast(ID as varchar(max)) + ','
    + isnull('''' + [CompanyName] + '''', 'null') + ','
    + isnull('''' + [ShortName] + '''', 'null') + ');'
    as [sql]
 from [bm_Companies]



 -- Персонал
select personid as id, firstname, middlename, lastname from [personnel]

select 'insert into dim_employees(external_id, firstname, middlename, lastname ) values ('
    + cast(personid as varchar(max)) + ','
    + isnull('''' + [firstname] + '''', 'null') + ','
    + isnull('''' + [middlename] + '''', 'null') + ','
    + isnull('''' + [lastname] + '''', 'null') + ');'
    as [sql]
 from [personnel]
