echo Step 1: merge gdx files
gdxmerge *.gdx id=output_energy_balance,output_emissions,output_capacity,output_trade,output_energy_balance_annual,output_other,output_energydemandstatistics,output_technology_costs_detailed,output_fuelcosts,StorageLevelTSStart

echo Step 2: create energy balance csv
echo Model Version,Region,Sector,Technology,Mode,Fuel,Timeslice,Type,Unit,PathwayScenario,Year,Value > output_production.csv
gdxdump merged.gdx symb=output_energy_balance format=csv noHeader >> output_production.csv

echo Step 3: create emissions csv
echo Model Version,Region,Sector,Emission,Technology,Type,PathwayScenario,Year,Value > output_emissions.csv
gdxdump merged.gdx symb=output_emissions format=csv noHeader >> output_emissions.csv

echo Step 4: create capacity csv
echo Model Version,Region,Sector,Technology,Type,PathwayScenario,Year,Value > output_capacity.csv
gdxdump merged.gdx symb=output_capacity format=csv noHeader >> output_capacity.csv

echo Step 4: create trade csv
echo Model Version,Region,Region,Fuel,Type,Year,Value > output_trade.csv
gdxdump merged.gdx symb=output_trade format=csv noHeader >> output_trade.csv

echo Step 5: create simplified annual energy balance csv
echo Model Version,Region,Sector,Technology,Fuel,Type,Unit,PathwayScenario,Year,Value > output_annual_energy_balance.csv
gdxdump merged.gdx symb=output_energy_balance_annual format=csv noHeader >> output_annual_energy_balance.csv

echo Step 6: create additional output statistics csv
echo Model Version,Type,Region,Sector/Technology,Fuel,Year,Value > output_additional_statistics.csv
gdxdump merged.gdx symb=output_other format=csv noHeader >> output_additional_statistics.csv

echo Step 6: create additional energydemand statistics csv
echo Model Version,Type,Sector,Region,Fuel,Year,Value > output_energy_demand_statistics.csv
gdxdump merged.gdx symb=output_energydemandstatistics format=csv noHeader >> output_energy_demand_statistics.csv

echo Step 7: create detailed technology cost data csv
echo Model Version,Region,Technology,Input Fuel,Type,Unit,Year,Value > output_technology_costs_detailed.csv
gdxdump merged.gdx symb=output_technology_costs_detailed format=csv noHeader >> output_technology_costs_detailed.csv

echo Step 8: create endogenous fuel cost data csv
echo Model Version,Unit,Region,Fuel,Year,Value > output_endogenous_fuelcosts.csv
gdxdump merged.gdx symb=output_fuelcosts format=csv noHeader >> output_endogenous_fuelcosts.csv

echo Step 9: create storage level csv
echo Model Version,Storage,Year,Timeslice,Region,Value > output_storagelevel.csv
gdxdump merged.gdx symb=StorageLevelTSStart format=csv noHeader >> output_storagelevel.csv

pause