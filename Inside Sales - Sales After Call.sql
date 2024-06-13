/********************************************************************************************************************************************************
                        Business Purpose    -    KPI for sales after calls for inside sales representatives
                        JIRA                -    https://hintmd.atlassian.net/browse/DDOPS-50
                                                 https://hintmd.atlassian.net/browse/DDOPS-22
                                                 https://hintmd.atlassian.net/browse/DDOPS-5
                        Dependencies        -    STAGING_DEV.CDP.VW_REP_CALL_LOG
                                                 STAGING.SALES.VW_ACCOUNT
                                                 STAGING_TEST.SALES.VW_RSM_SALES
                        Version History     -    11/01/2023 - Created | Alex Ennis
                                                 12/01/2023 - Modified for Indentation and Query Optimization | Nikhila Kulkarni
						 12/22/2023 - Modified account status to use months instead | Alex Ennis
*********************************************************************************************************************************************************/

CREATE OR replace VIEW STAGING_TEST.CDP.VW_SALES_AFTER_CALL AS (
	WITH sales_data AS (
        SELECT 
            clg.rep_name, 
            clg.rep_id, 
            coalesce(
            a.to_account_id, clg.customer_id
            ) AS customer_idd, 
            true_lead_source_detail__c, 
            clg.id AS task_id, 
            clg.call_date, 
            act.createddate, 
            clg.completeddatetime AS call_dt, 
            sal."OrderDate" AS order_date, 
            sal."OrderNumber" :: integer :: text AS order_number, 
            sal."Product_Reporting_Name" AS product_name, 
            sal."Revenue", 
            sal."Quantity", 
            sal."AccountID" AS cn, 
            sal."Effective Account Name" AS customer_name, 
            a.to_account_id, 
            clg.customer_id 
        FROM 
            STAGING_TEST.CDP.VW_REP_CALL_LOG clg 
            LEFT JOIN STAGING_TEST.SALES.VW_AFFILIATION as a ON clg.customer_id = a.from_account_id 
            LEFT JOIN STAGING_test.SALES.VW_ACCOUNT act ON customer_idd = act.account_id 
            LEFT JOIN STAGING_TEST.SALES.VW_RSM_SALES sal ON act.customer_number = sal."AccountID"
        ), 
        orders_placed_after_call AS (
        SELECT 
            * 
        FROM 
            sales_data sd 
        WHERE 
            sd.order_date >= sd.call_date
        ), 
        sales AS (
        SELECT 
            DISTINCT rep_id, 
            rep_name, 
            CN, 
            customer_name, 
            order_date, 
            count(DISTINCT task_id) AS num_calls, 
            true_lead_source_detail__c, 
            createddate 
        FROM 
            orders_placed_after_call 
        GROUP BY 
            rep_id, 
            rep_name, 
            CN, 
            customer_name, 
            order_date, 
            true_lead_source_detail__c, 
            createddate
        ), 
        first_last_call AS (
        SELECT 
            CN, 
            rep_id, 
            rep_name, 
            MIN(call_dt) AS first_call_dt, 
            MAX(call_dt) AS last_call_dt 
        FROM 
            orders_placed_after_call 
        GROUP BY 
            CN, 
            rep_id, 
            rep_name
        ), 
        revenues AS (
        SELECT 
            DISTINCT CN, 
            COUNT(DISTINCT order_number) as cn_orders_after_call, 
            SUM(
            CASE WHEN product_name like 'RHA%' THEN "Revenue" ELSE 0 END
            ) AS RHA_REVENUE_after_call, 
            SUM(
            CASE WHEN product_name = 'DAXXIFY' THEN "Revenue" ELSE 0 END
            ) AS DAXI_REVENUE_after_call, 
            SUM(
            CASE WHEN product_name like 'RHA%' THEN "Quantity" ELSE 0 END
            ) AS RHA_QUANTITY_after_call, 
            SUM(
            CASE WHEN product_name = 'DAXXIFY' THEN "Quantity" ELSE 0 END
            ) AS DAXI_QUANTITY_after_call, 
            SUM("Revenue") AS TOTAL_REVENUE_after_call, 
            SUM("Quantity") AS TOTAL_QUANTITY_after_call 
        FROM 
            orders_placed_after_call 
        GROUP BY 
            CN
        ), 
        min_call AS (
        SELECT 
            min(call_date) AS first_call, 
            coalesce(
            sd.to_account_id, sd.customer_id
            ) AS customer_idd, 
            sd.cn AS customer_number 
        FROM 
            sales_data sd 
        GROUP BY 
            ALL
        ), 
        orderbeforecall AS (
        WITH max_order AS (
            SELECT 
            mc.first_call, 
            mc.customer_number, 
            max(sd.order_date) AS last_order, 
            sd.createddate 
            FROM 
            sales_data sd 
            LEFT JOIN min_call mc ON mc.customer_number = sd.cn 
            WHERE 
            sd.order_date < (mc.first_call) 
            GROUP BY
            ALL
        ) 
        SELECT 
            CASE WHEN DATEDIFF(MONTH, last_order, first_call) > 11 THEN 'lapsed12+MONTHS' 
                WHEN DATEDIFF(MONTH, last_order, first_call) > 5 THEN 'lapsed6to11MONTHS' 
                WHEN DATEDIFF(DAY, last_order, first_call) > 0 THEN 'Active'  
                ELSE 'Net New' 
            END AS lapsed_status, 
            DATEDIFF(DAY, last_order, first_call) AS date_difference, 
            first_call, 
            last_order, 
            customer_number, 
            createddate 
        FROM 
            max_order
        ), 
        finset AS (
        SELECT 
            DISTINCT sal.rep_name, 
            sal.cn, 
            sal.customer_name, 
            sal.createddate, 
            sal.true_lead_source_detail__c, 
            flc.first_call_dt AS rep_first_call_date, 
            flc.last_call_dt AS rep_last_call_date, 
            sal.num_calls AS rep_num_calls, 
            min(flc.first_call_dt) over (partition by sal.cn) AS cn_first_call_date, 
            max(flc.last_call_dt) over (partition by sal.cn) AS cn_last_call_date, 
            sum(sal.num_calls) over (partition by sal.cn) AS cn_total_calls, 
            min(sal.order_date) AS first_order_after_call, 
            rev.cn_orders_after_call, 
            rev.rha_revenue_after_call, 
            rev.daxi_revenue_after_call, 
            rev.rha_quantity_after_call, 
            rev.daxi_quantity_after_call, 
            rev.TOTAL_REVENUE_after_call, 
            rev.TOTAL_QUANTITY_after_call 
        FROM 
            sales sal 
            LEFT JOIN first_last_call flc ON (
            sal.cn = flc.cn 
            AND sal.rep_id = flc.rep_id
            ) 
            LEFT JOIN revenues rev ON (sal.cn = rev.cn) 
        GROUP BY 
            sal.rep_name, 
            sal.cn, 
            sal.true_lead_source_detail__c, 
            sal.createddate, 
            flc.first_call_dt, 
            flc.last_call_dt, 
            sal.customer_name, 
            sal.num_calls, 
            rev.cn_orders_after_call, 
            rev.rha_revenue_after_call, 
            rev.daxi_revenue_after_call, 
            rev.rha_quantity_after_call, 
            rev.daxi_quantity_after_call, 
            rev.TOTAL_REVENUE_after_call, 
            rev.TOTAL_QUANTITY_after_call
        ) 
        SELECT 
        fin.rep_name, 
        fin.cn, 
        fin.customer_name, 
        CASE WHEN obc.last_order IS null THEN 'DigiLead' ELSE 'Existing' END AS source, 
        fin.rep_first_call_date, 
        fin.rep_last_call_date, 
        fin.rep_num_calls, 
        fin.cn_first_call_date, 
        CASE WHEN obc.createddate IS null THEN fin.createddate ELSE obc.createddate END AS createddate, 
        fin.cn_last_call_date, 
        fin.cn_total_calls, 
        fir.rep_name AS cn_first_caller, 
        lst.rep_name AS cn_last_caller, 
        obc.date_difference AS Days_Between_First_Call_Previous_Order, 
        obc.last_order AS last_order_before_call, 
        CASE WHEN last_order IS null 
        AND (
            obc.createddate > mc.first_Call 
            or fin.createddate > mc.first_Call
        ) THEN 'YES' ELSE 'NO' END AS Is_Conversion, 
        coalesce(obc.lapsed_status, 'Net New') AS account_standing_at_first_call, 
        fin.first_order_after_call, 
        fin.cn_orders_after_call, 
        fin.rha_revenue_after_call, 
        fin.daxi_revenue_after_call, 
        fin.rha_quantity_after_call, 
        fin.daxi_quantity_after_call, 
        fin.TOTAL_REVENUE_after_call, 
        fin.TOTAL_QUANTITY_after_call 
        FROM 
        finset fin 
        LEFT JOIN first_last_call fir ON (
            fin.cn = fir.cn 
            AND fin.cn_first_call_date = fir.first_call_dt
        ) 
        LEFT JOIN first_last_call lst ON (
            fin.cn = lst.cn 
            AND fin.cn_last_call_date = lst.last_call_dt
        ) 
        LEFT JOIN orderbeforecall obc ON obc.customer_number = fin.cn 
        LEFT JOIN min_call mc ON mc.customer_number = fin.cn 
        ORDER BY 
        last_order_before_call DESC

);
