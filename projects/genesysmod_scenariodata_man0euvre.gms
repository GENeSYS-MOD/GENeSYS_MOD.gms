*
* ############ Man0EUvRE project scenario overlay ############
*
* Country case-study feedback (CS1-CS9) collected in the Man0EUvRE project for
* the 30-region European model. Loaded only with --project_scenario=man0euvre,
* after genesysmod_scenariodata_europe.gms.
*
* Reproducibility: this file on its own does not reproduce the published
* Man0EUvRE runs. Those runs also carried two edits to the core equations that
* were deliberately not upstreamed, because they hardcoded region names:
*   - TrC6_SymmetricalTransmissionExpansion skipped the PT-ES pair from 2040 on
*   - S7a_Add_E2PRatio_up skipped PT / S_Battery_Li-Ion
* Here the PT-ES convergence is instead expressed as data (commissioned capacity,
* see below), which keeps PTES_TradeConvergence compatible with the TrC6 band;
* S9_PT_LiIon_MaxDuration is held at StorageE2PRatio * the deviation factor
* (6h with the shipped data) rather than the intended 8h.
* The exact state used for the published runs is tagged man0euvre-final-asrun.
*

* CS9: PT coal (all sectors, tagged 'Coal' in Par_TagTechnologyToSubsets) produces 0
* energy but ResidualCapacity keeps carrying leftover TotalCapacity beyond 2025 -
* zero out remaining capacity and block new build
ResidualCapacity('PT',t,y)$(TagTechnologyToSubsets(t,'Coal') and YearVal(y)>=2025) = 0;
NewCapacity.up(y,t,'PT')$(TagTechnologyToSubsets(t,'Coal') and YearVal(y)>=2025) = 0;
TotalCapacityAnnual.fx(y,t,'PT')$(TagTechnologyToSubsets(t,'Coal') and YearVal(y)>=2025) = 0;


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
equation S8_PT_LiIon_MinDuration(STORAGE,YEAR_FULL,REGION_FULL);
S8_PT_LiIon_MinDuration(s,y,r)$(sameas(r,'PT') and sameas(s,'S_Battery_Li-Ion'))..
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

* the ES->PT direction is 0.7 GW larger after the 2025 commissioning; LNEG feedback is that grid
* reinforcement brings PT->ES to parity by 2040, so the difference is commissioned exogenously.
* Totals are recursive (TrC2b), which makes PTES_TradeConvergence feasible under the TrC6 band.
CommissionedTradeCapacity('PT','Power','2040','ES') = CommissionedTradeCapacity('PT','Power','2040','ES') + 0.7;


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