select * 
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4;

--select * 
--from PortfolioProject..CovidVaccinations$
--order by 3,4;

--Select the data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2;

--Looking at Total cases vs Total deaths
--Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathParcentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2;

--Looking at Total deaths vs Population
--Shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as 
ParcentPopulationInfect
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2;

--Looking at coutries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as 
ParcentPopulationInfect
from PortfolioProject..CovidDeaths$
where continent is not null
group by location, population
order by ParcentPopulationInfect desc;

--Showing Countries with highest deaths per population

select location, max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by TotalDeathsCount desc

--Let's break things down by continent
--showing continents with highest deaths per population

select continent, max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathsCount desc

--Global Numbers

select sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathParcentage
from PortfolioProject..CovidDeaths$
where continent is not null
--group by date
order by 1,2;

--looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from  PortfolioProject..CovidDeaths$ dea
join  PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 --uning CTE

 with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from  PortfolioProject..CovidDeaths$ dea
join  PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 )
 select *, (RollingPeopleVaccinated/population)*100
 from popvsvac

 --Temp Table
 drop table if exists #ParcentagePopulationVaccinated
 create table #ParcentagePopulationVaccinated
 ( 
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric)

 insert into #ParcentagePopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from  PortfolioProject..CovidDeaths$ dea
join  PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 --where dea.continent is not null
 --order by 2,3
select *, (RollingPeopleVaccinated/population)*100
 from #ParcentagePopulationVaccinated

--creating view to store data for later visualization

Create View ParcentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from  PortfolioProject..CovidDeaths$ dea
join  PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

 select *
 from ParcentagePopulationVaccinated


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc