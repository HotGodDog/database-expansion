-- 1. Каждый пользователь имеет одинаковое количество измерений?
--    Выводим ФИО и число пачек по каждому пользователю
select
	t1.id,
	t1.name,
	coalesce(t2.measurment_count, 0)
from employees t1
left join
(
	-- Подзапрос: считаем пачки измерений по пользователям
	select
		employee_id,
		count(*) as measurment_count
	from measurment_baths
	group by employee_id
) as t2 on t1.id = t2.employee_id;



-- 2. У нас нет пустых пачек измерения?
--    Ищем пачки, для которых нет ни одной строки в таблице параметров
select t1.*
from measurment_baths t1
left join
(
	-- Подзапрос: пачки, у которых есть хотя бы один параметр
	select distinct measurment_bath_id
	from measurment_input_params
) as t2 on t1.id = t2.measurment_bath_id
where t2.measurment_bath_id is null;



-- 3. Каждая пачка измерений содержит полное количество параметров (5 шт)?
--    Показываем пачки, где различных параметров меньше пяти
select
	t1.id,
	t1.started,
	coalesce(t2.params_count, 0) as params_count
from measurment_baths t1
left join
(
	-- Подзапрос: число различных параметров в каждой пачке
	select
		measurment_bath_id,
		count(distinct param_type_id) as params_count
	from measurment_input_params
	group by measurment_bath_id
) as t2 on t1.id = t2.measurment_bath_id
where coalesce(t2.params_count, 0) < 5;



-- 4. Все значения корректны и в рамках нужного нам диапазона?
select
	t1.measurment_bath_id,
	t3.name as param_name,
	t1.value
from measurment_input_params t1
inner join params_type t3
on t1.param_type_id = t3.id
inner join
(
	-- Подзапрос: допустимые диапазоны значений по типам параметров
	select 'Температура воздуха' as param_name, -58::numeric as min_value, 58::numeric as max_value
	union all
	select 'Атмосферное давление', 500, 900
	union all
	select 'Направление ветра', 0, 360
	union all
	select 'Скорость ветра', 0, 15
) as t4 on t3.name = t4.param_name
where t1.value < t4.min_value or t1.value > t4.max_value;



-- 5. Все единицы измерения верны и корректны по отношению к указанным параметрам?
--    Сверяем единицу измерения каждого типа параметра со списком допустимых
select
	t1.id,
	t1.name as param_name,
	coalesce(t3.name, '*') as unit_name  -- '*' - единицы измерения нет в справочнике units
from params_type t1
left join units t3
on t1.unit_id = t3.id
left join
(
	-- Подзапрос: допустимые единицы измерения для каждого параметра
	select 'Высота метеопоста' as param_name, 'м' as unit_name
	union all
	select 'Температура воздуха', '°C'
	union all
	select 'Атмосферное давление', 'мм рт. ст.'
	union all
	select 'Направление ветра', '°'
	union all
	select 'Скорость ветра', 'м/с'
) as t4 on t1.name = t4.param_name
	and t3.name = t4.unit_name
where t4.param_name is null;
