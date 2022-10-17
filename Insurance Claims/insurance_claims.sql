/* Missing data from column error, copy csv into single column & splitting

create table insurance_claims (
	policy_number text,
	policy_bind_date text,
	policy_state text,
	policy_csl text,
	policy_deductable text, 
	policy_annual_premium text, 
	umbrella_limit text,
	months_as_customer text, 
	age text,
	insured_zipcode text,
	insured_sex text,
	insured_education_level text,
	insured_occupation text,
	insured_hobbies text,
	insured_relationship text,
	capital_gains text,
	capital_loss text,
	incident_date text,
	incident_type text,
	collision_type text,
	incident_severity text,
	authories_contacted text,
	incident_state text,
	incident_city text,
	incident_location text,
	incident_hour text,
	number_of_vehicles_involved text, 
	property_damage text, 
	bodily_injuries text,
	witnesses text,
	police_report text, 
	total_claim_amount text, 
	injury_claim text, 
	property_claim text,
	vehicle_claim text,
	auto_make text, 
	auto_model text,
	auto_year text, 
	fraud_reported text)
;
insert into insurance_claim
	select 
		split_part(policy_number,',',1)policy_number,
		split_part(policy_number,',',2)policy_bind_date,
		split_part(policy_number,',',3)policy_state,
		split_part(policy_number,',',4)policy_csl ,
		split_part(policy_number,',',5)policy_deductable,
		split_part(policy_number,',',6)policy_annual_premium ,
		split_part(policy_number,',',7)umbrella_limit,
		split_part(policy_number,',',8)months_as_customer  ,
		split_part(policy_number,',',9)age ,
		split_part(policy_number,',',10)insured_zipcode ,
		split_part(policy_number,',',11)insured_zipcode ,
		split_part(policy_number,',',12)insured_education_level ,
		split_part(policy_number,',',13)insured_occupation ,
		split_part(policy_number,',',14)insured_hobbies ,
		split_part(policy_number,',',15)insured_relationship ,
		split_part(policy_number,',',16)capital_gains ,
		split_part(policy_number,',',17)capital_loss  ,
		split_part(policy_number,',',18)incident_date ,
		split_part(policy_number,',',19)incident_date ,
		split_part(policy_number,',',20)collision_type ,
		split_part(policy_number,',',21)incident_severity ,
		split_part(policy_number,',',22)authories_contacted ,
		split_part(policy_number,',',23)incident_state  ,
		split_part(policy_number,',',24)incident_city ,
		split_part(policy_number,',',25)incident_location  ,
		split_part(policy_number,',',26)incident_hour ,
		split_part(policy_number,',',27)number_of_vehicles_involved  ,
		split_part(policy_number,',',28)incident_location ,
		split_part(policy_number,',',29)bodily_injuries  ,
		split_part(policy_number,',',30)witnesses   ,
		split_part(policy_number,',',31)police_report   ,
		split_part(policy_number,',',32)total_claim_amount   ,
		split_part(policy_number,',',33)injury_claim   ,
		split_part(policy_number,',',34)property_claim   ,
		split_part(policy_number,',',35)vehicle_claim    ,
		split_part(policy_number,',',36)auto_make   ,
		split_part(policy_number,',',37)auto_model   ,
		split_part(policy_number,',',38)auto_year   ,
		split_part(policy_number,',',39)fraud_reported 	
from insurance_claims
;
--Use regex 
delete from insurance_claim where policy_number is null
;
drop table insurance_claims
*/
create table insurance_claim (
	policy_number text,
	policy_bind_date text,
	policy_state text,
	policy_csl text,
	policy_deductable text, 
	policy_annual_premium text, 
	umbrella_limit text,
	months_as_customer text, 
	age text,
	insured_zipcode text,
	insured_sex text,
	insured_education_level text,
	insured_occupation text,
	insured_hobbies text,
	insured_relationship text,
	capital_gains text,
	capital_loss text,
	incident_date text,
	incident_type text,
	collision_type text,
	incident_severity text,
	authories_contacted text,
	incident_state text,
	incident_city text,
	incident_location text,
	incident_hour text,
	number_of_vehicles_involved text, 
	property_damage text, 
	bodily_injuries text,
	witnesses text,
	police_report text, 
	total_claim_amount text, 
	injury_claim text, 
	property_claim text,
	vehicle_claim text,
	auto_make text, 
	auto_model text,
	auto_year text, 
	fraud_reported text);
select * from insurance_claim;
--Fixing data types
alter table insurance_claim
alter column policy_bind_date type date
	using policy_bind_date::date,
alter column policy_deductable type int
	using policy_deductable::integer,
alter column policy_annual_premium type numeric
	using policy_annual_premium::numeric,
alter column umbrella_limit type int
	using umbrella_limit::integer,
alter column months_as_customer type int
	using months_as_customer::integer,
alter column age type int
	using age::integer,
alter column capital_gains type int
	using capital_gains::integer,
alter column capital_loss type int
	using capital_loss::integer,
alter column incident_date type date
	using incident_date::date,
alter column incident_hour type int
	using incident_hour::integer,
alter column number_of_vehicles_involved type int
	using number_of_vehicles_involved::integer,
alter column bodily_injuries type int
	using bodily_injuries::integer,
alter column witnesses type int
	using witnesses::integer,
alter column total_claim_amount type int
	using total_claim_amount::integer,
alter column injury_claim type int
	using injury_claim::integer,
alter column property_claim type int
	using property_claim::integer,
alter column vehicle_claim type int
	using vehicle_claim::integer
;
alter table insurance_claim
add constraint policy_number primary key (policy_number)
;
select * from insurance_claim;
