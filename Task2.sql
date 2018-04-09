-- Step 1:  Create table to import Order transactions

CREATE
  TABLE "ORDER_HISTORY"
  (
    "ROW_ID"  VARCHAR2(10 BYTE),
    "ORDERID" VARCHAR2(20 BYTE),
    "ORDERDATE" DATE,
    "CUSTOMERID"  VARCHAR2(20 BYTE),
    "PRODUCTID"   VARCHAR2(20 BYTE),
    "PRODUCTNAME" VARCHAR2(200 BYTE),
    "SALES"       VARCHAR2(15 BYTE),
    "QUANTITY"    varchar2(15 byte)
  );
  
-- Step 2:  Import the Order csv file.

-- Step 3:  Find top 10 Bestselling products.

CREATE table TOP10_PRODUCTS as
select B.* from (
select a.*,
ROW_NUMBER() over (order by TOTAL_ORDERS desc) as ROWN
from (
select COUNT(DISTINCT(ORDERID)) TOTAL_ORDERS,PRODUCTNAME
from ORDER_HISTORY group by PRODUCTNAME)A ) B WHERE B.ROWN <11;

-- Find Product Combinations and the number of occurrences

create table LHSRHS_FACT as
select C.* from (
select LHS,RHS,SUM(NUMLHS) SUMNUMLHS,SUM(NUMRHS) SUMNUMRHS,COUNT(*) NUMLHSRHS from (
(select PRODUCTNAME LHS,COUNT(distinct ORDERID)NUMLHS ,ORDERID from ORDER_HISTORY group by PRODUCTNAME,ORDERID )SUMLHS
join
(select PRODUCTNAME RHS,COUNT(distinct ORDERID) NUMRHS ,ORDERID from ORDER_HISTORY group by PRODUCTNAME,ORDERID ) SUMRHS
on SUMLHS.ORDERID=SUMRHS.ORDERID
) group by LHS, RHS)C;

--SUMNUMLHS – No of Left Hand Side Products in the transactions
--SUMNUMRHS – No of Right Hand Side Products in the transactions
--NUMLHSRHS – No of Occurrences of LHS and RHS combination

-- Step 5: Find the Number of Transactions for Main Product (Left Hand Side Product)

create table LHS_TXN as
select D.LHs,SUM(SUMNUMLHS) LHSNUMTXN from (
select C.* from (
select LHS,RHS,SUM(NUMLHS) SUMNUMLHS,SUM(NUMRHS) SUMNUMRHS,COUNT(*) NUMLHSRHS from (
(select PRODUCTNAME LHS,COUNT(distinct ORDERID)NUMLHS ,ORDERID from ORDER_HISTORY group by PRODUCTNAME,ORDERID )SUMLHS
join
(select PRODUCTNAME RHS,COUNT(distinct ORDERID) NUMRHS ,ORDERID from ORDER_HISTORY group by PRODUCTNAME,ORDERID ) SUMRHS
on SUMLHS.ORDERID=SUMRHS.ORDERID
) group by LHS, RHS)C ) D
group by D.LHs
;
--LHSNUMTXN – Total no of transactions containing the Best Selling Product.

-- Step 6: Calculate Support, Confidence and Lift.

select 
a.LHS,a.RHS,A.NUMLHSRHS NO_OF_OCCURENCES,
ROUND(NUMLHSRHS/B.LHSNUMTXN,3) as SUPPORT,
ROUND(TOTAL_ORDERS/B.LHSNUMTXN,3) as CONFIDENCE,
ROUND(ROUND(TOTAL_ORDERS/B.LHSNUMTXN,3)/ROUND(SUMNUMRHS/B.LHSNUMTXN,2),2) as LIFT
from LHSRHS_FACT a,
LHS_TXN B,
TOP10_PRODUCTS C
where 
a.LHS= B.LHS and 
a.LHS = C.PRODUCTNAME and
a.LHS != a.RHS
ORDER BY A.NUMLHSRHS desc;

--LHS – Best Selling Product
--RHS – Product bought frequently with the Best Selling Product
