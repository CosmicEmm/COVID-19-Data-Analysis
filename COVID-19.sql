CREATE DATABASE IF NOT EXISTS covid_19;

USE covid_19;

-- Create Tables ------------------------------------------------------

CREATE TABLE IF NOT EXISTS Deaths(
	country VARCHAR(255),
    date DATE,
    population INT,
    total_cases INT,
    new_cases INT,
    total_deaths INT,
    new_deaths INT,
    total_tests INT,
    new_tests INT,
    positive_rate DECIMAL,
    code VARCHAR(10),
    continent VARCHAR(255),
    population_density DECIMAL,
    median_age DECIMAL,
    life_expectancy DECIMAL
    );

CREATE TABLE IF NOT EXISTS Vaccinations(
	country VARCHAR(255),
    date DATE,
    population INT,
    total_vaccinations INT,
    people_vaccinated INT,
    people_fully_vaccinated INT,
    total_boosters INT,
    new_vaccinations INT,
    code VARCHAR(10),
    continent VARCHAR(255),
    population_density DECIMAL,
    median_age DECIMAL,
    life_expectancy DECIMAL
    );

-- -------------------------------------------------------------------
-- Load data from CSV files into tables
-- Loading files requires proper server/client privileges and `local_infile` config.
-- Ignore 1 row to skip CSV header
-- -------------------------------------------------------------------

/*
LOAD DATA LOCAL INFILE 'F:\COVID-19 Deaths.csv'
INTO TABLE deaths
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
*/

/*
LOAD DATA LOCAL INFILE 'F:\COVID-19 Vaccinations.csv'
INTO TABLE vaccinations
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
*/

-- --------------------------------------------------------------------
-- Basic sanity checks and quick inspection
-- --------------------------------------------------------------------

-- Count number of records
SELECT COUNT(*) AS total_rows FROM deaths;
SELECT COUNT(*) AS total_rows FROM vaccinations;

-- Preview first rows to inspect columns (use LIMIT for readability)
SELECT * FROM deaths LIMIT 10;
SELECT * FROM vaccinations LIMIT 10;

-- --------------------------------------------------------------------
-- Data Cleaning and Formatting
-- --------------------------------------------------------------------

-- Move the 'code' column to be the first column
ALTER TABLE deaths
MODIFY code VARCHAR(10)
FIRST;

ALTER TABLE vaccinations
MODIFY code VARCHAR(10)
FIRST;

-- Moving the 'continent' column after the 'code' column
ALTER TABLE deaths
MODIFY continent VARCHAR(255)
AFTER code;

ALTER TABLE vaccinations
MODIFY continent VARCHAR(255)
AFTER code;

-- Rename column 'country' to 'location'
ALTER TABLE deaths
RENAME COLUMN country TO location;

ALTER TABLE vaccinations
RENAME COLUMN country TO location;

-- Update data in table
UPDATE deaths
SET location = 'World excl. China'
where location = '"World excl. China';

UPDATE vaccinations
SET location = 'World excl. China'
where location = '"World excl. China';

UPDATE deaths
SET continent = NULL
WHERE continent = '';

UPDATE deaths
SET code = 'INCOME'
WHERE location LIKE '%countries';

-- Remove rows where code is empty
DELETE FROM deaths
WHERE code = '';

-- Order by location and date
SELECT * FROM deaths
ORDER BY 3, 4;

SELECT * FROM vaccinations
ORDER BY 3, 4;

-- Select specific columns for analysis
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM deaths
WHERE continent IS NOT NULL  # exludes grouped countries and entire continents
ORDER BY 1, 2;

-- --------------------------------------------------------------------
-- Looking at Total Cases vs Total Deaths to find the likelihood of one dying after contracting COVID
-- --------------------------------------------------------------------

-- Pakistan
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Rate
FROM deaths
WHERE location = 'Pakistan'
ORDER BY 1, 2;

-- United States of America
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Rate
FROM deaths
WHERE location like '%States%'
ORDER BY 1, 2;

-- --------------------------------------------------------------------
-- Looking at Total Cases vs Population to find the percentage of population infected
-- --------------------------------------------------------------------

-- Pakistan
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Infection_Rate
FROM deaths
WHERE location = 'Pakistan'
ORDER BY 1, 2;

-- --------------------------------------------------------------------
-- Grouped aggregations
-- --------------------------------------------------------------------

-- Looking at countries with the highest infection rates with respect to population
SELECT location, population, MAX(total_cases) AS highest_infection_count , MAX(total_cases/population)*100 AS population_infection_rate
FROM deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY population_infection_rate DESC;

-- Looking at countries with the highest death count
SELECT location, MAX(total_deaths) AS highest_death_count
FROM deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_death_count DESC;

-- Looking at the relationship between death count and the economic status of countries
SELECT location, MAX(total_deaths) AS highest_death_count
FROM deaths
WHERE code = 'INCOME'
GROUP BY location
ORDER BY highest_death_count DESC;

-- Breaking things down by continent
SELECT location, MAX(total_deaths) AS highest_death_count
FROM deaths
WHERE continent IS NULL AND code != 'INCOME'
GROUP BY location
ORDER BY highest_death_count DESC;

-- Calculate the grand total of all deaths across North America using Subquery
SELECT SUM(highest_death_count) AS grand_total
FROM(
	SELECT location, MAX(total_deaths) AS highest_death_count
	FROM deaths
	WHERE continent = 'North America'
	GROUP BY location
	ORDER BY highest_death_count DESC
    ) AS grouped; # Every derived table must have its own alias

-- --------------------------------------------------------------------
-- Global Numbers
-- --------------------------------------------------------------------

-- Total number of cases and deaths recorded worldwide (per day)
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS death_count, (SUM(new_deaths)/SUM(new_cases))*100 as death_rate
FROM deaths
WHERE continent IS NULL
GROUP BY date
ORDER BY 1;

-- Total number of cases and deaths recorded worldwide (aggregate)
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS death_count, (SUM(new_deaths)/SUM(new_cases))*100 as death_rate
FROM deaths
WHERE continent IS NULL;

-- --------------------------------------------------------------------
-- Join tables for combined analysis
-- Inner join deaths and vaccinations on location and date (time-aligned rows)
-- --------------------------------------------------------------------
SELECT d.location, d.date, d.population, d.total_deaths, d.new_deaths, v.new_vaccinations, v.people_vaccinated
FROM deaths AS d
INNER JOIN vaccinations AS v
    ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
LIMIT 100;

-- --------------------------------------------------------------------
-- Percentage of population vaccinated in each country (using three alternative methods)
-- --------------------------------------------------------------------

-- Method 1: CTE ------------------------------------------------------
WITH PopvsVac (Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS (
	SELECT d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY location ORDER BY date) AS RollingPeopleVaccinated
	FROM deaths AS d
	INNER JOIN vaccinations AS v
		ON d.location = v.location AND d.date = v.date
	WHERE d.continent IS NOT NULL
    )
SELECT Location, Population, MAX(RollingPeopleVaccinated) AS total_vaccines, MAX((RollingPeopleVaccinated/Population)*100) AS vaccination_rate
FROM PopvsVac
GROUP BY location, population
ORDER BY 1;

-- Method 2: Temp Table -----------------------------------------------
DROP TABLE if exists vaccination_rate; # speeds up workflow when making alterations to a temp table

CREATE TEMPORARY TABLE vaccination_rate(
	location VARCHAR(255),
    date DATE,
    population INT,
    new_vaccinations INT,
    rolling_vaccine_count BIGINT  # If a column needs to hold large totals, set datatype to BIGINT
    );
    
INSERT INTO vaccination_rate  # Temp table can be populated by selecting data from existing tables
SELECT d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY location ORDER BY date) AS RollingPeopleVaccinated
FROM deaths AS d
INNER JOIN vaccinations AS v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL;

SELECT location, population, MAX(rolling_vaccine_count) as total_vaccines, MAX((rolling_vaccine_count/population)*100) AS vaccination_rate
FROM vaccination_rate
GROUP BY location, population
ORDER BY 1;

-- METHOD 3: Subquery -------------------------------------------------
SELECT location, population, MAX(RollingPeopleVaccinated) AS total_vaccines, MAX((RollingPeopleVaccinated/Population)*100) AS vaccination_rate
FROM(
	SELECT d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY location ORDER BY date) AS RollingPeopleVaccinated
	FROM deaths AS d
	INNER JOIN vaccinations AS v
	ON d.location = v.location AND d.date = v.date
	WHERE d.continent IS NOT NULL
    ORDER BY 1, 2
    ) AS grouped
GROUP BY location, population
ORDER BY 1;

-- --------------------------------------------------------------------
-- Create View: Views are helpful to share a reusable query for dashboards / BI tools
-- --------------------------------------------------------------------

DROP VIEW if exists RollingPeopleVaccinated;

CREATE VIEW RollingPeopleVaccinated AS
SELECT d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY location ORDER BY date) AS RollingPeopleVaccinated
FROM deaths AS d
INNER JOIN vaccinations AS v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL;

SELECT location, population, MAX(rollingpeoplevaccinated) AS total_vaccinations
FROM rollingpeoplevaccinated
WHERE population >= 200000000
GROUP by location, population
ORDER BY population DESC;