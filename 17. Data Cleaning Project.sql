-- Data Cleaning Project

SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank Values
-- 4. Remove Any Columns 

# We can create another table to staging the raw data
CREATE TABLE layoffs_staging 
LIKE layoffs;

SELECT *
FROM layoffs_staging;

# Let's insert the data form the layoffs table
INSERT layoffs_staging
SELECT *
FROM layoffs;


-- 1. Remove Duplicates
-- Check, identify and delete existing duplicates in the table
# To ensure data integrity before performing deletions, 
# I first create a new table, layoffs_staging2, as a copy of layoffs_staging. 
# In this new table, I add an additional column, 
# row_num, which will help identify duplicate records.
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

# Using the ROW_NUMBER() function, I assign a unique row number to each record, 
# partitioning by all columns in the table. This allows any duplicate entries to receive a row_num greater than 1.
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;

# After populating layoffs_staging2, I perform a validation step to check for duplicates by filtering records where row_num is greater than 1. 
# If duplicates are found, they are removed, ensuring that only distinct records remain in the table.
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;

# This approach helps maintain the original data while safely removing duplicates in a structured manner.


-- 2. Standardize the Data
# Standardizing data finding issues in the data and then fixing it.

# Next, I check for any leading white spaces in the company column to ensure data consistency
SELECT company, TRIM(company)
FROM layoffs_staging2;

# After detecting leading white spaces in the company column, I use LTRIM() to remove them and update layoffs_staging2, ensuring consistent formatting.
UPDATE layoffs_staging2
SET company = TRIM(company);

# Next, I examine the industry column to identify any potential data issues.
SELECT DISTINCT(industry)
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';
# I found an inconsistency in the industry column where "coryptoCurrency" and "Crypto Currency" likely refer to the same industry.

# I'll standardize the naming to ensure data consistency.
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

# Next, I review the location column and find no issues.
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;
#  Its data appears clean and consistent.

# I found an issue in the country column where "United States" appears with a trailing period.
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT *
FROM layoffs_staging2;

# The date column is currently defined as text, but it should be in the datetime format for proper handling.
# I will convert the column to datetime to ensure correct date operations and improve data integrity.
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- 3. Null Values or Blank Values
# Next, I check the industry column for NULL or blank values to identify any missing data that may need to be addressed.
# If any blank values are found in the industry column, I will update them to NULL to ensure consistency in handling missing data.
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

# To repopulate NULL values in the industry column, I will search for companies that have missing industry values and check 
# if the same company appears elsewhere in the table with a valid industry. If a match is found, I will update the NULL values accordingly.
SELECT t1.company, t1.industry,  t2.company, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL 
AND t2. industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2. industry IS NOT NULL;

# We successfully filled in NULL values for some companies, but one company still has a missing industry value. 
# I will assign it to "Other".
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL;

UPDATE layoffs_staging2
SET industry = 'Other'
WHERE company LIKE 'Bally%';

# There are many NULL values in the total_laid_off and percentage_laid_off columns. 
# Since we lack the total number of employees to calculate these values, we cannot repopulate them.
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

# To ensure data quality and avoid issues in analysis, I will delete all rows where total_laid_off or percentage_laid_off contain NULL values.
# But the original raw data remains available in the layoffs table.
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

# The final step in the data cleaning process is to remove the row_num column that was created earlier.
SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
# Now that the data has been cleaned and the unnecessary columns removed, our table is ready for exploratory data analysis.