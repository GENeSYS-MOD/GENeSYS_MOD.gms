AvailabilityFactor(r,'X_DAC_HT',y) = 0;
AvailabilityFactor(r,'X_DAC_LT',y) = 0;


parameter warning_TotalAnnualMinCapacityTooHigh;
warning_TotalAnnualMinCapacityTooHigh(r,t,y)$(TotalAnnualMaxCapacity(r,t,y)<TotalAnnualMinCapacity(r,t,'2025')) = 1;

TotalAnnualMaxCapacity(r,t,y)$(TotalAnnualMaxCapacity(r,t,y)<TotalAnnualMinCapacity(r,t,'2025')) = TotalAnnualMinCapacity(r,t,'2025');

* Limit capacity expansion in 2025 to only actually (historically) installed capacities
NewCapacity.up('2025',t,r)$(TagTechnologyToSubsets(t,'PowerSupply') and not TotalAnnualMinCapacity(r,t,'2025') and not AnnualMinNewCapacity(r,t,'2025')) = TotalAnnualMinCapacity(r,t,'2025');

ProductionByTechnologyAnnual.up(y,'CHP_WasteToEnergy','Heat_District',r) = RegionalBaseYearProduction(r,'CHP_WasteToEnergy','Heat_District','2018');
OutputActivityRatio(r,'CHP_WasteToEnergy',f,'1',y) = 0;

ProductionByTechnologyAnnual.up(y,'HD_Heatpump_ExcessHeat','Heat_District',r)$(YearVal(y)>2018) = SpecifiedAnnualDemand(r,'Heat_District',y)*0.08;

ProductionByTechnologyAnnual.up(y,'HLI_Geothermal','Heat_Low_Industrial',r) = SpecifiedAnnualDemand(r,'Heat_Low_Industrial',y)*0.25;


$ifthen %emissionPathway% == REPowerEU_Sweden

ProductionByTechnologyAnnual.up(y,'HHI_Scrap_EAF','Heat_High_Industrial',r) = SpecifiedAnnualDemand(r,'Heat_High_Industrial',y)*0.65;
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_PSNG_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.002*(YearVal(y)-2025);
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_FRT_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.002*(YearVal(y)-2025);

$elseif %emissionPathway% == NECPEssentials_Sweden


ProductionByTechnologyAnnual.up(y,'HHI_Scrap_EAF','Heat_High_Industrial',r) = SpecifiedAnnualDemand(r,'Heat_High_Industrial',y)*0.6;
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_PSNG_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.00175*(YearVal(y)-2025);
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_FRT_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.00175*(YearVal(y)-2025);

$elseif %emissionPathway% == Green_Sweden

ProductionByTechnologyAnnual.up(y,'HHI_Scrap_EAF','Heat_High_Industrial',r) = SpecifiedAnnualDemand(r,'Heat_High_Industrial',y)*0.75;
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_PSNG_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.00225*(YearVal(y)-2025);
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_FRT_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.00225*(YearVal(y)-2025);

$elseif %emissionPathway% == Trinity_Sweden
ProductionByTechnologyAnnual.up(y,'HHI_Scrap_EAF','Heat_High_Industrial',r) = SpecifiedAnnualDemand(r,'Heat_High_Industrial',y)*0.5;
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_PSNG_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.001*(YearVal(y)-2025);
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_FRT_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.001*(YearVal(y)-2025);

$endif

equation DistrictHeatProductionAnnualLowerLimit(r_full, FUEL, y_full);
DistrictHeatProductionAnnualLowerLimit(r,f,y)$(sameas(f,'Heat_District') and DistrictHeatDemand(r,y)).. sum(t,ProductionByTechnologyAnnual(y,t,'Heat_District',r)) =g= DistrictHeatDemand(r,y)*InputActivityRatio(r,'X_Convert_HD',f,'1',y)*0.95;
 
equation DistrictHeatProductionAnnualUpperLimit(r_full, FUEL, y_full);
DistrictHeatProductionAnnualUpperLimit(r,f,y)$(sameas(f,'Heat_District') and DistrictHeatDemand(r,y)).. sum(t,ProductionByTechnologyAnnual(y,t,'Heat_District',r)) =l= DistrictHeatDemand(r,y)*InputActivityRatio(r,'X_Convert_HD',f,'1',y)*1.05;
 
equation DistrictHeatProductionSplit(r_full, Sector, y_full);
DistrictHeatProductionSplit(r,se,y)$(DistrictHeatSplit(r,se,y)).. sum((f,t)$(TagDemandFuelToSector(f,se) and TagTechnologyToSubsets(t,'Convert')),ProductionByTechnologyAnnual(y,t,f,r)) =g= DistrictHeatDemand(r,y)*DistrictHeatSplit(r,se,y);

* National limits to annual new capacities
parameter NationalAnnualMaxNewCapacity(TECHNOLOGY,YEAR_FULL);
NationalAnnualMaxNewCapacity('HB_Biomass','2025') = 6;
NationalAnnualMaxNewCapacity('HB_Biomass','2030') = 6;
NationalAnnualMaxNewCapacity('HB_Biomass','2035') = 6;
NationalAnnualMaxNewCapacity('HB_Biomass','2040') = 6;
NationalAnnualMaxNewCapacity('HB_Biomass','2045') = 6;
NationalAnnualMaxNewCapacity('HB_Biomass','2050') = 6;
NationalAnnualMaxNewCapacity('HB_Biomass','2055') = 6;
NationalAnnualMaxNewCapacity('HB_Biomass','2060') = 6;
NationalAnnualMaxNewCapacity('P_Nuclear','2035') = 2.5;
NationalAnnualMaxNewCapacity('P_Nuclear','2040') = 5;
NationalAnnualMaxNewCapacity('P_Nuclear','2045') = 5;

equation NationalAnnualMaxNewCapacityConstraint(YEAR_FULL,TECHNOLOGY);
NationalAnnualMaxNewCapacityConstraint(y,t)$(NationalAnnualMaxNewCapacity(t,y) <> 0).. sum(r,NewCapacity(y,t,r)) =l= NationalAnnualMaxNewCapacity(t,y);

parameter NationalAnnualMinNewCapacity(TECHNOLOGY,YEAR_FULL);
NationalAnnualMinNewCapacity('P_Nuclear','2035') = 2.5;
NationalAnnualMinNewCapacity('P_Nuclear','2040') = 5;
NationalAnnualMinNewCapacity('P_Nuclear','2045') = 5;

equation NationalAnnualMinNewCapacityConstraint(YEAR_FULL,TECHNOLOGY);
NationalAnnualMinNewCapacityConstraint(y,t)$(NationalAnnualMinNewCapacity(t,y) <> 0).. sum(r,NewCapacity(y,t,r)) =g= NationalAnnualMinNewCapacity(t,y);