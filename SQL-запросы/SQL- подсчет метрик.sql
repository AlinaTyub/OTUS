-- ������� 1
-- ���������� ARPU (����� �� ������������) � ARPPU (����� �� ��������� ������������) �� ��� 2022 ����
select
	sum(tt.transaction_revenue) / count(distinct(tt.client_id)) as ARPU,
	sum(tt.transaction_revenue) / count(distinct(case when tt.transaction_revenue != 0 then tt.client_id else null end))  as ARPPU
from (
	select
		t.transaction_id,
		t.transaction_revenue,
		t.client_id 
	from transactions t
	where t.date  between '2022-05-01' and '2022-05-31'
	group by t.transaction_id, t.transaction_revenue, t.client_id) as tt;


-- ����� ������� ������� ��������� ARPPU ��������� ��������:
--select
--	sum(tt.transaction_revenue) / count(distinct(tt.client_id)) as ARPPU
--from (
--	select
--		t.transaction_id,
--		t.transaction_revenue,
--		t.client_id 
--	from transactions t
--	where t.date  between '2022-05-01' and '2022-05-31' and t.transaction_revenue != 0
--	group by t.transaction_id, t.transaction_revenue, t.client_id) as tt;

-- ������� 2
-- ��������� ���������� ��������� (������ �� �������������) � ������� ��� � �������� �� ���������� �������
select
	s."source",
	count(distinct (tt.client_id)) as count_clients,
	float8(count(distinct(case when tt.transaction_revenue != 0 then tt.client_id else null end))) / float8(count(distinct (tt.client_id))) as C,
	avg(tt.transaction_revenue) as AOV
from (
	select
		t.transaction_id,
		t.transaction_revenue,
		t.client_id 
	from transactions t
	where t.date  between '2022-05-01' and '2022-05-31'
	group by t.transaction_id, t.transaction_revenue, t.client_id) as tt
join sources s
on tt.client_id = s.client_id
group by s."source" 

-- ������� 3
-- � ������ ���������� ����������� ����������� ������� ������� �� ������ ������������ �� ��� 2022 ����
select
	s."source",
	float8(count(tt.transaction_id)) /  float8(count(distinct(tt.client_id))) as count_transactions_per_user
from (
	select
		t.transaction_id,
		t.transaction_revenue,
		t.client_id 
	from transactions t
	where t.date  between '2022-05-01' and '2022-05-31' and t.transaction_revenue != 0
	group by t.transaction_id, t.transaction_revenue, t.client_id) as tt
join sources s
on tt.client_id = s.client_id
group by s."source";

-- ������� 4 (*)
-- ��� �������������, ����������� ����� 1-�� ������ � ���, ���������� ������� ���-�� ���� ����� ��������
with client_date as(
	select
		tt.client_id,
		tt.date
	from (
		select
			t.transaction_id,
			t.transaction_revenue,
			t.client_id,
			min(t.date) as date
		from transactions t
		where t.date  between '2022-05-01' and '2022-05-31' and t.transaction_revenue != 0
		group by t.transaction_id, t.transaction_revenue, t.client_id) as tt
),
loyal_clients as(
	select
		cd.client_id
	from client_date as cd
	group by cd.client_id
	having count(cd.date) > 1
),
days_between_orders as(
	select
		tt.client_id,
		tt.date,
		tt.date - lag(tt.date) over(partition by tt.client_id order by  tt.date) as count_days
	from (
		select
			t.transaction_id,
			t.transaction_revenue,
			t.client_id,
			min(t.date) as date
		from transactions t
		where t.date  between '2022-05-01' and '2022-05-31' and t.transaction_revenue != 0
		group by t.transaction_id, t.transaction_revenue, t.client_id) as tt
	where tt.client_id in (select lc.client_id from loyal_clients as lc)
)
-- ������� ���������� ���� ����� �������� �� ���� �������������
select
	avg(dbo.count_days) as avg_count_days_between_orders
from days_between_orders as dbo

-- ���� ���� ����� ��������� ������� ���������� ���� ����� �������� ��� ������� ������������, �� ������ ����
-- (� ��� ����� ��������� ������� �� ������� �� �������������)
--select
--	dbo.client_id,
--	avg(count_days)
--from days_between_orders as dbo
--group by dbo.client_id
