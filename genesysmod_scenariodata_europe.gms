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

