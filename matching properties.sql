/* matching properties */
with propmatch as (
select sale.Address, sale.SoldPrice, sale.MonthlyPayment, lease.SoldPrice as rent, (lease.SoldPrice - sale.MonthlyPayment) as profit
from (
	select Address, soldprice, MonthlyPayment, max(SettledDate) mostrecent
	from Residential
	where Category = 'ress'
	group by Address, soldprice, MonthlyPayment
	) as sale
join (
	select Address, soldprice, max(SettledDate) mostrecent
	from Residential
	where Category = 'resl'
	group by Address, soldprice
	) as lease
on sale.address = lease.address)

select *, avg(profit) over () as avg_profit
from propmatch
order by profit desc