--Задание: рассчитать долю новой пользователей, пришедших из поиска и совершивших заказ

-- В таблице транзакций есь транзакции, которые приходятся на разные даты (можно убедиться, запустив закомментированный скрипт).
-- Кажется, такого быть не должно.
--select
--	t.transaction_id
--	,count(t.date) as count_dates
--from transactions t
--where t.date >= '2022-05-01' and t.date <= '2022-05-31'
--group by t.transaction_id
--having count(t.date) > 1

-- Посмотрела на данные. Строки совпадают целиком, кроме дат (см. закомментированный скрипт ниже). Полных дубликатов строк нет.
-- Есть идея взять первую дату для каждого такого случая, но не факт, что это будет верно. Поэтому пока оставила таблицу без изменений.
--select * from transactions t
--where t.transaction_id in (
--	select
--		t.transaction_id
--	from transactions t
--	where t.date >= '2022-05-01' and t.date <= '2022-05-31'
--	group by t.transaction_id
--	having count(t.date) > 1)
--order by t.transaction_id

-- Дополнительно возник вопрос про транзакции, где выручка 0 рублей. Просто нет данных? Или это какие-то неудавшеся транзакции? Учитывать ли их?
-- Пока оставила все транзакции.

with cl_search_enjine_traffic_date as(
	select
		*
	from (
		select
			cl.client_id
			,min(cl.first_date_visits) as first_date_visits
		from cl_first_date_visits cl
		group by cl.client_id) as unique_cl_first_date_visits
	join (
		select
			t.client_id
			,t."date" 
		from transactions t
		where t.date >= '2022-05-01' and t.date <= '2022-05-31') as transactions_may_2022 using(client_id)
	join (
		select
			distinct(s.client_id)	
		from sources s
		where s.source = 'Search engine traffic') as cl_search_enjine_traffic using (client_id)
),
new_cl as(
	select
		t1.client_id
		,1 as new -- все новые клиенты, подходящие под условия задачи, помечаются единичками
	from cl_search_enjine_traffic_date t1
	where t1.first_date_visits = t1.date
)
select float8(sum(new)) / float8(count(*)) * 100 as new_search_engine_traffic_share
from (select distinct (cl.client_id) from cl_first_date_visits cl) as ucl
left join new_cl using (client_id)

--Доля считалась от всех клиентов, в том числе не совершивших заказов