/*
============================================================
Create Database and Schemas
============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists.
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas
    within the database: 'bronze', 'silver', and 'gold'.

WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists.
    All data in the database will be permanently deleted. Proceed with caution
    and ensure you have proper backups before running this script.
*/


--Drop and recreate the Database ''DataWarehouse''

IF EXISTS (SELECT 1 FROM sys.databases  WHERE NAME = 'DataWarehouse')

BEGIN 
ALTER DATABASE DataWarehouse SET Single_user with ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
	END;
	GO



--Create DataWarehouse Database
Create DATABASE DataWarehouse

-- Use the DataBase
USE DATABASE DataWarehouse
GO



--Creating the Schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
