--Add down payment (20%), interest (8%), insurance, and monthly payment
Alter Table Residential
ADD DownPayment20 int, Interest float, insurance float, MonthlyPayment int;


Update Residential
set DownPayment20 = SoldPrice*.2
where Category = 'ress';

Update Residential
set Interest = .08
where Category = 'ress';

Update Residential
set Insurance = round(SoldPrice*.0055556, 0)
where category = 'ress';


--Principal and interest
update Residential
set MonthlyPayment =
	((SoldPrice - DownPayment20)*(Interest/12))/(1-(1/(power((1+(Interest/12)),360))));


--Final monthly payment
Update residential
set MonthlyPayment = case
	when associationfeefrequency = 'monthly' and associationfee is not null then monthlypayment + (TaxAnnualTotal/12) + (insurance/12) + AssociationFee
	when associationfeefrequency = 'quarterly' and associationfee is not null then monthlypayment + (TaxAnnualTotal/12) + (insurance/12) + (AssociationFee/4)
	when associationfeefrequency = 'semiannually' and associationfee is not null then monthlypayment + (TaxAnnualTotal/12) + (insurance/12) + (AssociationFee/6)
	when associationfeefrequency = 'annually' and associationfee is not null then monthlypayment + (TaxAnnualTotal/12) + (insurance/12) + (AssociationFee/12)
	else monthlypayment + (TaxAnnualTotal/12) + (insurance/12) end
where Category = 'ress';


--Tax amounts for residential sale is required for calculations. Null values will be deleted from table.
Delete from Residential
where TaxAnnualTotal is null and category = 'ress';