--1
select sum(t.transaction_value),
tc.category_name 
from transactions t inner join transaction_category tc on( t.id_trans_cat=tc.id_trans_cat)
group by tc.category_name ;

--2

select
    sum(t.transaction_value) 
 from transactions t 
  inner join transaction_category tc on ( t.id_trans_cat=tc.id_trans_cat)
  and tc.category_name ='UŻYWKI' 
  inner join transaction_bank_accounts tba on (t.id_trans_ba =tba.id_trans_ba)
  inner join bank_account_types bat on (bat.id_ba_type=tba.id_ba_typ) and bat.ba_type ='ROR' 
  inner join bank_account_owner bao on (bao.id_ba_own=bat.id_ba_own) and bao.owner_name ='Janusz Kowalski'
 where extract (year from t.transaction_date)=2020;

--3
select  
extract(year from t.transaction_date) transaction_year,
concat(extract(quarter from t.transaction_date) ||'_'|| extract(year from t.transaction_date)) transaction_quarter,
concat(extract(month from t.transaction_date) ||'_'|| extract(year from t.transaction_date)) transaction_month,
sum(t.transaction_value)
 from transactions t 
  inner join transaction_type tt on ( t.id_trans_type =tt.id_trans_type)
  and tt.transaction_type_name ='Obciążenie' 
  inner join transaction_bank_accounts tba on (t.id_trans_ba =tba.id_trans_ba)
  inner join bank_account_types bat on (bat.id_ba_type=tba.id_ba_typ) and bat.ba_type like 'ROR%' 
  inner join bank_account_owner bao on (bao.id_ba_own=bat.id_ba_own) and bao.owner_name ='Janusz i Grażynka'
 where extract (year from t.transaction_date)=2019
 group by rollup ((extract(year from t.transaction_date)),
                 (extract(quarter from t.transaction_date)),
                 (extract(month from t.transaction_date)))
order by 2;
             
--4  

with standard_year as(
        select
         extract(year from t.transaction_date) as extracted_year,
         sum(t.transaction_value) as sales_year
          from transactions t 
            inner join transaction_type tt on ( t.id_trans_type =tt.id_trans_type)
            and tt.transaction_type_name ='ObciÄ…Å¼enie' 
            inner join transaction_bank_accounts tba on (t.id_trans_ba =tba.id_trans_ba)
            inner join bank_account_types bat on (bat.id_ba_type=tba.id_ba_typ) and bat.ba_type like 'ROR%' 
            inner join bank_account_owner bao on (bao.id_ba_own=bat.id_ba_own) and bao.owner_name ='Janusz i GraÅ¼ynka'
           group by extracted_year
           order by extracted_year), 
     previous_year as (
                    select *, lag(sales_year) over (order by extracted_year) as previous_year_sales
                    from standard_year )
    select extracted_year, sales_year, previous_year_sales, previous_year_sales - sales_year as Diff_years
    from previous_year;

--5

select t.transaction_date ,t.transaction_value, 
    FIRST_VALUE(t.transaction_date) OVER (ORDER BY t.transaction_date 
                                        GROUPS BETWEEN CURRENT ROW AND 1 FOLLOWING 
                                            EXCLUDE CURRENT ROW) as next_transactions_day,
          FIRST_VALUE(t.transaction_date) OVER (ORDER BY t.transaction_date 
                                        GROUPS BETWEEN CURRENT ROW AND 1 FOLLOWING 
                                           EXCLUDE CURRENT ROW) - t.transaction_date AS days_beetween_transaction                                          
 from transactions t 
  inner join transaction_type tt on ( t.id_trans_type =tt.id_trans_type)
  and tt.transaction_type_name ='Obciążenie'
  inner join transaction_subcategory ts on (ts.id_trans_subcat=t.id_trans_subcat) and ts.subcategory_name ='Technologie'
  inner join transaction_bank_accounts tba on (t.id_trans_ba =tba.id_trans_ba)
  inner join bank_account_types bat on (bat.id_ba_type=tba.id_ba_typ) and bat.ba_type ='ROR' 
  inner join bank_account_owner bao on (bao.id_ba_own=bat.id_ba_own) and bao.owner_name ='Janusz Kowalski'
   --where extract (quarter from t.transaction_date) =1 and extract (year from t.transaction_date)=2019;
  --tutaj chyba coś pomyliłem i nie moge znaleźć co bo w pierwszym kwartale wyświetla mi tylko jedną tranzakcję
  
  
  