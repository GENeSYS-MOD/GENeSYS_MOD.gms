AvailabilityFactor(r,'X_DAC_HT',y) = 0;
AvailabilityFactor(r,'X_DAC_LT',y) = 0;


parameter warning_TotalAnnualMinCapacityTooHigh;
warning_TotalAnnualMinCapacityTooHigh(r,t,y)$(TotalAnnualMaxCapacity(r,t,y)<TotalAnnualMinCapacity(r,t,'2025')) = 1;

TotalAnnualMaxCapacity(r,t,y)$(TotalAnnualMaxCapacity(r,t,y)<TotalAnnualMinCapacity(r,t,'2025')) = TotalAnnualMinCapacity(r,t,'2025');

* Limit capacity expansion in 2025 to only actually (historically) installed capacities
NewCapacity.up('2025',t,r)$(TagTechnologyToSubsets(t,'PowerSupply') and not TotalAnnualMinCapacity(r,t,'2025') and not sameas(t,'P_Nuclear')) = TotalAnnualMinCapacity(r,t,'2025');

ProductionByTechnologyAnnual.up(y,'CHP_WasteToEnergy','Heat_District',r) = RegionalBaseYearProduction(r,'CHP_WasteToEnergy','Heat_District','2018');
OutputActivityRatio(r,'CHP_WasteToEnergy',f,'1',y) = 0;

ProductionByTechnologyAnnual.up(y,'HD_Heatpump_ExcessHeat','Heat_District',r)$(YearVal(y)>2018) = SpecifiedAnnualDemand(r,'Heat_District',y)*0.08;

ProductionByTechnologyAnnual.up(y,'HLI_Geothermal','Heat_Low_Industrial',r) = SpecifiedAnnualDemand(r,'Heat_Low_Industrial',y)*0.25;


$ifthen %emissionPathway% == REPowerEU

ProductionByTechnologyAnnual.up(y,'HHI_Scrap_EAF','Heat_High_Industrial',r) = SpecifiedAnnualDemand(r,'Heat_High_Industrial',y)*0.65;
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_PSNG_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.002*(YearVal(y)-2025);
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_FRT_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.002*(YearVal(y)-2025);

$elseif %emissionPathway% == NECPEssentials


ProductionByTechnologyAnnual.up(y,'HHI_Scrap_EAF','Heat_High_Industrial',r) = SpecifiedAnnualDemand(r,'Heat_High_Industrial',y)*0.6;
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_PSNG_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.00175*(YearVal(y)-2025);
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_FRT_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.00175*(YearVal(y)-2025);

$elseif %emissionPathway% == Green

ProductionByTechnologyAnnual.up(y,'HHI_Scrap_EAF','Heat_High_Industrial',r) = SpecifiedAnnualDemand(r,'Heat_High_Industrial',y)*0.75;
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_PSNG_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.00225*(YearVal(y)-2025);
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_FRT_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.00225*(YearVal(y)-2025);

$elseif %emissionPathway% == Trinity
ProductionByTechnologyAnnual.up(y,'HHI_Scrap_EAF','Heat_High_Industrial',r) = SpecifiedAnnualDemand(r,'Heat_High_Industrial',y)*0.5;
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_PSNG_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.001*(YearVal(y)-2025);
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_FRT_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.001*(YearVal(y)-2025);

$endif

equation DistrictHeatProductionAnnual(r_full, FUEL, y_full);
DistrictHeatProductionAnnual(r,f,y)$(sameas(f,'Heat_District')).. sum(t,ProductionByTechnologyAnnual(y,t,'Heat_District',r)) =g= DistrictHeatDemand(r,y)*1.2048;

equation DistrictHeatProductionSplit(r_full, Sector, y_full);
DistrictHeatProductionSplit(r,se,y)$(DistrictHeatSplit(r,se,y)).. sum((f,t)$(TagDemandFuelToSector(f,se) and TagTechnologyToSubsets(t,'Convert')),ProductionByTechnologyAnnual(y,t,f,r)) =g= DistrictHeatDemand(r,y)*DistrictHeatSplit(r,se,y);


equation CapacityUpperLimitPV2030(y_full, r_full);
CapacityUpperLimitPV2030(y,r).. sum(t$(TagTechnologyToSubsets(t,'Solar') and TagTechnologyToSubsets(t,'PowerSupply')), TotalCapacityAnnual('2030', t, 'FR')) =l= 54.4;

equation CapacityUpperLimitPV2035(y_full, r_full);
CapacityUpperLimitPV2035(y,r).. sum(t$(TagTechnologyToSubsets(t,'Solar') and TagTechnologyToSubsets(t,'PowerSupply')), TotalCapacityAnnual('2035', t, 'FR')) =l= 68.4;

equation CapacityUpperLimitPV2050(y_full, r_full);
CapacityUpperLimitPV2050(y,r).. sum(t$(TagTechnologyToSubsets(t,'Solar') and TagTechnologyToSubsets(t,'PowerSupply')), TotalCapacityAnnual('2050', t, 'FR')) =l= 82.4;
*
*parameter CO2StorageCost(REGION_FULL,YEAR_FULL);
*CO2StorageCost(r,y) = 4.81;
*CO2StorageCost(r,'2025') = 4.58;
*CO2StorageCost(r,'2030') = 4.35;
*CO2StorageCost(r,'2035') = 4.15;
*CO2StorageCost(r,'2040') = 3.94;
*CO2StorageCost(r,'2045') = 3.94;
*CO2StorageCost(r,'2050') = 3.94;
*CO2StorageCost(r,'2055') = 3.94;
*CO2StorageCost(r,'2060') = 3.94;

TagTechnologyToSubsets('P_Wind_Onshore_Inf','Onshore') = 1;
TagTechnologyToSubsets('P_Wind_Onshore_Avg','Onshore') = 1;
TagTechnologyToSubsets('P_Wind_Onshore_Opt','Onshore') = 1;

TagTechnologyToSubsets('P_Wind_Offshore_Shallow','Offshore') = 1;
TagTechnologyToSubsets('P_Wind_Offshore_Transitional','Offshore') = 1;
TagTechnologyToSubsets('P_Wind_Offshore_Deep','Offshore') = 1;


equation CapacityUpperLimitOnshore2030(y_full, r_full);
CapacityUpperLimitOnshore2030(y,r).. sum(t$(TagTechnologyToSubsets(t,'Onshore')), TotalCapacityAnnual('2030', t, 'FR')) =l= 34.2;
equation CapacityUpperLimitOnshore2035(y_full, r_full);
CapacityUpperLimitOnshore2035(y,r).. sum(t$(TagTechnologyToSubsets(t,'Onshore')), TotalCapacityAnnual('2035', t, 'FR')) =l= 40.7;
equation CapacityUpperLimitOnshore2050(y_full, r_full);
CapacityUpperLimitOnshore2050(y,r).. sum(t$(TagTechnologyToSubsets(t,'Onshore')), TotalCapacityAnnual('2050', t, 'FR')) =l= 47.2;
equation CapacityUpperLimitOnshore2055(y_full, r_full);
CapacityUpperLimitOnshore2055(y,r).. sum(t$(TagTechnologyToSubsets(t,'Onshore')), TotalCapacityAnnual('2055', t, 'FR')) =l= 49.5;
equation CapacityUpperLimitOnshore2060(y_full, r_full);
CapacityUpperLimitOnshore2060(y,r).. sum(t$(TagTechnologyToSubsets(t,'Onshore')), TotalCapacityAnnual('2060', t, 'FR')) =l= 51.9;

equation CapacityUpperLimitOffshore2030(y_full, r_full);
CapacityUpperLimitOffshore2030(y,r).. sum(t$(TagTechnologyToSubsets(t,'Offshore')), TotalCapacityAnnual('2030', t, 'FR')) =l= 3.6;
equation CapacityUpperLimitOffshore2035(y_full, r_full);
CapacityUpperLimitOffshore2035(y,r).. sum(t$(TagTechnologyToSubsets(t,'Offshore')), TotalCapacityAnnual('2035', t, 'FR')) =l= 8.6;
equation CapacityUpperLimitOffshore2050(y_full, r_full);
CapacityUpperLimitOffshore2050(y,r).. sum(t$(TagTechnologyToSubsets(t,'Offshore')), TotalCapacityAnnual('2050', t, 'FR')) =l= 13.6;
equation CapacityUpperLimitOffshore2055(y_full, r_full);
CapacityUpperLimitOffshore2055(y,r).. sum(t$(TagTechnologyToSubsets(t,'Offshore')), TotalCapacityAnnual('2055', t, 'FR')) =l= 15.5;
equation CapacityUpperLimitOffshore2060(y_full, r_full);
CapacityUpperLimitOffshore2060(y,r).. sum(t$(TagTechnologyToSubsets(t,'Offshore')), TotalCapacityAnnual('2060', t, 'FR')) =l= 17.7;