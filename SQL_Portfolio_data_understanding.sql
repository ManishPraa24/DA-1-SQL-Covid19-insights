
-- These SQL Queries are practiced in Microsoft SQL Server Management Studio
-- The data related to COVID-19 is being taken from an authentic course uploaded on freecodecamp.org youtube channel (Alex the analyst's Data Analysis Course)

-- Two excel files are imported in SSMS named 'CovidDeath.xsl' and 'CovidVaccinations.xsl'



-- -- START OF PROJECT -- -- 



-- 1. Selecting all attributes from CovidDeaths$ table

SELECT *
FROM CovidDeaths$
ORDER BY 3, 4



-- 2. Selecting all attributes from CovidVaccinations$ table

SELECT *
FROM CovidVaccinations$
ORDER BY 3,4




-- 3. Calculating percentage of total_deaths to total_cases per country

SELECT Location, AVG(total_deaths*100/total_cases) OVER (PARTITION BY location) AS DeathPercent
FROM CovidDeaths$
UNION                            -- UNION used to eliminate duplicates
SELECT Location, AVG(total_deaths*100/total_cases) OVER (PARTITION BY location) AS DeathPercent
FROM CovidDeaths$




-- 4. Calculating percentage of total_deaths to total_cases and percentage of total_cases to population in INDIA

SELECT location, date, population, total_cases, total_deaths, (total_deaths*100/total_cases) AS DeathPercent
		, (total_cases*100/population) AS InfectedPercent
FROM CovidDeaths$
WHERE 
	location LIKE '%india%'
ORDER BY 1, 2




-- 5. Calculating Highest Infection rate and Highest Death rate occurred for every country (As data is collected everyday, I have taken the maximum as it would be the last date when data was collected)

SELECT DISTINCT(location), population, MAX(total_cases*100/population) OVER (PARTITION BY location) AS MaxInfectionPercent
	    , MAX(total_deaths*100/total_cases) OVER (PARTITION BY location) AS MaxDeathPercent
FROM CovidDeaths$
ORDER BY 2 DESC, 3 DESC


-- 6. Calculating Highest Death count per population for every country

SELECT DISTINCT(location), population, 
	   MAX(cast(total_deaths as int)) OVER (PARTITION BY location) AS TotalDeaths
FROM CovidDeaths$
ORDER BY TotalDeaths DESC


-- 7. Calculating MAX Infection rate, MAX Death rate per cases, and MAX Death per population occurred for every Continent
--		(Here, as data for continent was given seperately, it is being calculated accordingly, as location will be continent itself)

	-- METHOD - 1
SELECT location, MAX(total_cases*100/population)
       , MAX(total_deaths*100/total_cases)  
       , MAX(total_deaths*100/population)  
FROM CovidDeaths$
WHERE continent is NULL
GROUP BY location



     -- METHOD - 2
SELECT DISTINCT(location), continent, population, MAX(total_cases*100/population) OVER (PARTITION BY location) AS MaxInfectionRate
       , MAX(total_deaths*100/total_cases)  OVER (PARTITION BY location) AS MaxDeathRatePerCases
       , MAX(total_deaths*100/population)  OVER (PARTITION BY location) AS MaxDeathRatePerPopulation
FROM CovidDeaths$
WHERE continent is NULL




-- 8. Calculating the same insights globally. (Here, global data was also given, but, I am calculating it by reiterating through every country)

SELECT 'World', SUM(DISTINCT(population)) AS TotalPopulation, SUM(new_cases) AS total_cases
, SUM(CAST(new_deaths AS INT)) AS total_deaths
, SUM(CAST(new_deaths AS INT))*100/SUM(new_cases) AS death_percent
FROM CovidDeaths$
WHERE continent IS NOT NULL       -- Eliminating Continent as it would add duplicate values




-- 9. Representing total COVID Vaccinations done everyday in every country

SELECT *
FROM CovidDeaths$ CD
	JOIN CovidVaccinations$ CV
		ON CD.location = CV.location
			AND CD.date = CV.date


-- 10. Calculating TOTAL VACCINATIONS TO POPULATION ratio of every country

		-- METHOD - 1
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
	   , SUM (CAST(CV.new_vaccinations AS INT)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS rolling_total_vaccinations
FROM CovidDeaths$ CD
	JOIN CovidVaccinations$ CV
		ON CD.location = CV.location
			AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
ORDER BY 2, 3



-- METHOD - 2 (USING CTE)
WITH PopvsVac (continent, location, date, population, new_vaccinations,rolling_total_vaccinations)
	AS(
		SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
		       , SUM (CAST(CV.new_vaccinations AS INT)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS rolling_total_vaccinations
		FROM CovidDeaths$ CD
			JOIN CovidVaccinations$ CV
				ON CD.location = CV.location
					AND CD.date = CV.date
		WHERE CD.continent IS NOT NULL
)
SELECT *, (rolling_total_vaccinations/population)*100
FROM PopvsVac







-- -- -- -- END OF PROJECT -- -- -- --