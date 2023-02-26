--select 
--	e.event_type
--	,count(e.event_type)
--from events as e 
--group by e.event_type 



with cte_funnel_events as(
	select 
		e."userId" as user_id,
		e."sessionId" session_id,
		e.date,
		e."_time",
		e.event_type, 
		case
			when e.event_type like '%AddToCart%' then 'AddToCart'
			when e.event_type like '%Transaction%' then 'Transaction'
			else e.event_type 
		end as funnel_step
	from events e
	where e.event_type not in ('isWishlistAdd', 'isViewCheckoutStep1')
	order by 1, 2, 3, 4
)
-- ќткрыта€ воронка
--select 
--	f.funnel_step
--	,count(distinct f.user_id) as users
--from cte_funnel_events as f
--group by f.funnel_step
--order by users desc
-- «акрыта€ воронка (все шаги должны быть пройдены друг за другом)
select
	result.step,
	count(distinct result.user_id)
from(
	select
		funnel.user_id,
		funnel.session_id,
		case
			when funnel.funnel_step1 like 'isViewCatalog' and funnel.funnel_step2 like 'isViewProductCardPage' and funnel.funnel_step3 like 'AddToCart' and funnel.funnel_step4 like 'isViewCart'then 'step4'
			when funnel.funnel_step1 like 'isViewCatalog' and funnel.funnel_step2 like 'isViewProductCardPage' and funnel.funnel_step3 like 'AddToCart' then 'step3'
			when funnel.funnel_step1 like 'isViewCatalog' and funnel.funnel_step2 like 'isViewProductCardPage' then 'step2'
			when funnel.funnel_step1 like 'isViewCatalog' then 'step1'
			else null
		end as step
	from(
		select
			ff.date,
			ff._time,
			ff.user_id,
			ff.session_id,
			ff.funnel_step as funnel_step1
			-- считаем следующие шаги
			,lead(ff.funnel_step, 1) over (partition by ff.session_id order by ff._time) as funnel_step2
			,lead(ff.funnel_step, 2) over (partition by ff.session_id order by ff._time) as funnel_step3
			,lead(ff.funnel_step, 3) over (partition by ff.session_id order by ff._time) as funnel_step4
			,lead(ff.funnel_step, 4) over (partition by ff.session_id order by ff._time) as funnel_step5
			,lead(ff.funnel_step, 5) over (partition by ff.session_id order by ff._time) as funnel_step6
		from(
			select 
				f.date,
				f._time,
				f.user_id,
				f.session_id,
				f.funnel_step,
				lag(f.funnel_step) over (partition by session_id order by f._time) as prev_funnel_step
			from cte_funnel_events as f
			order by f.session_id, f._time) as ff
		where ff.funnel_step != ff.prev_funnel_step or ff.prev_funnel_step is null) as funnel) as result
group by result.step