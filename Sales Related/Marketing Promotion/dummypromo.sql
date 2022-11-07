create table dummy_market (
	tv numeric,
	radio numeric,
	socialmed numeric,
	influencer text,
	sales numeric)
	
select * from dummy_market;

select 
		round(sum(tv),2) as tv_total,
		round(sum(radio),2) as radio_total,
		round(sum(socialmed),2) as social_total
from dummy_market;