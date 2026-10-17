do $$
begin

    -- Тип данных для интерполяции (x0, y0, x1, y1)

    begin

        drop type if exists interpolation_type cascade;

        create type interpolation_type as
        (
            x0 numeric,
            y0 numeric,
            x1 numeric,
            y1 numeric
        );

        comment on type interpolation_type is 'Опорные точки для линейной интерполяции';

    exception when others then
        raise notice 'Ошибка при создании типа данных для интерполяции: %', SQLERRM;
        raise; 
    end;



    -- Функция поиска опорных точек

    begin

        create or replace function get_interpolation_params(p_temp numeric)
            returns interpolation_type
            language 'plpgsql'
        as $BODY$
        declare
            v_params interpolation_type;
        begin

            -- Нижняя опорная точка
            select temperature, correction into v_params.x0, v_params.y0
            from temperature_corrections
            where temperature <= p_temp order by temperature desc limit 1;

            -- Верхняя опорная точка
            select temperature, correction into v_params.x1, v_params.y1
            from temperature_corrections
            where temperature >= p_temp order by temperature asc limit 1;

            -- Если значения выпали за границы таблицы (null),
            -- то приравниваем их граничным значениям
            if v_params.x0 is null then
                v_params.x0 := v_params.x1;
                v_params.y0 := v_params.y1;
            end if;

            if v_params.x1 is null then
                v_params.x1 := v_params.x0;
                v_params.y1 := v_params.y0;
            end if;

            return v_params;
        end;
        $BODY$;

        comment on function get_interpolation_params(numeric) is 'Возвращает пару опорных точек';

    exception when others then
        raise notice 'Ошибка при создании функции поиска опорных точек: %', SQLERRM;
        raise;
    end;



    -- Функция расчета интерполяции

    begin

        create or replace function calc_interpolated(p_x numeric, p_params interpolation_type)
            returns numeric
            language 'plpgsql'
        as $BODY$
        begin
            -- Защита от деления на ноль в случае равенства опорных точек
            if p_params.x1 = p_params.x0 then
                return p_params.y0;
            end if;

            -- Линейная интерполяция
            return p_params.y0 + (p_x - p_params.x0) * (p_params.y1 - p_params.y0) / (p_params.x1 - p_params.x0);
        end;
        $BODY$;

        comment on function calc_interpolated(numeric, interpolation_type) is 'Линейная интерполяция';

    exception when others then
        raise notice 'Ошибка при создании функции расчёта интерполяции: %', SQLERRM;
        raise;
    end;

end;
$$