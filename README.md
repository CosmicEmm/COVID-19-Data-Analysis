# 🦠 COVID-19 Data Analysis in MySQL

This project demonstrates **data cleaning, transformation, and analytical querying** of global COVID-19 datasets using **MySQL 8.0+**. It showcases advanced SQL concepts such as **window functions**, **CTEs**, **temporary tables**, **Subqueries**, **joins**, and **views** — all designed as a portfolio project for data analytics and database development roles.

---

## 📚 Overview

The dataset combines worldwide COVID-19 **deaths** and **vaccinations** statistics, then performs:

- Data import and preprocessing (cleaning malformed entries)
- Aggregation of key metrics (total deaths, vaccination counts)
- Time-series analysis using **rolling sums**
- Creation of reusable **views** for dashboards or BI tools
- Export of summarized results for further analysis in Python / Excel

---

## 🏗️ Project Structure

| Folder / File | Description |
|----------------|-------------|
| `COVID-19.sql` | Main SQL script that includes data cleaning, joins, and analytical queries. |
| `data/` | Contains input CSV files (`deaths.csv`, `vaccinations.csv`) |

---

## 🧰 Tools & Technologies

- **MySQL 8.0+** — Database & SQL engine  
- **SQL Workbench / MySQL CLI** — Query execution  
- **Python 3.x** *(optional)* — For data visualization or export analysis  
- **Pandas**, **mysql-connector-python**, **SQLAlchemy**

---

## ⚙️ How to Run

1. **Clone the repository**
   ```bash
   git clone https://github.com/<your-username>/COVID19-MySQL-Analysis.git
   cd COVID19-MySQL-Analysis
