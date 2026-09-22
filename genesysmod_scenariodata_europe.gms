AvailabilityFactor(r,'X_DAC_HT',y) = 0;
AvailabilityFactor(r,'X_DAC_LT',y) = 0;


* Limit capacity expansion in 2025 to only actually (historically) installed capacities
NewCapacity.up('2025',t,r)$(TagTechnologyToSubsets(t,'PowerSupply') and not AnnualMinNewCapacity(r,t,'2025') and not TotalAnnualMinCapacity(r,t,'2025') and not sum((tg,rg)$(TagTechnologyToSubsets(t,tg) and TagRegionToSubsets(r,rg)), GroupTotalAnnualMinCapacity(tg,rg,'2025'))) = 0;

* need to check and move to data
ProductionByTechnologyAnnual.up(y,'CHP_WasteToEnergy','Heat_District',r) = RegionalBaseYearProduction(r,'CHP_WasteToEnergy','Heat_District','2018');
OutputActivityRatio(r,'CHP_WasteToEnergy',f,'1',y) = 0;

* need to check and move to data
ProductionByTechnologyAnnual.up(y,'HD_Heatpump_ExcessHeat','Heat_District',r)$(YearVal(y)>2018) = SpecifiedAnnualDemand(r,'Heat_District',y)*0.08;

* need to check and move to data
ProductionByTechnologyAnnual.up(y,'HLI_Geothermal','Heat_Low_Industrial',r) = SpecifiedAnnualDemand(r,'Heat_Low_Industrial',y)*0.25;


ProductionByTechnologyAnnual.lo('2025','HB_Oil_Boiler','Heat_Buildings',r) = RegionalBaseYearProduction(r,'HB_Oil_Boiler','Heat_Buildings','2018')*0.3;
CurtailmentCostFactor = 45;
