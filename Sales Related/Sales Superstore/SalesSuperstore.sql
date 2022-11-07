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
/*South and Central regions are the worst profitable sources within company sales consistently. */

--Finding the most profitable month by year
with dp as (
	select 
			extract(month from order_date ) as month, 
			extract(year from order_date) as year,
			round(sum(profit),2) as monthly_profit,
			round(sum(sales),2) as monthly_sales
	from salesforce
	group by month, year
	order by month, year)
select month,year, monthly_profit, monthly_sales from dp
order by monthly_profit desc
;
/*Using windows functions we can find the revenue growth every month with a where statement for
year to make the table cleaner.*/
with 
	monthly_revenue as (
		select 
			extract(month from order_date ) as month,
			extract(year from order_date) as year,
			round(sum(sales),2) as revenue
		from salesforce
		group by month, year
),
	prev_month_revenue as (
		select 
				* ,
				lag(revenue) over (order by month) as prev_month_rev
		from monthly_revenue
		where year = '2014'
	)
select
		*,
		round(100*(revenue-prev_month_rev)/prev_month_rev,1) as revenue_growth
from prev_month_revenue 
;
--Diving deeper we can examine revenue growth within states using partition by
with 
	monthly_revenue as (
		select 
			state,
			extract(month from order_date ) as month,
			extract(year from order_date) as year,
			round(sum(sales),2) as revenue
		from salesforce
		group by month, year, state
),
	prev_month_revenue as (
		select 
				* ,
				lag(revenue) over (partition by state order by month) as prev_month_rev
		from monthly_revenue
		where year ='2014' and state = 'Alabama'
	)
select
		*,
		round(100*(revenue-prev_month_rev)/prev_month_rev,1) as revenue_growth
from prev_month_revenue 

/*Company profits steady increased from 2014. Higher profit during fall/winter months. Large
drop off in profit and sales on 02/17, 04/17 in sales and profits 
however 3rd highest profits on 03/17*/

--Most profitable state
select state, round(sum(profit),2) as total_profit from salesforce
group by state
order by total_profit desc
;
/*Large metropolitan states source of highest sales. However TX, OH, PA, IL have net loss. Need
to look deeper.*/ 
select 
		state, 
		category,
		round(sum(profit),2) as total_profit,
		round(sum(sales),2) as total_sales,
		round(sum(quantity),2) as total_units
from salesforce
where state in ('Texas', 'Ohio', 'Pennsylvania', 'Illinois')
group by state, category
order by total_profit 
;
select 
		state, 
		sub_category,
		round(sum(profit),2) as total_profit,
		round(sum(sales),2) as total_sales,
		round(sum(quantity),2) as total_units
from salesforce
where state in ('Texas', 'Ohio', 'Pennsylvania', 'Illinois')
group by state, sub_category
order by total_profit 
;
/*Binders a source of the highest net loss.  Phones in Texas has the highest sales however, the highest
profits but sales to profit ratio is quite same compared to other sales not queried. */

--Category performances
select 
		category, 
		round(sum(sales),2) as total_sales, 
		round(sum(profit),2) as total_profit 
from salesforce
group by category
order by total_sales desc
;
select 
		state, 
		category,
		round(sum(profit),2) as total_profit,
		round(sum(sales),2) as total_sales,
		round(sum(quantity),2) as total_units
from salesforce
where state in ('Texas', 'Ohio', 'Pennsylvania', 'Illinois') and category = 'Furniture'
group by state, category
order by total_profit  
;
-- Let's see how the profit margins line up with each category
select 	
		category,
		round(sum(profit),2) as total_profit,
		round(100 * sum(profit) / sum(sales), 2) as profit_margin
	from salesforce
group by category
order by profit_margin desc
;

/*Sales are divided almost equally however, the profit margin is quite low for Furniture compared to
other categories. Likewise, west and east regions make up for losses for other regions however,
profit margins cannot be kept up every month to makeup the loss as seen previously.*/


--Worst performing sub_categories

select 
		sub_category,
		round(100* sum(profit) / sum(sales),2) as profit_margin
from salesforce
group by sub_category
order by profit_margin desc
;
/* Several sub categories have high profit margins that are nearly double others. Some furniture
items are being sold at a loss */

select 
		sub_category,
		year,
		profit
from ( select 
	  			sub_category,
	  			year,
	  			profit,
	  			row_number() over(order by profit desc) as rnk
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
/* Running the subquery, we can see that Tables are consistently making a new loss every year. Likewise,
we find copiers, paper as a top earner every years as well. Although labels, paper, envelopes have
the highest profit margins, they're not the largest gainers. */

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

/* Given the negative profit margins in mostly central and southern regional states, how does returns
contribute to net loss */

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
select 
		ship_mode, 
		sum(quantity) as total_units,
		round(100*sum(quantity)/sum(sum(quantity)) over(),2) as total_shipping
from salesforce
group by ship_mode
order by total_units desc
;
/*40% of goods sold are sold at a higher shipping cost. How many are returned? */
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
group by sub_category, ship_mode
order by total_units desc
;
select sub_category, ship_mode, sum(quantity) as total_units from salesforce
where sub_category in ('Supplies','Bookcases','Tables')
group by sub_category, ship_mode
order by total_units desc
;
/*Given the sub categories with the lowest profit margins, they aren't the highest product returned.
The top 5 returned products still range within 10-25% profit margins. While Paper ranks 2nd with the 
2nd highest profit margins as well. */

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
select 
		region,
		sum(quantity) as total_units, 
		round(sum(profit),2) as total_profit, 
		count(r.order_id) as total_returns 
from salesforce sf
inner join returns r
	on sf.order_id = r.order_id
group by region
order by total_returns desc
;
/* Central has the 2nd least amount of returns however, the greatest net loss. West region returns
have the highest amount but the low cost items as well as being the most profitable region. Returns
effect profits but depends on the price of products */

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
--Segment Analysis
select 
		segment,
		round(100 * sum(profit) / sum(sales), 2) as profit_margin
from salesforce
group by segment
order by profit_margin desc
;

select 
		segment,
		round(sum(sales),2),
		round(sum(sales)/sum(sum(sales)) over () , 2) as revenue_share
from salesforce
group by segment
 
/*Consumers contribute the most to sales even with lower profit margins. This is most likely
contributed with high quantity of sales. */
