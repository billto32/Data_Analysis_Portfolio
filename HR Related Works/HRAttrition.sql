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

select gender , count(attrition), count(employeecount) from hrattrition
where attrition = 'Yes'
group by gender
;
select gender , attrition from hrattrition
where gender = 'Female'
;
select age, count(attrition) as attrition from hrattrition
group by age
order by attrition desc
;
select employeenumber , attrition from public.hrattrition
where attrition = 'Yes'

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
select jobsatisfaction, attrition, count(jobsatisfaction) from public.hrattrition
group by jobsatisfaction, attrition
order by jobsatisfaction, attrition

select environmentsatisfaction, count(environmentsatisfaction) from hrattrition
where attrition = 'Yes'
group by environmentsatisfaction





