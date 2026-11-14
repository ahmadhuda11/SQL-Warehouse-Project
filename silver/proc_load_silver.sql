
CREATE OR ALTER PROCEDURE silver.load_silver AS  

BEGIN 

-- First table 

DECLARE @start_time DATETIME, @end_time DATETIME

PRINT '>> Truncating table silver.crm_cust_info before inserting data'; 
SET @start_time = GETDATE();
TRUNCATE table silver.crm_cust_info;	
PRINT '>> Inserting Data into: silver.crm_cust_info';
PRINT 'Loading CRM tables'; 
 
INSERT INTO silver.crm_cust_info ( 
cst_id,
cust_key,
cust_firstname,
cust_lastname,
cst_marital_status,
cst_gndr,
cst_create_date
)


-- Trimming, checking for unwanted spaces and stuff
SELECT
cst_id,
cust_key,
TRIM(cust_firstname) as  cust_FirstName,
TRIM(cust_lastname) as cust_LastName,

--- fixing the names, mapping in other context
CASE WHEN UPPER (TRIM (cst_marital_status)) = 'S' THEN 'Single'
    WHEN UPPER (TRIM (cst_marital_status)) = 'M' THEN 'Married'
	ELSE 'n/a' -- here we are replacing 'S' 'M' with 'Single' and 'Married' 
	END cst_marital_status,



	--- fixing the names, mapping in other context
CASE WHEN UPPER (TRIM (cst_gndr)) = 'F' THEN 'Female'
    WHEN UPPER (TRIM (cst_gndr)) = 'M' THEN 'Male'
	ELSE 'n/a' -- here we are replacing 'F' 'M' with 'Female' and 'Male' 
	END cst_gndr,
cst_create_date

FROM ( 

-- Ranking and finding rank 1  and parititioning them by cst_id 
select 
*,
row_number () OVER ( PARTITION by cst_id order by cst_create_date DESC) Flag_last
from bronze.crm_cust_info
where cst_id  is not  null 
)t WHERE flag_last = 1 

  SET @end_time = GETDATE();
        PRINT '>> load Duration: ' + CAST (DATEDIFF (second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-----';

--- Second table 

PRINT '>> Truncating table silver.crm_prd_info before inserting data'; 
SET @start_time = GETDATE()
TRUNCATE table silver.crm_prd_info;
PRINT '>> Inserting Data into: silver.crm_cust_info';

INSERT INTO silver.crm_prd_info (
prd_id,
category_id,
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
)

-- Extract category ID and product key from the composite prd_key field
SELECT 
prd_id,
REPLACE (SUBSTRING (prd_key, 1, 5), '-' ,'_') as category_id,-- Extract category_id
SUBSTRING (prd_key, 7, LEN(prd_key)) as prd_key, --  Extract product key 
prd_nm,
COALESCE (Prd_cost, 0) as prd_cost,

CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
	 WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
	 WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
	 WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
	 ELSE 'n/a'

	 END AS prd_line, -- Map Product lines to descriptive values 


CAST( prd_start_dt AS DATE) AS prd_start_dt, -- changes the datatype to DATE
CAST (LEAD(	prd_start_dt) OVER ( PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE)  prd_end_dt -- Calculate the end date as one date before the next start date
FROM bronze.crm_prd_info

 SET @end_time = GETDATE();
        PRINT '>> load Duration: ' + CAST (DATEDIFF (second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-----'; 




--- Third table 

PRINT '>> Truncating table silver.crm_sales_details before inserting data';
SET @start_time = GETDATE();
TRUNCATE table silver.crm_sales_details;
PRINT '>> Inserting Data into: silver.crm_sales_details';


INSERT INTO silver.crm_sales_details  (
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price 

	)


SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
	ELSE CAST ( CAST(sls_order_dt AS VARCHAR) AS DATE ) 
	END AS sls_order_dt,

	CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL 
	ELSE CAST (CAST(sls_ship_dt AS VARCHAR) AS DATE ) 
	END AS sls_ship_dt,

	CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
	ELSE CAST (CAST(sls_due_dt AS VARCHAR) AS DATE)
	END as sls_due_dt,

CASE WHEN  sls_sales IS NULL OR sls_sales <= 0 or sls_sales != sls_quantity * ABS(sls_price)
			THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
		END AS sls_sales,
	sls_quantity,
CASE WHEN sls_price is NULL OR sls_price <= 0 
		THEN sls_sales / NULLIF(sls_quantity, 0) 
	ELSE sls_price 

END AS sls_price 
FROM bronze.crm_sales_details

set @end_time = GETDATE();

PRINT '<< Loading time:' + CAST ( DATEDIFF ( second, @start_time, @end_time) AS NVARCHAR) + 'seconds'

 PRINT '-----'; 




-- ERP first table
PRINT '>> Truncating table silver.erp_cust_az12 before inserting data';
SET @start_time = GETDATE();
TRUNCATE table silver.erp_cust_az12;
PRINT '>> Inserting Data into: silver.erp_cust_az12';
Insert into silver.erp_cust_az12 (
cid,
bdate, 
gen
) 
SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING (cid, 4, LEN (cid)) 
ELSE cid
END as cid, 

CASE WHEN bdate > GETDATE() THEN NULL
ELSE bdate
END as bdate,
CASE WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'female'
	 WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
ELSE 'N/A'
END AS gen
FROM bronze.erp_cust_az12
SET @end_time = GETDATE()
PRINT '<< Loading duration:' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'
PRINT '=================='


-- ERP second table 
PRINT '>> Truncating table silver.erp_loc_a101 before inserting data'; 
SET @start_time = GETDATE();
TRUNCATE table silver.erp_loc_a101;
PRINT '>> Inserting Data into: silver.erp_loc_a101';

INSERT INTO silver.erp_loc_a101 ( cid, cntry) -- we inserting the new data to the silver layer

SELECT 
REPLACE(cid, '-', '') cid, -- we replacing the '-' with ''

CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany' -- we mapping out the results to clean the data and remove unwanted spaces and changing the abberavtion''
	 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
	 WHEN TRIM(cntry) = '' OR cntry is NULL THEN 'N/A'
	ELSE TRIM(cntry) 
	end as cntry
		
FROM bronze.erp_loc_a101

SET @end_time = GETDATE();
PRINT '<< Loading time:' + CAST ( DATEDIFF ( second, @start_time, @end_time) as nvarchar) + 'seconds'
PRINT'------------------'

--ERP third table

PRINT '>> Truncating table silver.erp_px_cat_g1v2 before inserting data';
set @start_time = GETDATE()
TRUNCATE table silver.erp_px_cat_g1v2;
PRINT '>> Inserting Data into: silver.erp_px_cat_g1v2';

INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, MAINTENANCE) 

select
id,
cat,
subcat,
MAINTENANCE
from bronze.erp_px_cat_g1v2

SET @end_time = GETDATE();
PRINT '<< Loading time:' + CAST ( DATEDIFF ( second, @start_time, @end_time) as nvarchar) + 'seconds'
PRINT'------------------'


END



