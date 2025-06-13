AvailabilityFactor(r,'X_DAC_HT',y) = 0;
AvailabilityFactor(r,'X_DAC_LT',y) = 0;


parameter warning_TotalAnnualMinCapacityTooHigh;
warning_TotalAnnualMinCapacityTooHigh(r,t,y)$(TotalAnnualMaxCapacity(r,t,y)<TotalAnnualMinCapacity(r,t,'2025')) = 1;

TotalAnnualMaxCapacity(r,t,y)$(TotalAnnualMaxCapacity(r,t,y)<TotalAnnualMinCapacity(r,t,'2025')) = TotalAnnualMinCapacity(r,t,'2025');

* Limit capacity expansion in 2025 to only actually (historically) installed capacities
NewCapacity.up(r,t,'2025')$(TagTechnologyToSubsets(t,'PowerSupply') and not TotalAnnualMinCapacity(r,t,'2025')) = TotalAnnualMinCapacity(r,t,'2025');


parameter ProductionAnnualLowerLimit;
ProductionAnnualLowerLimit(y,'Heat_District',r) = SpecifiedAnnualDemand(r,'Heat_District',y);
SpecifiedAnnualDemand(r,'Heat_Buildings',y) = SpecifiedAnnualDemand(r,'Heat_District',y)*0.85+SpecifiedAnnualDemand(r,'Heat_Buildings',y);
SpecifiedAnnualDemand(r,'Heat_District',y) = 0;


positive variable heatingslack(y_full,r_full);
equation Add_DistrictHeatLimit(y_full,f,r_full);
Add_DistrictHeatLimit(y,'Heat_District',r).. sum((l,t,m)$(OutputActivityRatio(r,t,'Heat_District',m,y) <> 0), RateOfActivity(r,t,m,l,y)*OutputActivityRatio(r,t,'Heat_District',m,y)*YearSplit(l,y)) =g= ProductionAnnualLowerLimit(y,'Heat_District',r)-heatingslack(y,r);


ProductionByTechnologyAnnual.up(r,'HLI_Geothermal','Heat_Low_Industrial',y) = SpecifiedAnnualDemand(r,'Heat_Low_Industrial',y)*0.25;

AvailabilityFactor(r,'HB_Lignite','2018') = 0;
AvailabilityFactor(r,'HB_Solar_Thermal','2018') = 0;
*AvailabilityFactor(r,'HB_Hardcoal','2018') = 0;





$ifthen %emissionPathway% == REPowerEU

ProductionByTechnologyAnnual.up(r,'HHI_Scrap_EAF','Heat_High_Industrial',y) = SpecifiedAnnualDemand(r,'Heat_High_Industrial',y)*0.65;
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_PSNG_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.002*(YearVal(y)-2025);
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_FRT_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.002*(YearVal(y)-2025);

$elseif %emissionPathway% == NECPEssentials


ProductionByTechnologyAnnual.up(r,'HHI_Scrap_EAF','Heat_High_Industrial',y) = SpecifiedAnnualDemand(r,'Heat_High_Industrial',y)*0.6;
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_PSNG_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.00175*(YearVal(y)-2025);
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_FRT_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.00175*(YearVal(y)-2025);

$elseif %emissionPathway% == Green

ProductionByTechnologyAnnual.up(r,'HHI_Scrap_EAF','Heat_High_Industrial',y) = SpecifiedAnnualDemand(r,'Heat_High_Industrial',y)*0.75;
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_PSNG_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.00225*(YearVal(y)-2025);
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_FRT_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.00225*(YearVal(y)-2025);

$elseif %emissionPathway% == Trinity
ProductionByTechnologyAnnual.up(r,'HHI_Scrap_EAF','Heat_High_Industrial',y) = SpecifiedAnnualDemand(r,'Heat_High_Industrial',y)*0.5;
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_PSNG_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.001*(YearVal(y)-2025);
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_FRT_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.001*(YearVal(y)-2025);

$endif

*equation Add_HeatpumpLimit(r_full,y_full);
*Add_HeatpumpLimit(r,y).. sum(t$(sameas(t,'HB_Heatpump_Aerial') or sameas(t,'HB_Heatpump_Ground')),ProductionByTechnologyAnnual(r,t,'Heat_Buildings',y)) =l=  0.75*SpecifiedAnnualDemand(r,'Heat_Buildings',y);


*ModalSplitByFuelAndModalType(r,'Mobility_Passenger','MT_PSNG_ROAD_RE',y) = ModalSplitByFuelAndModalType(r,'Mobility_Passenger','MT_PSNG_ROAD_RE','2018');


*ProductionByTechnologyAnnual.lo('NO','P_Hydro_Reservoir','Power','2018') = 350;

RegionalBaseYearProduction('SE','HB_Direct_Electric',f,y) = 0;
RegionalBaseYearProduction('SE','HB_Biomass',f,y) = 0;
RegionalBaseYearProduction(r,'CHP_Biomass_Solid','Heat_District',y) = 0;
RegionalBaseYearProduction(r,'CHP_Biomass_Solid','Power',y) = 0;

NewCapacity.up(r,'PSNG_Rail_Conv',y) = 0;
NewCapacity.up(r,'FRT_Rail_Conv',y) = 0;
*ResidualCapacity(r,t,y)$(TagTechnologyToSubsets(t,'Transport')) = 0;
NewCapacity.up(r,t,'%year%')$(TagTechnologyToSubsets(t,'Transport')) = +INF;
NewCapacity.up(r,'HMHI_Steam_Electric','%year%') = +INF;
NewCapacity.up(r,'HLI_Biomass','%year%') = +INF;
NewCapacity.up(r,'HLI_Direct_Electric','%year%') = +INF;
NewCapacity.up(r,'HD_Heatpump_ExcessHeat',y) = 0;
ResidualCapacity('SE','HD_Heatpump_ExcessHeat',y) = 4.75;
*ResidualCapacity(r,'HB_Hardcoal',y) = 0;
NewCapacity.up('SE','HB_Direct_Electric',y) = +INF;
NewCapacity.up('SE','HB_Biomass',y) = 6;



*NewStorageCapacity.fx('S_HD_Pit','2018',r) = 0;
