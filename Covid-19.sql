select*
from CovidDeaths$
order by 3,4
--select* 
--from CovidVaccinations$
--Order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
order by 1,2

-- Looking at total cases vs total deaths
--Shows Likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
Where location like '%egypt%'
order by 1,2


-- Looking at total cases Vs population 
-- shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths$
Where location like '%egypt%'
order by 1,2


-- Looking at countries with highest infection rate compared to population

select location, population, Max (total_cases) as HighestInfectioncount,max ((total_deaths/total_cases))*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths$
--Where location like '%egypt%'
group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with highest death count per population

select location, max(cast (total_deaths as int)) As totaldeathcount
from [Portfolio Project]..CovidDeaths$
--Where location like '%egypt%'
where continent is not null
group by location, population
order by totaldeathcount desc

-- Lets break things down by continent
-- Showing continents with the highest death count per population

select continent, max(cast (total_deaths as int)) As totaldeathcount
from [Portfolio Project]..CovidDeaths$
--Where location like '%egypt%'
where continent is not null
group by continent
order by totaldeathcount desc


-- Global Numbers
select  sum(new_cases)as total_cases, sum(cast (new_deaths as int))as total_deaths, sum(cast (new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths$
--Where location like '%egypt%'
where continent is not null
--group by date
order by 1,2


--Looking on total Population Vs Vaccination

Select dea.continent,Dea.location, Dea.date,Dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
,(RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths$ Dea
join [Portfolio Project]..CovidVaccinations$ Vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use Cte
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Temp Table
Drop table if exists #PercentPopulationVaccinated

Create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for late visualizations
USE [Portfolio Project]
GO
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select*
from PercentPopulationVaccinated
