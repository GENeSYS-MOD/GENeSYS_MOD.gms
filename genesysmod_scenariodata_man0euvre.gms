* CS9: PT coal (all sectors, tagged 'Coal' in Par_TagTechnologyToSubsets) produces 0
* energy but ResidualCapacity keeps carrying leftover TotalCapacity beyond 2025 -
* zero out remaining capacity and block new build
ResidualCapacity('PT',t,y)$(TagTechnologyToSubsets(t,'Coal') and YearVal(y)>=2025) = 0;
NewCapacity.up(y,t,'PT')$(TagTechnologyToSubsets(t,'Coal') and YearVal(y)>=2025) = 0;
TotalCapacityAnnual.fx(y,t,'PT')$(TagTechnologyToSubsets(t,'Coal') and YearVal(y)>=2025) = 0;


TotalAnnualMaxCapacity(r,t,y)$(TotalAnnualMaxCapacity(r,t,y)<TotalAnnualMinCapacity(r,t,'2025')) = TotalAnnualMinCapacity(r,t,'2025');

ProductionByTechnologyAnnual.up(y,'CHP_WasteToEnergy','Heat_District',r) = RegionalBaseYearProduction(r,'CHP_WasteToEnergy','Heat_District','2018');
OutputActivityRatio(r,'CHP_WasteToEnergy',f,'1',y) = 0;

ProductionByTechnologyAnnual.up(y,'HD_Heatpump_ExcessHeat','Heat_District',r)$(YearVal(y)>2018) = SpecifiedAnnualDemand(r,'Heat_District',y)*0.08;

ProductionByTechnologyAnnual.up(y,'HLI_Geothermal','Heat_Low_Industrial',r) = SpecifiedAnnualDemand(r,'Heat_Low_Industrial',y)*0.25;


$ifthen %emissionPathway% == REPowerEU

ProductionByTechnologyAnnual.up(y,'HHI_Scrap_EAF','Heat_High_Industrial',r) = SpecifiedAnnualDemand(r,'Heat_High_Industrial',y)*0.65;
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_PSNG_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.002*(YearVal(y)-2025);
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_FRT_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.002*(YearVal(y)-2025);
TagCanFuelBeTraded('ETS') = 0;

PeakingSlackAdd('FR') = 0.0190;


$elseif %emissionPathway% == NECPEssentials

ProductionByTechnologyAnnual.up(y,'HHI_Scrap_EAF','Heat_High_Industrial',r) = SpecifiedAnnualDemand(r,'Heat_High_Industrial',y)*0.6;
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_PSNG_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.00175*(YearVal(y)-2025);
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_FRT_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.00175*(YearVal(y)-2025);
TagCanFuelBeTraded('ETS') = 0;

PeakingSlackAdd('FR') = 0.0251;

$elseif %emissionPathway% == Green

ProductionByTechnologyAnnual.up(y,'HHI_Scrap_EAF','Heat_High_Industrial',r) = SpecifiedAnnualDemand(r,'Heat_High_Industrial',y)*0.75;
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_PSNG_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.00225*(YearVal(y)-2025);
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_FRT_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.00225*(YearVal(y)-2025);
TagCanFuelBeTraded('ETS') = 0;

PeakingSlackAdd('FR') = 0.0323;
PeakingSlackAdd('CH') = 0.0837;
PeakingSlackAdd('IE') = 0.1555;
PeakingSlackAdd('UK') = 0.0470;
PeakingSlackAdd('FI') = 0.0209;


$elseif %emissionPathway% == Trinity
ProductionByTechnologyAnnual.up(y,'HHI_Scrap_EAF','Heat_High_Industrial',r) = SpecifiedAnnualDemand(r,'Heat_High_Industrial',y)*0.5;
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_PSNG_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.001*(YearVal(y)-2025);
ModalSplitByFuelAndModalType(r,f,mt,y)$(sameas(mt,'MT_FRT_ROAD') and YearVal(y)>2025 and ModalSplitByFuelAndModalType(r,f,mt,y)) = ModalSplitByFuelAndModalType(r,f,mt,'2025')-0.001*(YearVal(y)-2025);
TagCanFuelBeTraded('ETS') = 0;

PeakingSlackAdd('FR') = 0.0198;


$endif


*increase the lower and upper battery duration for Portugal
equation PT_LiIon_MinDuration(STORAGE,YEAR_FULL,REGION_FULL);
PT_LiIon_MinDuration(s,y,r)$(sameas(r,'PT') and sameas(s,'S_Battery_Li-Ion'))..
  (sum((yy)$(OperationalLifeStorage(s) >= Yearval(y)-Yearval(yy) and Yearval(y)-Yearval(yy) >= 0), NewStorageCapacity(s,yy,r)) + ResidualStorageCapacity(r,s,y))
  =g=
  sum((t,m)$(TechnologyToStorage(t,s,m,y)), TotalCapacityAnnual(y,t,r) * 4 * 0.0036);

equation S9_PT_LiIon_MaxDuration(STORAGE,YEAR_FULL,REGION_FULL);
S9_PT_LiIon_MaxDuration(s,y,r)$(sameas(r,'PT') and sameas(s,'S_Battery_Li-Ion'))..
  (sum((yy)$(OperationalLifeStorage(s) >= Yearval(y)-Yearval(yy) and Yearval(y)-Yearval(yy) >= 0), NewStorageCapacity(s,yy,r)) + ResidualStorageCapacity(r,s,y))
  =l=
  sum((t,m)$(TechnologyToStorage(t,s,m,y)), TotalCapacityAnnual(y,t,r) * 8 * 0.0036);

*convergence of interconnection capacity ES <-> PT
equation PTES_TradeConvergence(FUEL,YEAR_FULL,REGION_FULL,RR_FULL);
PTES_TradeConvergence(f,y,r,rr)$(sameas(f,'Power') and sameas(r,'PT') and sameas(rr,'ES') and YearVal(y)>=2040)..
  TotalTradeCapacity(y,f,r,rr) =e= TotalTradeCapacity(y,f,rr,r);



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