select * from CovidDeaths 
where continent is  null 
order by 3,4

select * from CovidVaccinations order by 3,4


select  [location],[date],total_cases,new_cases,total_deaths,[population] 
from CovidDeaths  order by 1,2

--Finding out total case Vs total deaths

select  [location],[date],total_cases,total_deaths, round((total_deaths/total_cases)*100,2) as deathpercentage
from CovidDeaths 
where [location] like '%states%' and continent is not null
order by 1,2


---Finding out Total case Vs Population

select  [location],[date],total_cases,[population], round((total_cases/[population])*100,2) as totalcasepercentage
from CovidDeaths
where continent is not null
order by totalcasepercentage desc


---Findng out Highly infected country
select  [location],Max(cast(total_cases as int)) as max_total_cases,cast([population] as int), max(round(((total_cases/[population])*100),2)) as highlyinfectedpercentage
from CovidDeaths 
where continent is not null
group by [location],[population]
order by highlyinfectedpercentage  desc

--finding out the highest death count in each country per population

select  [location],Max(cast(total_deaths as int)) as highest_total_deaths
from CovidDeaths 
where continent is not null
group by [location],[population]
order by highest_total_deaths desc


--- looking highest death count by contient

select  location as contient,Max(cast(total_deaths as int)) as highest_total_deaths
from CovidDeaths 
where continent is  null
group by location
order by highest_total_deaths desc


----finding out golbal death rate  per day


select [date],sum(total_cases)as total_cases,sum(cast(total_deaths as int)) as total_deaths, round((sum(cast(total_deaths as int))/sum(total_cases)*100),2) as globaldeathpercentage
from CovidDeaths
where continent is not null
group by  [date]
order by globaldeathpercentage desc


---- findout out the death rate global

select sum(total_cases)as total_cases,sum(cast(total_deaths as int)) as total_deaths, round((sum(cast(total_deaths as int))/sum(total_cases)*100),2) as globaldeathpercentage
from CovidDeaths
where continent is not null
order by globaldeathpercentage desc

--looking at total poulation 

select de.continent,de.location,de.date,de.population,va.new_vaccinations,
sum(cast(va.new_vaccinations as int)) over (partition by de.location order by de.date) as runningtotal 
from CovidDeaths de
join CovidVaccinations va on
de.date=va.date and 
de.location=va.location
where de.continent is not null     
order by 2,3

---Finding out how much percentage of people vaccinated in each country

with pepVsvac(continent,location,date,population,new_vaccinations,vaccrunningtotal)
as
(
select de.continent,de.location,de.date,de.population,va.new_vaccinations,
sum(cast(va.new_vaccinations as int)) over (partition by de.location order by de.date) as vaccrunningtotal 
from CovidDeaths de
join CovidVaccinations va on
de.date=va.date and 
de.location=va.location
where de.continent is not null  
)

select location,population,max(vaccrunningtotal) as totalpeoplevacci,
round((max(vaccrunningtotal)/population),2) as vaccinationperecntage  from  pepVsvac
group by location,population
order by vaccinationperecntage desc

--Temp table
DROP table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(200),
location nvarchar(200),
date datetime,
Population numeric,
new_vaccinations numeric,
vaccrunningtotal numeric,
 
)
insert into #PercentPopulationVaccinated
select de.continent,de.location,de.date,de.population,va.new_vaccinations,
sum(cast(va.new_vaccinations as int)) over (partition by de.location order by de.date) as vaccrunningtotal 
from CovidDeaths de
join CovidVaccinations va on
de.date=va.date and 
de.location=va.location
where de.continent is not null  

select * from #PercentPopulationVaccinated


---View

create view worlddeathpercentage AS
select [date],sum(total_cases)as total_cases,sum(cast(total_deaths as int)) as total_deaths, 
round((sum(cast(total_deaths as int))/sum(total_cases)*100),2) as globaldeathpercentage
from CovidDeaths
where continent is not null
group by  [date]
