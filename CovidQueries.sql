SELECT *
FROM covid..covid_deaths
ORDER BY 3,4;

--SELECT *
--FROM covid..covid_vaccinations
--ORDER BY 3,4;

-- Select data to be used

SELECT Location, date, total_cases, new_cases, total_deaths, population
from covid..covid_deaths
ORDER BY 1,2

--looking at total cases vs total deaths
--shows the likelihood of dying given that you have covid in the US
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS percent_deaths
FROM covid..covid_deaths
WHERE location like '%states'
ORDER BY 1,2

--looking at total cases vs population
--shows percentage of population that has covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS percent_infected
FROM covid..covid_deaths
WHERE location like '%states'
ORDER BY 1,2

-- looking at countries with highest infection rate vs population

SELECT Location, Population, MAX(total_cases) AS total_infection_count,MAX(total_cases/population)*100 AS highest_percent_infected
FROM covid..covid_deaths
GROUP BY population,location
ORDER BY 4 DESC

-- Showing countries with highest death count per population

SELECT Location, Population, MAX(CAST(total_deaths AS INT)) AS total_death_count,MAX(total_deaths/population)*100 AS highest_percent_died
FROM covid..covid_deaths
WHERE continent IS NOT null
GROUP BY population,location
ORDER BY 3 DESC;

--show continents with highest death count per population

SELECT location,population,MAX(CAST(total_deaths AS INT)) AS total_death_count,MAX(total_deaths/population)*100 AS highest_percent_died
FROM covid..covid_deaths
WHERE continent IS null
GROUP BY location,population
ORDER BY highest_percent_died DESC;

-- GLOBAL NUMBERS

SELECT date, sum(new_cases) AS daily_new_cases, SUM(CAST(new_deaths AS int)) AS daily_new_deaths, 
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS percent_deaths_world
FROM covid..covid_deaths
WHERE continent IS NOT null
GROUP BY date
ORDER BY 1,2;

--Total population vs vaccinations
--USE CTE

WITH PopVsVac (Continent, Location, Date, Population, new_vaccinations, rolling_vacc_count)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CAST(vac.new_vaccinations AS int)) OVER 
	(PARTITION by dea.Location ORDER BY dea.location, dea.date) AS rolling_vacc_count
--,	(rolling_vacc_count/population)*100 AS percent_vaccinated		

FROM covid..covid_deaths dea
JOIN covid..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
)

SELECT *,(rolling_vacc_count/population)*100 AS percent_vaccinated
FROM PopVsVac

--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
DATE datetime,
Population numeric,
new_vaccinations numeric,
rolling_vacc_count numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CAST(vac.new_vaccinations AS int)) OVER 
	(PARTITION by dea.Location ORDER BY dea.location, dea.date) AS rolling_vacc_count
--,	(rolling_vacc_count/population)*100 AS percent_vaccinated		

FROM covid..covid_deaths dea
JOIN covid..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null


SELECT *,(rolling_vacc_count/population)*100 AS percent_vaccinated
FROM #PercentPopulationVaccinated
ORDER BY location

--Creating view to store data for vizualizations

USE [covid]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create VIEW PercentPopVacc AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CAST(vac.new_vaccinations AS int)) OVER 
	(PARTITION by dea.Location ORDER BY dea.location, dea.date) AS rolling_vacc_count
--,	(rolling_vacc_count/population)*100 AS percent_vaccinated		

FROM covid..covid_deaths dea
JOIN covid..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null


