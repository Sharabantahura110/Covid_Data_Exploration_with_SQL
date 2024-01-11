Select *
From [SQL.Project]..CovidDeaths$
order by 3,4


--Select *
--From [SQL.Project]..CovidVaccinations$
--order by 3,4


--data thats are going to use

Select location, date, total_cases, new_cases, total_deaths, population
From [SQL.Project]..CovidDeaths$
order by 1,2


--Total cases vs Total Deaths
--likelihood of dying if people contract covid in their country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [SQL.Project]..CovidDeaths$
Where location like '%states%'
order by 1,2


--Total cases vs Population
--Percentage of population got into Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From [SQL.Project]..CovidDeaths$
Where location like '%states%'
order by 1,2


--Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From [SQL.Project]..CovidDeaths$
--Where location like '%states%'
Group by location, population
order by PercentagePopulationInfected desc


--Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [SQL.Project]..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc


--Breaking down by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [SQL.Project]..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [SQL.Project]..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by date
order by 1,2


--Total cases vs Total deaths vs Death Percentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [SQL.Project]..CovidDeaths$
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2



Select *
From [SQL.Project]..CovidVaccinations$

--join two table

Select *
From [SQL.Project]..CovidDeaths$ dea
join [SQL.Project]..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date


--Total Population vs Vaccination


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [SQL.Project]..CovidDeaths$ dea
join [SQL.Project]..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

---------

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RollingPeopleVaccinated
From [SQL.Project]..CovidDeaths$ dea
join [SQL.Project]..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3



--USING CTE--

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RollingPeopleVaccinated
From [SQL.Project]..CovidDeaths$ dea
join [SQL.Project]..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

)

Select * ,(RollingPeopleVaccinated/Population)* 100
From PopvsVac



--TEMP TABLE--

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RollingPeopleVaccinated
From [SQL.Project]..CovidDeaths$ dea
join [SQL.Project]..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From  #PercentPopulationVaccinated


--Creating View to store data for later visualization--

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RollingPeopleVaccinated
From [SQL.Project]..CovidDeaths$ dea
join [SQL.Project]..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
