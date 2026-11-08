do $$
begin

	-- Создаем новые структуры

	begin
        -- Мусор дроп
		drop table if exists public.calc_correction_heights cascade;
		drop table if exists public.calc_correction_types cascade;
		drop table if exists public.calc_correction cascade;
		drop table if exists public.calc_correction_headers cascade;

		drop sequence if exists public.calc_correction_height_seq cascade;
		drop sequence if exists public.calc_correction_types_seq cascade;
		drop sequence if exists public.calc_correction_seq cascade;
		drop sequence if exists public.calc_correction_headers_seq cascade;

        -- Создание счетчиков
        create sequence public.calc_correction_height_seq;
		create sequence public.calc_correction_types_seq;
		create sequence public.calc_correction_seq;
		create sequence public.calc_correction_headers_seq;

		comment on sequence public.calc_correction_height_seq      is 'Счетчик кодов стандартных высот';
		comment on sequence public.calc_correction_types_seq       is 'Счетчик кодов типов корректировок';
		comment on sequence public.calc_correction_seq          is 'Счетчик кодов строк корректировок';
		comment on sequence public.calc_correction_headers_seq  is 'Счетчик кодов заголовков таблиц корректировок';
        

		-- Таблица стандартных высот
		create table public.calc_correction_heights
		(
			id integer not null default nextval('public.calc_correction_height_seq'),
			height integer not null
		);
		alter sequence public.calc_correction_height_seq owned by public.calc_correction_heights.id;

		comment on table public.calc_correction_heights         is 'Таблица стандартных высот';
		comment on column public.calc_correction_heights.id     is 'Уникальный код';
		comment on column public.calc_correction_heights.height is 'Высота';
        

		-- Справочник заголовков таблиц корректировок
		create table public.calc_correction_headers
		(
			id integer not null default nextval('public.calc_correction_headers_seq'),
			header_values integer[] not null
		);
		alter sequence public.calc_correction_headers_seq owned by public.calc_correction_headers.id;

		comment on table public.calc_correction_headers              is 'Справочник заголовков таблиц корректировок';
		comment on column public.calc_correction_headers.id            is 'Уникальный код заголовка';
		comment on column public.calc_correction_headers.header_values is 'Значения заголовков столбцов таблицы';


		-- Справочник типов таблиц корректировок
		create table public.calc_correction_types
		(
			id integer not null default nextval('public.calc_correction_types_seq'),
			parent_id integer,
			measurment_equipment_id integer,
			description text not null,
			header_id integer
		);
		alter sequence public.calc_correction_types_seq owned by public.calc_correction_types.id;

		comment on table public.calc_correction_types                           is 'Справочник типов таблиц корректировок';
		comment on column public.calc_correction_types.id                       is 'Уникальный код';
		comment on column public.calc_correction_types.parent_id                is 'Уникальный код родительского типа таблицы';
		comment on column public.calc_correction_types.measurment_equipment_id  is 'Тип оборудования';
		comment on column public.calc_correction_types.description              is 'Описание таблицы корректировок';
		comment on column public.calc_correction_types.header_id                is 'Код заголовка таблицы корректировок';


		-- Универсальная таблица корректировок
		create table public.calc_correction
		(
			id integer not null default nextval('public.calc_correction_seq'),
			height_id integer not null,
			type_id integer not null,
			row_values integer[] not null
		);
		alter sequence public.calc_correction_seq owned by public.calc_correction.id;

		comment on table public.calc_correction             is 'Универсальная таблица корректировок';
		comment on column public.calc_correction.id         is 'Уникальный код';
		comment on column public.calc_correction.height_id  is 'Код высоты';
		comment on column public.calc_correction.type_id    is 'Код типа таблицы корректировок';
		comment on column public.calc_correction.row_values is 'Значения корректировок по столбцам заголовка';

	end;



	-- Добавляем данные

	begin
		insert into public.calc_correction_heights(height)
		values(200),(400),(800),(1200),(1600),(2000),(2400),(3000),(4000);

		insert into public.calc_correction_headers(header_values)
		values
			(array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50]),                 -- 1: таблица 2
			(array[40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150]),       -- 2: таблица 3, ВР
			(array[3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);                -- 3: таблица 3, ДМК

		insert into public.calc_correction_types(description, header_id)
		values
			('Таблица 2', 1),                                  -- 1
			('Таблица 3, скорость среднего ветра', null),       -- 2
			('Таблица 3, направление среднего ветра', null);    -- 3

		insert into public.calc_correction_types(description, parent_id, measurment_equipment_id, header_id)
		values
			('Таблица 3, Скорость среднего ветра (ВР)',     2, 2, 2),    -- 4
			('Таблица 3, Направление среднего ветра (ВР)',  3, 2, null), -- 5
			('Таблица 3, Скорость среднего ветра (ДМК)',    2, 1, 3),    -- 6
			('Таблица 3, Направление среднего ветра (ДМК)', 3, 1, null); -- 7

		insert into public.calc_correction_types(description, parent_id)
		values
			('Таблица 2, Положительные температуры', 1), -- 8
			('Таблица 2, Отрицательные температуры', 1); -- 9

		insert into public.calc_correction(height_id, type_id, row_values)
		values
			-- Таблица 2, отрицптельные значения
			(1, 9, array[-1, -2, -3, -4, -5, -6, -7, -8, -8, -9, -20, -29, -39, -49]),  -- 200
			(2, 9, array[-1, -2, -3, -4, -5, -6, -6, -7, -8, -9, -19, -29, -38, -48]),  -- 400
			(3, 9, array[-1, -2, -3, -4, -5, -6, -6, -7, -7, -8, -18, -28, -37, -46]),  -- 800
			(4, 9, array[-1, -2, -3, -4, -4, -5, -5, -6, -7, -8, -17, -26, -35, -44]),  -- 1200
			(5, 9, array[-1, -2, -3, -3, -4, -4, -5, -6, -7, -7, -17, -25, -34, -42]),  -- 1600
			(6, 9, array[-1, -2, -3, -3, -4, -4, -5, -6, -6, -7, -16, -24, -32, -40]),  -- 2000
			(7, 9, array[-1, -2, -2, -3, -4, -4, -5, -5, -6, -7, -15, -23, -31, -38]),  -- 2400
			(8, 9, array[-1, -2, -2, -3, -4, -4, -4, -5, -5, -6, -15, -22, -30, -37]),  -- 3000
			(9, 9, array[-1, -2, -2, -3, -4, -4, -4, -4, -5, -6, -14, -20, -27, -34]),  -- 4000

			-- Таблица 2, положитеьные значения
			(1, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]), -- 200
			(2, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]), -- 400
			(3, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]), -- 800
			(4, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]), -- 1200
			(5, 8, array[1, 2, 3, 3, 4, 5, 6, 7, 7, 10, 20, 30, null, null]), -- 1600
			(6, 8, array[1, 2, 3, 3, 4, 5, 6, 8, 9, 10, 20, 30, null, null]), -- 2000
			(7, 8, array[1, 2, 3, 4, 4, 5, 6, 8, 9, 10, 20, 30, null, null]), -- 2400
			(8, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]), -- 3000
			(9, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]), -- 4000

			-- Таблица 3, Скорость среднего ветра (ВР)
			(1, 4, array[3, 4, 5, 6, 7, 7, 8, 9, 10, 11, 12, 12]),      -- 200
			(2, 4, array[4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]),    -- 400
			(3, 4, array[4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15, 16]),    -- 800
			(4, 4, array[4, 5, 7, 8, 8, 9, 11, 12, 13, 15, 15, 16]),    -- 1200
			(5, 4, array[4, 6, 7, 8, 9, 10, 11, 13, 14, 15, 17, 17]),   -- 1600
			(6, 4, array[4, 6, 7, 8, 9, 10, 11, 13, 14, 16, 17, 18]),   -- 2000
			(7, 4, array[4, 6, 8, 9, 9, 10, 12, 14, 15, 16, 18, 19]),   -- 2400
			(8, 4, array[5, 6, 8, 9, 10, 11, 12, 14, 15, 17, 18, 19]),  -- 3000
			(9, 4, array[5, 6, 8, 9, 10, 11, 12, 14, 16, 18, 19, 20]),  -- 4000

			-- Таблица 3, Направление среднего ветра (ВР)
			(1, 5, array[0]), -- 200
			(2, 5, array[1]), -- 400
			(3, 5, array[2]), -- 800
			(4, 5, array[2]), -- 1200
			(5, 5, array[3]), -- 1600
			(6, 5, array[3]), -- 2000
			(7, 5, array[3]), -- 2400
			(8, 5, array[4]), -- 3000
			(9, 5, array[4]), -- 4000

			-- Таблица 3,Скорость среднего ветра (ДМК)
			(1, 6, array[4, 6, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21, 22]),      -- 200
			(2, 6, array[5, 7, 10, 11, 12, 14, 17, 18, 20, 22, 23, 25, 27]),    -- 400
			(3, 6, array[5, 8, 10, 11, 13, 15, 18, 19, 21, 23, 25, 27, 28]),    -- 800
			(4, 6, array[5, 8, 11, 12, 13, 16, 19, 20, 22, 24, 26, 28, 30]),    -- 1200
			(5, 6, array[6, 8, 11, 13, 14, 17, 20, 21, 23, 25, 27, 29, 32]),    -- 1600
			(6, 6, array[6, 9, 11, 13, 14, 17, 20, 21, 24, 26, 28, 30, 32]),    -- 2000
			(7, 6, array[6, 9, 12, 14, 15, 18, 21, 22, 25, 27, 29, 32, 34]),    -- 2400
			(8, 6, array[6, 9, 12, 14, 15, 18, 21, 23, 25, 28, 30, 32, 36]),    -- 3000
			(9, 6, array[6, 10, 12, 14, 16, 19, 22, 24, 26, 29, 32, 34, 36]),   -- 4000

			-- Таблица 3, Направление среднего ветра (ДМК)
			(1, 7, array[1]),   -- 200
			(2, 7, array[2]),   -- 400
			(3, 7, array[3]),   -- 800
			(4, 7, array[3]),   -- 1200
			(5, 7, array[4]),   -- 1600
			(6, 7, array[4]),   -- 2000
			(7, 7, array[4]),   -- 2400
			(8, 7, array[5]),   -- 3000
			(9, 7, array[5]);   -- 4000
	end;



	-- Проверка согласованности справочников

	begin
		if exists
		(
			select 1
			from public.calc_correction_headers as h
			where array_length(h.header_values, 1) is null
			   or array_length(h.header_values, 1) = 0
			   or exists
			   (
					select 1
					from unnest(h.header_values) as hv(value)
					where hv.value is null
			   )
		) then
			raise exception 'Заголовки таблиц корректировок не должны быть пустыми или содержать NULL';
		end if;

		if exists
		(
			select h.id, hv.value
			from public.calc_correction_headers as h
			cross join lateral unnest(h.header_values) as hv(value)
			group by h.id, hv.value
			having count(*) > 1
		) then
			raise exception 'Значения внутри заголовка таблицы корректировок не должны повторяться';
		end if;

		if exists
		(
			select 1
			from public.calc_correction as c
			join public.calc_correction_types as t on t.id = c.type_id
			left join public.calc_correction_types as p on p.id = t.parent_id
			left join public.calc_correction_headers as h
				on h.id = coalesce(t.header_id, p.header_id)
			where
				(
					h.id is not null
					and coalesce(array_length(c.row_values, 1), 0)
						<> coalesce(array_length(h.header_values, 1), 0)
				)
				or
				(
					h.id is null
					and coalesce(array_length(c.row_values, 1), 0) <> 1
				)
		) then
			raise exception 'Длина строки корректировок не соответствует заголовку таблицы';
		end if;

		if exists
		(
			select 1
			from public.calc_correction as c
			cross join lateral unnest(c.row_values) with ordinality as rv(value, position)
			where rv.value is null
			  and (c.type_id <> 8 or rv.position < 13)
		) then
			raise exception 'Строка корректировок содержит NULL в позиции, где требуется значение';
		end if;

		if exists
		(
			select 1
			from public.calc_correction_heights as h
			cross join (values (4), (5), (6), (7), (8), (9)) as rt(type_id)
			left join public.calc_correction as c
				on c.height_id = h.id
				and c.type_id = rt.type_id
			where c.id is null
		) then
			raise exception 'Для одной из стандартных высот заполнены не все таблицы корректировок';
		end if;
	end;


	-- Функция интерполяции температурной поправки

	begin
		create or replace function public.fn_calc_temperature_interpolation(
			par_temperature numeric)
			returns numeric
			language 'plpgsql'
		as $BODY$
		begin
			return public.calc_interpolated(
				par_temperature,
				public.get_interpolation_params(par_temperature)
			);
		end;
		$BODY$;

		comment on function public.fn_calc_temperature_interpolation(numeric)
			is 'Функция расчета интерполированной температурной поправки';
	end;


	-- Процедура расчёта приближённого бюллетеня Метео-11

	begin
		drop procedure if exists public.pr_calc_meteo_approximate(public.parameters_list_type, integer);

		create procedure public.pr_calc_meteo_approximate(
			par_params public.parameters_list_type,
			par_equipment_id integer
		)
		language 'plpgsql'
		as $BODY$
		declare
			var_temperature_correction numeric;
			var_delta_t0 integer;
			var_wind_input integer;
			var_speed_type_id integer;
			var_direction_type_id integer;
			var_wind_header_values integer[];
			var_zero_wind boolean default false;
		begin
			-- Проверка общих входных параметров по ТЗ
			if par_params is null then
				raise exception 'Входные параметры не переданы';
			end if;

			if par_equipment_id is null or par_equipment_id not in (1, 2) then
				raise exception 'Тип оборудования должен быть 1 (ДМК) или 2 (ВР)';
			end if;

			if par_params.equipment_id is null or par_params.equipment_id <> par_equipment_id then
				raise exception 'Тип оборудования во входных параметрах не совпадает с отдельным параметром процедуры';
			end if;

			if par_params.height is null then
				raise exception 'Высота метеопоста не задана';
			end if;

			if par_params.temperature is null or
			   par_params.temperature not between -58 and 58 or
			   par_params.temperature <> round(par_params.temperature, 1) then
				raise exception 'Температура должна быть в диапазоне от -58 до 58 с одним знаком после запятой';
			end if;

			if par_params.pressure is null or
			   par_params.pressure not between 500 and 900 or
			   par_params.pressure <> trunc(par_params.pressure) then
				raise exception 'Давление должно быть целым числом в диапазоне от 500 до 900';
			end if;

			if par_params.wind_direction is null or
			   par_params.wind_direction not between 0 and 59 or
			   par_params.wind_direction <> trunc(par_params.wind_direction) then
				raise exception 'Направление ветра должно быть целым числом в диапазоне от 0 до 59';
			end if;

			-- Проверка параметра, зависящего от оборудования
			if par_equipment_id = 1 then
				if par_params.wind_speed is null or
				   par_params.wind_speed not between 0 and 15 or
				   par_params.wind_speed <> trunc(par_params.wind_speed) then
					raise exception 'Для ДМК скорость ветра должна быть целым числом в диапазоне от 0 до 15';
				end if;

				var_wind_input := par_params.wind_speed::integer;
				var_speed_type_id := 6;
				var_direction_type_id := 7;
				var_zero_wind := var_wind_input < 3;
			else
				if par_params.bullet_drift is null or
				   par_params.bullet_drift not between 0 and 150 or
				   par_params.bullet_drift <> trunc(par_params.bullet_drift) then
					raise exception 'Для ВР дальность сноса пуль должна быть целым числом в диапазоне от 0 до 150';
				end if;

				var_wind_input := par_params.bullet_drift::integer;
				var_speed_type_id := 4;
				var_direction_type_id := 5;
				var_zero_wind := var_wind_input < 40;
			end if;

			-- Отклонение приземной виртуальной температуры
			var_temperature_correction := public.fn_calc_temperature_interpolation(par_params.temperature);
			var_delta_t0 := round(par_params.temperature + var_temperature_correction - 15.9)::integer;

			if var_delta_t0 < -50 or var_delta_t0 > 39 then
				raise exception 'Для отклонения температуры % в таблице 2 нет необходимых значений', var_delta_t0;
			end if;

			-- Обязательные составляющие поправки не должны отсутствовать
			if var_delta_t0 <> 0 and exists
			(
				select 1
				from public.calc_correction_heights as h
				cross join public.calc_correction_headers as th
				left join public.calc_correction as c_tens
					on c_tens.height_id = h.id
					and c_tens.type_id = case when var_delta_t0 > 0 then 8 else 9 end
					and (abs(var_delta_t0) / 10) * 10 > 0
				left join public.calc_correction as c_units
					on c_units.height_id = h.id
					and c_units.type_id = case when var_delta_t0 > 0 then 8 else 9 end
					and abs(var_delta_t0) % 10 > 0
				where th.id = 1
				  and
				  (
						(
							(abs(var_delta_t0) / 10) * 10 > 0
							and c_tens.row_values[
								array_position(th.header_values, (abs(var_delta_t0) / 10) * 10)
							] is null
						)
						or
						(
							abs(var_delta_t0) % 10 > 0
							and c_units.row_values[
								array_position(th.header_values, abs(var_delta_t0) % 10)
							] is null
						)
				  )
			) then
				raise exception 'В таблице 2 отсутствуют значения, необходимые для отклонения температуры %', var_delta_t0;
			end if;

			-- Заголовок скорости ветра для выбранного оборудования
			if not var_zero_wind then
				select h.header_values
				into var_wind_header_values
				from public.calc_correction_types as t
				join public.calc_correction_headers as h on h.id = t.header_id
				where t.id = var_speed_type_id;

				if par_equipment_id = 1 and array_position(var_wind_header_values, var_wind_input) is null then
					raise exception 'Значение % отсутствует в заголовке таблицы 3 для ДМК', var_wind_input;
				end if;
			end if;

			drop table if exists pg_temp.meteo_calculation_result;
			create temporary table meteo_calculation_result
			(
				height integer not null,
				temperature_deviation integer not null,
				wind_direction integer not null,
				wind_speed numeric not null
			);

			-- Расчёт значений для каждой стандартной высоты
			insert into pg_temp.meteo_calculation_result(
				height, temperature_deviation, wind_direction, wind_speed
			)
			with temperature_calc as
			(
				select
					h.id as height_id,
					case
						when var_delta_t0 = 0 then 0
						else
							case
								when (abs(var_delta_t0) / 10) * 10 > 0 then
									c_tens.row_values[
										array_position(th.header_values, (abs(var_delta_t0) / 10) * 10)
									]
								else 0
							end
							+
							case
								when abs(var_delta_t0) % 10 > 0 then
									c_units.row_values[
										array_position(th.header_values, abs(var_delta_t0) % 10)
									]
								else 0
							end
					end as temperature_deviation
				from public.calc_correction_heights as h
				cross join public.calc_correction_headers as th
				left join public.calc_correction as c_tens
					on c_tens.height_id = h.id
					and c_tens.type_id = case when var_delta_t0 > 0 then 8 else 9 end
					and (abs(var_delta_t0) / 10) * 10 > 0
				left join public.calc_correction as c_units
					on c_units.height_id = h.id
					and c_units.type_id = case when var_delta_t0 > 0 then 8 else 9 end
					and abs(var_delta_t0) % 10 > 0
				where th.id = 1
			),
			-- Для ВР скорость интерполируется между ближайшими столбцами таблицы 3
			wind_calc as
			(
				select
					h.id as height_id,
					case
						when var_zero_wind then 0::numeric
						when par_equipment_id = 1 then
							c_speed.row_values[array_position(var_wind_header_values, var_wind_input)]::numeric
						when lower_bound.header_value = upper_bound.header_value then
							c_speed.row_values[lower_bound.position]::numeric
						else
							c_speed.row_values[lower_bound.position]::numeric
							+ (var_wind_input - lower_bound.header_value)::numeric
							* (c_speed.row_values[upper_bound.position] - c_speed.row_values[lower_bound.position])
							/ (upper_bound.header_value - lower_bound.header_value)
					end as wind_speed,
					case
						when var_zero_wind then 0
						else (par_params.wind_direction::integer + c_direction.row_values[1]) % 60
					end as wind_direction
				from public.calc_correction_heights as h
				left join public.calc_correction as c_speed
					on c_speed.height_id = h.id
					and c_speed.type_id = var_speed_type_id
				left join public.calc_correction as c_direction
					on c_direction.height_id = h.id
					and c_direction.type_id = var_direction_type_id
				left join lateral
				(
					select hv.header_value, hv.position::integer
					from unnest(var_wind_header_values) with ordinality as hv(header_value, position)
					where hv.header_value <= var_wind_input
					order by hv.header_value desc
					limit 1
				) as lower_bound on par_equipment_id = 2 and not var_zero_wind
				left join lateral
				(
					select hv.header_value, hv.position::integer
					from unnest(var_wind_header_values) with ordinality as hv(header_value, position)
					where hv.header_value >= var_wind_input
					order by hv.header_value
					limit 1
				) as upper_bound on par_equipment_id = 2 and not var_zero_wind
			)
			select
				h.height,
				t.temperature_deviation,
				w.wind_direction,
				w.wind_speed
			from public.calc_correction_heights as h
			join temperature_calc as t on t.height_id = h.id
			join wind_calc as w on w.height_id = h.id
			order by h.height;
		end;
		$BODY$;

		comment on procedure public.pr_calc_meteo_approximate(public.parameters_list_type, integer)
			is 'Расчёт приближённого бюллетеня Метео-11 по входным параметрам и типу оборудования';
	end;


	-- Первичные ключи, ограничения и связи справочников

	begin
		alter table public.calc_correction_heights
			add constraint pk_calc_correction_heights primary key (id);
		comment on constraint pk_calc_correction_heights on public.calc_correction_heights
			is 'Первичный ключ справочника стандартных высот';

		alter table public.calc_correction_headers
			add constraint pk_calc_correction_headers primary key (id);
		comment on constraint pk_calc_correction_headers on public.calc_correction_headers
			is 'Первичный ключ справочника заголовков';

		alter table public.calc_correction_types
			add constraint pk_calc_correction_types primary key (id);
		comment on constraint pk_calc_correction_types on public.calc_correction_types
			is 'Первичный ключ справочника типов корректировок';

		alter table public.calc_correction
			add constraint pk_calc_correction primary key (id);
		comment on constraint pk_calc_correction on public.calc_correction
			is 'Первичный ключ универсальной таблицы корректировок';

		alter table public.calc_correction_heights
			add constraint uq_calc_correction_heights_height unique (height);
		comment on constraint uq_calc_correction_heights_height on public.calc_correction_heights
			is 'Уникальность стандартной высоты';

		alter table public.calc_correction
			add constraint uq_calc_correction_height_type unique (height_id, type_id);
		comment on constraint uq_calc_correction_height_type on public.calc_correction
			is 'Уникальность строки корректировок для высоты и типа таблицы';

		alter table public.calc_correction_heights
			add constraint ck_calc_correction_heights_list
			check (height in (200, 400, 800, 1200, 1600, 2000, 2400, 3000, 4000));
		comment on constraint ck_calc_correction_heights_list on public.calc_correction_heights
			is 'Проверка соответствия высоты перечню стандартных высот бюллетеня';

		alter table public.calc_correction_types
			add constraint fk_calc_correction_types_parent
			foreign key (parent_id) references public.calc_correction_types(id);
		comment on constraint fk_calc_correction_types_parent on public.calc_correction_types
			is 'Связь дочернего типа таблицы с родительским';

		alter table public.calc_correction_types
			add constraint fk_calc_correction_types_equipment
			foreign key (measurment_equipment_id) references public.measurement_equipment(id);
		comment on constraint fk_calc_correction_types_equipment on public.calc_correction_types
			is 'Связь типа таблицы корректировок с типом оборудования';

		alter table public.calc_correction_types
			add constraint fk_calc_correction_types_header
			foreign key (header_id) references public.calc_correction_headers(id);
		comment on constraint fk_calc_correction_types_header on public.calc_correction_types
			is 'Связь типа таблицы корректировок с её заголовком';

		alter table public.calc_correction
			add constraint fk_calc_correction_height
			foreign key (height_id) references public.calc_correction_heights(id);
		comment on constraint fk_calc_correction_height on public.calc_correction
			is 'Связь строки корректировок со стандартной высотой';

		alter table public.calc_correction
			add constraint fk_calc_correction_type
			foreign key (type_id) references public.calc_correction_types(id);
		comment on constraint fk_calc_correction_type on public.calc_correction
			is 'Связь строки корректировок с типом таблицы';
	end;

end $$;
