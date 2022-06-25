use PortfolioProject

--drop database QLBongDa
--drop table CovidDeaths
--drop table CovidVaccinations



--Select data we will use

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
Order by 1,2

--Looking a total_case and total_deaths
--Show likelihood of dying
select location, date,  total_cases, total_deaths , (total_deaths/total_cases)*100 as Death_rate
from CovidDeaths
where location like '%vietnam%'
order by 1,2

--Looking at total case and population 
--Show what percentage of population got Covid
select location, date, total_cases, population , (total_cases/population)*100 as Sick_rate
from CovidDeaths 
where location is not null

--Select the location have the best sick_rate a day
select distinct location, total_cases/population as Best_sick_rate from CovidDeaths
where (total_cases/population) = (select max(total_cases/population) from CovidDeaths)


--Looking at Countries with Highest Infection Rate compare to Population

Select location, Population, max(cast(total_cases as int)) as Max_case, max(cast(total_cases as int)/population) as Percentage
From CovidDeaths
where continent is not null
group by location, population
order by Percentage desc

--Showing Countries with Highest Death Count per Population

select location, population, max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
where continent is not null 
group by location, population
order by TotalDeathCount desc

--Let's breaking things down by continent


select location, max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

--Showing continents with the highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount 
From CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global number

select top 1 total_cases, total_deaths, (total_deaths/total_cases) as DeathPercentage
from CovidDeaths
where location = 'world'
order by total_cases desc

select location, new_vaccinations from CovidVaccinations

--Looking at Total Population vs Vaccination

create view PopvsVac as
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations 
	,sum(convert(bigint,vac.new_vaccinations)) 
	over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)* 100 as Percentage
from CovidDeaths as dea
	join CovidVaccinations as vac
		on dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null

--drop view Popvs_Vac

select *, (RollingPeopleVaccinated/population)*100 as Percentage from PopvsVac

--Table Temp

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations 
	,sum(convert(bigint,vac.new_vaccinations)) 
	over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)* 100 as Percentage
from CovidDeaths as dea
	join CovidVaccinations as vac
		on dea.location = vac.location
		and dea.date = vac.date
--where dea.continent is not null

--Creating view for visualization

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations 
	,sum(convert(bigint,vac.new_vaccinations)) 
	over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)* 100 as Percentage
from CovidDeaths as dea
	join CovidVaccinations as vac
		on dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null
