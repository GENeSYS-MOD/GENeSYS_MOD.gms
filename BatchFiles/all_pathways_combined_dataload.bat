cd ..
echo "Load Green Data"
gams genesysmod.gms -gdxCompress=1 --emissionPathway=Green --emissionspenalty=1000 --solver=gurobi --switch_test_data_load=1 -gdx=Green_dataload --elmod_nthhour=788 --elmod_hour_steps=4 --threads=2 -o=BatchFiles\Logs\Green_dataload.log --Info=Green_dataload

echo "Load REPowerEU Data"
gams genesysmod.gms -gdxCompress=1 --emissionPathway=REPowerEU --emissionspenalty=435 --solver=gurobi --switch_test_data_load=1 -gdx=REPowerEU_dataload --elmod_nthhour=788 --elmod_hour_steps=4 --threads=2 -o=BatchFiles\Logs\REPowerEU_dataload.log --Info=REPowerEU_dataload

echo "Load Trinity Data"
gams genesysmod.gms -gdxCompress=1 --emissionPathway=Trinity --emissionspenalty=1275 --solver=gurobi --switch_test_data_load=1 -gdx=Trinity_dataload --elmod_nthhour=788 --elmod_hour_steps=4 --threads=2 -o=BatchFiles\Logs\Trinity_dataload.log --Info=Trinity_dataload

echo "Load NECPEssentials Data"
gams genesysmod.gms -gdxCompress=1 --emissionPathway=NECPEssentials --emissionspenalty=900 --solver=gurobi --switch_test_data_load=1 -gdx=NECPE_dataload --elmod_nthhour=788 --elmod_hour_steps=4 --threads=2 -o=BatchFiles\Logs\NECPE_dataload.log --Info=NECPE_dataload
pause