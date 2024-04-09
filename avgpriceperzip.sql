/* average purchase price & rent per zip code*/
select avgtbl.*, daytbl.avgdaysprice, daytbl.avgdaysrent
from (
	select rentjoin.Zip_Code, avgprice, avgmortgage, avgrent, RentCount, PriceCount
	from (select Zip_Code, format(avg(soldprice), 'f0') as avgrent, count(Zip_Code) as RentCount
		from Residential
		where category = 'resl' and (Status = 'closed' or Status = 'pending' or status = 'activeundercontract')
		group by Zip_Code) rentjoin
	left join (select Zip_Code, format(avg(soldprice), 'f0') as avgprice, format(avg(MonthlyPayment), 'f0') as avgmortgage, count(Zip_Code) as PriceCount
		from Residential
		where category = 'ress' and (Status = 'closed' or Status = 'pending' or status = 'activeundercontract')
		group by Zip_Code) pricejoin
	on rentjoin.zip_code = pricejoin.Zip_Code) as avgtbl
join (
	select renttbl.*, pricetbl.avgdaysprice
	from (select Zip_Code, avg(dom) as avgdaysprice
		from Residential
		where category = 'ress' and (Status = 'closed' or Status = 'pending' or status = 'activeundercontract')
		group by Zip_Code) as pricetbl
	right join (select Zip_Code, avg(dom) as avgdaysrent
		from Residential
		where category = 'resl' and (Status = 'closed' or Status = 'pending' or status = 'activeundercontract')
		group by Zip_Code) as renttbl
	on pricetbl.Zip_Code = renttbl.Zip_Code) as daytbl
on avgtbl.Zip_Code = daytbl.Zip_Code



/* average per bedroom */
select case when rentbed.Zip_Code is null then pricebed.Zip_Code else rentbed.Zip_Code end as ZipCode,
	case when rentbed.Bedrooms is null then pricebed.Bedrooms else rentbed.Bedrooms end as Bedrooms,
	pricebed.avgprice, pricebed.avgmortgage, rentbed.avgrent
from (
	select Zip_Code, bedrooms, format(avg(soldprice), 'f0') as avgrent
	from Residential
	where category = 'resl' and (Status = 'closed' or Status = 'pending' or status = 'activeundercontract')
	group by Zip_Code, Bedrooms) as rentbed
full outer join (
	select Zip_Code, bedrooms, format(avg(soldprice), 'f0') as avgprice, format(avg(monthlypayment), 'f0') as avgmortgage
	from Residential
	where category = 'ress' and (Status = 'closed' or Status = 'pending' or status = 'activeundercontract')
	group by Zip_Code, Bedrooms) as pricebed
on rentbed.Zip_Code = pricebed.Zip_Code AND rentbed.Bedrooms = pricebed.Bedrooms
order by ZipCode, Bedrooms



/* average per quarter */
Select case when pricetbl.yearlyresults is null then renttbl.yearlyresults else pricetbl.yearlyresults end as Year,
	case when pricetbl.quarterlyresults is null then renttbl.quarterlyresults else pricetbl.quarterlyresults end as Quarter,
	case when pricetbl.Zip_Code is null then renttbl.Zip_Code else pricetbl.Zip_Code end as ZipCode, 
	pricetbl.avgprice, monthlyprice, renttbl.avgrent, (avgrent-monthlyprice) as profit
from (
	select
		case when datepart(year, settleddate) = 2022 then 2022
		when datepart(year, settleddate) = 2023 then 2023 end as yearlyresults,
		case when datepart(quarter, settleddate) = 1 then '1st quarter'
		when datepart(quarter, settleddate) = 2 then '2nd quarter'
		when datepart(quarter, settleddate) = 3 then '3rd quarter'
		when datepart(quarter, settleddate) = 4 then '4th quarter' end as quarterlyresults,
		Zip_Code, cast(format(avg(SoldPrice), 'f0') as float) as avgprice, cast(format(avg(monthlypayment), 'f0')as int) as monthlyprice
	from Residential
	where category = 'ress' and (Status = 'closed' or Status = 'pending' or status = 'activeundercontract')
	group by
		case when datepart(year, settleddate) = 2022 then 2022
		when datepart(year, settleddate) = 2023 then 2023 end,
		case when datepart(quarter, settleddate) = 1 then '1st quarter'
		when datepart(quarter, settleddate) = 2 then '2nd quarter'
		when datepart(quarter, settleddate) = 3 then '3rd quarter'
		when datepart(quarter, settleddate) = 4 then '4th quarter' end, Zip_Code) as pricetbl
full outer join (
	select
		case when datepart(year, settleddate) = 2022 then 2022
		when datepart(year, settleddate) = 2023 then 2023 end as yearlyresults,
		case when datepart(quarter, settleddate) = 1 then '1st quarter'
		when datepart(quarter, settleddate) = 2 then '2nd quarter'
		when datepart(quarter, settleddate) = 3 then '3rd quarter'
		when datepart(quarter, settleddate) = 4 then '4th quarter' end as quarterlyresults,
		Zip_Code, cast(format(avg(SoldPrice), 'f0') as int) as avgrent
	from Residential
	where category = 'resl' and (Status = 'closed' or Status = 'pending' or status = 'activeundercontract')
	group by
		case when datepart(year, settleddate) = 2022 then 2022
		when datepart(year, settleddate) = 2023 then 2023 end,
		case when datepart(quarter, settleddate) = 1 then '1st quarter'
		when datepart(quarter, settleddate) = 2 then '2nd quarter'
		when datepart(quarter, settleddate) = 3 then '3rd quarter'
		when datepart(quarter, settleddate) = 4 then '4th quarter' end, Zip_Code) as renttbl
on renttbl.yearlyresults = pricetbl.yearlyresults AND renttbl.quarterlyresults = pricetbl.quarterlyresults AND renttbl.Zip_Code = pricetbl.Zip_Code
order by Year, Quarter, ZipCode