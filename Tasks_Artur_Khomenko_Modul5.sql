Use modul5;

go
----------------------TASKS With SubQuery--------------------
--1 
Select productid
	from [dbo].[products]
		Where  productid in (Select productid	
					from [dbo].[supplies]
						where detailid = All(Select detailid
																	from supplies
																		Where supplierid = 3) )
		
--2
Select supplierid, name
	from [dbo].[suppliers]
		Where supplierid in ( Select supplierid 
					from [dbo].[supplies] as s
						Where  quantity > (Select AVG(quantity)
									 from [dbo].[supplies]
										where detailid = 1 
											and productid = s.productid
																		) 
							)

--3

Select detailid, name
	from [dbo].[details]
		Where detailid in ( Select detailid
					from [dbo].[supplies]
						Where productid in ( Select productid
									from [dbo].[products]
										Where city = 'London'  )	)

--4
Select supplierid, name
	from [dbo].[suppliers]
		Where supplierid in ( Select  supplierid
					from [dbo].[supplies]
						where detailid in ( Select detailid
									from [dbo].[details]
										where color = 'Red' )
							)
	
--5
Select detailid
	from [dbo].[details]
		Where detailid in ( Select detailid
					from [dbo].[supplies]
						where supplierid in ( Select supplierid
									from [dbo].[suppliers]
									Where supplierid = 2))

--6

Select productid
	from [dbo].[products]
		where productid in ( Select productid
					from [dbo].[supplies]
					Group by productid
					Having AVG(quantity) > (Select MAX(quantity)
								from [dbo].[supplies]
								Where productid = 1) 
																	
										 )


--7
Select productid
	from products
		Where productid  not in ( Select productid
					from [dbo].[supplies]
									 )
		


-------------------------Tasks with UNION, UNION ALL , EXCEPT, INTERSECT---------------------------

--1

Select supplierid, name, city 
	from [dbo].[suppliers]
		Where city = 'London'

	Union

Select supplierid, name, city 
	from [dbo].[suppliers]
		Where city = 'Paris'



--2
Select city
	from [dbo].[suppliers]
		UNION all
Select city
	from [dbo].[details]
		order by city

Select city
	from [dbo].[suppliers]
		UNION
Select city
	from [dbo].[details]
	order by city


--3

Select *
	from  [dbo].[suppliers]	
	EXCEPT
Select *
	from  [dbo].[suppliers]
		Where supplierid in ( Select supplierid
						from [dbo].[supplies]
							Where detailid in ( Select detailid
								from [dbo].[details]
									Where city = 'London') )
																
 
--4
Select productid, city
	from [dbo].[products]
		Where city in ('London', 'Paris')
	EXCEPT
Select productid, city
	from [dbo].[products]
		Where city in ('Paris','Roma')


--5
Select supplierid, detailid, productid
	from [dbo].[supplies]
		Where supplierid in ( Select supplierid
					from suppliers
						Where city = 'London')
		UNION

Select supplierid, detailid, productid
	from [dbo].[supplies]
		Where detailid in ( Select detailid
					from details
						Where color = 'Green')
							and productid in ( Select productid
								from [dbo].[products]
									Where city <> 'Paris')



---------------------------------TASKS WITH CTE--------------------------------------
--1
;With cte as(
	Select 1 as c,2 as d
	UNION ALL
	Select  c+1,d + 100
		from cte
			Where c < 110	
			),
	cte_2 as(
	Select d + 10 as d2
		from cte
	)

Select *
	from cte_2
OPTION(MAXRECURSION 0)

--2
;With Factorial as 
(
	Select 1 as Position , 1 as Value
	Union All
	Select  Position + 1,  ( Position + 1) * Value
		from Factorial
			Where  Position < 10
)

Select Position, Value
	from Factorial

--3
  
;With fibonacci as (
      Select 1 as Position, 1 as Value, 0 as n1
      Union all
      Select Position + 1, Value + n1, Value
      from fibonacci 
      Where Position < 20
     )
Select Position, Value
from fibonacci

--3 
;With cte as 

(
	Select cast('2013-11-25'as date) as Date1

	Union all

	Select dateadd(DAY,1,Date1 )
		from cte
			Where Date1 < '2014-03-05'
)
Select MIN(Date1) as StartDate, MAX(Date1) as EndDate
	from  (Select Date1, datepart(mm, Date1) as Month1
		from cte) as a
	Group by Month1

--4
SET Datefirst  1
Declare @first as int = DATEPART(WEEKDAY, '2019-05-01')

;With cte as 
(
	Select @first as num, cast('2019-05-01'as date) as date1

	Union all

	Select num + 1,  dateadd(dd,1,date1) 
		from cte
			Where date1 < '2019-05-31'
)
		Select
		Max(Monday) as Monday,
		Max(Tuesday) as Tuesday,
		Max(Wendesday) as Wendesday,
		Max(Thursday) as Thursday,
		Max(Friday) as Friday,
		Max(Saturday) as Saturday,
		Max(Sunday) as Sunday
			from (
			Select (num /7)+1 as weeknum ,
			case When (num % 7) = 1 Then  DATENAME(dd, date1)  End as Monday,
			case When (num % 7) = 2 Then  DATENAME(dd, date1) End as Tuesday,
			case When (num % 7) = 3 Then  DATENAME(dd, date1) End as Wendesday,
			case When (num % 7) = 4 Then  DATENAME(dd, date1) End as Thursday,
			case When (num % 7) = 5 Then  DATENAME(dd, date1) End as Friday,
			case When (num % 7) = 6 Then  DATENAME(dd, date1) End as Saturday,
			case When (num % 7) = 0 Then  DATENAME(dd, date1) End as Sunday
				from cte) as a
			group by weeknum

--5

;With cte as 
(
	Select  region_id, id, name, 0 as place_level
		from [dbo].[geography] 
			WHere region_id is NULL	

	Union All

	Select g2.region_id, g2.id as place_id, g2.name, cte.place_level + 1 as place_level
		from [dbo].[geography] as g2 
			 join cte ON  g2.region_id = cte.id
				

)

Select * 
	from cte
		Where place_level = 1

--6
;with cte as 
(
	Select region_id, id , name, 0 as place_level
		from [dbo].[geography]
			Where region_id = 4
			
	Union All

	Select g2.region_id , g2.id , g2.name, cte.place_level + 1 as place_level
		from [dbo].[geography] as g2 
			join cte ON cte.id = g2.region_id
				
)			
Select *
	from  cte 
		
--7

;with cte as 
(
	Select region_id, id , name, 0 as place_level
		from [dbo].[geography]
			Where region_id is Null

	Union All

	Select g2.region_id , g2.id , g2.name, cte.place_level + 1 as place_level
		from [dbo].[geography] as g2 
			join cte ON cte.id = g2.region_id
				
)			
Select *
	from  cte 

--8

;With cte as 
	(
		Select name,id ,region_id,1 as place_level
			from [dbo].[geography]
				Where id = 2

		Union All

		Select g2.name, g2.id ,g2.region_id ,  cte.place_level + 1 as place_level
			from [dbo].[geography] as g2 
				join cte ON cte.id = g2.region_id
				
	)			
	Select *
		from  cte 
		
--9

;With cte as 
(
	Select name,id, 1 as place_id,--cast(''as varchar(2000)) as parentpath ,
	 cast('/' + name as varchar(2000) ) as path
		from [dbo].[geography]
			Where id = 2

	Union All

	Select g2.name,g2.id, place_id + 1,
	--cast(isnull(cte.parentpath, '') + '/' + cte.name as varchar(2000)),
	cast(cte.path + '/' + g2.name as varchar (2000))
		from [dbo].[geography] as g2 
			join cte ON cte.id = g2.region_id
				
)			
Select name, place_id, path
	from  cte
	
--10
;with cte as 
(
	Select name,id,region_id, 0 as pathlen,
	 cast('/' + name as varchar(2000) ) as path
		from [dbo].[geography]
			Where id = 2
				 

	Union All

	Select g2.name,g2.id, g2.region_id,pathlen + 1,
	cast(cte.path + '/' + g2.name as varchar (2000))
		from [dbo].[geography] as g2 
			join cte ON cte.id = g2.region_id
							
)			
Select name,pathlen, path
	from  cte 
	
		
	
