-- select data that we are going to be using

select location, date, total_cases, new_cases, total_cases, population 
from covid_deaths;


-- looking at total cases vs total deaths
-- shows the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid_deaths
where location like 'dji%'

-- looking at total cases vs population
-- shows what percentage of the population got covid

select location, date, total_cases, population, (total_cases/population)*100 as CasesPopulation
from covid_deaths
where location like 'somalia'


-- Countries with highest infection rate compared to population


select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from covid_deaths
group by location, population
order by PercentPopulationInfected desc;

-- showing countries with highest death count per population

select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
from covid_deaths
where continent is not null
group by location, population
order by TotalDeathCount desc;


-- Break down by continent

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from covid_deaths
where continent is null
group by location
order by TotalDeathCount desc;

-- Global Numbers

select date, sum(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
from covid_deaths
where continent is not null
group by date
order by 1, 2

-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from covid_deaths dea
join covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1, 2, 3

-- rolling count of vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RolllingPeopleVaccinated
from covid_deaths dea
join covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- Total people vaccinated per population using CTE
with PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RolllingPeopleVaccinated
from covid_deaths dea
join covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2, 3
)
select *, (RollingPeopleVaccinated/population)*100 
from PopvsVac

-- creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RolllingPeopleVaccinated
from covid_deaths dea
join covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3



