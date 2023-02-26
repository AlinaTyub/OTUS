--Найти месяцы и страны с нулевой выручкой за месяц.
select
	o.date 
	,o.country
from orders as o
where
	o.revenue is null or o.revenue = 0;
	

--Вывести пользователей и заказы, совершенных в странах Прибалтики
select
	o.users 
	,o.orders
from orders as o
where
	o.country in ('Lithuania', 'Latvia', 'Estonia');
	


--Найти строчки, для которых средний чек > 60
select
	o.*
	,o.revenue / o.orders as ARPPU
from orders as o
where
	o.revenue / o.orders > 60;