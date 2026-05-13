AvailabilityFactor(r,'X_DAC_HT',y) = 0;
AvailabilityFactor(r,'X_DAC_LT',y) = 0;



parameter warning_TotalAnnualMinCapacityTooHigh;
warning_TotalAnnualMinCapacityTooHigh(r,t,y)$(TotalAnnualMaxCapacity(r,t,y)<TotalAnnualMinCapacity(r,t,'2025')) = 1;

TotalAnnualMaxCapacity(r,t,y)$(TotalAnnualMaxCapacity(r,t,y)<TotalAnnualMinCapacity(r,t,'2025')) = TotalAnnualMinCapacity(r,t,'2025');

* Limit capacity expansion in 2025 to only actually (historically) installed capacities
NewCapacity.up('2025',t,r)$(TagTechnologyToSubsets(t,'PowerSupply') and not AnnualMinNewCapacity(r,t,'2025') and not TotalAnnualMinCapacity(r,t,'2025')) = 0;

ProductionByTechnologyAnnual.up(y,'CHP_WasteToEnergy','Heat_District',r) = RegionalBaseYearProduction(r,'CHP_WasteToEnergy','Heat_District','2018');
OutputActivityRatio(r,'CHP_WasteToEnergy',f,'1',y) = 0;

ProductionByTechnologyAnnual.up(y,'HD_Heatpump_ExcessHeat','Heat_District',r)$(YearVal(y)>2018) = SpecifiedAnnualDemand(r,'Heat_District',y)*0.08;

ProductionByTechnologyAnnual.up(y,'HLI_Geothermal','Heat_Low_Industrial',r) = SpecifiedAnnualDemand(r,'Heat_Low_Industrial',y)*0.25;


$ifthen %emissionPathway% == REPowerEU

ProductionByTechnologyAnnual.up(y,'HHI_Scrap_EAF','Heat_High_Industrial',r) = SpecifiedAnnualDemand(r,'Heat_High_Industrial',y)*0.65;
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_PSNG_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.002*(YearVal(y)-2025);
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_FRT_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.002*(YearVal(y)-2025);
TagCanFuelBeTraded('ETS') = 0;

$elseif %emissionPathway% == NECPEssentials


ProductionByTechnologyAnnual.up(y,'HHI_Scrap_EAF','Heat_High_Industrial',r) = SpecifiedAnnualDemand(r,'Heat_High_Industrial',y)*0.6;
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_PSNG_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.00175*(YearVal(y)-2025);
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_FRT_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.00175*(YearVal(y)-2025);
TagCanFuelBeTraded('ETS') = 0;

$elseif %emissionPathway% == Green

ProductionByTechnologyAnnual.up(y,'HHI_Scrap_EAF','Heat_High_Industrial',r) = SpecifiedAnnualDemand(r,'Heat_High_Industrial',y)*0.75;
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_PSNG_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.00225*(YearVal(y)-2025);
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_FRT_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.00225*(YearVal(y)-2025);
TagCanFuelBeTraded('ETS') = 0;

$elseif %emissionPathway% == Trinity
ProductionByTechnologyAnnual.up(y,'HHI_Scrap_EAF','Heat_High_Industrial',r) = SpecifiedAnnualDemand(r,'Heat_High_Industrial',y)*0.5;
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_PSNG_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.001*(YearVal(y)-2025);
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_FRT_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.001*(YearVal(y)-2025);
TagCanFuelBeTraded('ETS') = 0;

$endif



ProductionByTechnologyAnnual.lo('2025','HB_Oil_Boiler','Heat_Buildings',r) = RegionalBaseYearProduction(r,'HB_Oil_Boiler','Heat_Buildings','2018')*0.3;
CurtailmentCostFactor = 45;


equation DistrictHeatProductionAnnualLowerLimit(r_full, FUEL, y_full);
DistrictHeatProductionAnnualLowerLimit(r,f,y)$(sameas(f,'Heat_District') and DistrictHeatDemand(r,y)).. sum(t,ProductionByTechnologyAnnual(y,t,'Heat_District',r)) =g= DistrictHeatDemand(r,y)*InputActivityRatio(r,'X_Convert_HD',f,'1',y)*0.95;

equation DistrictHeatProductionAnnualUpperLimit(r_full, FUEL, y_full);
DistrictHeatProductionAnnualUpperLimit(r,f,y)$(sameas(f,'Heat_District') and DistrictHeatDemand(r,y)).. sum(t,ProductionByTechnologyAnnual(y,t,'Heat_District',r)) =l= DistrictHeatDemand(r,y)*InputActivityRatio(r,'X_Convert_HD',f,'1',y)*1.05;

equation DistrictHeatProductionSplit(r_full, Sector, y_full);
DistrictHeatProductionSplit(r,se,y)$(DistrictHeatSplit(r,se,y)).. sum((f,t)$(TagDemandFuelToSector(f,se) and TagTechnologyToSubsets(t,'Convert')),ProductionByTechnologyAnnual(y,t,f,r)) =g= DistrictHeatDemand(r,y)*DistrictHeatSplit(r,se,y);



$ifthen %emissionPathway% == NECPEssentials

set subset / Solar, Onshore, Offshore/;
alias(subset, sub);

parameter NECPCapacityPlans(r_full, subset, y_full);

NECPCapacityPlans('ES', 'Solar', '2025') = 44.197;
NECPCapacityPlans('ES', 'Solar', '2030') = 71.473;
NECPCapacityPlans('ES', 'Onshore', '2025') = 36.149;
NECPCapacityPlans('ES', 'Onshore', '2030') = 62.054;

NECPCapacityPlans('FR', 'Solar', '2025') = 26.9;
NECPCapacityPlans('FR', 'Solar', '2030') = 54.4;
NECPCapacityPlans('FR', 'Solar', '2035') = 68.4;
NECPCapacityPlans('FR', 'Solar', '2050') = 82.4;
NECPCapacityPlans('FR', 'Solar', '2055') = 86.4;
NECPCapacityPlans('FR', 'Solar', '2060') = 90.4;
NECPCapacityPlans('FR', 'Onshore', '2025') = 25.2;
NECPCapacityPlans('FR', 'Onshore', '2030') = 34.2;
NECPCapacityPlans('FR', 'Onshore', '2035') = 40.7;
NECPCapacityPlans('FR', 'Onshore', '2050') = 47.2;
NECPCapacityPlans('FR', 'Onshore', '2055') = 49.5;
NECPCapacityPlans('FR', 'Onshore', '2060') = 51.9;
NECPCapacityPlans('FR', 'Offshore', '2025') = 3.003;
NECPCapacityPlans('FR', 'Offshore', '2030') = 3.6;
NECPCapacityPlans('FR', 'Offshore', '2035') = 8.6;
NECPCapacityPlans('FR', 'Offshore', '2050') = 13.6;
NECPCapacityPlans('FR', 'Offshore', '2055') = 15.5;
NECPCapacityPlans('FR', 'Offshore', '2060') = 17.7;

NECPCapacityPlans('GR', 'Solar', '2025') = 8.5;
NECPCapacityPlans('GR', 'Solar', '2030') = 13.5;
NECPCapacityPlans('GR', 'Solar', '2035') = 18.5;
NECPCapacityPlans('GR', 'Solar', '2040') = 26;
NECPCapacityPlans('GR', 'Solar', '2045') = 30;
NECPCapacityPlans('GR', 'Solar', '2050') = 35.1;
NECPCapacityPlans('GR', 'Onshore', '2025') = 7;
NECPCapacityPlans('GR', 'Onshore', '2030') = 8.9;
NECPCapacityPlans('GR', 'Onshore', '2035') = 9.5;
NECPCapacityPlans('GR', 'Onshore', '2040') = 11;
NECPCapacityPlans('GR', 'Onshore', '2045') = 13;
NECPCapacityPlans('GR', 'Onshore', '2050') = 13;
NECPCapacityPlans('GR', 'Offshore', '2025') = 0;
NECPCapacityPlans('GR', 'Offshore', '2030') = 1.9;
NECPCapacityPlans('GR', 'Offshore', '2035') = 3.9;
NECPCapacityPlans('GR', 'Offshore', '2040') = 5.8;
NECPCapacityPlans('GR', 'Offshore', '2045') = 8.2;
NECPCapacityPlans('GR', 'Offshore', '2050') = 11.8;

NECPCapacityPlans('DE', 'Solar', '2025') = 117.7;
NECPCapacityPlans('DE', 'Solar', '2030') = 215;
NECPCapacityPlans('DE', 'Solar', '2040') = 400;
NECPCapacityPlans('DE', 'Onshore', '2025') = 64;
NECPCapacityPlans('DE', 'Onshore', '2030') = 115;
NECPCapacityPlans('DE', 'Onshore', '2040') = 160;
NECPCapacityPlans('DE', 'Offshore', '2025') = 9.215;
NECPCapacityPlans('DE', 'Offshore', '2030') = 30;
NECPCapacityPlans('DE', 'Offshore', '2035') = 40;
NECPCapacityPlans('DE', 'Offshore', '2045') = 70;




NewCapacity.up('2025',t,r)$(TagTechnologyToSubsets(t,'PowerSupply') and sum(sub, TagTechnologyToSubsets(t,sub)) and sum(subset, NECPCapacityPlans(r,subset,'2025'))) = +INF;


equation NECPCapacityExpansion(r_full, subset, y_full);
NECPCapacityExpansion(r,sub,y)$(NECPCapacityPlans(r,sub,y))..
sum(t$(TagTechnologyToSubsets(t,sub) and TagTechnologyToSubsets(t,'PowerSupply')), TotalCapacityAnnual(y, t, r)) =e= NECPCapacityPlans(r,sub,y);


$endIf