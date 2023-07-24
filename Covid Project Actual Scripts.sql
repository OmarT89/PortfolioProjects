--Select *
--From PortfolioProject..CovidDeaths
--order by 3,4

----Select *
----From PortfolioProject..CovidVaccinations
----order by 3,4

-- Select Data that we are going to be using! 
-- Shows likelihood of diying if contract covid in your country
Select 
	Location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 as DeathPercentage
From 
	PortfolioProject..CovidDeaths
Where location
	like '%Egypt%'
order by 
	1,
	2

-- Looking at total cases vs Population:
Select 
	Location, 
	date, 
	total_cases, 
	population, 
	(total_cases/population)*100 as InfectionPercentage
From 
	PortfolioProject..CovidDeaths
--Where location
--	like '%Egypt%'
order by 
	1,
	2

-- Looking for highest infection rates vs population:
Select 
	Location, 
	Population, 
	MAX(total_cases) as HighestInfectionCount,
	MAX((total_cases/population))*100 as InfectionPercentage
From 
	PortfolioProject..CovidDeaths
--Where location
--	like '%Egypt%'
Group by Location, Population
order by InfectionPercentage desc

-- Countries with Highest Death count per population!
Select 
	Location, 
	MAX(CAST(total_deaths as int)) as TotalDeathCount
From 
	PortfolioProject..CovidDeaths
Where 
	continent is not null
--Where location
--	like '%Egypt%'
Group by Location
order by TotalDeathCount desc

-- Breakup things with continent!
Select 
	location, 
	MAX(CAST(total_deaths as int)) as TotalDeathCount
From 
	PortfolioProject..CovidDeaths
Where 
	continent is null
--Where location
--	like '%Egypt%'
Group by location
order by TotalDeathCount desc


-- Showing the continents with the highst death count:
Select 
	continent, 
	MAX(CAST(total_deaths as int)) as TotalDeathCount
From 
	PortfolioProject..CovidDeaths
Where 
	continent is not null
--Where location
--	like '%Egypt%'
Group by continent
order by TotalDeathCount desc


--Global Numbers:
Select 
	SUM(new_cases) as TotalCases,
	SUM(CAST(new_deaths as int)) as TotalDeaths,
	SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group By date
Order by 1,2


--Tot Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPepoleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3



-- USE CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPepoleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac



--TempTable:
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPepoleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
-- Where dea.continent is not null
-- order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS!
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPepoleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3