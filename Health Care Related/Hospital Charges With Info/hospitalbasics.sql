create table hospitalinfo (
	providerid integer primary key,
	hospitalname varchar(100),
	address varchar(100),
	city varchar(100),
	state varchar(2),
	zipcode varchar(5),
	countyname varchar(50),
	phonenumber varchar(10),
	hospitaltype varchar(50),
	hospitalownership varchar(100),
	emergencyservice varchar(3),
	ehrmet varchar(5),
	hospitalrating varchar(5)
);
select * from hospitalinfo;
--Show all nulls
select * from hospitalinfo
where NOT(hospitalinfo IS NOT NULL)
order by hospitalname;
--Check for duplicates
select * from hospitalinfo h1
	where (select count(*) from hospitalinfo h2
		  	where h1.hospitalname = h2.hospitalname
		  	and h1.zipcode = h2.zipcode) >1;
	--Alternative method using window functions
		/*select * from (
			select providerid,
				count(*) over (partition by providerid) as c1 from hospitalinfo)h1 
				where c1 >1;*/
--Drop NA, children hospital types are missing ratings. Create view alternative
select count(hospitalrating) from hospitalinfo
where hospitalrating = 'Not Available';

delete from hospitalinfo 
where hospitalrating = 'Not Available';

--Total hospitals per state
select state, count(state) as total_hospital from hospitalinfo
group by state
order by total_hospital desc;
/*Relationship between population  # of hospitals?*/

--Hospital types//dropped childrens
select hospitaltype, count(hospitaltype) from hospitalinfo
group by hospitaltype;
--Ownerships
select hospitalownership, count(hospitalownership) as total_ownership_type from hospitalinfo
group by hospitalownership 
order by hospitalownership, total_ownership_type desc;

/*	select count(hospitalownership) as gov_owner from hospitalinfo
where hospitalownership like 'Gov%'
Majority of hospitals in US are non-profit
*/

--conditional aggregation, count(case()) provides total of all ownerships
select 
		sum(case when hospitalownership like 'Gov%' then 1 else 0 end) as "gov_owned",
		sum(case when hospitalownership like 'Vol%' then 1 else 0 end) as "vol_owned"
from hospitalinfo

-- Ratings counted
select hospitalrating, count(hospitalrating) as total_hospitals from hospitalinfo
group by hospitalrating
order by hospitalrating;
/*Quality of hospitals in US? Bell curved*/

--Avg ratings by state (before data type change)
select state, round(avg(cast(hospitalrating as decimal (10,2))),2) as avg_hospital_ratings
from hospitalinfo
group by state
order by avg_hospital_ratings
limit 5;
/* 4/5 of worst rated hospitals located in east coast */

-- alternative ratings calc
/*select h1.state, round(avg(cast(h1.hospitalrating as decimal (10,2))),2) as avg_hospital_ratings
	from hospitalinfo h1
	inner join hospitalinfo h2
	on h1.providerid = h2.providerid 
	group by h1.state
	order by avg_hospital_ratings desc
limit 5; */

--Ratings in lowest avg state
select hospitalrating, count(hospitalrating) from hospitalinfo
where state = 'DC'
group by hospitalrating;

-- Number of hospitals per state
/*select h1.state, count(h1.hospitalrating)
	from hospitalinfo h1
	inner join hospitalinfo h2
	on h1.providerid = h2.providerid 
	group by h1.state
	order by count(h1.hospitalrating) desc
limit 5;*/

--Change type for easier calc (removed NA ratings)
alter table hospitalinfo
alter column hospitalrating type integer
using hospitalrating::integer

--Most 5 rating hospitals by state
select state,count(hospitalrating) from hospitalinfo
	where hospitalrating = '5'
	group by state
	order by count(hospitalrating) desc
	limit 10;
--Finding the ratio of X ratings per total rating
select state,
		round(100 * sum(hospitalrating) / sum(sum(hospitalrating)) over (),2) as ratings
	from hospitalinfo
where hospitalrating = '5'
group by state
order by ratings desc;
/* 13.41% of total 5 collected ratings located in Texas 
(total sum per state / sum of all ratings)
*/

--Most 1 ratings ratio
select state,
	round(100*sum(hospitalrating)/sum(sum(hospitalrating)) over(),2) as lowestratio
	from hospitalinfo
where hospitalrating = '1'
group by state
order by lowestratio desc;
/* NY staggering amount of 1 ratings */

select state,
	count(hospitalrating) as oneratings
	from hospitalinfo
where hospitalrating = '1'
group by state
order by oneratings desc;
/*TX and CA has the largest total of hospitals in the US however, lowest total 1 ratings*/
select hospitalrating,
	count(hospitalrating) as TXratings
	from hospitalinfo
where state = 'TX'
group by hospitalrating
--Using CTE, easier calculations
	with ratingcte as (
	select state, hospitalrating as rating, count(hospitalrating) as totalrating 
	from hospitalinfo
	group by state, hospitalrating
	order by hospitalrating desc)

	select rating, totalrating from ratingcte
	where state = 'TX'
