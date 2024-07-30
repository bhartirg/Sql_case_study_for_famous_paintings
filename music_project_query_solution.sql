#1.Fetch all the paintings which are not displayed on any museums?
select name from music.work where museum_id is null;


#2) Are there museuems without any paintings?
select * from music.museum m where not exists (select 1 from music.work w  where w.museum_id=m.museum_id);


#3)How many paintings have an asking price of more than their regular price? 
select count(work_id) as number_of_painting from music.product_size where sale_price > regular_price;


#4) Identify the paintings whose asking price is less than 50% of its regular price
select * from music.product_size where sale_price<(1/2)*regular_price;


#5) Which canva size costs the most?
select cs.label as canva, ps.sale_price
	from (select *
		  , rank() over(order by sale_price desc) as rnk 
		  from music.product_size) ps
	join music.canvas_size cs on cs.size_id=ps.size_id
	where ps.rnk=1;
    

#6) Identify the museums with invalid city information in the given dataset
select * from music.museum where city is null or city=' ' or city not regexp '^[A-Za-z ]+$';


#7) Museum_Hours table has 1 invalid entry. Identify it and remove it.
select * from music.museum_hours where museum_id is null or museum_id=' ' or open is null or open=' ' or close is null or
                                  close=' ' or day is null or day=' ' or museum_id NOT REGEXP '^[0-9]+$' or
                                  open NOT REGEXP '^(0[1-9]|1[0-2]):[0-5][0-9]:[AP]M$' or
                                  close NOT REGEXP '^(0[1-9]|1[0-2]):[0-5][0-9]:[AP]M$' or
                                  day NOT IN ('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');

delete from music.museum_hours where museum_id is null or museum_id=' ' or open is null or open=' ' or close is null or
                                  close=' ' or day is null or day=' ' or museum_id NOT REGEXP '^[0-9]+$' or
                                  open NOT REGEXP '^(0[1-9]|1[0-2]):[0-5][0-9]:[AP]M$' or
                                  close NOT REGEXP '^(0[1-9]|1[0-2]):[0-5][0-9]:[AP]M$' or
                                  day NOT IN ('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');


#8) Fetch the top 10 most famous painting subject
    select * 
	from (
		select s.subject,count(1) as no_of_paintings,
		rank() over (order by count(1) desc) as ranking
		from music.work w
		join music.subject s on s.work_id=w.work_id
		group by s.subject) x
	where ranking <= 10;
    
    
#9) Identify the museums which are open on both Sunday and Monday. Display museum name, city.    
select m.name,m.city from music.museum_hours mh join music.museum m on mh.museum_id=m.museum_id 
                  where day='sunday' and 
                  exists (Select 1 from  music.museum_hours mh2 where mh2.museum_id=m.museum_id and mh2.day='monday');
                  
                  
#10) How many museums are open every single day?   

  select count(*) as number_of_museum_opened_each_day
	from (select museum_id, count(*) as x
		  from music.museum_hours
		  group by museum_id
		  having count(*) = 7) as subquery;
   
    
# 11) Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)
  select m.name as museum, m.city,m.country,x.no_of_painintgs
	from (	select m.museum_id, count(1) as no_of_painintgs
			, rank() over(order by count(1) desc) as rnk
			from work w
			join museum m on m.museum_id=w.museum_id
			group by m.museum_id) x
	join museum m on m.museum_id=x.museum_id
	where x.rnk<=5;    


 #12) Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)
    select a.full_name,a.style,x.no_of_paintings from (select a.artist_id,count(1) as no_of_paintings
                                                         , rank() over (order by count(1) desc ) as rnk from 
                                                         work w join artist a on a.artist_id=w.artist_id 
                                                         group by a.artist_id) x join artist a on a.artist_id=x.artist_id
                                                         where x.rnk<=5;   
					
                    
#13) Display the 3 least popular canva sizes 
select label,ranking,no_of_paintings
	from (
		select cs.size_id,cs.label,count(1) as no_of_paintings
		, dense_rank() over(order by count(1) ) as ranking
		from work w
		join product_size ps on ps.work_id=w.work_id
		join canvas_size cs on cs.size_id = ps.size_id
		group by cs.size_id,cs.label) x
	where x.ranking<=3 limit 3;          
    
#14) Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?    
select name,state,day,hours_open from (select m.name,m.state,mh.day,abs(time_format(timediff(close,open),'%H')) 
as hours_open,dense_rank() over(order by abs(time_format(timediff(close,open),'%H')) desc ) as ranking from museum m join museum_hours mh on
m.museum_id=mh.museum_id )x where x.ranking=1;    