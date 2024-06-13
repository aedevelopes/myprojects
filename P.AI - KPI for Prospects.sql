/********************************************************************************************************************************************************
                        Business Purpose    -    KPI for P.AI Prospects
                        JIRA                -    https://hintmd.atlassian.net/browse/DD-350
                        Dependencies        -    Procedure SP_LOAD_PAI_KPI() sourcing from view - VW_PAI_KPI       
                        Version History     -    08/18/2023 - Created | Alex Ennis, Senthil Selvaraj
                                            -    11/22/2023 - Alex Ennis - Formatted to appropriate source objects
*********************************************************************************************************************************************************/

create or replace view STAGING_TEST.CDP.VW_PAI_KPI(
	TRUE_LEAD_SOURCE_DETAIL__C,
	CUSTOMER_NUMBER__C,
	NAME,
	TERRITORY,
	LEAD_STATUS__C,
	AGENT_AFFL_COUNT,
	LOCATION_AFFL_COUNT,
	CASE_COUNT,
	FIRST_SAMPLE,
	FIRST_ORDER,
	RSM,
	PAC,
	SUM_OF_REVENUE,
	FIRST_ORDER_REVENUE,
	ORDER_COUNT,
	WEBSITE
) as
(
WITH affl_count AS (
                    SELECT FROM_ACCOUNT_CN, COUNT(DISTINCT FROM_NAME) AS agent_affl_count 
                    FROM STAGING_TEST.SALES.VW_AFFILIATION GROUP BY 1
                    )
,location_affl AS (
                   SELECT CUSTOMERNUMBER, COUNT(customernumber) AS location_affl_count 
                   FROM STAGING_TEST.CDP.VW_PRACTICE_ADDRESS
                   GROUP BY 1
                   )  
                   
,   STATUS AS (
                SELECT "AccountID" AS CN, MIN("OrderDate") AS FIRST_ORDER
                FROM STAGING_TEST.SALES.VW_RSM_SALES GROUP BY 1
                )
                
, FIRST_REV AS (
                WITH dates AS (
                                SELECT "AccountID" AS CN, sum("Revenue") as first_order_revenue,"OrderDate"
                                FROM "STAGING"."SALES"."VW_RSM_SALES"
                                GROUP BY ALL
                                )
                SELECT * FROM (
                                SELECT "AccountID" as cnN, MIN("OrderDate") as first
                                FROM "STAGING"."SALES"."VW_RSM_SALES"
                                GROUP BY 1
                                ) AS a
               LEFT JOIN dates AS d 
               ON d.CN = a.cnN AND "OrderDate" = a.first
               )
, ORDERCOUNT AS (
                SELECT DISTINCT CN AS num, count(orders) as ORDER_COUNT
                FROM (
                      SELECT DISTINCT "AccountID" AS CN, "OrderDate" as orders
                      FROM STAGING_TEST.SALES.VW_RSM_SALES
                     )
                     group by 1
                )  
                
,   SAMPLED AS (
                SELECT EFFECTIVE_ACCOUNT_NUMBER AS CN, MIN(SAMPLE_DATE) AS FIRST_SAMPLE 
                FROM  STAGING_TEST.SAMPLES.VW_SAMPLE_MASTER GROUP BY 1
                )
,   TERRITORY AS (
                  SELECT * FROM STAGING_TEST.SALES.VW_TERRITORY_ZIP
                  )
                  
,   CASES AS (
              SELECT ACCOUNT_ID, COUNT(DISTINCT CASE_NUMBER) AS case_count 
              FROM STAGING_TEST.SALES.VW_CASE
              GROUP BY 1
              )
          
,   NUMBERS AS(
               SELECT CUSTOMER_NUMBER AS CN
               FROM STAGING_TEST.SALES.VW_ACCOUNT
               WHERE LOWER(REGEXP_REPLACE(WEBSITE, '[a-zA-Z]+://|www.|Www.|WWW.|/[^)]*', '')) IN 
                        (
                        SELECT LOWER(REGEXP_REPLACE(URL, '[a-zA-Z]+://|www.|Www.|WWW.|/[^)]*', '')) 
                        FROM STITCH_TEST.PROVIDERAI.SALES_ENABLEMENT_EXP -- Only exists in STITCH_TEST as its one time load | static
                        )
               AND (DATE(CREATEDDATE) > '2022-11-01')
                ) 
                
,   PACs as (
            SELECT "TerritoryName" as tt, "RSMName" as rr, "SalesRepName" as ss FROM STAGING_TEST.SALES.VW_TERRITORY_PERSON
             )  

SELECT A.TRUE_LEAD_SOURCE_DETAIL__C AS TRUE_LEAD_SOURCE_DETAIL,A.CUSTOMER_NUMBER, A.NAME, t.NAME as territory, A.LEAD_Status__C,agent_affl_count, location_affl_count
, case_count
, FIRST_SAMPLE, FIRST_ORDER, rr as RSM, ss as PAC, Sum("Revenue") AS SUM_OF_REVENUE
, FR.FIRST_ORDER_REVENUE, OC.ORDER_COUNT, A.website

FROM STAGING_TEST.SALES.VW_ACCOUNT AS A

LEFT JOIN affl_count Ag ON A.CUSTOMER_NUMBER = ag.FROM_ACCOUNT_CN

LEFT JOIN location_affl loc ON A.CUSTOMER_NUMBER = loc.CUSTOMERNUMBER

LEFT JOIN status ST ON ST.CN = A.CUSTOMER_NUMBER

LEFT JOIN sampled b ON b.CN = A.CUSTOMER_NUMBER

LEFT JOIN TERRITORY t ON ZIP = PRIMARY_ZIP__C

LEFT JOIN CASES C ON C.ACCOUNT_ID = A.ACCOUNT_ID

LEFT JOIN STAGING_TEST.SALES.VW_RSM_SALES  as s ON "AccountID" = A.CUSTOMER_NUMBER

LEFT JOIN PACs ON tt = territory

LEFT JOIN FIRST_REV AS FR ON A.CUSTOMER_NUMBER = FR.CN

LEFT JOIN ORDERCOUNT AS OC ON OC.NUM = A.CUSTOMER_NUMBER

WHERE (a.TRUE_LEAD_SOURCE_DETAIL__C ilike 'providerai%'
OR
A.CUSTOMER_NUMBER IN (SELECT CN FROM NUMBERS)) 
and A.CUSTOMER_NUMBER not in (select CUSTOMER_NUMBER from  STAGING_TEST.SALES.VW_ACCOUNT where name ilike '%providerai%')
group by ALL
);
