
-- Joining  tables with their primary key. ( crm_cust_info with erp_cust_az12 ) 


	CREATE OR ALTER VIEW gold.dim_customers AS  -- we created a view here to use.

	SELECT 
	ROW_NUMBER () OVER ( ORDER BY ci.cst_id) as customer_key, --- -- Generate a unique surrogate key for each customer

			ci.cst_id AS customer_id, 
			ci.cust_key AS customer_number,
			ci.cust_firstname AS firstname,
			ci.cust_lastname AS lastname,
			la.CNTRY AS country,
			ci.cst_marital_status AS marital_status,

		CASE WHEN cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master for gender info after asking our colleagues
			ELSE  LOWER(COALESCE(ca.gen, 'n/a'))
			END AS gender,

			ca.bdate AS birthdate,
			ci.cst_create_date AS create_date

		FROM silver.crm_cust_info as ci 
		LEFT JOIN silver.erp_cust_az12 as ca
		ON ci.cust_key =  ca.cid
		LEFT JOIN silver.erp_loc_a101 as la
		ON ci.cust_key = la.cid


		GO



CREATE OR ALTER VIEW gold.dim_products AS
 SELECT
ROW_NUMBER () OVER ( ORDER BY pn.prd_start_dt,  prd_id) as Product_key,
	pn.prd_id AS product_id,
    pn.prd_key AS product_number,
    pn.prd_nm AS product_name,
    pn.category_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance AS maintenance,
    pn.prd_cost AS cost,
    pn.prd_line AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.category_id = pc.id 
WHERE prd_end_dt IS NULL -- Filter out all historical data







CREATE OR ALTER VIEW gold.fact_sales AS 
SELECT
    a.sls_ord_num AS order_number,
    b.product_key,
    cu.customer_key,
    a.sls_order_dt AS order_date,
    a.sls_ship_dt AS shipping_date,
    a.sls_due_dt AS due_date,
    a.sls_sales AS sales_amount,
    a.sls_quantity AS quantity,
    a.sls_price AS price
FROM silver.crm_sales_details as a 
LEFT JOIN gold.dim_products as b    
ON a.sls_prd_key = b.product_number
LEFT JOIN gold.dim_customers as cu 
ON  a.sls_cust_id = cu.customer_id


 -- Just testing here and checking the views. 
SELECT * from gold.fact_sales
select * from gold.dim_customers
select * from gold.fact_sales








