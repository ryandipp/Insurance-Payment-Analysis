with first as
(
select 
referal_code,
min(date_trunc(date(first_transaction_date), month)) first_pay
from `ins_policy`
where periode_id = 'Monthly'
group by 1
order by 1 asc
)
,
paydate as
(
select
first.referal_code,
first.first_pay,
date_trunc(pa.payment_date, month) pay_date
from first
join
`payment` pa
on first.referal_code = pa.referal_code
)
,
t0 as
(
select *,
date_diff(pay_date,first_pay,month) period
from paydate
)
,
t1 as
(
select
first_pay,
period,
count(distinct referal_code) cohort
from t0
group by 1,2
order by 1,2 asc)
,
t2 as
(select
*,
max(cohort) over (partition by first_pay order by period) total
from t1
order by 1,2)

select
first_pay, period, cohort,
round((cohort/total),2) percentage
from t2
order by 1,2;


