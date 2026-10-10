select
    row_number() over (order by t."Тип", t."Наименование") as "№",
    t."Наименование",
    t."Тип"
from
(
    -- Таблицы
    select
        table_name as "Наименование",
        'Таблица'  as "Тип"
    from information_schema.tables
    where table_schema = 'public'
    	and table_type   = 'BASE TABLE'

    union all

    -- Счётчики
    select
        sequence_name as "Наименование",
        'Счётчик'     as "Тип"
    from information_schema.sequences
    where sequence_schema = 'public'

    union all

    -- Ограничения с расшифровкой вида
    select
        constraint_name as "Наименование",
        case constraint_type
            when 'PRIMARY KEY' then 'Ограничение (первичный ключ)'
            when 'FOREIGN KEY' then 'Ограничение (внешний ключ)'
            when 'CHECK'       then 'Ограничение (проверка)'
            when 'UNIQUE'      then 'Ограничение (уникальность)'
        end as "Тип"
    from information_schema.table_constraints
    where table_schema = 'public'
  		and constraint_name not like '%not_null'
) as t
order by t."Тип", t."Наименование";