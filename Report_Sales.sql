 /*
 With checkdup as
(
	Select  *,
		ROW_NUMBER() over(partition by [OrderNumber],[CustomerCode],[OrderDate],[Product Code],[Revenue] order by OrderNumber) as dup
	From [Transaction Detail] 	
)
Select * 
From checkdup
Where dup = 1
*/
-- Xem qua tất cả các bảng thì data đã sạch. Giờ sẽ xem chi tiết để hiểu data -> [Data Dictionary]


with CUS as 
(
	Select 
	CustomerCode,
	ROW_NUMBER() Over (partition by CustomerCode Order by CustomerCode) as rownum
	from [Transaction Detail] 
) -- đánh số thứ tự để xác định số lần mua hàng
, repeat_buyers as (
select distinct 
	 CustomerCode
FROM CUS
where  rownum > 1 -- > 1 thì mua lại tức returning
)

, first_purchase as (
select distinct
	  CustomerCode
FROM CUS
where  rownum = 1  --> 1 nên là mua lần đầu
)

select 
	(case
		when r.CustomerCode IS NOT NULL
		then 'repeat'
		else 'new'
		end 
	 ) as Type,
	 count(*) as number_of_customer, -- tính số khách hàng cho 2 loại là rời bỏ hay quay lại mua hàng

	 (	
	 select count(distinct CustomerCode)
			from CUS
	 ) as total_customers, -- tổng số khách hàng

        FORMAT(cast(count(*) as decimal(18,2))
		/
		cast(
	 ( select 
		  count(distinct CustomerCode)
	   from CUS) as decimal(18,2)), 'P') as repeat_rate
from first_purchase f 
left join  repeat_buyers r on f.CustomerCode = r.CustomerCode
group by 
	case
		when r.CustomerCode IS NOT NULL
		then 'repeat'
		else 'new'
		end
-- Vừa xem tỉ lệ quay lại mua thì nhận ra là công ty thuộc diện chuyên phân phối sll và khách hàng là các đối tác lớn(B2B)
-- Tỷ lệ quay lại mua hàng ko có ý nghĩa

--//////////////////
-- Tổng doanh thu theo năm 
Select 
	YEAR(OrderDate) as Year,
	Round(SUM(Revenue),1) as Total_Revenue
From [Transaction Detail]
Group By YEAR(OrderDate)
--Lợi nhuận theo năm
Select 
	YEAR(OrderDate) as Year,
	Round(SUM(Revenue)- SUM(Costs),1) as Profit
From [Transaction Detail]
Group By YEAR(OrderDate)

--Loại khách hàng cùng doanh thu mang lại 
Select 
	[Customer Type] as Customer_Type,
	Round(sum(Revenue),1) as Revenue
From [Transaction Detail]
Group By [Customer Type]
--Lợi nhuận theo ngành hàng
Select 
	[Customer Type] as Customer_Type,
	Round(SUM(Revenue)- SUM(Costs),1) as Profit
From [Transaction Detail]
Group By [Customer Type]
--Doanh thu lợi nhuận từng khách hàng mang lại
Select 
	CustomerName,
	Round(sum(Revenue),1) as Revenue,
	Round(SUM(Revenue)- SUM(Costs),1) as Profit
From [Transaction Detail]
Group By CustomerName
Order By 1 DESC
--Top 10 mã khách hàng mang lại nhiều lợi nhuận nhiều nhất
Select 
	Top 6 [Product Code],
	Round(sum(Revenue),1) as Revenue,
	Round(SUM(Revenue)- SUM(Costs),1) as Profit
From [Transaction Detail]
Group By [Product Code]
Order By Profit DESC


