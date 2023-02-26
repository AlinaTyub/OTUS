--�������: ���������� ���� ����� �������������, ��������� �� ������ � ����������� �����

-- � ������� ���������� ��� ����������, ������� ���������� �� ������ ���� (����� ���������, �������� ������������������ ������).
-- �������, ������ ���� �� ������.
--select
--	t.transaction_id
--	,count(t.date) as count_dates
--from transactions t
--where t.date >= '2022-05-01' and t.date <= '2022-05-31'
--group by t.transaction_id
--having count(t.date) > 1

-- ���������� �� ������. ������ ��������� �������, ����� ��� (��. ������������������ ������ ����). ������ ���������� ����� ���.
-- ���� ���� ����� ������ ���� ��� ������� ������ ������, �� �� ����, ��� ��� ����� �����. ������� ���� �������� ������� ��� ���������.
--select * from transactions t
--where t.transaction_id in (
--	select
--		t.transaction_id
--	from transactions t
--	where t.date >= '2022-05-01' and t.date <= '2022-05-31'
--	group by t.transaction_id
--	having count(t.date) > 1)
--order by t.transaction_id

-- ������������� ������ ������ ��� ����������, ��� ������� 0 ������. ������ ��� ������? ��� ��� �����-�� ���������� ����������? ��������� �� ��?
-- ���� �������� ��� ����������.

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
		,1 as new -- ��� ����� �������, ���������� ��� ������� ������, ���������� ����������
	from cl_search_enjine_traffic_date t1
	where t1.first_date_visits = t1.date
)
select float8(sum(new)) / float8(count(*)) * 100 as new_search_engine_traffic_share
from (select distinct (cl.client_id) from cl_first_date_visits cl) as ucl
left join new_cl using (client_id)

--���� ��������� �� ���� ��������, � ��� ����� �� ����������� �������