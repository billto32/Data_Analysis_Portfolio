create table salesforce (
	row_id serial primary key,
	order_id varchar(100),
	order_date varchar(50),
	ship_date varchar(50),
	ship_mode varchar(50),
	customer_id varchar(50),
	customer_name varchar(50),
	segment varchar(50),
	country varchar(50),
	city varchar(50),
	state varchar(50),
	postal_code varchar(5),
	region varchar(50),
	product_id varchar(50),
	category varchar(50),
	sub_category varchar(50),
	product_name varchar(200),
	sales numeric,
	quanitity integer, 
	discount numeric,
	profit numeric)
;
create table returns (
	returned boolean,
	order_id varchar(100) primary key
)

create table salesrep(
	person varchar(50),
	region varchar(50) primary key
)

select * from salesforce;
select * from returns;
select * from salesrep;

alter table salesforce 
alter column order_date type date
USING order_date::date,
alter column ship_date  type date
USING ship_date::date
;
--Finding the most profitable month by year
with dp as (
	select 
			extract(month from order_date ) as month, 
			extract(year from order_date) as year,
			round(sum(profit),2) as monthly_sum
	from salesforce
	group by month, year
	order by month, year)
select month, monthly_sum from dp
where year = '2014'
order by monthly_sum desc
;
--Most profitable state
select state, round(sum(profit),2) as total_profit from salesforce
group by state
order by total_profit desc
;
--Which state has the highest profit by month,year
select 
		state,
		month,
		year,
		profit
from ( select 
	  			state,
	  			month,
	  			year,
	  			profit,
	  			row_number() over(order by profit desc) as rnk
	 	from (	
	  			select 
						state,
						extract(month from order_date) as month,
						extract(year from order_date) as year,
						round(sum(profit),2) as profit
				from salesforce
				group by state, month, year
			)n
group by state, month , year,profit) n2
where n2.rnk <= 10
;
--Which regions
select 
		region,
		year,
		profit
from ( select 
	  			region,
	  			year,
	  			profit,
	  			row_number() over(order by profit desc) as rnk
	 	from (	
	  			select 
						region,
						extract(year from order_date) as year,
						round(sum(profit),2) as profit
				from salesforce
				group by region, year
			)n
group by region, year,profit) n2
order by profit desc
;

--Worst performing sub_categories
select 
		sub_category,
		year,
		profit
from ( select 
	  			sub_category,
	  			year,
	  			profit,
	  			row_number() over(order by profit) as rnk
	 	from (	
	  			select 
						sub_category,
						extract(year from order_date) as year,
						round(sum(profit),2) as profit
				from salesforce
				group by sub_category, year
			)n
group by sub_category, year,profit) n2
where n2.rnk <= 10
;
--Product with greatest loss
select 
		product_name,
		year,
		profit
from ( select 
	  			product_name,
	  			year,
	  			profit,
	  			row_number() over(order by profit) as rnk
	 	from (	
	  			select 
						product_name,
						extract(year from order_date) as year,
						round(sum(profit),2) as profit
				from salesforce
				group by product_name, year
			)n
group by product_name, year,profit) n2
where n2.rnk <= 10
;

--Fix spelling
alter table salesforce
rename column quanitity to quantity
;

select * from salesforce
;
--Total units sold
select sub_category, sum(quantity) as total_units from salesforce
group by sub_category
order by total_units desc
;
--Method of shipping
select sub_category, ship_mode, sum(quantity) as total_units from salesforce
group by sub_category, ship_mode
order by total_units desc
;
--Relation with returns and profit
select 
		sub_category, 
		sum(quantity) as total_units, 
		round(sum(profit),2) as total_profit, 
		count(r.order_id) as total_returns 
from salesforce sf
inner join returns r
	on sf.order_id = r.order_id
group by sub_category
order by total_profit
;
--Shipping cost?
select sub_category, ship_mode, sum(quantity) as total_units from salesforce
where sub_category in ('Binders','Tables','Machines')
group by sub_category, ship_mode
order by total_units desc
;
--Where are the returns from
select 
		region,
		sub_category, 
		ship_mode,
		sum(quantity) as total_units, 
		round(sum(profit),2) as total_profit, 
		count(r.order_id) as total_returns 
from salesforce sf
inner join returns r
	on sf.order_id = r.order_id
group by region, sub_category, ship_mode
order by total_profit
;
--What product generates most loss
select 
		product_name, 
		sum(quantity) as total_units, 
		round(sum(profit),2) as total_profit
from salesforce 
group by product_name
order by total_profit 
;
--Best salesrep
select person, sf.region, round(sum(sales),2) as total_sales from salesforce sf
inner join salesrep sr
	on sf.region = sr.region
group by person, sf.region
order by total_sales desc
;
