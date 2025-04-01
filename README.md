# MySQL Data Cleaning Project

## Project Overview
This project focuses on cleaning raw data in MySQL by following a structured process to prepare it for exploratory data analysis (EDA). The raw data undergoes four key steps: removing duplicates, standardizing data, handling null and blank values, and removing unnecessary columns.

## Steps Involved in Data Cleaning

### 1. **Remove Duplicates**
   - A new table, **layoffs_staging2**, is created to hold the cleaned data.
   - The **ROW_NUMBER()** function is applied to partition the data based on all columns.
   - Duplicate rows are identified and removed by checking for rows with **row_num** greater than 1.

### 2. **Standardize the Data**
   - Leading white spaces in the **company** column are removed using the **TRIM()** function for consistency.
   - Industry names such as "CryptoCurrency" and "Crypto Currency" are standardized to a single format Crypto.
   - A period is removed from "United States." in the **country** column to ensure proper formatting.
   - The **date** column, originally stored as text, is converted to the **datetime** format.

### 3. **Null Values or Blank Values**
   - Blank values in the **industry** column are updated to **NULL**.
   - **NULL** values in the **industry** column are populated by checking other records for valid industry data associated with the same company.
   - Rows with **NULL** values in the **total_laid_off** and **percentage_laid_off** columns are deleted, as they cannot be repopulated without the total employee count.

### 4. **Remove Any Columns**
   - Columns **total_laid_off** and **percentage_laid_off** are deleted to ensure data quality and avoid issues in analysis.
   - The **row_num** column, used for identifying duplicates, is removed to clean up the final dataset.

## Final Dataset
Once the data cleaning process is completed, the final dataset is ready for exploratory data analysis (EDA), ensuring it is free of duplicates, standardized, and free from missing or irrelevant data.

## Conclusion
This project demonstrates the process of cleaning and transforming raw data in MySQL through systematic steps. The cleaned dataset is now optimized for in-depth analysis and visualizations.

