AvailabilityFactor(r,'X_DAC_HT',y) = 0;
AvailabilityFactor(r,'X_DAC_LT',y) = 0;


* Limit capacity expansion in 2025 to only actually (historically) installed capacities
NewCapacity.up('2025',t,r)$(TagTechnologyToSubsets(t,'PowerSupply') and not AnnualMinNewCapacity(r,t,'2025') and not TotalAnnualMinCapacity(r,t,'2025') and not sum((tg,rg)$(TagTechnologyToSubsets(t,tg) and TagRegionToSubsets(r,rg)), GroupTotalAnnualMinCapacity(tg,rg,'2025'))) = 0;


ProductionByTechnologyAnnual.lo('2025','HB_Oil_Boiler','Heat_Buildings',r) = RegionalBaseYearProduction(r,'HB_Oil_Boiler','Heat_Buildings','2018')*0.3;

CurtailmentCostFactor = 45;




$ifthen exist genesysmod_scenariodata_man0euvre.gms
$include genesysmod_scenariodata_man0euvre.gms
$else
display "HINT: No scenario data for man0euvre found!";
$endif