select * from measurement_parameter_types t1
left join public.measurement_equipment t2
on t1.measurement_equipment_id = t2.id
where
	t2.id is null


select * from measurement_parameter_types t1
inner join public.measurement_equipment t2
on t1.measurement_equipment_id = t2.id


select t1.*,
	coalesce(t2.id, -1) as equipment_id,
	coalesce(t2.description, '*') as equipment_name
	from measurement_parameter_types t1
left join public.measurement_equipment t2
on t1.measurement_equipment_id = t2.id


select * from
(
	-- Подзапрос
	select t1.*,
		coalesce(t2.id, -1) as equipment_id,
		coalesce(t2.description, '*') as equipment_name
		from measurement_parameter_types t1
	left join public.measurement_equipment t2
	on t1.measurement_equipment_id = t2.id
) as inner_t1
where
	inner_t1.equipment_id != -1


select min(started) as min_started, max(started) as max_started
from public.measurement_batchs


select * from measurement_batchs t1
inner join
(
	select min(started) as min_started
	from public.measurement_batchs t1
) as t2 on t1.started = t2.min_started



select * from public.measurement_input_params t1
inner join
(
	-- Подзапрос
	select * from measurement_batchs t1
	inner join
	(
		-- Подзапрос
		select min(started) as min_started
		from public.measurement_batchs t1
	) as t2 on t1.started = t2.min_started
) as inner_t2 on t1.measurement_batch_id = inner_t2.id


select measurement_batch_id from
(
	select measurement_batch_id, count(*) as count_records
	from public.measurement_input_params t1
	group by measurement_batch_id
) as t1