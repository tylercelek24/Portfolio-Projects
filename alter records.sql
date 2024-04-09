--Principal and interest
update Residential
set MonthlyPayment =
	((SoldPrice - DownPayment20)*(Interest/12))/(1-(1/(power((1+(Interest/12)),360))));


--Add down payment (20%), interest (8%), and insurance
Alter Table Residential
ADD DownPayment20 int, Interest float, insurance float;

Update Residential
set DownPayment20 = SoldPrice*.2
where Category = 'ress';

Update Residential
set Interest = .08
where Category = 'ress';

Update Residential
set Insurance = round(SoldPrice*.0055556, 0)
where category = 'ress';


--Final monthly payment
Update residential
set MonthlyPayment = case
	when associationfeefrequency = 'monthly' then monthlypayment + (TaxAnnualTotal/12) + (insurance/12) + AssociationFee
	when associationfeefrequency = 'quarterly' then monthlypayment + (TaxAnnualTotal/12) + (insurance/12) + (AssociationFee/4)
	when associationfeefrequency = 'annually' then monthlypayment + (TaxAnnualTotal/12) + (insurance/12) + (AssociationFee/12)
	else monthlypayment + (TaxAnnualTotal/12) + (insurance/12) end
where Category = 'ress';


--Remove incomplete data
delete from Residential
where TaxAnnualTotal = 0 or TaxAnnualTotal > 100000;