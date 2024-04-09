/* matching properties */
select lease.address, lease.SoldPrice, resi.MonthlyPayment, (lease.SoldPrice - resi.MonthlyPayment) as profit ,lease.Status, resi.Status
from (
	select *
	from Residential
	where Category = 'resl') as lease
join (
	select *
	from Residential
	where Category = 'ress') as resi
on lease.address = resi.address;