-- Список параметров с ошибками

with 
    -- Собираем парамертры измерений в одну строку для каждой пачки измерений
    batch_params as (
        select
            measurement_batch_id,
            max(case when measurement_parameter_type_id = 1 then measurement_value end) as height,
            max(case when measurement_parameter_type_id = 2 then measurement_value end) as temperature,
            max(case when measurement_parameter_type_id = 3 then measurement_value end) as pressure,
            max(case when measurement_parameter_type_id = 4 then measurement_value end) as wind_direction,
            max(case when measurement_parameter_type_id = 5 then measurement_value end) as wind_speed,
            max(case when measurement_parameter_type_id = 6 then measurement_value end) as bullet_drift
        from measurement_input_params
        group by measurement_batch_id
    ),

    -- Добавляем результаты проверки параметров для каждой пачки измерений
    validation_results as (
        select 
            bp.measurement_batch_id,
            mb.measurement_equipment_id,
            bp.height,
            bp.temperature,
            bp.pressure,
            bp.wind_direction,
            bp.wind_speed,
            bp.bullet_drift,
            pc.name as error_name,
            pc.description as error_description
        from batch_params as bp
        join measurement_batchs as mb
            on mb.id = bp.measurement_batch_id
        left join lateral parmeters_checking(
            row(
                mb.measurement_equipment_id,
                bp.height, bp.temperature, bp.pressure,
                bp.wind_direction, bp.wind_speed, bp.bullet_drift
            )::parameters_list_type
        ) as pc on true
    )

    -- Объединяем ошибки одной пачки измерений в одну строку
    select
        measurement_batch_id,
        measurement_equipment_id,
        height, temperature, pressure,
        wind_direction, wind_speed, bullet_drift,
        case when count(error_name) = 0 then 'Нет ошибки'
            else 'Есть ошибка'
        end as error_flag,
        coalesce(string_agg(error_description, '; '), '') as error_descriptions
    from validation_results
    group by
        measurement_batch_id, measurement_equipment_id,
        height, temperature, pressure,
        wind_direction, wind_speed, bullet_drift
    order by measurement_batch_id;



-- Лучший стрелок

with 
    -- Собираем парамертры измерений в одну строку для каждой пачки измерений
    batch_params as (
        select
            measurement_batch_id,
            max(case when measurement_parameter_type_id = 1 then measurement_value end) as height,
            max(case when measurement_parameter_type_id = 2 then measurement_value end) as temperature,
            max(case when measurement_parameter_type_id = 3 then measurement_value end) as pressure,
            max(case when measurement_parameter_type_id = 4 then measurement_value end) as wind_direction,
            max(case when measurement_parameter_type_id = 5 then measurement_value end) as wind_speed,
            max(case when measurement_parameter_type_id = 6 then measurement_value end) as bullet_drift
        from measurement_input_params
        group by measurement_batch_id
    ),

    -- Добавляем результаты проверки параметров для каждой пачки измерений
    validation_results as (
        select 
            bp.measurement_batch_id,
            mb.measurement_equipment_id,
            bp.height,
            bp.temperature,
            bp.pressure,
            bp.wind_direction,
            bp.wind_speed,
            bp.bullet_drift,
            pc.name as error_name,
            pc.description as error_description
        from batch_params as bp
        join measurement_batchs as mb
            on mb.id = bp.measurement_batch_id
        left join lateral parmeters_checking(
            row(
                mb.measurement_equipment_id,
                bp.height, bp.temperature, bp.pressure,
                bp.wind_direction, bp.wind_speed, bp.bullet_drift
            )::parameters_list_type
        ) as pc on true
    )

    -- Находим лучшего стрелка
    select
        e.id as employee_id,
        e.name as employee_name,
        count(vr.error_name) as errors_count
    from employees as e
    left join measurement_batchs as mb
        on mb.employee_id = e.id
    left join validation_results as vr
        on vr.measurement_batch_id = mb.id
    group by e.id, e.name
    order by errors_count, e.name;



-- Тесты функций форматирования

-- Тест для функции форматирования даты и времени
with test_cases(input_date, expected) as (
    values
        (timestamp '2026-09-24 09:30', '24093'),
        (timestamp '2026-10-05 18:05', '05180'),
        (timestamp '2026-12-31 23:59', '31235')
)
select
    input_date,
    expected,
    format_meteo_datetime(input_date) as actual,
    format_meteo_datetime(input_date) = expected as is_ok
from test_cases;


-- Тест для функции форматирования высоты
with test_cases(input_height, expected) as (
    values
        (67, 	'0067'),
        (100, 	'0100'),
        (1300, 	'1300')
)
select
    input_height,
    expected,
    format_meteo_height(input_height) as actual,
    format_meteo_height(input_height) = expected as is_ok
from test_cases;


-- Тест для функции форматирования давления
with test_cases(input_pressure, expected) as (
    values
        (765, 	'015'),
        (750, 	'000'),
        (743, 	'507'),
		(500, 	'750'),
		(900, 	'150')
)
select
    input_pressure,
    expected,
    format_meteo_pressure(input_pressure) as actual,
    format_meteo_pressure(input_pressure) = expected as is_ok
from test_cases;


-- Тест для функции форматирования температуры
with test_cases(input_temperature, expected) as (
    values
        (25, 	'11'),
        (23, 	'09'),
        (3, 	'63')
)
select
    input_temperature,
    expected,
    format_meteo_temperature(input_temperature) as actual,
    format_meteo_temperature(input_temperature) = expected as is_ok
from test_cases;


-- Тест для функции форматирования давления и температуры
with test_cases(input_pressure, input_temperature, expected) as (
    values
        (765, 25, 	'01511'),
        (743, 23, 	'50709'),
        (737, 3, 	'51363')
)
select
	input_pressure,
    input_temperature,
    expected,
    format_meteo_pressure_temperature(input_pressure, input_temperature) as actual,
    format_meteo_pressure_temperature(input_pressure, input_temperature) = expected as is_ok
from test_cases;
