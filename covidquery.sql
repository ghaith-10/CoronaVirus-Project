SELECT *
FROM [dbo].[Coviddeaths]
ORDER by 3,4

SELECT *
FROM CovidVaccination

-- Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Coviddeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths in the UAE 
-- (Order by 2 means it will order in asc of the second column so by date)
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS DeathPercentage
 FROM Coviddeaths
 WHERE location LIKE '%Emirates%' 
ORDER BY 2

-- Looking at Total Cases Vs Population
SELECT Location, date, population, total_cases, (total_cases/population) *100 AS PercentPopulationInfected
FROM Coviddeaths
WHERE location LIKE '%Emirates%' 
ORDER BY 1,2

-- Looking at countries	with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) *100 AS PercentPopulationInfected
FROM Coviddeaths
WHERE continent IS NOT NULL
GROUP BY population, location
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(total_deaths) AS Total_deaths
FROM Coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_deaths DESC
-- *Correction to above query*
SELECT Location, MAX(CAST(total_deaths as int)) AS Total_deaths
FROM Coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_deaths DESC

-- Breaking things to continents

-- Show the totaldeathcount by continent
SELECT continent, MAX(CAST(total_deaths as int)) AS Total_deaths
FROM Coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_deaths DESC

-- The query above is not that accurate. Although this query shows that other continents been classified which is not among the main continents that we know of in the real world
-- We could just filter out the extra continents(location) which would be an approximate estimation of deathcounts in continents.
SELECT location, MAX(CAST(total_deaths as int)) AS Total_deaths
FROM Coviddeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_deaths DESC

-- Look at Total Population vs Vaccinations
-- Rolling count 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(Convert(bigint, v.new_vaccinations)) OVER 
(Partition by d.location order by d.location, d.date) AS RollingPeopleVaccinated 
FROM Coviddeaths d
JOIN CovidVaccination v
on d.location = v.location
and d.date = v.date
WHERE d.continent is not null
order by 2,3

-- USE CTE
-- make sure number of columns are the same using the with syntax and select

WIth PopVsVac (Continent, Location, Date, Population,New_vaccinations, RollingPeopleVaccinated)
AS
(SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(Convert(bigint, v.new_vaccinations)) OVER 
(Partition by d.location order by d.location, d.date) AS RollingPeopleVaccinated 
FROM Coviddeaths d
JOIN CovidVaccination v
on d.location = v.location
and d.date = v.date
WHERE d.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population) * 100 AS Vaccinated_perc
FROM PopVsVac

