create table hospitalcharges (
	uniqueid serial primary key,
	drgdef varchar(150),
	providerid integer,
	providername varchar(100),
	address varchar(50),
	city varchar(50),
	state varchar(2),
	zipcode varchar(5),
	region varchar(50),
	totaldischarge numeric,
	avgcovercost numeric,
	avgtotalpay numeric,
	avgmedicarepay numeric);

select * from hospitalcharges;
---nulls
select * from hospitalcharges
where not (hospitalcharges is not null);
--duplicates
select providerid from hospitalcharges 
group by providerid
having count(*) > 1;
--top treatments
select drgdef, count(drgdef) as total_op from hospitalcharges
group by drgdef
order by total_op desc;
-- State costs
select state, 
	max(avgcovercost) as maxcover, 
	max(avgtotalpay) as maxtotal,
	max(avgmedicarepay) as maxmedicare
	from hospitalcharges
group by state
order by maxcover, maxtotal, maxmedicare;

select drgdef, 
	sum(totaldischarge) as totaldischarge,
	round(avg(avgcovercost),2) as avgcovercost, 
	round(avg(avgtotalpay),2) as avgtotalpay,
	round(avg(avgmedicarepay),2) as avgmedicare
	from hospitalcharges
group by drgdef
order by totaldischarge desc
/*Quality of treatment vs cost, treatment availablity vs cost */

select drgdef, round(avg(avgtotalpay),2) as avgtotalpay from hospitalcharges
group by drgdef
order by avgtotalpay desc;

select drgdef, round(variance(avgtotalpay),2) as variance 
from hospitalcharges
group by drgdef
order by variance desc;

--top states per drgdef
select drgdef , state, avgtotalpay
from 
(select 
	drgdef,state,avgtotalpay,
	row_number() over (partition by drgdef order by avgtotalpay desc) rn
	from hospitalcharges) a
where rn = 1;
/*Highest total payment by state for ea treatment*/

select drgdef,state,avgtotalpay
from (
	select drgdef,state,avgtotalpay,
	rank() over(order by avgtotalpay desc) rnk
	from hospitalcharges) a
where rnk <= 10
-- Total types of treatments by state
select drgdef, state, count(drgdef) as totaltreatments from hospitalcharges
group by drgdef,state
order by totaltreatments desc;


/*Joining with hospitalinfo analysis*/

-- rating with avgtotalpayment
with hospital as(
	select 
			hi.hospitalname as name,
			hi.state as state, 
			hi.hospitalrating as rating, 
			hc.avgtotalpay as avgtotalpay,
			hc.avgcovercost as avgcovercost,
			hc.avgmedicarepay as avgmedicarepay
	from hospitalinfo_bckup hi
	inner join hospitalcharges hc
	on hi.providerid = hc.providerid
	order by hc.avgtotalpay desc
)
select name, state, rating, round(avg(avgtotalpay),2) as avgtotalpay from hospital
group by name , state, rating 
order by avgtotalpay desc;
/*Relationship between rating as cost? Factor in treatment types */
with hospital as(
	select 
			hi.hospitalname as name,
			hi.state as state, 
			hi.hospitalrating as rating, 
			hc.drgdef as treatment,
			hc.avgtotalpay as avgtotalpay,
			hc.avgcovercost as avgcovercost,
			hc.avgmedicarepay as avgmedicarepay
	from hospitalinfo_bckup hi
	inner join hospitalcharges hc
	on hi.providerid = hc.providerid
	order by hc.avgtotalpay desc
)
select name, state, rating, treatment, round(avg(avgtotalpay),2) as avgtotalpay from hospital
group by name , state, rating , treatment
order by avgtotalpay desc;

--Specific States
with hospital as(
	select 
			hi.hospitalname as name,
			hi.state as state, 
			hi.hospitalrating as rating, 
			hc.avgtotalpay as avgtotalpay,
			hc.avgcovercost as avgcovercost,
			hc.avgmedicarepay as avgmedicarepay
	from hospitalinfo_bckup hi
	inner join hospitalcharges hc
	on hi.providerid = hc.providerid
	order by hc.avgtotalpay desc
)
select name , state, rating , round(avg(avgtotalpay),2) as avgtotalpay from hospital
where rating not like '%Not%' and state ='DC'
group by name, state, rating
order by avgtotalpay desc;

-- Type + Cost 
select hi.state, hi.hospitaltype, round(avg(hc.avgtotalpay),2) as avgpayment from hospitalinfo_bckup hi
left join hospitalcharges hc
	on hi.providerid = hc.providerid 
where hc.avgtotalpay notnull
group by hi.hospitaltype,hi.state
order by avgpayment desc;

select hi.hospitalownership, round(avg(hc.avgtotalpay),2) as avgpayment from hospitalinfo_bckup hi
inner join hospitalcharges hc
	on hi.providerid = hc.providerid
group by hi.hospitalownership
order by avgpayment desc;



