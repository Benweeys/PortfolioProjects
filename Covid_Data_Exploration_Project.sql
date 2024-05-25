
/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Window Functions, Aggregate Functions, Creating Views, Converting Data Types
	
*/


/*
Exploring the dataset revealed that it contains aggregate numbers for continents and worldwide
In such cases, the "location" field contains the continent name and the "continent" field is left empty
Hence rows where "continent" is blank is ommitted from our analysis
As the data is of a time series format, we use "Max" function to analyse the variable at its peak
*/


-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects.dbo.CovidDeaths$
WHERE continent is not null 
ORDER BY location,date

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if contracting covid in Singapore

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjects.dbo.CovidDeaths$
WHERE location like '%Singapore' and continent is not null
ORDER BY location,date


-- Looking at Total Cases vs Population
-- Shows percentage of population that contracted Covid in Singapore

SELECT location, date, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProjects.dbo.CovidDeaths$
WHERE location like '%Singapore'
ORDER BY 1,2


-- Looking at Countries with the Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentagePopulationInfected
FROM PortfolioProjects.dbo.CovidDeaths$
GROUP BY location,population
ORDER BY 4 DESC

-- Looking at Countries with the Highest Death Rate 
SELECT location, MAX(cast(total_cases as int)) as HighestCaseCount, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX(cast(total_deaths as float)/cast(total_cases as float)*100) as PercentageDeath
FROM PortfolioProjects.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY PercentageDeath DESC


-- BY CONTINENT

-- Looking continents ranked by the Highest Death Count
SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProjects.dbo.CovidDeaths$
WHERE continent is null
and location not in ('World','International')
GROUP BY location 
ORDER BY HighestDeathCount DESC


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as cases, SUM(CAST(new_deaths as int)) as deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases) * 100) as DeathPercentage
FROM PortfolioProjects.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY date
order by 1,2

-- Percentage of Population that has received at least one Covid Vaccine (calculation using Partition By)
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.date) as RollingPeopleVaccinated,
SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.date)/dea.population*100 as PercentagePopulationVaccinated
FROM PortfolioProjects.dbo.CovidDeaths$ as dea
JOIN PortfolioProjects.dbo.CovidVaccinations$ as vac
	on dea.date = vac.date
	and dea.location = vac.location
WHERE dea.continent is not null
ORDER BY 1,2


--- Using CTE to perform calculation using Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProjects.dbo.CovidDeaths$ dea
JOIN PortfolioProjects.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentagePopulationVaccinated
FROM PopvsVac


--- Using Temp Table to perform calculation using Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric, 
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProjects.dbo.CovidDeaths$ dea
JOIN PortfolioProjects.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date


SELECT  *, (RollingPeopleVaccinated/population)*100 as PercentagePeopleVaccinated
FROM #PercentPopulationVaccinated



-- Creating View to store data for visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProjects.dbo.CovidDeaths$ as dea
Join PortfolioProjects.dbo.CovidVaccinations$ as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


