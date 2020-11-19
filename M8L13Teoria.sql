--1

select 
    pmr.region_name, 
    avg(p.product_quantity) as average_in_regions
 from products p
 inner join product_manufactured_region pmr on(p.product_man_region=pmr.id)
group by pmr.region_name
order by average_in_regions desc;

--2
select
    string_agg(coalesce(p.product_name ,'brak_produktu') ||'  '|| coalesce(pmr.region_name, 'brak-regionu'),';' order by p.product_name) 
 from products p right join product_manufactured_region pmr on (p.product_man_region=pmr.id)
group by p.product_name ;

--3
select 
    p.product_name,
    pmr.region_name,
    sum(s.sal_value),
    count(s.sal_prd_id) as liczba_produktow
 from sales s inner join
 products p on (s.sal_prd_id=p.id) inner join product_manufactured_region pmr on (p.product_man_region=pmr.id) where pmr.region_name ='EMEA'
group by p.product_name, pmr.region_name;

--4
select 
    sum(s.sal_value),
    concat(extract (year from s.sal_date)|| '_'|| extract(month from s.sal_date)) as sales_data
 from sales s
group by sales_data
order by 1 desc;

--5
--nie wiem dlaczego numeracja w grouping zaczyna się od 3
select 
    avg(p.product_quantity),
    p.product_code ,
    p.manufactured_date,
    pmr.region_name, 
        grouping (p.product_code, p.manufactured_date, pmr.region_name )
        from products p inner join product_manufactured_region pmr on (p.product_man_region=pmr.id)
        group by grouping sets ((p.product_code),
                                (p.manufactured_date),
                                (pmr.region_name), 
                                ());
                            
 --6
 
    select 
    p.product_name,
    p.product_code,
    p.manufactured_date,
    p.product_man_region,
    pmr.region_name,
    sum(p.product_quantity) over (partition by p.product_name) as suma
    from products p right join
    product_manufactured_region pmr on (p.product_man_region=pmr.id) 
                               
                            
                            
--7

with asc_d as(
select *,
dense_rank() over (order by sub.suma ) as ranking
from
    (select 
    p.product_name,
    pmr.region_name,
    sum(p.product_quantity) over (partition by p.product_name) as suma
    from products p right join
    product_manufactured_region pmr on (p.product_man_region=pmr.id) ) sub
    )
select 
asc_d.product_name,
asc_d.region_name,
asc_d.ranking
from asc_d
where asc_d.ranking=2;

                    
