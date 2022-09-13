select * from housing;
--Showing all null values from table
select * from housing
where NOT(housing IS NOT NULL)
order by parcelid;
--null addresses
select * from housing
where propertyaddress is null
order by parcelid;
--null value duplicates
select h1.parcelid, h1.propertyaddress, h2.parcelid, h2.propertyaddress from housing h1
inner join housing h2
	on h1.parcelid = h2.parcelid	
	and h1.uniqueid != h2.uniqueid
where h1.propertyaddress is null;
--repopulating propertyaddress
select h1.parcelid, h1.propertyaddress, h2.parcelid, h2.propertyaddress
	     
	   from housing h1
inner join housing h2
	on h1.parcelid = h2.parcelid	
	and h1.uniqueid != h2.uniqueid
where h1.propertyaddress is not null;
--update table
update housing as h1  
set propertyaddress = coalesce (h1.propertyaddress,h2.propertyaddress)  
from housing as h2
where h1.parcelid = h2.parcelid and h1.uniqueid != h2.uniqueid
and h1.propertyaddress is null and h2.propertyaddress is not null;
--splitting property address w/o city using substrings
select split_part(propertyaddress, ',', 1) as address,
		split_part(propertyaddress, ', ', 2) as city
from housing;
--new columns 
alter table housing 
add column address_updated varchar(100),
add column city varchar(100)
returning *;

update housing
set address_updated = split_part(propertyaddress, ',', 1),
	city = split_part(propertyaddress, ', ', 2)
returning *;

--fix address
update housing
set propertyaddress = address_updated
returning propertyaddress, address_updated;
--drop address_updated
alter table housing
drop column address_updated;
--splitting owneraddresses
select split_part(owneraddress, ',', 1) as owneraddress,
		split_part(owneraddress, ', ', 2) as ownercity,
		split_part(owneraddress, ', ', 3) as ownerstate
from housing;

alter table housing 
add column ownercity varchar(100),
add column ownerstate varchar(100)
;

update housing 
set owneraddress = split_part(owneraddress, ',', 1),
	ownercity = split_part(owneraddress, ', ', 2), 
	ownerstate = split_part(owneraddress, ', ', 3);

alter table housing
rename column city to propertycity;
--edit soldasvacant boolean to varchar 
select 
	cast(case
				when soldasvacant = true then 'yes'
				else 'no'
				end as varchar(3)) from housing;
				
alter table housing
alter column soldasvacant type varchar(5);

update housing
	set soldasvacant = cast(case
				when soldasvacant = 'true' then 'yes'
				else 'no'
				end as varchar(3));
select count(soldasvacant) as totalvacantsold,
	sum(case when soldasvacant = 'yes' then 1 else 0 end)as total_yes,
	sum(case when soldasvacant = 'no' then 1 else 0 end)as total_no
	from housing;

select distinct (soldasvacant), count(soldasvacant) from housing
	group by soldasvacant
	order by 2;
--removing duplicates
with cte_housing as (
	select *,
		row_number() over(
		partition by parcelid, propertyaddress, salesprice, salesdate,legalreference
		order by uniqueid) as rn
	from housing)

/*select * from cte_housing
	where rn > 1
	order by propertyaddress */

delete from housing
	where uniqueid in (select uniqueid from cte_housing where rn>1);
	
/*delete housing where uniqueid in 
	(with cte_housing as (
		select uniqueid, 
		row_number() over(partition by
		parcelid, propertyaddress, salesprice,salesdate,legalreference
		from housing) as rn
	select uniqueid from cte_housing
	where rn > 1); */

/*delete from housing 
where uniqueid in (
	select uniqueid from 
		(select *,
			row_number () over(partition by parcelid, propertyaddress, salesprice, salesdate,legalreference
		order by uniqueid) as rn
	from housing)r1
	where r1.rn>1);*/
	
--delete unused columns
select * from housing;
/*alter table housing
	drop column taxdistrict */
		