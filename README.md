

Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

#### Specifications
- **Data Sources**: Import data from two source systems (ERP and CRM) provided as CSV files.
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
- **Integration**: Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope**: Focus on the latest dataset only; historization of data is not required.
- **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics teams.

---

### BI: Analytics & Reporting (Data Analytics)

#### Objective
Develop SQL-based analytics to deliver detailed insights into:
- **Customer Behavior**
- **Product Performance**
- **Sales Trends**

These insights empower stakeholders with key business metrics, enabling strategic decision-making.

---

## 🛡️ License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and share this project with proper attribution.

## 🌟 About Me

Hi there! I'm **Ahmad**, an aspiring **Data Engineer** with a background in banking and a strong interest in building reliable, scalable, and analytics-ready data solutions.

I'm currently developing my skills in **SQL, Python, Data Warehousing, ETL, and Data Modeling**, while building hands-on projects that simulate real-world data engineering environments.





## Data Catalog

### Overview

The Gold Layer represents business-ready data structured to support analytics and reporting. It follows a **Star Schema**, consisting of two dimension views and one fact view.

### 1. gold.dim_customers

**Purpose:** Stores customer details enriched with demographic and geographic information.

| Column Name | Data Type | Description |
|---|---|---|
| customer_key | INT | Surrogate key uniquely identifying each customer record. |
| customer_id | INT | Unique identifier assigned to each customer in the source system. |
| customer_number | NVARCHAR(50) | Alphanumeric customer reference number. |
| first_name | NVARCHAR(50) | Customer's first name. |
| last_name | NVARCHAR(50) | Customer's last name. |
| country | NVARCHAR(50) | Country where the customer resides. |
| marital_status | NVARCHAR(50) | Customer's marital status (e.g., Married, Single). |
| gender | NVARCHAR(50) | Customer's gender (e.g., Male, Female). |
| birthdate | DATE | Customer's date of birth. |

### 2. gold.dim_products

**Purpose:** Provides detailed information about products, including their categories, costs, and attributes.

| Column Name | Data Type | Description |
|---|---|---|
| product_key | INT | Surrogate key uniquely identifying each product record. |
| product_id | INT | Unique product identifier from the source system. |
| product_number | NVARCHAR(50) | Alphanumeric product reference number. |
| product_name | NVARCHAR(50) | Descriptive product name, including type, color, or size. |
| category_id | NVARCHAR(50) | Identifier representing the product category. |
| category | NVARCHAR(50) | High-level product classification (e.g., Bikes, Components). |
| subcategory | NVARCHAR(50) | More detailed classification within a category. |
| maintenance_required | NVARCHAR(50) | Indicates whether the product requires maintenance (Yes/No). |
| cost | INT | Product cost in monetary units. |
| product_line | NVARCHAR(50) | Product line or series (e.g., Road, Mountain). |
| start_date | DATE | Date when the product became available. |

### 3. gold.fact_sales

**Purpose:** Stores transactional sales data for business analytics and reporting.

| Column Name | Data Type | Description |
|---|---|---|
| order_number | NVARCHAR(50) | Alphanumeric identifier for the sales order (e.g., SO54496). |
| product_key | INT | Foreign key referencing `gold.dim_products`. |
| customer_key | INT | Foreign key referencing `gold.dim_customers`. |
| order_date | DATE | Date when the order was placed. |
| shipping_date | DATE | Date when the order was shipped. |
| due_date | DATE | Date when payment was due. |
| sales_amount | INT | Total monetary value of the sales line item. |
| quantity | INT | Number of product units ordered. |
| price | INT | Price per unit of the product. |

### Relationships

The Gold Layer implements a **Star Schema** with `gold.fact_sales` at the center.

- `gold.fact_sales.product_key` → `gold.dim_products.product_key`
- `gold.fact_sales.customer_key` → `gold.dim_customers.customer_key`

Both dimension tables have a **one-to-many relationship** with the fact table.

### Sales Calculation

The total sales amount is calculated as:

`Sales Amount = Quantity × Price`

-- here is an ilustration for the above.

--The diagram illustrates the Star Schema implemented in the Gold Layer of the data warehouse. It shows how the central sales fact view connects to the customer and product dimension views through surrogate keys, enabling efficient analysis of sales performance across different customers and products.

<img width="1694" height="933" alt="image" src="https://github.com/user-attachments/assets/b4a60c77-8ce2-4648-b6f5-5b61a2543460" />




