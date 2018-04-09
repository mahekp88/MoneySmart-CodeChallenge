--Step 1 : Create Input Table to hold the User session transaction log.
create table  "PAGE_VIEWS"  
  (
    "ID"      VARCHAR2(5 BYTE),
    "USER_ID" VARCHAR2(7 BYTE),
    "PAGE_ID" VARCHAR2(7 BYTE),
    "VISIT_DATE" DATE,
    "VISIT_TIME" VARCHAR2(10 BYTE)
);

--Step 2 : Import the input csv file

--Step 3: Calculate User Sessions per page per day.

select PAGE_ID,VISIT_DATE,COUNT(1) TOTAL_USER_SESSIONS from 
PAGE_VIEWS
group by 
PAGE_ID,VISIT_DATE
order by PAGE_ID ;