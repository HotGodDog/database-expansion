do $$
begin

    -- Создаем временную таблицу для проверки

    begin

        drop table if exists check_results;

        create temp table check_results
        (
            t        numeric,   -- входная температура
            expected numeric,   -- ожидаемая поправка (посчитана вручную)
            actual   numeric,   -- полученная поправка (функции проекта)
            status   text       -- OK / ОШИБКА
        );

    exception when others then
        raise notice 'Ошибка при создании временной таблицы: %', SQLERRM;
        raise;
    end;



    -- Проверка интерполяции

    declare
        -- {температура, ожидаемая поправка}
        v_cases numeric[][] := array
        [
            [-100, 0   ],   -- ниже всех опорных: clamp на первую точку (ТЗ: «Ниже 0 -> 0»)
            [ -10, 0   ],   -- между -58 и 0: отрезок плоский, поправка 0
            [   0, 0   ],   -- точное попадание в опорную точку (x0 = x1)
            [ 7.5, 0.75],   -- середина отрезка 5..10: 0.5 + 2.5*(1-0.5)/(10-5)
            [  12, 1   ],   -- отрезок 10..15 плоский: поправка 1 на всём участке
            [  23, 1.8 ],   -- ПРИМЕР 1 из ТЗ: 1.5 + 3*(2-1.5)/(25-20) = 1.8
            [  25, 2   ],   -- точное попадание в опорную точку
            [27.5, 2.75],   -- середина отрезка 25..30: 2 + 2.5*(3.5-2)/(30-25)
            [  40, 4.5 ],   -- последняя опорная точка
            [  50, 4.5 ]    -- выше всех опорных: clamp на последнюю точку
        ];
        v_case   numeric[];
        v_actual numeric;
    begin

        foreach v_case slice 1 in array v_cases
        loop
            -- цепочка вызовов: температура -> опорные точки -> поправка
            v_actual := calc_interpolated(v_case[1], get_interpolation_params(v_case[1]));

            insert into check_results(t, expected, actual, status)
            values (v_case[1], v_case[2], v_actual,
                    case when abs(v_actual - v_case[2]) < 0.000001
                        then 'OK'
                        else 'ОШИБКА'
                    end);
        end loop;

    exception when others then
        raise notice 'Ошибка при проверке интерполяции: %', SQLERRM;
        raise;
    end;

end;
$$;



-- Вывод результатов проверки

select t,
    expected as "ожидалось",
    actual   as "получено",
    status
from check_results
order by t;