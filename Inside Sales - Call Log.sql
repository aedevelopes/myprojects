/********************************************************************************************************************************************************
                        Business Purpose    -    Call Log for inside sales representatives
                        JIRA                -    https://hintmd.atlassian.net/browse/DDOPS-50
                                                 https://hintmd.atlassian.net/browse/DDOPS-22
                                                 https://hintmd.atlassian.net/browse/DDOPS-5
                        Dependencies        -    STITCH_TEST.OCE_CRM.USER    
                                                 STITCH_TEST.OCE_CRM.TASK
                                                 STAGING_TEST.sales.vw_account
                        Version History     -    11/01/2023 - Created | Alex Ennis, Senthil Selvaraj
*********************************************************************************************************************************************************/

create or replace view STAGING_TEST.CDP.VW_REP_CALL_LOG  
as (
    SELECT 
      date(t.activitydate) as Call_Date
    , t.ownerid as rep_id
    , u.name as rep_name
    , CASE WHEN t.whatid is not null then t.whatid
        WHEN t.whoid is not null then t.whoid
        else null
      END as customer_id
    , t.calldisposition
    , a.account_phase -- account_phase is not in staging_dev.sales.vw_account
    , t.calldurationinseconds
    , t.calltype
    , t.tasksubtype 
    , t.subject
    , t.description
    , t.status
    , t.completeddatetime
    , t.accountid
    , t.whoid
    , t.id
    FROM staging_test.sales.vw_person as U -- ProfileID to be added
        LEFT JOIN staging_test.sales.vw_task as T
            ON u.person_id = t.ownerid 
        LEFT JOIN staging_test.sales.vw_account as A
            ON A.account_id = t.accountid
    WHERE U.profile_name = 'Aesthetic Account Executive' 
    and date(t.activitydate) >= '2023-09-05'
   );
