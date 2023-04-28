
Select  *
From Portfolio..CovidDeaths
Where continent is not null
order by 3,4

Select  *
From Portfolio..CovidVaccinations
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeaths
order by 1,2

Select Location, date, total_cases, total_deaths, 
CONVERT(DECIMAL(18, 4), (CONVERT(DECIMAL(18, 4), total_deaths) / CONVERT(DECIMAL(18, 2), total_cases)))*100 as [DeathsPercentage]
From Portfolio..CovidDeaths
order by 1,2

Select Location, date, new_cases, total_cases, total_deaths, 
CONVERT(DECIMAL(18, 4), (CONVERT(DECIMAL(18, 4), total_deaths) / CONVERT(DECIMAL(18, 2), total_cases)))*100 as [DeathsPercentage]
From Portfolio..CovidDeaths
Where location like '%state%'
order by 1,2

Select Location, date, new_cases, total_cases, population, 
CONVERT(DECIMAL(18, 7), (CONVERT(DECIMAL(18, 7), total_cases) / CONVERT(DECIMAL(18, 2), population)))*100 as [Cases]
From Portfolio..CovidDeaths
Where location like '%state%'
order by 1,2

Select Location,population, MAX(total_cases) as HighestInfectionCount,  
MAX(CONVERT(DECIMAL(18, 7), (CONVERT(DECIMAL(18, 7), total_cases) / CONVERT(DECIMAL(18, 7), population))))*100 as [MAXCases]
From Portfolio..CovidDeaths
Where location like '%state%'
Group by location, population
order by MAXCases DESC

Select Location, MAX(cast(total_deaths as bigint)) as HighestDeathcount
From Portfolio..CovidDeaths
Where location like '%state%'
--Where continent is not null
Group by location 
order by HighestDeathcount DESC

Select Location, MAX(cast(total_deaths as bigint)) as HighestDeathcount
From Portfolio..CovidDeaths
Where location like '%state%'
--Where continent is null 
Group by location 
order by HighestDeathcount DESC

Select continent, MAX(cast(total_deaths as bigint)) as HighestDeathcount
From Portfolio..CovidDeaths
Where continent is not null
Group by continent
order by HighestDeathcount DESC

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(CAST(new_deaths as bigint))/nullif(SUM(New_cases),0)*100 as DeathPercentage  
From Portfolio..CovidDeaths
Where continent is not null 
Group By date  
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(CAST(new_deaths as bigint))/nullif(SUM(New_cases),0)*100 as DeathPercentage  
From Portfolio..CovidDeaths
Where continent is not null 
--Group By date  
order by 1,2

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingTotalVacs) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by vac.location, vac.date) as RollingTotalVacs
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations2 vac
	On dea.location = vac.location
	and dea.date = vac.date
	and dea.continent = vac.continent
where dea.continent is not null 
--Order by 2,3
)
Select *, (RollingTotalVacs/Population) *100
From PopvsVac
Order by 2,3

DROP Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric, 
RollingTotalVacs numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingTotalVacs
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations2 vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--Order by 2,3

Select *, (RollingTotalVacs/Population) *100
From #PercentPopulationVaccinated


Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingTotalVacs
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations2 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--Order by 2,3


Select location, SUM(cast(new_deaths as bigint)) as TotalDeathCount
From Portfolio..CovidDeaths
where continent is null
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'Lower middle income', 'Low income', 'High income')
Group by location
order by TotalDeathCount desc

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
from Portfolio..CovidDeaths

Group by location, Population
order by PercentPopulationInfected desc


Select Location, Population, date, MAX(Total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio..CovidDeaths
Group by location, population, date
order by PercentPopulationInfected desc

