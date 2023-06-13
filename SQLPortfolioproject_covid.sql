--Select *
--from portfolioproject..CovidDeaths
--order by 3,4

--Select * 
--from portfolioproject..CovidVaccines
--order by 3,4

-- Select Data we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1, 2

-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contracted covid in the United States from 2020 - 2021

Select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1, 2

-- Looking at total cases vs population in the United States from 2020 - 2021
-- Shows what percentage of population got covid

Select location, date, total_cases, population, round((total_cases/population)*100,2) As DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1, 2

-- Looking at countries with highest infection rate compared to population

Select location, MAX(total_cases) as HighestInfectionCount, round(Max((total_cases/population))*100, 2) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc

-- Showing Countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
Order by TotalDeathCount desc

-- Breaking things down by continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null
Group by location
Order by TotalDeathCount desc

-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
Order by TotalDeathCount desc


-- Global numbers

Select date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) As Total_deaths, Sum(new_cases)/SUM(cast(new_deaths as int))*100 as Death_percentage
From PortfolioProject..CovidDeaths
Where continent is not null
group by date
Order by 1, 2

Select Sum(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, sum(new_cases)/Sum(cast(new_deaths as int)) *100 as Total_death_percentages
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1, 2

-- Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(convert(int, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccines vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(convert(int, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccines vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(convert(int, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccines vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(convert(int, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccines vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null

Select * from PercentPopulationVaccinated