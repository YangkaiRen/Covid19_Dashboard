use new_schema;
desc covid_death;
desc covid_vaccinations;

-- 1. Data Processing
-- 1.1 Checking Dublication (no dublication exist)
select iso_code, continent, location, date, total_cases, count(*) amount from covid_death
group by iso_code, continent, location, date,total_cases having amount > 1;

select iso_code, continent, location, date,total_tests, count(*) amount from covid_vaccinations
group by iso_code, continent, location,total_tests, date having amount > 1;

-- 1.2 Transforming Data Types
alter table covid_death modify date date;
alter table covid_vaccinations modify date date;



-- 1.3 Seperated death and vaccinations data by locatin and continent;

create table df_death_con (select * from covid_death where iso_code like "OWID%") ;
create table df_death_loc (select * from covid_death where iso_code not like "OWID%");
create table df_vac_con (select * from covid_vaccinations where iso_code like "OWID%");
create table df_vac_loc (select * from covid_vaccinations  where iso_code not like "OWID%");

-- 1.4 Checking content issue
select count(ifnull(continent,1)), continent from df_death_loc group by continent;
select count(ifnull(continent,1)), location from df_death_loc group by location;
select count(ifnull(continent,1)), continent from df_vac_loc group by continent;
select count(ifnull(continent,1)), location from df_vac_loc group by location;
-- Both death and vac 'continent' tables have issue. continent column have null vaule, and the content in location column should belong to continent column.
select count(ifnull(continent,1)), continent from df_death_con group by continent;
select count(ifnull(continent,1)), location from df_death_con group by location;
select count(ifnull(continent,1)), continent from df_vac_con group by continent;
select count(ifnull(continent,1)), location from df_vac_con group by location;

select * from df_death_con where continent = 'Europe';
select * from df_death_con where continent ='Asia';

-- Creating new table of "Kosovo" and "Northem Cyprus"

create table kosovo_Cyprus_death (select * from df_death_con where continent ='Europe' or continent ='Asia');
create table  kosovo_Cyprus_vac (select * from df_vac_con where continent ='Europe' or continent ='Asia');

-- Delete kosovo_Cyprus from origin table
delete from df_death_con where continent ='Europe' or continent ='Asia';
delete from df_vac_con where continent ='Europe' or continent ='Asia';

-- Fix kosovo_Cyprus_death and kosovo_Cyprus_vac iso_code 

-- Delete continent columns first, Then Changed the column name from location to continent from df_death_con and df_vac_con name
alter table df_death_con drop continent;
alter table df_vac_con drop continent;

alter table df_death_con change location continent text;
alter table df_vac_con change location continent text;

-- 2. Analysis
-- 2.1 Select Data that we are going to use
select continent, location, date, population, total_cases, new_cases, total_deaths, new_deaths from df_death_loc;
select continen, date, population, total_cases, new_cases total_deaths, new_deaths from df_death_con;

select continent, location, date, new_tests, total_tests from df_vac_loc;
select continent, date, new_tests, total_tests from df_vac_loc;

-- Looking at Total Casese vs Total Death
select location, date, total_cases, total_deaths, (total_deaths/total_cases) from df_death_loc order by 1, 2;

select continent, date, total_cases, total_deaths, (total_deaths/total_cases) from df_death_con order by 1, 2;

-- Looining at Total Cases vs Popuation
select location, date, total_cases, population, (total_deaths/population) from df_death_loc order by 1, 2;

select continent, date, total_cases, population, (total_deaths/population) from df_death_con order by 1, 2;

-- Looking at Countries with Highest Infection Rate compared to Population
select location, max(population), max(total_cases) HighestInfectionCount, max((total_cases/population)*100) DeathPerentage
from df_death_loc group by location
order by HighestInfectionCount desc;

-- Showing Countries with Highest Death Count per Population
select location, max(total_deaths) TotalDeathCount, max(total_deaths_per_million) from df_death_loc
group by location 
order by  TotalDeathCount desc;

-- Looking at Highest Death count with Continent
select continent, max(total_deaths) TotalDeathCount, max(total_deaths_per_million)
from df_death_con
where continent = 'Africa' or continent = 'North America' or continent = 'South America' or 
continent = 'Europe' or continent = 'Asia' or continent = 'Oceania'
group by continent
order by TotalDeathCount desc;

-- looking at Total Population vs Vaccinations
select dea.location, max(dea.date), max(dea.population), max(vac.total_vaccinations)
from df_death_loc dea
join df_vac_loc vac
on dea.location = vac.location
and dea.date = vac.date
group by dea.location
order by max(dea.population) desc;