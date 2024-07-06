-- Sales | [dbo].[FactInternetSales]
-- Products | [dbo].[DimProduct] / [dbo].[DimProductCategory] / [dbo].[DimProductSubcategory]
-- Customers | [dbo].[DimCustomer]
-- Dates | [dbo].[DimDate]
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

with customer as (
	select 
		cust.CustomerKey,
		cust.FirstName,
		cust.LastName,
		concat(cust.FirstName,' ',cust.LastName) FullName,
		case
			when cust.Gender = 'M' then 'Male'
			else 'Female' 
		end as Gender,
		cust.datefirstpurchase First_Purchase,
		geo.City Customer_City,
		geo.EnglishCountryRegionName Customer_Country
	from dbo.DimCustomer cust
	left join dbo.DimGeography geo
	on cust.GeographyKey = geo.GeographyKey
	),
product as (
		select
			distinct
			p.ProductKey,
			p.EnglishProductName Product_Name,
			p.color,
			p.Size,
			p.ModelName,
			ps.EnglishProductSubcategoryName Product_Sub_Category,
			pc.EnglishProductCategoryName Product_Category,
			isnull (p.Status,'Outdated') Product_Status
		from dbo.DimProduct p
		left join dbo.DimProductSubcategory ps
		on p.ProductSubcategoryKey = ps.ProductSubcategoryKey
		left join dbo.DimProductCategory pc
		on ps.ProductCategoryKey = pc.ProductCategoryKey
		)
select
	dt.CalendarYear Year,
	dt.CalendarQuarter Quarter,
	dt.EnglishMonthName Month,
	left(dt.EnglishMonthName, 3) Month_Short,
	dt.MonthNumberOfYear Month_of_Year,
	dt.WeekNumberOfYear Week_of_Year,
	dt.DayNumberOfMonth Day_of_Month,
	dt.EnglishDayNameOfWeek Day,
	dt.DayNumberOfWeek Day_of_Week,
	dt.FullDateAlternateKey Date,
	cust.FirstName,
	cust.LastName,
	cust.FullName,
	cust.Gender,
	cust.Customer_City,
	cust.Customer_Country,
	prod.Product_Name,
	prod.Product_Sub_Category,
	prod.Product_Category,
	fs.SalesOrderNumber,
	fs.SalesAmount
from dbo.FactInternetSales fs
inner join (
			select *
			from dbo.DimDate
			where CalendarYear >=2022 -- YEAR(GETDATE())-2 
			) dt
on fs.OrderDateKey = dt.DateKey
left join customer cust
on fs.CustomerKey = cust.CustomerKey
left join product prod
on fs.ProductKey = prod.ProductKey
order by date; 

