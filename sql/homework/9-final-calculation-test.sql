-- Тест 1: типовые входные данные ДМК из примера ТЗ

do $$
declare
	var_params public.parameters_list_type;
begin
	var_params := row(1, 100, 25, 765, 15, 6, null)::public.parameters_list_type;
	call public.pr_calc_meteo_approximate(var_params, 1);
end $$;

select
	height as "H",
	temperature_deviation as "TT",
	wind_direction as "HH",
	wind_speed as "CC"
from pg_temp.meteo_calculation_result
order by height;


-- Тест 2: типовой расчёт для ВР, дальность сноса пуль 100 м

do $$
declare
	var_params public.parameters_list_type;
begin
	var_params := row(2, 100, 25, 765, 15, null, 100)::public.parameters_list_type;
	call public.pr_calc_meteo_approximate(var_params, 2);
end $$;

select
	height as "H",
	temperature_deviation as "TT",
	wind_direction as "HH",
	wind_speed as "CC"
from pg_temp.meteo_calculation_result
order by height;


-- Тест 3: ДМК, скорость 2 м/с ниже порога; температура 3 °C даёт отрицательные TT

do $$
declare
	var_params public.parameters_list_type;
begin
	var_params := row(1, -100, 3, 500, 0, 2, null)::public.parameters_list_type;
	call public.pr_calc_meteo_approximate(var_params, 1);
end $$;

select
	height as "H",
	temperature_deviation as "TT",
	wind_direction as "HH",
	wind_speed as "CC"
from pg_temp.meteo_calculation_result
order by height;


-- Тест 4: ДМК, скорость 3 м/с на нижней границе таблицы; TT = 0 и переход 59 -> 0

do $$
declare
	var_params public.parameters_list_type;
begin
	var_params := row(1, 0, 15, 900, 59, 3, null)::public.parameters_list_type;
	call public.pr_calc_meteo_approximate(var_params, 1);
end $$;

select
	height as "H",
	temperature_deviation as "TT",
	wind_direction as "HH",
	wind_speed as "CC"
from pg_temp.meteo_calculation_result
order by height;


-- Тест 5: ВР, дальность 39 м ниже порога нулевого ветра

do $$
declare
	var_params public.parameters_list_type;
begin
	var_params := row(2, 100, 25, 765, 15, null, 39)::public.parameters_list_type;
	call public.pr_calc_meteo_approximate(var_params, 2);
end $$;

select
	height as "H",
	temperature_deviation as "TT",
	wind_direction as "HH",
	wind_speed as "CC"
from pg_temp.meteo_calculation_result
order by height;


-- Тест 6: ВР, дальность 40 м на нижней границе таблицы; проверка перехода направления

do $$
declare
	var_params public.parameters_list_type;
begin
	var_params := row(2, 100, 25, 765, 59, null, 40)::public.parameters_list_type;
	call public.pr_calc_meteo_approximate(var_params, 2);
end $$;

select
	height as "H",
	temperature_deviation as "TT",
	wind_direction as "HH",
	wind_speed as "CC"
from pg_temp.meteo_calculation_result
order by height;


-- Тест 7: ВР, интерполяция для 45 м; на высоте 200 м ожидается CC = 3,5

do $$
declare
	var_params public.parameters_list_type;
begin
	var_params := row(2, 100, 25, 765, 15, null, 45)::public.parameters_list_type;
	call public.pr_calc_meteo_approximate(var_params, 2);
end $$;

select
	height as "H",
	temperature_deviation as "TT",
	wind_direction as "HH",
	wind_speed as "CC"
from pg_temp.meteo_calculation_result
order by height;


-- Тест 8: ВР, дальность 150 м на верхней границе ТЗ и таблицы

do $$
declare
	var_params public.parameters_list_type;
begin
	var_params := row(2, 100, 25, 765, 59, null, 150)::public.parameters_list_type;
	call public.pr_calc_meteo_approximate(var_params, 2);
end $$;

select
	height as "H",
	temperature_deviation as "TT",
	wind_direction as "HH",
	wind_speed as "CC"
from pg_temp.meteo_calculation_result
order by height;


-- Тест 9: ДМК, скорость 15 м/с на верхней границе ТЗ и таблицы

do $$
declare
	var_params public.parameters_list_type;
begin
	var_params := row(1, 100, 25, 750, 59, 15, null)::public.parameters_list_type;
	call public.pr_calc_meteo_approximate(var_params, 1);
end $$;

select
	height as "H",
	temperature_deviation as "TT",
	wind_direction as "HH",
	wind_speed as "CC"
from pg_temp.meteo_calculation_result
order by height;
