select *
from PortfolioProject..[COVID Deaths]
order by 3,4

--select *
--from PortfolioProject..[COVID Vaccinations]
--order by 3,4

select location,date,total_cases, new_cases,total_deaths,population
from PortfolioProject..[COVID Deaths]
order by 1,2

--Looking at total cases vs total deaths	 But during import death data is null still we will do it
--Shows likelihood of dying one's contract with covid.
select location,date, new_cases,total_deaths, (new_cases/total_deaths)*100 as PercentageofDeath
from PortfolioProject..[COVID Deaths]
where location like 'Afg%'
order by 1,2

--Looking at total cases vs total Population
select location,date, total_cases, population, (total_cases/population)*100 as PercentageofCases
from PortfolioProject..[COVID Deaths]
order by 1,2

-- Looking for highest infection rate
select location,population,max(total_cases) as HighestInfection, Max((total_cases/population))*100 as PercentageofInfection
from PortfolioProject..[COVID Deaths]
group by location, population
order by PercentageofInfection Desc;

-- Country with the highest Death count per pop(We are casting it as the data type is in nvarchar instead of int. So, in order to get the 
--proper desc order we need to cast it. It's not shown below as the column data is null but it will work)

select location,population,max(cast(total_deaths as bigint)) as HighestDeath
from PortfolioProject..[COVID Deaths]
where continent is not null
group by location, population
order by HighestDeath Desc;

-- WRT TO CONTINENT

select continent,max(cast(total_deaths as bigint)) as HighestDeath
from PortfolioProject..[COVID Deaths]
where continent is not null
group by continent
order by HighestDeath Desc;

--GLOBAL NUM(heiarchie CONT-->COUNTRY)

select date, SUM(new_cases) as NEWCASESCOUNT, SUM(new_deaths) as NEWDEATHCOUNT , SUM(new_deaths) /SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..[COVID Deaths]
--where continent is not null
where new_deaths <> 0
group by date
order by 1,2;

select  SUM(new_cases) as NEWCASESCOUNT, SUM(new_deaths) as NEWDEATHCOUNT , SUM(new_deaths) /SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..[COVID Deaths]
----where continent is not null
--where new_deaths <> 0
--group by date
order by 1,2;


--LOOKING AT TOTAL POP VS VACC
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVacinated
--(RollingPeopleVacination/dea.population)*100
--SUM(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location)
from PortfolioProject..[COVID Deaths] as dea
join PortfolioProject..[COVID Vaccinations] as vac
on dea.location=vac.location
and dea.date=vac.date


--We can't call RollingPeopleVacination as newly created colum. So, we need to use CTE or temp table for it

--USING CTE
 
With PopvsVac (Continent, location, date, population,new_vaccinations, RollingPeopleVacinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVacinated
--(RollingPeopleVacination/dea.population)*100
--SUM(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location)
from PortfolioProject..[COVID Deaths] as dea
join PortfolioProject..[COVID Vaccinations] as vac
on dea.location=vac.location
and dea.date=vac.date
--order by 2,3(we can t use order by clause in CTE)
)
select *, (RollingPeopleVacinated/population)*100 as Rollbytotalpop
from PopvsVac


--USING TEMP TABLE
drop table if exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVacinated
--(RollingPeopleVacination/dea.population)*100
--SUM(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location)
from PortfolioProject..[COVID Deaths] as dea
join PortfolioProject..[COVID Vaccinations] as vac
on dea.location=vac.location
and dea.date=vac.date
--order by 2,3(we can t use order by clause in CTE)

select *, (RollingPeopleVaccinated/population)*100 as Rollbytotalpop
from #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALISATION 
drop view if exists PercentPopulationVaccinated
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVacinated
--(RollingPeopleVacination/dea.population)*100
--SUM(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location)
from PortfolioProject..[COVID Deaths] as dea
join PortfolioProject..[COVID Vaccinations] as vac
on dea.location=vac.location
and dea.date=vac.date


Select *
from PercentPopulationVaccinated