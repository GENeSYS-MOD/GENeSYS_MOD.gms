AvailabilityFactor(r,'X_DAC_HT',y) = 0;
AvailabilityFactor(r,'X_DAC_LT',y) = 0;



parameter warning_TotalAnnualMinCapacityTooHigh;
warning_TotalAnnualMinCapacityTooHigh(r,t,y)$(TotalAnnualMaxCapacity(r,t,y)<TotalAnnualMinCapacity(r,t,'2025')) = 1;

TotalAnnualMaxCapacity(r,t,y)$(TotalAnnualMaxCapacity(r,t,y)<TotalAnnualMinCapacity(r,t,'2025')) = TotalAnnualMinCapacity(r,t,'2025');

NewCapacity.up('2025',t,r)$(TagTechnologyToSubsets(t,'PowerSupply') and not TotalAnnualMinCapacity(r,t,'2025')) = TotalAnnualMinCapacity(r,t,'2025');


equation Add_FlatH2Imports(y_full,l_full,r_full);
Add_FlatH2Imports(y,l,r)..   RateOfActivity(y,l,'Z_Import_H2','1',r)  =l= sum(ll,RateOfActivity(y,ll,'Z_Import_H2','1',r))*YearSplit(l,y)*1.05;

equation Add_FlatGasImports(y_full,l_full,r_full);
Add_FlatGasImports(y,l,r)..   RateOfActivity(y,l,'Z_Import_Gas','1',r)  =l= sum(ll,RateOfActivity(y,ll,'Z_Import_Gas','1',r))*YearSplit(l,y)*1.05;

parameter ProductionAnnualLowerLimit;
ProductionAnnualLowerLimit(y,'Heat_District',r) = SpecifiedAnnualDemand(r,'Heat_District',y);
SpecifiedAnnualDemand(r,'Heat_District',y) = 0;


positive variable heatingslack(y_full,r_full);
equation Add_ProductionAnnualLowerLimit(y_full,f,r_full);
Add_ProductionAnnualLowerLimit(y,'Heat_District',r).. sum((l,t,m)$(OutputActivityRatio(r,t,'Heat_District',m,y) <> 0), RateOfActivity(y,l,t,m,r)*OutputActivityRatio(r,t,'Heat_District',m,y)*YearSplit(l,y)) =g= ProductionAnnualLowerLimit(y,'Heat_District',r)-heatingslack(y,r);

NewCapacity.up('%year%',t,r)$(TagTechnologyToSubsets(t,'Transport')) = +INF;
NewCapacity.up(y,'PSNG_Rail_Conv',r) = 0;
NewCapacity.up(y,'FRT_Rail_Conv',r) = 0;

$ifthen %emissionPathway% == Trinity
VariableCost(r,'Z_Import_H2',m,y) = VariableCost(r,'Z_Import_H2',m,y)*2;

$endif

*ResidualCapacity(r,t,y)$(TagTechnologyToSubsets(t,'Buildings')) = 0;
*NewCapacity.up(y,t,r)$(TagTechnologyToSubsets(t,'Buildings')) = +INF;
NewCapacity.up(y,'HD_Heatpump_ExcessHeat',r) = 0;

*ProductionByTechnologyAnnual.lo('2018','HB_Direct_Electric','Heat_Buildings','SE') = 53;
*ProductionByTechnologyAnnual.lo('2018','HB_Biomass','Heat_Buildings','SE') = 40;
*ProductionByTechnologyAnnual.lo('2018','HB_Heatpump_Aerial','Heat_Buildings','SE') = 35;


ProductionByTechnologyAnnual.up(y,'HLI_Geothermal','Heat_Low_Industrial',r) = SpecifiedAnnualDemand(r,'Heat_Low_Industrial',y)*0.25;

*ProductionByTechnologyAnnual.lo('2018','HB_Direct_Electric','Heat_Buildings','NO') = 40;
*ProductionByTechnologyAnnual.up('2018','HB_Convert_DH','Heat_Buildings','AT') = +INF;


*ResidualCapacity(r,t,y)$(TagTechnologyToSubsets(t,'Transport')) = 0;
*NewCapacity.up(y,t,r)$(TagTechnologyToSubsets(t,'Transport')) = +INF;

ModalSplitByFuelAndModalType(r,'Mobility_Passenger','MT_PSNG_ROAD_CONV',y)$
((ModalSplitByFuelAndModalType(r,'Mobility_Passenger','MT_PSNG_ROAD_CONV',y)+ModalSplitByFuelAndModalType(r,'Mobility_Passenger','MT_PSNG_ROAD_RE',y))>ModalSplitByFuelAndModalType(r,'Mobility_Passenger','MT_PSNG_ROAD',y))
= ModalSplitByFuelAndModalType(r,'Mobility_Passenger','MT_PSNG_ROAD',y)-ModalSplitByFuelAndModalType(r,'Mobility_Passenger','MT_PSNG_ROAD_RE',y)-0.01;

ModalSplitByFuelAndModalType(r,'Mobility_Passenger','MT_PSNG_ROAD_RE',y) = ModalSplitByFuelAndModalType(r,'Mobility_Passenger','MT_PSNG_ROAD_RE','2018');

AvailabilityFactor(r,'HB_Lignite','2018') = 0;
AvailabilityFactor(r,'HB_H2_Boiler',y)$(YearVal(y)<2035) = 0;
