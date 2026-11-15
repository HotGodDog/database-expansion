-- Пример Воловикова, у меня не работает
create sequence seq_ase_units;
select nextval('public.seq_ase_units');


select max(id) from public.base_units
create sequence seq_ase_units set start = 5;


alter table public.base_units alter column id set default
nextval('public.seq_ase_units');


insert into public.base_units (Name) values('Литр')
select * from base_units



-- Исправление примера Воловикова от нейронки
alter sequence seq_ase_units restart with 5;

alter table public.base_units
alter column id set default nextval('public.seq_ase_units');

insert into public.base_units (Name) values ('Литр');
select * from base_units;


-- Моя попытка написать подобное для другой таблицы
select max(id) from public.employees;

create sequence seq_employees start with 5;

alter table public.employees
alter column id set default nextval('public.seq_employees');

insert into public.employees (NAME) values ('Кологривый');
select * from public.employees;


-- Еще одна моя попытка
select max(id) from public.measurement_batchs;

alter sequence seq_measurement_batchs restart with 22;

alter table public.measurement_batchs
alter column id set default nextval('public.seq_measurement_batchs');

insert into public.measurement_batchs (employee_id) 
values (3);
select * from public.measurement_batchs;


-- Примеры Воловикова
alter table public.base_units
alter column name set not null;

-- Ошибка для примера
insert into base_units(name) values(null);

-- Вложенные транзакции
-- Пакетная обработка либо 3 вставим либо 3 не вставим
do $$
begin

	insert into base_units(name) values('Тонна');
	insert into base_units(name) values(null);	-- Ошибка
	insert into base_units(name) values('Тонна1');

end $$;

select * from base_units


do $$
begin

	insert into base_units(name) values('Тонна');
	insert into base_units(name) values('null');	-- Ошибка
	insert into base_units(name) values('Тонна1');

end $$;

select * from base_units


-- Вложенные транзакции, после ошибки в вложенной произойдет полный откат
-- У меня на этом моменте не работает что-то
do $$
begin

	insert into base_units(name) values('Тонна0');
	insert into base_units(name) values('null');
	insert into base_units(name) values('Тонна1');
	commit;	-- Коммит позволяет избежать каскадной отмены
	
	begin

		insert into base_units(name) values(null);
		insert into base_units(name) values('Тонна3');
		
	end;

end $$;

select * from base_units



-- Жалкие попытки повторить самостоятельно
alter table public.employees
alter column name set not null;
do $$
begin

	insert into employees(name) values('Каптан америка');
	insert into employees(name) values('Чебурашка');
	commit;
	begin

		insert into employees(name) values(null);
		insert into employees(name) values('Шизик');
		
	end;

end $$;

select * from employees

-- Чищу null
select * from employees where name is null;
delete from employees where name is null;


-- По дз комментарии
-- Надо будет сделать все заново с использованием всех изученных инструментов
-- Научится делать ERD диаграммы через PSQL
-- Добавить первую расчетную таблицу