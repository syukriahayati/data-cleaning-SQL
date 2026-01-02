# Data Cleaning Project using SQL

## 📌 Project Overview
This project focuses on cleaning a real-world dataset using SQL.  
The dataset contains company layoff information, including company name, industry, country, number of employees laid off, and dates.

The main goal of this project is to transform raw data into a clean, consistent, and analysis-ready dataset.

---

## 📊 Dataset
- Dataset name: Layoffs Dataset  
- Source: Alex The Analyst (YouTube)  
- Original file: layoffs.csv  
- Data type: Company layoff records  

The dataset was obtained from the following repository:  
https://github.com/AlexTheAnalyst/MySQL-YouTube-Series/blob/main/layoffs.csv

---

## 🎯 Objective
The objectives of this project are:
- Remove duplicate records  
- Handle missing and null values  
- Standardize text formats  
- Fix inconsistent data types  
- Improve overall data quality for further analysis  

---

## 🧹 Data Cleaning Steps
The following steps were performed using SQL:

1. Created a staging table to avoid modifying the raw dataset  
2. Removed duplicate records using `ROW_NUMBER()`  
3. Standardized company and industry names  
4. Converted date columns into proper `DATE` format  
5. Handled null and blank values  
6. Removed rows with missing critical information  

Example actions:
- Replaced blank industry values with `NULL`  
- Merged similar industry labels (e.g., "Crypto" and "Crypto Currency")  

---

## 🛠 Tools Used
- MySQL  
- SQL (CTE, Window Functions)  
- GitHub  

---

## 📈 Result
After cleaning:
- Duplicate records were successfully removed  
- Data inconsistencies were reduced  
- The dataset is now structured and ready for exploratory data analysis (EDA)  

---

## 📁 Project Structure
├── README.md
├── layoffs_raw.sql
├── layoffs_cleaning.sql
└── layoffs_cleaned.sql

---

## 🔗 Reference
- Alex The Analyst – MySQL Data Cleaning Project  
- YouTube Video: https://www.youtube.com/watch?v=4UltKCnnnTA
