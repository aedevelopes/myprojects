/********************************************************************************************************************************************************
                        Business Purpose    -    getting status count for PAI KPI
                        JIRA                -    n/a
                        Dependencies        -    STAGING_TEST.SALES.VW_AFFILIATION
                                                 STAGING_TEST.CDP.VW_PRACTICE_ADDRESS
                                                 STAGING_TEST.SALES.VW_RSM_SALES
                                                 STAGING_TEST.SAMPLES.VW_SAMPLE_MASTER
                                                 STAGING_TEST.SALES.VW_TERRITORY_ZIP
                                                 DATASCI.CDPARCHIVE.SALES_ENABLEMENT_EXP
                                                 STAGING_TEST.SALES.VW_TERRITORY_PERSON
                                                 STAGING_TEST.SALES.VW_ACCOUNT
                                                 STAGING_TEST.SALES.VW_RSM_SALES
                        Version History     -    11/01/2023 - Created | Alex Ennis, Senthil Selvaraj
************************************************************************************************************************************************/

create or replace view STAGING_TEST.CDP.VW_PAI_LEAD_STATUS(
	RSM,
	"RSMEmail",
	PAC,
	UPDATED_STATUSES
) as
(
With prai as (
                        WITH affl_count AS 
                                 (
                                     SELECT TO_ACCOUNT_CN AS CUSTOMER_NUMBER, COUNT(DISTINCT FROM_NAME) AS agent_affl_count 
                                     FROM STAGING_TEST.SALES.VW_AFFILIATION GROUP BY 1
                                 )
                        , location_affl AS 
                                 (
                                      SELECT CUSTOMERNUMBER, COUNT(customernumber) AS location_affl_count
                                      FROM STAGING_TEST.CDP.VW_PRACTICE_ADDRESS
                                      GROUP BY ALL
                                 )  
                                           
                        , STATUS AS     
                                (
                                      SELECT "AccountID" AS CN, MIN("OrderDate") AS FIRST_ORDER
                                      FROM STAGING_TEST.SALES.VW_RSM_SALES GROUP BY 1
                                )
                                        
                        , SAMPLED AS 
                                (
                                      SELECT EFFECTIVE_ACCOUNT_NUMBER AS CN, MIN(SAMPLE_DATE) AS FIRST_SAMPLE 
                                      FROM STAGING_TEST.SAMPLES.VW_SAMPLE_MASTER GROUP BY 1
                                )
                        ,   TERRITORY AS 
                                (
                                      SELECT * FROM STAGING_TEST.SALES.VW_TERRITORY_ZIP
                                )
                                      
                             -- 10/18/2023 -- Since One time load and reference to the results, pushed to DATASCI.CDPARCHIVE.SALES_ENABLEMENT_EXP
                             
                         ,   NUMBERS AS
                                (
                                       SELECT CUSTOMER_NUMBER AS CN
                                       FROM STAGING_TEST.SALES.VW_ACCOUNT c
                                       WHERE LOWER(REGEXP_REPLACE(WEBSITE, '[a-zA-Z]+://|www.|Www.|WWW.|/[^)]*', '')) IN 
                                                (
                                                SELECT LOWER(REGEXP_REPLACE(URL, '[a-zA-Z]+://|www.|Www.|WWW.|/[^)]*', '')) 
                                                FROM DATASCI.CDPARCHIVE.SALES_ENABLEMENT_EXP
                                                )
                                       AND (DATE(CREATEDDATE) > '2022-11-01') --OR DATE(CREATEDDATE) < '2021-01-01')
                                ) 
                                        
                        ,   PACs as 
                                (
                                       SELECT "TerritoryName" as tt, "RSMName" as rr, "SalesRepName" as ss FROM STAGING_TEST.SALES.VW_TERRITORY_PERSON
                                )   
                                     
                        SELECT c.CUSTOMER_NUMBER, c.NAME, t.NAME as territory, c.LEAD_Status__C,agent_affl_count, location_affl_count--, case_count
                        , FIRST_SAMPLE, FIRST_ORDER, rr as RSM, ss as PAC, Sum("Revenue"),acc.website
                        
                        FROM STAGING_TEST.SALES.VW_ACCOUNT c
                        
                        
                        LEFT JOIN affl_count Ag ON c.CUSTOMER_NUMBER = ag.CUSTOMER_NUMBER
                        
                        LEFT JOIN location_affl loc ON c.CUSTOMER_NUMBER = loc.CUSTOMERNUMBER
                        
                        LEFT JOIN status a ON a.CN = c.CUSTOMER_NUMBER
                        
                        LEFT JOIN sampled b ON b.CN = c.CUSTOMER_NUMBER
                        
                        LEFT JOIN TERRITORY t ON ZIP = PRIMARY_ZIP__C
                        
                        LEFT JOIN STAGING_TEST.SALES.VW_RSM_SALES  as s ON "AccountID" = c.CUSTOMER_NUMBER
                        
                        LEFT JOIN PACs ON tt = territory
                        
                        LEFT JOIN STAGING_TEST.SALES.VW_ACCOUNT as acc on c.customer_number = acc.customer_number
                        
                        WHERE (
                                c.TRUE_LEAD_SOURCE_DETAIL__C ilike 'providerai%' OR
                                a.CN IN (SELECT CN FROM NUMBERS)
                              ) 
                        and C.CUSTOMER_NUMBER not in (select CUSTOMER_NUMBER from STAGING_TEST.SALES.VW_ACCOUNT where name ilike '%providerai%')
                        group by C.CUSTOMER_NUMBER, c.NAME, t.NAME, c.LEAD_Status__C,agent_affl_count, location_affl_count
                        , FIRST_SAMPLE, FIRST_ORDER, rsm, pac,acc.website
                )

, NEWCOUNT AS   (
                SELECT PAC, count(PAC) as count_updated
                FROM prai        
                LEFT JOIN STAGING_TEST.SALES.VW_TERRITORY_PERSON on pac = "SalesRepName"
                WHERE lead_Status__c not ilike 'new'
                group by PAC
                /*
                 change to ilike--if you want a list of pacs that have not updated
                 AND pac not in (SELECT distinct PAC
                                  FROM prai        
                                  WHERE lead_Status__c not ilike 'new') --add this part--if you want a list of pacs that have not updated
                */
                )

SELECT distinct prai.RSM,"RSMEmail", prai.PAC, COALESCE(count_updated, 0) as updated_statuses
FROM prai
LEFT JOIN NEWCOUNT as nc
ON prai.pac = nc.pac
LEFT JOIN STAGING_TEST.SALES.VW_TERRITORY_PERSON  as s
on prai.pac = "SalesRepName"
order by RSM
);
