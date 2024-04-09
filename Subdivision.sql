/* average purchase price & rent per zip code*/
select avgtbl.*, daytbl.avgdaysprice, daytbl.avgdaysrent
from (
	select rentjoin.Subdivision, avgprice, avgmortgage, avgrent, RentCount, PriceCount
	from (select Subdivision, format(avg(soldprice), 'f0') as avgrent, count(Subdivision) as RentCount
		from Residential
		where category = 'resl' and (Status = 'closed' or Status = 'pending' or status = 'activeundercontract')
		group by Subdivision) rentjoin
	left join (select Subdivision, format(avg(soldprice), 'f0') as avgprice, format(avg(MonthlyPayment), 'f0') as avgmortgage, count(Subdivision) as PriceCount
		from Residential
		where category = 'ress' and (Status = 'closed' or Status = 'pending' or status = 'activeundercontract')
		group by Subdivision) pricejoin
	on rentjoin.Subdivision = pricejoin.Subdivision) as avgtbl
join (
	select renttbl.*, pricetbl.avgdaysprice
	from (select Subdivision, avg(dom) as avgdaysprice
		from Residential
		where category = 'ress' and (Status = 'closed' or Status = 'pending' or status = 'activeundercontract')
		group by Subdivision) as pricetbl
	right join (select Subdivision, avg(dom) as avgdaysrent
		from Residential
		where category = 'resl' and (Status = 'closed' or Status = 'pending' or status = 'activeundercontract')
		group by Subdivision) as renttbl
	on pricetbl.Subdivision = renttbl.Subdivision) as daytbl
on avgtbl.Subdivision = daytbl.Subdivision;



/* average per bedroom */
select case when rentbed.Subdivision is null then pricebed.Subdivision else rentbed.Subdivision end as Subdiv,
	case when rentbed.Bedrooms is null then pricebed.Bedrooms else rentbed.Bedrooms end as Bedrooms,
	pricebed.avgprice, pricebed.avgmortgage, rentbed.avgrent
from (
	select Subdivision, bedrooms, format(avg(soldprice), 'f0') as avgrent
	from Residential
	where category = 'resl' and (Status = 'closed' or Status = 'pending' or status = 'activeundercontract')
	group by Subdivision, Bedrooms) as rentbed
full outer join (
	select Subdivision, bedrooms, format(avg(soldprice), 'f0') as avgprice, format(avg(monthlypayment), 'f0') as avgmortgage
	from Residential
	where category = 'ress' and (Status = 'closed' or Status = 'pending' or status = 'activeundercontract')
	group by Subdivision, Bedrooms) as pricebed
on rentbed.Subdivision = pricebed.Subdivision AND rentbed.Bedrooms = pricebed.Bedrooms
order by Subdiv, Bedrooms;