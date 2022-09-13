/*Rental Demand by Genre and Total Sales
count(distinct cust.customer_id)*/
with t1 as (
			select cat.name as genre, count(cust.customer_id) as total_customers
			from category cat
				inner join film_category fcat
					on cat.category_id = fcat.category_id
				inner join film f
					on fcat.film_id = f.film_id
				inner join inventory inv
					on f.film_id = inv.film_id
				inner join rental rent
					on inv.inventory_id = rent.inventory_id
				inner join customer cust
					on rent.customer_id = cust.customer_id
			group by genre
			order by total_customers desc),
 	t2 as (
			select cat.name as genre, sum(pay.amount) as total_sales
			from category cat
				inner join film_category fcat
					on cat.category_id = fcat.category_id
				inner join film f
					on fcat.film_id = f.film_id
				inner join inventory inv
					on f.film_id = inv.film_id
				inner join rental rent
					on inv.inventory_id = rent.inventory_id
				inner join payment pay
					on rent.rental_id = pay.rental_id
			group by genre
			order by total_sales desc)	
			
select t1.genre, total_customers, total_sales from t1
inner join t2
	on t1.genre = t2.genre
;

select title , rating, count(i.film_id) as total_rental from film f
inner join inventory i
	on f.film_id = i.film_id
inner join rental r
	on i.inventory_id = r.inventory_id
group by title, rating
order by total_rental desc
;

select rating, count(i.film_id) as total_rental from film f
inner join inventory i
	on f.film_id = i.film_id
inner join rental r
	on i.inventory_id = r.inventory_id
group by rating
order by total_rental desc
;

select country, count(*) as total_customers, sum(amount) as total_sales from country c
inner join city ct
	on c.country_id = ct.country_id
inner join address ad
	on ct.city_id = ad.city_id
inner join customer cu
	on ad.address_id = cu.address_id
inner join payment p
	on cu.customer_id = p.customer_id
group by country
order by total_sales desc
;

select 
		store_id,
		sum(amount) as total_sales
from payment p
inner join rental r
	on p.rental_id = r.rental_id
inner join inventory i
	on r.inventory_id = i.inventory_id
group by store_id
;

/*Rental Return Times */

with dd as 
	(select 
	 	*,
	 	extract(day from return_date - rental_date) as date_difference from rental
	),
rd as 
	(select 
		rental_duration, 
		case 
	 		when rental_duration > date_difference then 'Returned Early'
			when rental_duration = date_difference then 'Returned On Time'
			else 'Returned Late'
		end as return_status
	from film f
	inner join inventory i
		on f.film_id = i.film_id 
	inner join dd d
		on i.inventory_id = d.inventory_id)
		
select return_status , count(*) from rd
group by return_status
;

select name, email, total_payment from
	(select 
			concat(first_name ||' '|| last_name) as name,
	 		email,
			sum(amount) as total_payment,
			row_number() over(order by sum(amount) desc) rnk
	from customer c
	inner join payment p
		on c.customer_id = p.customer_id
	group by name, email) py
where rnk <=5
;