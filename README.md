# 🦠 COVID-19 Data Analysis in MySQL

This project showcases **data cleaning**, **transformation**, and **analytical querying** of global COVID-19 datasets using **MySQL 8.0+**. It applies advanced SQL concepts such as **window functions**, **CTEs**, **temporary tables**, **subqueries**, **joins**, and **views**.

---

## 📚 Overview

The dataset combines worldwide COVID-19 **deaths** and **vaccinations** statistics, then performs:

- Data import and preprocessing
- Aggregation of key metrics
- Time-series analysis using **rolling sums**
- Creation of reusable **views** for dashboards or BI tools

---

## 📈 Key SQL Concepts Demonstrated

- `JOIN` on multiple datasets (deaths ↔ vaccinations)
- `SUM() OVER (PARTITION BY … ORDER BY …)` — window functions
- `WITH` Common Table Expressions (CTEs)
- `CREATE VIEW` for reusable aggregations
- `CREATE TEMPORARY TABLE` for intermediate storage
- `GROUP BY`, `MAX()`, `DELETE`, and `ALTER TABLE` examples
- `LOAD DATA LOCAL INFILE` for bulk imports

---

## 🏗️ Project Structure

| Folder / File | Description |
|----------------|-------------|
| `COVID-19.sql` | Main SQL script that includes data cleaning, joins, and analytical queries. |
| `data/` | Contains input CSV files (`deaths.csv`, `vaccinations.csv`) |

---

## 🧰 Tools & Technologies

- **MySQL 8.0+** — Database & SQL engine  
- **MySQL Workbench / MySQL CLI** — Query execution  

---

## ⚙️ How to Run

1. **Clone the repository**
   ```bash
   git clone https://github.com/<your-username>/COVID-19-Data-Analysis.git
   cd COVID-19-Data-Analysis
