AvailabilityFactor(r,'X_DAC_HT',y) = 0;
AvailabilityFactor(r,'X_DAC_LT',y) = 0;


parameter warning_TotalAnnualMinCapacityTooHigh;
warning_TotalAnnualMinCapacityTooHigh(r,t,y)$(TotalAnnualMaxCapacity(r,t,y)<TotalAnnualMinCapacity(r,t,'2025')) = 1;

TotalAnnualMaxCapacity(r,t,y)$(TotalAnnualMaxCapacity(r,t,y)<TotalAnnualMinCapacity(r,t,'2025')) = TotalAnnualMinCapacity(r,t,'2025');

* Limit capacity expansion in 2025 to only actually (historically) installed capacities
NewCapacity.up('2025',t,r)$(TagTechnologyToSubsets(t,'PowerSupply') and not TotalAnnualMinCapacity(r,t,'2025') and not sameas(t,'P_Nuclear')) = TotalAnnualMinCapacity(r,t,'2025');


parameter ProductionAnnualLowerLimit;
ProductionAnnualLowerLimit(y,'Heat_District',r) = SpecifiedAnnualDemand(r,'Heat_District',y);
SpecifiedAnnualDemand(r,'Heat_Buildings',y) = SpecifiedAnnualDemand(r,'Heat_District',y)*0.85+SpecifiedAnnualDemand(r,'Heat_Buildings',y);
SpecifiedAnnualDemand(r,'Heat_District',y) = 0;


equation Add_DistrictHeatLimit(y_full,f,r_full);
Add_DistrictHeatLimit(y,'Heat_District',r).. sum((l,t,m)$(OutputActivityRatio(r,t,'Heat_District',m,y) <> 0), RateOfActivity(y,l,t,m,r)*OutputActivityRatio(r,t,'Heat_District',m,y)*YearSplit(l,y)) =g= ProductionAnnualLowerLimit(y,'Heat_District',r)-heatingslack(y,r);


ProductionByTechnologyAnnual.up(y,'HLI_Geothermal','Heat_Low_Industrial',r) = SpecifiedAnnualDemand(r,'Heat_Low_Industrial',y)*0.25;

AvailabilityFactor(r,'HB_Lignite','2018') = 0;
AvailabilityFactor(r,'HB_Solar_Thermal','2018') = 0;
*AvailabilityFactor(r,'HB_Hardcoal','2018') = 0;





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

*equation Add_HeatpumpLimit(r_full,y_full);
*Add_HeatpumpLimit(r,y).. sum(t$(sameas(t,'HB_Heatpump_Aerial') or sameas(t,'HB_Heatpump_Ground')),ProductionByTechnologyAnnual(y,t,'Heat_Buildings',r)) =l=  0.75*SpecifiedAnnualDemand(r,'Heat_Buildings',y);


*ModalSplitByFuelAndModalType(r,'Mobility_Passenger','MT_PSNG_ROAD_RE',y) = ModalSplitByFuelAndModalType(r,'Mobility_Passenger','MT_PSNG_ROAD_RE','2018');


*ProductionByTechnologyAnnual.lo('2018','P_Hydro_Reservoir','Power','NO') = 350;

RegionalBaseYearProduction('SE','HB_Direct_Electric',f,y) = 0;
RegionalBaseYearProduction('SE','HB_Biomass',f,y) = 0;
RegionalBaseYearProduction(r,'CHP_Biomass_Solid','Heat_District',y) = 0;
RegionalBaseYearProduction(r,'CHP_Biomass_Solid','Power',y) = 0;

NewCapacity.up(y,'PSNG_Rail_Conv',r) = 0;
NewCapacity.up(y,'FRT_Rail_Conv',r) = 0;
*ResidualCapacity(r,t,y)$(TagTechnologyToSubsets(t,'Transport')) = 0;
NewCapacity.up('%year%',t,r)$(TagTechnologyToSubsets(t,'Transport')) = +INF;
NewCapacity.up('%year%','HMHI_Steam_Electric',r) = +INF;
NewCapacity.up('%year%','HLI_Biomass',r) = +INF;
NewCapacity.up('%year%','HLI_Direct_Electric',r) = +INF;
NewCapacity.up(y,'HD_Heatpump_ExcessHeat',r) = 0;
ResidualCapacity('SE','HD_Heatpump_ExcessHeat',y) = 4.75;
*ResidualCapacity(r,'HB_Hardcoal',y) = 0;
NewCapacity.up(y,'HB_Direct_Electric','SE') = +INF;
NewCapacity.up(y,'HB_Biomass','SE') = 6;



*NewStorageCapacity.fx('S_HD_Pit','2018',r) = 0;
