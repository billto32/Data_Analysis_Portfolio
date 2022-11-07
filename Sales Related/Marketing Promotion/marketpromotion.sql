create table market_discount(
	recency text,
	history text,
	used_discount text,
	used_bogo text,
	zipcode text,
	referral text,
	channel text,
	offer text,
	conversion text)
	
select * from market_discount;
select count(*) as potential_customer from market_discount;
--64000 potential customers record
select count(conversion) as total_customers from market_discount
where conversion = '1';
--9394 customer purchases
with p as ( 
		select zipcode, count(conversion) as potential_cust from market_discount
		where conversion = '0'
		group by zipcode),
	c as (
		select zipcode, count(conversion) as total_customers from market_discount
		where conversion = '1'
		group by zipcode)
select 
		p.zipcode, 
		potential_cust, 
		total_customers from p
inner join c
	on p.zipcode =c.zipcode
;
/*Lower percentage of conversions from Rural customers. Suburban and urban have similar conversion 
rates */
with p as ( 
		select channel, count(conversion) as potential_cust from market_discount
		where conversion = '0'
		group by channel),
	c as (
		select channel, count(conversion) as total_customers from market_discount
		where conversion = '1'
		group by channel)
select 
		p.channel, 
		potential_cust, 
		total_customers from p
inner join c
	on p.channel =c.channel
;
/* Similar trend with zipcode, those within suburban and urban locations most likely have more
access to web and phones allowing for more promotion visibility. */

	select offer, count(conversion) from market_discount
	where conversion = '1'
	group by offer

/* Discounts improve quantity of sales*/

