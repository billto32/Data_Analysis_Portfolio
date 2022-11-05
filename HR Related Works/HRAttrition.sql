create table hrattrition (
age text,
attrition text,
businesstravel text,
dailyrate text,
department text,
distancefromhome text,
education text,
educationfield text,
employeecount text,
employeenumber text,
environmentsatisfaction text,
gender text,
hourlyrate text,
jobinvolvment text,
joblevel text,
jobrole text,
jobsatisfaction text,
martialstatus text,
monthlyincome text,
monthlyrate text,
numcompaniesworked text,
over18 text,
overtime text,
percentsalaryhike text,
performancerating text,
relationshipsatisfaction text,
standardhours text,
stockoptionlevel text,
totalworkingyear text,
trainingtimeslastyear text,
worklifebalance text,
yearsatcompany text,
yearsincurrentrole text,
yearssincelastpromotion text,
yearswithcurrmanager text)

select * from hrattrition;

--Fixing data types
alter table hrattrition
alter column age type int
	using age::integer,
alter column dailyrate type int
	using dailyrate::integer,
alter column distancefromhome type int
	using distancefromhome::integer,
alter column education type int
	using education::integer,
alter column employeecount type int
	using employeecount::integer,
alter column employeenumber type int
	using employeenumber::integer,
alter column environmentsatisfaction type int
	using environmentsatisfaction::integer,
alter column hourlyrate type int
	using hourlyrate::integer,
alter column jobinvolvment type int
	using jobinvolvment::integer,
alter column joblevel type int
	using joblevel::integer,
alter column jobsatisfaction type int
	using jobsatisfaction::integer,
alter column monthlyincome type int
	using monthlyincome::integer,
alter column monthlyrate type int
	using monthlyrate::integer,
alter column numcompaniesworked type int
	using numcompaniesworked::integer,
alter column percentsalaryhike type int
	using percentsalaryhike::integer,
alter column performancerating type int
	using performancerating::integer,
alter column relationshipsatisfaction type int
	using relationshipsatisfaction::integer,
alter column standardhours type int
	using standardhours::integer,
alter column stockoptionlevel type int
	using stockoptionlevel::integer,
alter column totalworkingyear type int
	using totalworkingyear::integer,
alter column trainingtimeslastyear type int
	using trainingtimeslastyear::integer,
alter column worklifebalance type int
	using worklifebalance::integer,
alter column yearsatcompany type int
	using yearsatcompany::integer,
alter column yearsincurrentrole type int
	using yearsincurrentrole::integer,
alter column yearssincelastpromotion type int
	using yearssincelastpromotion::integer,
alter column yearswithcurrmanager type int
	using yearswithcurrmanager::integer
;
with a as (
	select gender , count(attrition) as attrition from hrattrition
	where attrition = 'Yes'
	group by gender),
b as (
	select gender , count(attrition) as retention from hrattrition
	where attrition = 'No'
	group by gender)
select a.gender, a.attrition, b.retention from a
inner join b 
	on a.gender = b.gender
group by a.gender ,a.attrition, b.retention
;
/* 13.78% attrition vs 17% attrition rate, minor difference between genders.*/


with a as (
		select 
			sum(
				case when age <20 then 1 else 0
			end) as "<20",
			sum(
				case when age between 21 and 30 then 1 else 0
			end) as "21-30",
			sum(
				case when age between 31 and 40 then 1 else 0
			end) as "31-40",
			sum(
				case when age between 40 and 50 then 1 else 0
			end) as "41-50",
			sum(
				case when age >50 then 1 else 0
			end) as ">50", 
			count(attrition) as attrition from hrattrition
	where attrition = 'Yes'
),
b as (select 
			sum(
				case when age <20 then 1 else 0
			end) as "<20",
			sum(
				case when age between 21 and 30 then 1 else 0
			end) as "21-30",
			sum(
				case when age between 31 and 40 then 1 else 0
			end) as "31-40",
			sum(
				case when age between 40 and 50 then 1 else 0
			end) as "41-50",
			sum(
				case when age >50 then 1 else 0
			end) as ">50", 
			count(attrition) as retention from hrattrition
	where attrition = 'No'
)
select * from a,b
;
select age, count(age) as total_employees from hrattrition
group by age
order by total_employees desc;
/*Most employee turnover rate occurs before 40. Employees start to settle down once they 
look for stability in the career. Employees at a younger age are more likely to move to different
companies possibly better salaries or advancement in their careers.*/

select 
		employeenumber , 
		round(cast(jobsatisfaction + environmentsatisfaction + relationshipsatisfaction as decimal)/3,2) as avgsatisfaction, 
		department, 
		jobrole, 
		performancerating, 
		monthlyincome, 
		percentsalaryhike 
from public.hrattrition
where attrition = 'Yes'
;
--Survey Evaluations
with a as (
	select jobsatisfaction , count(attrition) as attrition from hrattrition
	where attrition = 'Yes'
	group by jobsatisfaction),
b as (
	select jobsatisfaction , count(attrition) as retention from hrattrition
	where attrition = 'No'
	group by jobsatisfaction)
select a.jobsatisfaction, a.attrition, b.retention from a
inner join b 
	on a.jobsatisfaction = b.jobsatisfaction
group by a.jobsatisfaction ,a.attrition, b.retention

/* Employees may look for better opportunities however, a large portion still stay within the company
even while unsatisfied. Attrition rate decreases as employees are more satisfied. Similar trends
through other survey evaluations*/

with a as (
	select environmentsatisfaction , count(attrition) as attrition from hrattrition
	where attrition = 'Yes'
	group by environmentsatisfaction),
b as (
	select environmentsatisfaction , count(attrition) as retention from hrattrition
	where attrition = 'No'
	group by environmentsatisfaction)
select a.environmentsatisfaction, a.attrition, b.retention from a
inner join b 
	on a.environmentsatisfaction = b.environmentsatisfaction
group by a.environmentsatisfaction ,a.attrition, b.retention
order by attrition desc
;
/* Room for improvement in work environement */
with a as (
	select worklifebalance , count(attrition) as attrition from hrattrition
	where attrition = 'Yes'
	group by worklifebalance),
b as (
	select worklifebalance , count(attrition) as retention from hrattrition
	where attrition = 'No'
	group by worklifebalance)
select a.worklifebalance, a.attrition, b.retention from a
inner join b 
	on a.worklifebalance = b.worklifebalance
group by a.worklifebalance ,a.attrition, b.retention
order by attrition desc
;
/* Those with poor work life balance most likely adjusted  to the job type. Once accustomed to the
work, they are more likely to find and explore more opportunities with more free time. Those who
are satisfied settle down */

with a as (
	select relationshipsatisfaction , count(attrition) as attrition from hrattrition
	where attrition = 'Yes'
	group by relationshipsatisfaction),
b as (
	select relationshipsatisfaction , count(attrition) as retention from hrattrition
	where attrition = 'No'
	group by relationshipsatisfaction)
select a.relationshipsatisfaction, a.attrition, b.retention from a
inner join b 
	on a.relationshipsatisfaction = b.relationshipsatisfaction
group by a.relationshipsatisfaction ,a.attrition, b.retention
order by attrition desc
;
/* Those with satisfactorily relationships look for better career opportunities while those with 
poor relationships stick to work. */

with a as (
	select jobinvolvment , count(attrition) as attrition from hrattrition
	where attrition = 'Yes'
	group by jobinvolvment),
b as (
	select jobinvolvment , count(attrition) as retention from hrattrition
	where attrition = 'No'
	group by jobinvolvment)
select a.jobinvolvment, a.attrition, b.retention from a
inner join b 
	on a.jobinvolvment = b.jobinvolvment
group by a.jobinvolvment ,a.attrition, b.retention
order by attrition desc
;

--Length of Time Measurements
with a as (
	select yearsincurrentrole , count(attrition) as attrition from hrattrition
	where attrition = 'Yes'
	group by yearsincurrentrole),
b as (
	select yearsincurrentrole , count(attrition) as retention from hrattrition
	where attrition = 'No'
	group by yearsincurrentrole)
select a.yearsincurrentrole, a.attrition, b.retention from a
inner join b 
	on a.yearsincurrentrole = b.yearsincurrentrole
group by a.yearsincurrentrole ,a.attrition, b.retention
order by attrition desc
;
/*Those who starting early in their careers are more likely to leave the company. Looking for more
experience, and salary hikes. */

with a as (
	select yearsatcompany , count(attrition) as attrition from hrattrition
	where attrition = 'Yes'
	group by yearsatcompany),
b as (
	select yearsatcompany , count(attrition) as retention from hrattrition
	where attrition = 'No'
	group by yearsatcompany)
select a.yearsatcompany, a.attrition, b.retention from a
inner join b 
	on a.yearsatcompany = b.yearsatcompany
group by a.yearsatcompany ,a.attrition, b.retention
order by attrition desc
;
/* Likewise, we see a similar trend of those early on the company leaving for more opportunities. 
Possible relationships between managers. */

with a as (
	select yearswithcurrmanager , count(attrition) as attrition from hrattrition
	where attrition = 'Yes'
	group by yearswithcurrmanager),
b as (
	select yearswithcurrmanager , count(attrition) as retention from hrattrition
	where attrition = 'No'
	group by yearswithcurrmanager)
select a.yearswithcurrmanager, a.attrition, b.retention from a
inner join b 
	on a.yearswithcurrmanager = b.yearswithcurrmanager
group by a.yearswithcurrmanager ,a.attrition, b.retention
order by attrition desc
;
/* Employees are unlikely to resign due to managers. Depicted earlier, employees are more likely to leave
early on in their careers. However, there is a spike with employees stay 7 years. Still, the employees
are most likely satisfied with their managers after staying for so long. */

--Salary Influences
with a as (
	select yearssincelastpromotion , count(attrition) as attrition from hrattrition
	where attrition = 'Yes'
	group by yearssincelastpromotion),
b as (
	select yearssincelastpromotion , count(attrition) as retention from hrattrition
	where attrition = 'No'
	group by yearssincelastpromotion)
select a.yearssincelastpromotion, a.attrition, b.retention from a
inner join b 
	on a.yearssincelastpromotion = b.yearssincelastpromotion
group by a.yearssincelastpromotion ,a.attrition, b.retention
order by attrition desc
;
/* Large decrease in attrition rates after employees first year of promotion, employees
potentially satisfied with salaries to stay at company. */

with a as (
	select stockoptionlevel , count(attrition) as attrition from hrattrition
	where attrition = 'Yes'
	group by stockoptionlevel),
b as (
	select stockoptionlevel , count(attrition) as retention from hrattrition
	where attrition = 'No'
	group by stockoptionlevel)
select a.stockoptionlevel, a.attrition, b.retention from a
inner join b 
	on a.stockoptionlevel = b.stockoptionlevel
group by a.stockoptionlevel ,a.attrition, b.retention
order by attrition desc
;
/* Providing stock options increases incentitive to stay at the company for several more years. Large
amounts of money in make employees stay. Those without this opportunity most likely will leave. */

with a as (
	select percentsalaryhike , count(attrition) as attrition from hrattrition
	where attrition = 'Yes'
	group by percentsalaryhike),
b as (
	select percentsalaryhike , count(attrition) as retention from hrattrition
	where attrition = 'No'
	group by percentsalaryhike)
select a.percentsalaryhike, a.attrition, b.retention from a
inner join b 
	on a.percentsalaryhike = b.percentsalaryhike
group by a.percentsalaryhike ,a.attrition, b.retention
order by attrition desc
;
/* Similarly, large salary hikes influences employees to stay at the company.*/