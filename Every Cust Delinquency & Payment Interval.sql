with db as (
SELECT
po.referal_code,
po.gender,
date(po.register_time) register_time,
po.province_name,
po.marriage_status,
po.income,
po.product_id,
po.periode_id,
date(po.first_transaction_date) first_transaction_date,
po.PolicyStatus,
pa.payment_date,
pa.payment_method,
pa.number_of_recurring_payment,
pa.amount,
max(pa.payment_date) over () max_date,
(date_diff(date(po.first_transaction_date), date(po.register_time), day)) register_pay_days
FROM `ins_policy` po join `payment` pa
on po.referal_code = pa.referal_code
order by 1, pa.number_of_recurring_payment
),

monthly_df as (
select *,
date_diff(max_date, (max(payment_date) over (partition by referal_code)), month) late
from db
where periode_id = "Monthly"
),
quarterly_df as (
select *,
date_diff(max_date, (max(payment_date) over (partition by referal_code)), quarter) late
from db
where periode_id = "Quarterly"
),
yearly_df as (
select *,
date_diff(max_date, (max(payment_date) over (partition by referal_code)), year) late
from db
where periode_id = "Yearly"
),
halfly_df as (
select *,
ceil(date_diff(max_date, (max(payment_date) over (partition by referal_code)), month)/6) late
from db
where periode_id = "Half yearly"
),
all_df as(
select * from monthly_df
union all
select * from quarterly_df
union all
select * from yearly_df
union all
select * from halfly_df
)

select
referal_code,
max(register_pay_days) register_pay_days,
max(late) late
from all_df
group by 1
order by 1
