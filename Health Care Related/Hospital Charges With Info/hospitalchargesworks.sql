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
select drgdef, count(drgdef) as totalop from hospitalcharges
group by drgdef
order by totalop desc;
--
select state, 
	max(avgcovercost) as maxcover, 
	max(avgtotalpay) as maxtotal,
	max(avgmedicarepay) as maxmedicare
	from hospitalcharges
group by state
order by maxcover desc;

select drgdef, 
	sum(totaldischarge) as totaldischarge,
	round(avg(avgcovercost),2) as avgcovercost, 
	round(avg(avgtotalpay),2) as avgtotalpay,
	round(avg(avgmedicarepay),2) as avgmedicare
	from hospitalcharges
group by drgdef
order by totaldischarge desc

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
where rn = 1

select drgdef,state,avgtotalpay
from (
	select drgdef,state,avgtotalpay,
	rank() over(order by avgtotalpay desc) rnk
	from hospitalcharges) a
where rnk <= 10
-- 
select drgdef, state, count(drgdef) as totaltreatments from hospitalcharges
group by drgdef,state
order by totaltreatments desc;

/*Joining with hospitalinfo analysis*/

-- rating with avgtotalpayment
select hi.hospitalname,hi.state, hi.hospitalrating, hc.avgtotalpay from hospitalinfo_bckup hi
inner join hospitalcharges hc
on hi.providerid = hc.providerid
order by hc.avgtotalpay desc;

select hi.hospitalname, hi.state, hi.hospitalrating, hc.avgtotalpay from hospitalinfo_bckup hi
inner join hospitalcharges hc
on hi.providerid = hc.providerid
where hi.hospitalrating not like '%Not%' and hi.state ='DC'
order by hc.avgtotalpay desc;
--in ('1','2','3','4','5')
--
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



