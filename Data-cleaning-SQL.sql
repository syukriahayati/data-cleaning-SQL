-- start 18 December 25 8:02 AM
-- after creating schema, you need to import it. and here's your raw data :
SELECT * 
FROM layoffs;

-- anyway, there's a few step to clean the data :
-- 1. Remove duplicate
-- 2. Standardize the data
-- 3. NULL values or blank
-- 4. Remove any columns

-- 1. Remove duplicate
-- create another table, cause you can't do it in raw data.
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

-- now, if you have the table. next we'll check the duplicate using ROW_NUM and PARTITION (this is called WINDOWS FUNCTION) to all the column, aliasing row_num as new column
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, `date`, percentage_laid_off, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging;

-- use CTE for temporary storage instead of long subqueries
WITH duplicate_cte as (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, `date`, percentage_laid_off, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- we can't use DELETE over CTE ('cause its just temporary and not real data), so we need another table (just right click layoffs_staging -> copy to clipboard -> create statement -> paste here)

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
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- here, the table is done
SELECT *
FROM layoffs_staging2;

-- now insert the same value in CTE (just copy the query) into new table
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, `date`, percentage_laid_off, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging;

-- check the duplicate again
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- finally we can get rid of them with DELETE (I got an 1175 error here because of safe update, can't change it in preferences tho but this code works perfect: SET SQL_SAFE_UPDATES = 0;)
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SET SQL_SAFE_UPDATES = 0;


-- 2. Standardizing the data
-- you need to check each column carefully
-- column: company
SELECT company, TRIM(company)
FROM layoffs_staging2;

-- issue: company name need to be TRIM?
UPDATE layoffs_staging2
SET company = TRIM(company);

-- column: industry, use DISTINCT to see any differences and use ORDER BY
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- issue: Crypto writing
SELECT DISTINCT industry
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- change with this
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- column: location
-- I found some issues here, but have no idea how to fix the writing ('cause some country have their own alphabet)
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

-- column: country
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- issue: United States writing
SELECT DISTINCT country
FROM layoffs_staging2
WHERE country LIKE 'United States%';

-- change it with this
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country) 
WHERE country LIKE 'United States%';

-- column: date
-- issue: the formatting still in "text", while you need to change it to "date" (to be able to make time series)
SELECT `date`
FROM layoffs_staging2;

-- issue: change it with STR_TO_DATE
SELECT `date`,
STR_TO_DATE( `date`, '%m/%d/%Y')
FROM layoffs_staging2;

-- then update the entire column, but if you refresh the schema, you might notice the date column still on 'text' formatting
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE( `date`, '%m/%d/%Y');

-- so, we need ALTER 
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3. Working with NULL values or blank
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- notice there's NULL and BLANK value in industry column
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = '';

-- check every company if they are populable
-- this is populable
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- this is not populable
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

-- recommended: change the BLANK into NULL value
UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = '';

-- self JOIN 
SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2. company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- populate the NULLs (if populable)
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- 4. Remove any columns
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;

-- ends 31 December 2025 3:52 PM
