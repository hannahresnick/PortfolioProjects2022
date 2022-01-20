Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3, 4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3, 4

--Select data we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1, 2

--Look at total cases vs total deaths
--Shows likelihood of dying if covid contracted in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
Where location = 'United States'
Order by 1, 2

--Look at total cases vs population
--Shows what % of population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as case_percentage
From PortfolioProject..CovidDeaths
Where location = 'United States'
Order by 1, 2

--Look at countries w highest infection rates compared to population

Select location, population, MAX(total_cases) as max_case_count, MAX((total_cases/population))*100 as case_percentage
From PortfolioProject..CovidDeaths
Group by Location, population
Order by 4 DESC

--Show countries w highest death count per population
Select location, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
Order by 2 DESC


--Breaking things down by continent - continents w highest death count

Select continent, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by 2 DESC

--Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1, 2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1, 2


--Looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(cast(vax.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vax_count
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vax
	On dea.location = vax.location
	and dea.date = vax.date
Where dea.continent is not null
Order by 2, 3

--Percent population vaccinated

--USE CTE

With pop_vax (continent, location, date, population, new_vaccinations, rolling_vax_count)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(cast(vax.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vax_count
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vax
	On dea.location = vax.location
	and dea.date = vax.date
Where dea.continent is not null
--Order by 2, 3
)
Select *, (rolling_vax_count/population)*100 as rolling_percent_vax
From pop_vax

--USE TEMP TABLE

DROP table if exists #PercentPopVax
Create table #PercentPopVax
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
RollingVaxCount numeric)

Insert into #PercentPopVax
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(cast(vax.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vax_count
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vax
	On dea.location = vax.location
	and dea.date = vax.date
Where dea.continent is not null
Order by 2, 3

Select *, (RollingVaxCount/Population)*100 as RollingPercentVax
From #PercentPopVax

--Creating view to store data for later visualizations

Create view PercentPopVax as
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(cast(vax.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vax_count
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vax
	On dea.location = vax.location
	and dea.date = vax.date
Where dea.continent is not null
--Order by 2, 3