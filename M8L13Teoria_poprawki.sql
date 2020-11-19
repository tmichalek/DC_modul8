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