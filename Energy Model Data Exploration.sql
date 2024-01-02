/*
 Data Exploration using SQL Queries

Skills used: CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select distinct top 10 * from Energy_Model;

-----How countries use mix of fuels to produce electricity.

Select distinct Country, Year,CoalElectricity,HydroElectricity,GasElectricity,	
NuclearElectricity,Oilelectricity,RenewableElectricity from Energy_Model
Order by Country, Year


----Analyze trends in energy consumption over the years for different countries.

SELECT Country, Year,ElecPowerConsumption FROM Energy_Model
Order by Country, Year

----Calculating the average electricity consumption and the percentage of clean fuel
--access for each country by using aggregate function and Datatype conversion.

SELECT Country,Year, CountryCode, AVG(CAST(ElecPowerConsumption AS float)) AS AvgPowerConsumption
FROM Energy_Model
GROUP BY Country, CountryCode, Year
ORDER BY Country, Year;

With AvgPowerCTE (Country,Year,CleanFuelAccess,AvgPowerConsumption)
AS (
SELECT Country,Year,CleanFuelAccess, AVG(CAST(ElecPowerConsumption AS float)) AS AvgPowerConsumption
FROM Energy_Model
GROUP BY Country, CountryCode, Year,CleanFuelAccess
)
Select *, (AvgPowerConsumption*CleanFuelAccess)/100 AS CleanFuelPercent from AvgPowerCTE
ORDER BY Country, Year



---Identify the top and bottom countries in terms of energy consumption and clean energy access.

Select Top 10 Country,ElecPowerConsumption, EnergyUse, CleanFuelAccess from Energy_Model
where ElecPowerConsumption is NOT NUll
order by ElecPowerConsumption ASC, CleanFuelAccess ASC

Select Top 10 Country,ElecPowerConsumption, EnergyUse, CleanFuelAccess from Energy_Model
where ElecPowerConsumption is NOT NUll
order by ElecPowerConsumption DESC, CleanFuelAccess DESC

--CO2 Emissions and Renewable Energy:

---Using CTE  to calculate the CO2 emissions per capita for different countries. 

With CO2EmissionPerCapitaCTE (Country,Year,TotalCO2Emissions,TotalPopulation)
AS(
Select Country ,
Year,
SUM(CO2Emissions) OVER(PARTITION BY year, country order by year) AS TotalCO2Emissions,
SUM(TotalPopulation)  OVER(PARTITION BY year, country order by year) AS TotalPopulation
from Energy_Model
where Country IS NOT NULL AND Year IS NOT NULL
group by Country, Year, CO2Emissions, TotalPopulation
)
select *, cast(cast((TotalCO2Emissions/TotalPopulation) as float) as numeric(10,9))
AS CO2EmissionPerCapita from CO2EmissionPerCapitaCTE

--Creating Temp Table to calculate the percentage of fossil fuel consumption in total energy use for each country.

Drop table if exists #FossilFuelPerecent
Create table #FossilFuelPerecent( 
Country nvarchar(255),
TotalFossilFuelConsumption float,
TotalEnergyUse float,
)

insert into #FossilFuelPerecent
select country,
sum (cast (FossilFuelConsumption as float)) as TotalFossilFuelConsumption,
sum(cast (EnergyUse as float) ) as TotalEnergyUse
from Energy_Model
where FossilFuelConsumption is not null and EnergyUse is not null
group by country
order by country


select *, (TotalFossilFuelConsumption/TotalEnergyUse)*100
as FossilFuelConsumptionPercent 
from #FossilFuelPerecent


--Geospatial Analysis:
-- Creating View to for geospatial visualizations to calculate per capita energy cosumption

Create OR Alter View GeospatialVisualizations as
Select Year,EnergyUse, Country
RenewableEnergyConsumption,
SUM(cast (EnergyUse as float)) OVER(PARTITION BY year, country order by year) AS TotalEnergyUse,
SUM(TotalPopulation)  OVER(PARTITION BY year, country order by year) AS TotalPopulation
from Energy_Model
where Country IS NOT NULL AND Year IS NOT NULL AND EnergyUse IS NOT NULL
group by Country, Year, EnergyUse, TotalPopulation


Select Year,EnergyUse,RenewableEnergyConsumption,TotalEnergyUse,TotalPopulation,
  cast(cast((TotalEnergyUse/TotalPopulation) as float) as numeric (10,6))As PerCapitaEnergyCosumption
from GeospatialVisualizations
 
 ----Visualize the relationship between GDP per capita and energy intensity.

SELECT Country,CountryCode,Year,EnergyIntensity,GDPPerCapita FROM Energy_Model
where EnergyIntensity Is not null  and GDPPerCapita is not null 
order by Country,Year
