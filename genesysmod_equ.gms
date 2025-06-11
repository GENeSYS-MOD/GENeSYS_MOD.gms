* GENeSYS-MOD v3.1 [Global Energy System Model]  ~ March 2022
*
* #############################################################
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*
* #############################################################



* ######################
* # Objective Function #
* ######################

free variable z;


equation cost;
cost.. z =e= sum((y,r), TotalDiscountedCost(y,r))
+ sum((y,r), DiscountedAnnualTotalTradeCosts(y,r))
+ sum((y,f,r,rr), DiscountedNewTradeCapacityCosts(y,f,r,rr))
+ sum((y,f,r), DiscountedAnnualCurtailmentCost(y,f,r))
+ sum((y,r,f,t),BaseYearBounds_TooHigh(y,r,t,f)*9999)
+ sum((y,r,f,t),BaseYearBounds_TooLow(y,r,t,f)*9999)
+ sum((r,y),heatingslack(y,r)*9999)
- sum((y,r),DiscountedSalvageValueTransmission(y,r))
;

* #########################
* # Parameter assignments #
* #########################

RateOfDemand(y,l,f,r) = SpecifiedAnnualDemand(r,f,y)*SpecifiedDemandProfile(r,f,l,y) / YearSplit(l,y);
Demand(y,l,f,r) = RateOfDemand(y,l,f,r)*YearSplit(l,y);

Demand(y,l,f,r)$(Demand(y,l,f,r) < 0.000001) = 0;
CapacityFactor(r,t,l,y)$(CapacityFactor(r,t,l,y) < 0.000001) = 0;

parameter CanFuelBeUsedByModeByTech(YEAR_FULL, FUEL, REGION_FULL,TECHNOLOGY,MODE_OF_OPERATION);
CanFuelBeUsedByModeByTech(y,f,r,t,m)$
(InputActivityRatio(r,t,f,m,y)*
            TotalAnnualMaxCapacity(r,t,y)*
            sum(l,CapacityFactor(r,t,l,y))*
            AvailabilityFactor(r,t,y)*
            TotalTechnologyModelPeriodActivityUpperLimit(r,t)*
            TotalTechnologyAnnualActivityUpperLimit(r,t,y)
 > 0) = 1;

parameter CanFuelBeUsedByTech(YEAR_FULL, FUEL, REGION_FULL,TECHNOLOGY);
CanFuelBeUsedByTech(y,f,r,t)$
(sum((m), InputActivityRatio(r,t,f,m,y)*
            TotalAnnualMaxCapacity(r,t,y)*
            sum(l,CapacityFactor(r,t,l,y))*
            AvailabilityFactor(r,t,y)*
            TotalTechnologyModelPeriodActivityUpperLimit(r,t)*
            TotalTechnologyAnnualActivityUpperLimit(r,t,y))
 > 0) = 1;

parameter CanFuelBeUsed(YEAR_FULL, FUEL, REGION_FULL);
CanFuelBeUsed(y,f,r)$
(sum((m,t), InputActivityRatio(r,t,f,m,y)*
            TotalAnnualMaxCapacity(r,t,y)*
            sum(l,CapacityFactor(r,t,l,y))*
            AvailabilityFactor(r,t,y)*
            TotalTechnologyModelPeriodActivityUpperLimit(r,t)*
            TotalTechnologyAnnualActivityUpperLimit(r,t,y))
 > 0) = 1;

parameter CanFuelBeUsedInTimeslice(YEAR_FULL, TIMESLICE_FULL, FUEL, REGION_FULL);
CanFuelBeUsedInTimeslice(y,l,f,r)$
(sum((m,t), InputActivityRatio(r,t,f,m,y)*
            TotalAnnualMaxCapacity(r,t,y)*
            CapacityFactor(r,t,l,y)*
            AvailabilityFactor(r,t,y)*
            TotalTechnologyModelPeriodActivityUpperLimit(r,t)*
            TotalTechnologyAnnualActivityUpperLimit(r,t,y))
 > 0) = 1;

parameter CanFuelBeUsedOrDemanded(YEAR_FULL, FUEL, REGION_FULL);
CanFuelBeUsedOrDemanded(y,f,r)$
(sum((m,t), InputActivityRatio(r,t,f,m,y)*
            TotalAnnualMaxCapacity(r,t,y)*
            sum(l,CapacityFactor(r,t,l,y))*
            AvailabilityFactor(r,t,y)*
            TotalTechnologyModelPeriodActivityUpperLimit(r,t)*
            TotalTechnologyAnnualActivityUpperLimit(r,t,y))
 > 0 or SpecifiedAnnualDemand(r,f,y) > 0) = 1;

parameter CanFuelBeProduced(YEAR_FULL, FUEL, REGION_FULL);
CanFuelBeProduced(y,f,r)$
(sum((m,t), OutputActivityRatio(r,t,f,m,y)*
            TotalAnnualMaxCapacity(r,t,y)*
            sum(l,CapacityFactor(r,t,l,y))*
            AvailabilityFactor(r,t,y)*
            TotalTechnologyModelPeriodActivityUpperLimit(r,t)*
            TotalTechnologyAnnualActivityUpperLimit(r,t,y))
 > 0) = 1;

parameter CanFuelBeProducedByModeByTech(YEAR_FULL, FUEL, REGION_FULL,TECHNOLOGY,MODE_OF_OPERATION);
CanFuelBeProducedByModeByTech(y,f,r,t,m)$
(OutputActivityRatio(r,t,f,m,y)*
            TotalAnnualMaxCapacity(r,t,y)*
            sum(l,CapacityFactor(r,t,l,y))*
            AvailabilityFactor(r,t,y)*
            TotalTechnologyModelPeriodActivityUpperLimit(r,t)*
            TotalTechnologyAnnualActivityUpperLimit(r,t,y)
 > 0) = 1;

parameter CanFuelBeProducedByTech(YEAR_FULL, FUEL, REGION_FULL,TECHNOLOGY);
CanFuelBeProducedByTech(y,f,r,t)$
(sum((m), OutputActivityRatio(r,t,f,m,y)*
            TotalAnnualMaxCapacity(r,t,y)*
            sum(l,CapacityFactor(r,t,l,y))*
            AvailabilityFactor(r,t,y)*
            TotalTechnologyModelPeriodActivityUpperLimit(r,t)*
            TotalTechnologyAnnualActivityUpperLimit(r,t,y))
 > 0) = 1;

parameter CanFuelBeProducedInTimeslice(YEAR_FULL, TIMESLICE_FULL, FUEL, REGION_FULL);
CanFuelBeProducedInTimeslice(y,l,f,r)$
(sum((m,t), OutputActivityRatio(r,t,f,m,y)*
            TotalAnnualMaxCapacity(r,t,y)*
            CapacityFactor(r,t,l,y)*
            AvailabilityFactor(r,t,y)*
            TotalTechnologyModelPeriodActivityUpperLimit(r,t)*
            TotalTechnologyAnnualActivityUpperLimit(r,t,y))
 > 0) = 1;

parameter TagTimeIndependentFuel(YEAR_FULL, FUEL, REGION_FULL);
TagTimeIndependentFuel(y,f,r)$
(CanFuelBeUsedOrDemanded(y,f,r) = 1 and CanFuelBeProduced(y,f,r) = 0) = 1;
$if not set Info $setglobal Info reduced
$ifthen %Info% == "reduced"
TagTimeIndependentFuel(y,'Lignite',r) = 1;
TagTimeIndependentFuel(y,'Biomass',r) = 1;
TagTimeIndependentFuel(y,'Area_Rooftop_Residential',r) = 1;
TagTimeIndependentFuel(y,'Area_Rooftop_Commercial',r) = 1;
TagTimeIndependentFuel(y,'Hardcoal',r) = 1;
TagTimeIndependentFuel(y,'Nuclear',r) = 1;
TagTimeIndependentFuel(y,'Oil',r) = 1;
TagTimeIndependentFuel(y,'Air',r) = 1;
TagTimeIndependentFuel(y,'DAC_Dummy',r) = 1;
TagTimeIndependentFuel(y,'ETS',r) = 1;
TagTimeIndependentFuel(y,'ETS_Source',r) = 1;
$endif
$ifthen %Info% == "reduced2"
TagTimeIndependentFuel(y,'Lignite',r) = 1;
TagTimeIndependentFuel(y,'Biomass',r) = 1;
TagTimeIndependentFuel(y,'Area_Rooftop_Residential',r) = 1;
TagTimeIndependentFuel(y,'Area_Rooftop_Commercial',r) = 1;
TagTimeIndependentFuel(y,'Hardcoal',r) = 1;
TagTimeIndependentFuel(y,'Nuclear',r) = 1;
TagTimeIndependentFuel(y,'Oil',r) = 1;
TagTimeIndependentFuel(y,'Air',r) = 1;
TagTimeIndependentFuel(y,'DAC_Dummy',r) = 1;
TagTimeIndependentFuel(y,'ETS',r) = 1;
TagTimeIndependentFuel(y,'ETS_Source',r) = 1;
TagTimeIndependentFuel(y,'LNG',r) = 1;
TagTimeIndependentFuel(y,'LBG',r) = 1;
$endif

parameter PureDemandFuel(YEAR_FULL, FUEL, REGION_FULL);
PureDemandFuel(y,f,r)$
(CanFuelBeUsed(y,f,r) = 0 and SpecifiedAnnualDemand(r,f,y) > 0) = 1;


* ###############
* # Constraints #
* ###############

*
* ############### Capacity Adequacy A #############

*
equation CA1_TotalNewCapacity(YEAR_FULL,TECHNOLOGY,REGION_FULL);
CA1_TotalNewCapacity(y,t,r)$(sum(yy$((YearVal(y)-YearVal(yy) < OperationalLife(t)) AND (YearVal(y)-YearVal(yy) >= 0)), TotalAnnualMaxCapacity(r,t,yy)) > 0 and TotalTechnologyModelPeriodActivityUpperLimit(r,t) > 0).. AccumulatedNewCapacity(y,t,r) =e= sum(yy$((YearVal(y)-YearVal(yy) < OperationalLife(t)) AND (YearVal(y)-YearVal(yy) >= 0)), NewCapacity(yy,t,r));
AccumulatedNewCapacity.fx(y,t,r)$(sum(yy$((YearVal(y)-YearVal(yy) < OperationalLife(t)) AND (YearVal(y)-YearVal(yy) >= 0)), TotalAnnualMaxCapacity(r,t,yy)) = 0 or TotalTechnologyModelPeriodActivityUpperLimit(r,t) = 0) = 0;

equation CA2_TotalAnnualCapacity(YEAR_FULL,TECHNOLOGY,REGION_FULL);
CA2_TotalAnnualCapacity(y,t,r)$(AccumulatedNewCapacity.up(y,t,r) > 0 or ResidualCapacity(r,t,y) > 0).. AccumulatedNewCapacity(y,t,r) + ResidualCapacity(r,t,y) =e= TotalCapacityAnnual(y,t,r);
TotalCapacityAnnual.fx(y,t,r)$(AccumulatedNewCapacity.up(y,t,r) = 0 and ResidualCapacity(r,t,y) = 0) = 0;
AccumulatedNewCapacity.fx(y,t,r)$(AccumulatedNewCapacity.up(y,t,r) = 0) = 0;

parameter CanBuildTechnology(YEAR_FULL, TECHNOLOGY, REGION_FULL);
CanBuildTechnology(y,t,r)$
(TotalAnnualMaxCapacity(r,t,y)*
 sum(l,CapacityFactor(r,t,l,y))*
 AvailabilityFactor(r,t,y)*
 TotalTechnologyModelPeriodActivityUpperLimit(r,t)*
 TotalTechnologyAnnualActivityUpperLimit(r,t,y)
 > 0 and TotalCapacityAnnual.up(y,t,r) > 0) = 1;

RateOfActivity.fx(y,l,t,m,r)$
  (CapacityFactor(r,t,l,y) = 0
or AvailabilityFactor(r,t,y) = 0
or TotalTechnologyModelPeriodActivityUpperLimit(r,t) = 0
or TotalTechnologyAnnualActivityUpperLimit(r,t,y) = 0
or TotalAnnualMaxCapacity(r,t,y) = 0
or TotalCapacityAnnual.up(y,t,r) = 0
or (sum(f,OutputActivityRatio(r,t,f,m,y)) = 0 and sum(f,InputActivityRatio(r,t,f,m,y)) = 0)
) = 0;


$ifthen  %switch_intertemporal% == 1
equation CA3a_RateOfTotalActivity_Intertemporal(REGION_FULL,TIMESLICE_FULL,TECHNOLOGY,YEAR_FULL);
CA3a_RateOfTotalActivity_Intertemporal(r,l,t,y)$(CapacityFactor(r,t,l,y) > 0 and AvailabilityFactor(r,t,y) > 0 and TotalAnnualMaxCapacity(r,t,y) > 0 and TotalTechnologyModelPeriodActivityUpperLimit(r,t) > 0).. sum(m, RateOfActivity(y,l,t,m,r)) =e= TotalActivityPerYear(r,l,t,y) - DispatchDummy(r,l,t,y)*TagDispatchableTechnology(t) - CurtailedCapacity(r,l,t,y)*CapacityToActivityUnit(t);

equation CA4_TotalActivityPerYear_Intertemporal(REGION_FULL,TIMESLICE_FULL,TECHNOLOGY,YEAR_FULL);
CA4_TotalActivityPerYear_Intertemporal(r,l,t,y)$((sum(yy$((YearVal(y)-YearVal(yy) < OperationalLife(t)) AND (YearVal(y)-YearVal(yy) >= 0)),CapacityFactor(r,t,l,yy)) > 0 or CapacityFactor(r,t,l,'%year%') > 0) and TotalTechnologyModelPeriodActivityUpperLimit(r,t) > 0 and AvailabilityFactor(r,t,y) > 0 and TotalAnnualMaxCapacity(r,t,y) > 0).. TotalActivityPerYear(r,l,t,y) =e= sum(yy$((YearVal(y)-YearVal(yy) < OperationalLife(t)) AND (YearVal(y)-YearVal(yy) >= 0)),
(NewCapacity(yy,t,r) * CapacityFactor(r,t,l,yy) * CapacityToActivityUnit(t)))+(ResidualCapacity(r,t,y)*CapacityFactor(r,t,l,'%year%') * CapacityToActivityUnit(t));
$else

equation CA3b_RateOfTotalActivity(REGION_FULL,TIMESLICE_FULL,TECHNOLOGY,YEAR_FULL);
CA3b_RateOfTotalActivity(r,l,t,y)$(CapacityFactor(r,t,l,y) > 0 and AvailabilityFactor(r,t,y) > 0 and TotalAnnualMaxCapacity(r,t,y) > 0 and TotalTechnologyModelPeriodActivityUpperLimit(r,t) > 0).. sum(m, RateOfActivity(y,l,t,m,r)) =e= TotalCapacityAnnual(y,t,r) * CapacityFactor(r,t,l,y) * CapacityToActivityUnit(t) - DispatchDummy(r,l,t,y)*TagDispatchableTechnology(t) - CurtailedCapacity(r,l,t,y)*CapacityToActivityUnit(t);
$endif

equation CA3c_CurtailedCapacity(REGION_FULL,TIMESLICE_FULL,TECHNOLOGY,YEAR_FULL) Ensures that there cannot be more curtailment than actual installed capacity;
CA3c_CurtailedCapacity(r,l,t,y)..  TotalCapacityAnnual(y,t,r) =g= CurtailedCapacity(r,l,t,y);

equation CA5_CapacityAdequacy(YEAR_FULL,TECHNOLOGY,REGION_FULL) Constraint to limit timeslice generation to installed capacity and availability factor;
CA5_CapacityAdequacy(y,t,r)$(AvailabilityFactor(r,t,y)<1 and TotalAnnualMaxCapacity(r,t,y) > 0 and TotalTechnologyModelPeriodActivityUpperLimit(r,t) > 0 and TotalCapacityAnnual.up(y,t,r) > 0).. sum(l, sum(m, RateOfActivity(y,l,t,m,r))*YearSplit(l,y)) =l= sum(l,TotalCapacityAnnual(y,t,r)*CapacityFactor(r,t,l,y)*YearSplit(l,y)*AvailabilityFactor(r,t,y)*CapacityToActivityUnit(t));

*
* ##############* Energy Balances #############
*

equation EB1_TradeBalanceEachTS(YEAR_FULL,TIMESLICE_FULL,FUEL,r_full,rr_FULL);
EB1_TradeBalanceEachTS(y,l,f,r,rr)$(TradeRoute(r,f,y,rr) and TagCanFuelBeTraded(f)).. Import(y,l,f,r,rr) =e= Export(y,l,f,rr,r);
Import.fx(y,l,f,r,rr)$(TradeRoute(r,f,y,rr) = 0 or TagCanFuelBeTraded(f) = 0) = 0;
Export.fx(y,l,f,rr,r)$(TradeRoute(r,f,y,rr) = 0 or TagCanFuelBeTraded(f) = 0) = 0;
NetTrade.fx(y,l,f,r)$(sum(rr,TradeRoute(r,f,y,rr)) = 0 or TagCanFuelBeTraded(f) = 0) = 0;

equation EB2_EnergyBalanceEachTS(YEAR_FULL,TIMESLICE_FULL,FUEL,REGION_FULL);
EB2_EnergyBalanceEachTS(y,l,f,r)$(TagTimeIndependentFuel(y,f,r) = 0).. sum((t,m)$(OutputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity(y,l,t,m,r)*OutputActivityRatio(r,t,f,m,y))*YearSplit(l,y) =e= Demand(y,l,f,r) + sum((t,m)$(InputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity(y,l,t,m,r)*InputActivityRatio(r,t,f,m,y)*TimeDepEfficiency(r,t,l,y))*YearSplit(l,y) + NetTrade(y,l,f,r);

equation EB3_EnergyBalanceEachYear(YEAR_FULL,FUEL,REGION_FULL);
EB3_EnergyBalanceEachYear(y,f,r)$(TagTimeIndependentFuel(y,f,r)).. sum((l,t,m)$(OutputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity(y,l,t,m,r)*OutputActivityRatio(r,t,f,m,y)*YearSplit(l,y)) =g= sum((l,t,m)$(InputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity(y,l,t,m,r)*InputActivityRatio(r,t,f,m,y)*YearSplit(l,y)*TimeDepEfficiency(r,t,l,y)) + NetTradeAnnual(y,f,r);

equation EB4_NetTradeBalance(YEAR_FULL,TIMESLICE_FULL,FUEL,REGION_FULL);
EB4_NetTradeBalance(y,l,f,r)$(sum(rr,TradeRoute(r,f,y,rr)) and TagCanFuelBeTraded(f)).. sum(rr$(TradeRoute(r,f,y,rr)), Export(y,l,f,r,rr)*(1+TradeLossBetweenRegions(r,f,y,rr)) - Import(y,l,f,r,rr)) =e= NetTrade(y,l,f,r);

equation EB5_AnnualNetTradeBalance(YEAR_FULL,FUEL,REGION_FULL);
EB5_AnnualNetTradeBalance(y,f,r)$(sum(rr,TradeRoute(r,f,y,rr)) and TagCanFuelBeTraded(f)).. sum(l, (NetTrade(y,l,f,r))) =e= NetTradeAnnual(y,f,r);
NetTradeAnnual.fx(y,f,r)$(sum(rr,TradeRoute(r,f,y,rr)) = 0 or TagCanFuelBeTraded(f) = 0) = 0;

equation EB6_AnnualEnergyCurtailment(YEAR_FULL,FUEL,REGION_FULL);
EB6_AnnualEnergyCurtailment(y,f,r).. CurtailedEnergyAnnual(y,f,r) =e= sum((l,t,m),CurtailedCapacity(r,l,t,y)*OutputActivityRatio(r,t,f,m,y)*YearSplit(l,y)*CapacityToActivityUnit(t));

equation EB7_AnnualSelfSufficiency(YEAR_FULL,FUEL,REGION_FULL);
EB7_AnnualSelfSufficiency(y,f,r)$(SelfSufficiency(y,f,r) <> 0).. sum((l,t,m)$(OutputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity(y,l,t,m,r)*OutputActivityRatio(r,t,f,m,y)*YearSplit(l,y)) =g= (SpecifiedAnnualDemand(r,f,y)+sum((l,t,m)$(InputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity(y,l,t,m,r)*InputActivityRatio(r,t,f,m,y)*YearSplit(l,y)*TimeDepEfficiency(r,t,l,y)))*SelfSufficiency(y,f,r);

*
* ##############* Trade Capacities & Investments #############
*
equation TrC1_TradeCapacityPowerLinesImport(YEAR_FULL,TIMESLICE_FULL,FUEL,REGION_FULL,rr_full);
TrC1_TradeCapacityPowerLinesImport(y,l,'Power',r,rr)$(TradeRoute(r,'Power',y,rr) > 0).. (Import(y,l,'Power',r,rr)) =l= TotalTradeCapacity(y,'Power',rr,r)*YearSplit(l,y)*31.536;

equation TrC2a_TotalTradeCapacityStartYear(YEAR_FULL,FUEL,REGION_FULL,rr_full);
TrC2a_TotalTradeCapacityStartYear(y,f,r,rr)$(TradeRoute(r,f,y,rr) and TagCanFuelBeTraded(f) and YearVal(y) = %year%).. TotalTradeCapacity(y,f,r,rr) =e= TradeCapacity(r,f,y,rr);
equation TrC2b_TotalTradeCapacity(YEAR_FULL,FUEL,REGION_FULL,rr_full);
TrC2b_TotalTradeCapacity(y,f,r,rr)$(TradeRoute(r,f,y,rr) and TagCanFuelBeTraded(f) and YearVal(y) > %year%).. TotalTradeCapacity(y,f,r,rr) =e= TotalTradeCapacity(y-1,f,r,rr) + NewTradeCapacity(y,f,r,rr) + CommissionedTradeCapacity(r,f,y,rr);

equation TrC3_NewTradeCapacityLimitPowerLines(YEAR_FULL,FUEL,REGION_FULL,rr_full);
TrC3_NewTradeCapacityLimitPowerLines(y,'Power',r,rr)$(TradeRoute(r,'Power',y,rr) > 0 and GrowthRateTradeCapacity(r,'Power',y,rr) > 0 and YearVal(y) > %year%).. (GrowthRateTradeCapacity(r,'Power',y,rr)*YearlyDifferenceMultiplier(y))*TotalTradeCapacity(y-1,'Power',r,rr) =g= NewTradeCapacity(y,'Power',r,rr);
NewTradeCapacity.fx(y,'Power',r,rr)$(TradeRoute(r,'Power',y,rr) = 0 or GrowthRateTradeCapacity(r,'Power',y,rr) = 0) = 0;



*### Trade Capacities for H2 and Natural Gas, when initially no capacities existed, so that the model has the ability to build additional capacities
equation TrC4a_NewTradeCapacityLimitNatGas(YEAR_FULL,FUEL,REGION_FULL,rr_full);
TrC4a_NewTradeCapacityLimitNatGas(y,'Gas_Natural',r,rr)$(TradeRoute(r,'Gas_Natural',y,rr) and GrowthRateTradeCapacity(r,'Gas_Natural',y,rr)).. 100$(not TradeCapacity(r,'Gas_Natural',y,rr))+(GrowthRateTradeCapacity(r,'Gas_Natural',y,rr)*YearlyDifferenceMultiplier(y))*TotalTradeCapacity(y-1,'Gas_Natural',r,rr) =g= NewTradeCapacity(y,'Gas_Natural',r,rr);

equation TrC5a_NewTradeCapacityLimitH2(YEAR_FULL,FUEL,REGION_FULL,rr_full);
TrC5a_NewTradeCapacityLimitH2(y,'H2',r,rr)$(TradeRoute(r,'H2',y,rr) and GrowthRateTradeCapacity(r,'H2',y,rr)).. 50$(not TradeCapacity(r,'H2',y,rr))+(GrowthRateTradeCapacity(r,'H2',y,rr)*YearlyDifferenceMultiplier(y))*TotalTradeCapacity(y-1,'H2',r,rr) =g= NewTradeCapacity(y,'H2',r,rr);

NewTradeCapacity.fx(y,f,r,rr)$(not TradeRoute(r,f,y,rr)) = 0;


equation TrC4_NewTradeCapacityCosts(YEAR_FULL,FUEL,REGION_FULL,rr_full);
TrC4_NewTradeCapacityCosts(y,f,r,rr)$(TradeRoute(r,f,y,rr) and TradeCapacityGrowthCosts(r,f,rr))..  NewTradeCapacity(y,f,r,rr)*TradeCapacityGrowthCosts(r,f,rr)*TradeRoute(r,f,y,rr) =e= NewTradeCapacityCosts(y,f,r,rr);
equation TrC5_DiscountedNewTradeCapacityCosts(YEAR_FULL,FUEL,REGION_FULL,rr_full);
TrC5_DiscountedNewTradeCapacityCosts(y,f,r,rr)$(TradeRoute(r,f,y,rr) and TradeCapacityGrowthCosts(r,f,rr)).. NewTradeCapacityCosts(y,f,r,rr)/((1+GeneralDiscountRate(r))**(YearVal(y)-smin(yy, YearVal(yy))+0.5)) =e= DiscountedNewTradeCapacityCosts(y,f,r,rr);
DiscountedNewTradeCapacityCosts.fx(y,f,r,rr)$(TradeRoute(r,f,y,rr) = 0 or not TradeCapacityGrowthCosts(r,f,rr)) = 0;

$ifthen set set_symmetric_transmission
equation TrC6_SymmetricalTransmissionExpansion(YEAR_FULL,REGION_FULL,RR_FULL);
TrC6_SymmetricalTransmissionExpansion(y,r,rr)$(TradeRoute(r,'Power',y,rr) > 0).. NewTradeCapacity(y,'Power',r,rr) =g= NewTradeCapacity(y,'Power',rr,r)*%set_symmetric_transmission%;
$endif

equation TrC7_TradeCapacityLimitNonPower(YEAR_FULL,FUEL,REGION_FULL,rr_full);
TrC7_TradeCapacityLimitNonPower(y,f,r,rr)$(TradeCapacityGrowthCosts(r,f,rr) and not sameas(f,'Power')).. sum(l,Import(y,l,f,rr,r)) =l= TotalTradeCapacity(y,f,r,rr);




equation TrPl1aa_TradeCapacityPipelinesLines(YEAR_FULL,TIMESLICE_FULL,REGION_FULL,rr_full);
TrPl1aa_TradeCapacityPipelinesLines(y,l,r,rr).. Import(y,l,'H2',rr,r) =l= TotalTradeCapacity(y,'H2',r,rr)*YearSplit(l,y);


**##################LH2 Trucks####
equation TrPl1aaa_TradeCapacityTrucks(YEAR_FULL,TIMESLICE_FULL,REGION_FULL,rr_full);
TrPl1aaa_TradeCapacityTrucks(y,l,r,rr).. Import(y,l,'LH2',rr,r) =l= TotalTradeCapacity(y,'LH2',r,rr)*YearSplit(l,y);
**######################



*
* ##############* Pipeline-specific Capacity Accounting #############
*

$ifthen.equ_hydrogen_tradecapacity %switch_hydrogen_blending_share% == 0



equation TrPA1a_TradeCapacityPipelineAccounting(YEAR_FULL,TIMESLICE_FULL,REGION_FULL,rr_full);
* before it was H2 - instead of H2_blend - - update GM_Coding_Week_Berlin-Trondheim_2024
TrPA1a_TradeCapacityPipelineAccounting(y,l,r,rr).. sum(f$(not sameas(f,'H2_blend') and TagFuelToSubsets(f,'GasFuels')), Import(y,l,f,rr,r)) =l= TotalTradeCapacity(y,'Gas_Natural',r,rr)*YearSplit(l,y);

$else.equ_hydrogen_tradecapacity



scalar dedicated_h2;
dedicated_h2 = %switch_hydrogen_blending_share%;


equation TrPA1b_TradeCapacityPipelineAccountingGasFuels(YEAR_FULL,TIMESLICE_FULL,REGION_FULL,rr_full);
TrPA1b_TradeCapacityPipelineAccountingGasFuels(y,l,r,rr)$(%switch_hydrogen_blending_share%>0 and %switch_hydrogen_blending_share%<1).. sum(f$(not sameas(f,'H2_blend') and TagFuelToSubsets(f,'GasFuels')), Import(y,l,f,rr,r)) + Import(y,l,'H2_blend',rr,r)*(11.4/3.0) =l= TotalTradeCapacity(y,'gas_natural',r,rr)*YearSplit(l,y);
equation TrPA1c_TradeCapacityPipelineAccountingH2Blend(YEAR_FULL,TIMESLICE_FULL,REGION_FULL,rr_full);
TrPA1c_TradeCapacityPipelineAccountingH2Blend(y,l,r,rr)$(%switch_hydrogen_blending_share%>0 and %switch_hydrogen_blending_share%<1).. Import(y,l,'H2_blend',rr,r) =l= (%switch_hydrogen_blending_share%/((1-%switch_hydrogen_blending_share%)*(11.4/3.0))) * sum(f$(not sameas(f,'H2_blend') and TagFuelToSubsets(f,'GasFuels')), Import(y,l,f,rr,r));

equation TrPA1d_TradeCapacityPipelineAccountingCombined(YEAR_FULL,TIMESLICE_FULL,REGION_FULL,rr_full);
TrPA1d_TradeCapacityPipelineAccountingCombined(y,l,r,rr)$(%switch_hydrogen_blending_share% = 1).. sum(f$(not sameas(f,'H2_blend') and TagFuelToSubsets(f,'GasFuels')), Import(y,l,f,rr,r)) + Import(y,l,'H2_blend',rr,r)*(11.4/3.0) =l= TotalTradeCapacity(y,'Gas_Natural',r,rr)*YearSplit(l,y);

$endif.equ_hydrogen_tradecapacity

*
* ######## Gas-specific import restrictions over the year
*

equation TrPA2a_FlatH2Imports(y_full,l_full,r_full);
TrPA2a_FlatH2Imports(y,l,r)..   RateOfActivity(y,l,'Z_Import_H2','1',r)  =l= sum(ll,RateOfActivity(y,ll,'Z_Import_H2','1',r))*YearSplit(l,y)*1.05;

equation TrPA2b_FlatGasImports(y_full,l_full,r_full);
TrPA2b_FlatGasImports(y,l,r)..   RateOfActivity(y,l,'Z_Import_Gas','1',r)  =l= sum(ll,RateOfActivity(y,ll,'Z_Import_Gas','1',r))*YearSplit(l,y)*1.05;


*
* ############## Trading Costs #############
*
equation TC1_AnnualTradeCosts(y_full,REGION_FULL);
TC1_AnnualTradeCosts(y,r)$(sum((f,rr),TradeRoute(r,f,y,rr))).. sum((l,f,rr)$(TradeRoute(r,f,y,rr)),Import(y,l,f,r,rr) * TradeCosts(r,f,y,rr)) =e= AnnualTotalTradeCosts(y,r);
AnnualTotalTradeCosts.fx(y,r)$(sum((f,rr),TradeRoute(r,f,y,rr)) = 0) = 0;

equation TC2_DiscountedAnnualTradeCosts(y_full,REGION_FULL);
TC2_DiscountedAnnualTradeCosts(y,r)..  AnnualTotalTradeCosts(y,r)/((1+GeneralDiscountRate(r))**(YearVal(y)-smin(yy, YearVal(yy))+0.5)) =e= DiscountedAnnualTotalTradeCosts(y,r);

*
* ############## Accounting Technology Production/Use #############
*

equation ACC1_ComputeTotalAnnualRateOfActivity(YEAR_FULL,TECHNOLOGY,MODE_OF_OPERATION,REGION_FULL);
ACC1_ComputeTotalAnnualRateOfActivity(y,t,m,r)$(CanBuildTechnology(y,t,r) > 0).. sum(l, RateOfActivity(y,l,t,m,r)*YearSplit(l,y)) =e= TotalAnnualTechnologyActivityByMode(y,t,m,r);
TotalAnnualTechnologyActivityByMode.fx(y,t,m,r)$(CanBuildTechnology(y,t,r) = 0) = 0;

equation ACC2_FuelProductionByTechnologyAnnual(YEAR_FULL,TECHNOLOGY,FUEL,REGION_FULL);
ACC2_FuelProductionByTechnologyAnnual(y,t,f,r)$(sum(m, OutputActivityRatio(r,t,f,m,y)) > 0 and AvailabilityFactor(r,t,y) > 0 and TotalAnnualMaxCapacity(r,t,y) > 0 and TotalTechnologyModelPeriodActivityUpperLimit(r,t) > 0 and TotalCapacityAnnual.up(y,t,r) > 0).. sum(l, sum(m$(OutputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity(y,l,t,m,r)*OutputActivityRatio(r,t,f,m,y)) * YearSplit(l,y)) =e= ProductionByTechnologyAnnual(y,t,f,r);
ProductionByTechnologyAnnual.fx(y,t,f,r)$(sum(m, OutputActivityRatio(r,t,f,m,y)) = 0 or AvailabilityFactor(r,t,y) = 0 or TotalAnnualMaxCapacity(r,t,y) = 0 or TotalTechnologyModelPeriodActivityUpperLimit(r,t) = 0 or TotalCapacityAnnual.up(y,t,r) = 0) = 0;

equation ACC3_FuelUseByTechnologyAnnual(YEAR_FULL,TECHNOLOGY,FUEL,REGION_FULL);
ACC3_FuelUseByTechnologyAnnual(y,t,f,r)$(sum(m, InputActivityRatio(r,t,f,m,y)) > 0 and AvailabilityFactor(r,t,y) > 0 and TotalAnnualMaxCapacity(r,t,y) > 0 and TotalTechnologyModelPeriodActivityUpperLimit(r,t) > 0 and TotalCapacityAnnual.up(y,t,r) > 0).. sum(l, (sum(m$(InputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity(y,l,t,m,r)*InputActivityRatio(r,t,f,m,y))*YearSplit(l,y))) =e= UseByTechnologyAnnual(y,t,f,r);
UseByTechnologyAnnual.fx(y,t,f,r)$(sum(m, InputActivityRatio(r,t,f,m,y)) = 0 or AvailabilityFactor(r,t,y) = 0 or TotalAnnualMaxCapacity(r,t,y) = 0 or TotalTechnologyModelPeriodActivityUpperLimit(r,t) = 0 or TotalCapacityAnnual.up(y,t,r) = 0) = 0;

*
* ############### Capital Costs #############
*
equation CC1_UndiscountedCapitalInvestments(YEAR_FULL,TECHNOLOGY,REGION_FULL);
CC1_UndiscountedCapitalInvestments(y,t,r).. CapitalCost(r,t,y) * NewCapacity(y,t,r) =e= CapitalInvestment(y,t,r);
equation CC2_DiscountedCapitalInvestments(YEAR_FULL,TECHNOLOGY,REGION_FULL);
CC2_DiscountedCapitalInvestments(y,t,r).. CapitalInvestment(y,t,r)/((1+TechnologyDiscountRate(r,t))**(YearVal(y)-StartYear)) =e= DiscountedCapitalInvestment(y,t,r);

*
* ############### Investment & Capacity Limits / Smoothing Constraints #############
*

$ifthen %switch_investLimit% == 1

equation SC1_SpreadCapitalInvestmentsAcrossTime(YEAR_FULL);
SC1_SpreadCapitalInvestmentsAcrossTime(y)$(YearVal(y) > %year%).. sum((t,r),CapitalInvestment(y,t,r)) =l= 1/(smax(yy,Yearval(yy))-smin(yy,YearVal(yy)))*YearlyDifferenceMultiplier(y-1)*InvestmentLimit*sum(yy,sum((t,r),CapitalInvestment(yy,t,r)));

equation SC2_LimitAnnualCapacityAdditions(YEAR_FULL,REGION_FULL,TECHNOLOGY);
SC2_LimitAnnualCapacityAdditions(y,r,t)$(TagTechnologyToSubsets(t,'Renewables') and YearVal(y)>2025).. NewCapacity(y,t,r) =l= YearlyDifferenceMultiplier(y-1)*NewRESCapacity*TotalAnnualMaxCapacity(r,t,y);

equation SC3_SmoothingRenewableIntegration(YEAR_FULL,REGION_FULL,TECHNOLOGY,FUEL);
SC3_SmoothingRenewableIntegration(y,r,t,f)$(Yearval(y) > %year% and TagTechnologyToSubsets(t,'PhaseInSet') and SpecifiedAnnualDemand(r,f,y-1)).. ProductionByTechnologyAnnual(y,t,f,r) =g= ProductionByTechnologyAnnual(y-1,t,f,r)*PhaseIn(y)*((SpecifiedAnnualDemand(r,f,y)/SpecifiedAnnualDemand(r,f,y-1))$(SpecifiedAnnualDemand(r,f,y))+1$(not SpecifiedAnnualDemand(r,f,y)));

equation SC3_SmoothingFossilPhaseOuts(YEAR_FULL,REGION_FULL,TECHNOLOGY,FUEL);
SC3_SmoothingFossilPhaseOuts(y,r,t,f)$(Yearval(y) > %year% and TagTechnologyToSubsets(t,'PhaseOutSet') and SpecifiedAnnualDemand(r,f,y-1)).. ProductionByTechnologyAnnual(y,t,f,r) =l= ProductionByTechnologyAnnual(y-1,t,f,r)*PhaseOut(y)*((SpecifiedAnnualDemand(r,f,y)/SpecifiedAnnualDemand(r,f,y-1))$(SpecifiedAnnualDemand(r,f,y))+1$(not SpecifiedAnnualDemand(r,f,y)));

equation SC4a_RelativeTechnologyPhaseInLimit(YEAR_FULL,REGION_FULL,FUEL);
SC4a_RelativeTechnologyPhaseInLimit(y,r,f)$(Yearval(y) > %year% and ProductionGrowthLimit(f,y)>0 and not TagFuelToSubsets(f,'TransportFuels')).. sum((t)$(RETagTechnology(t,y)=1),ProductionByTechnologyAnnual(y,t,f,r)-ProductionByTechnologyAnnual(y-1,t,f,r)) =l= YearlyDifferenceMultiplier(y-1)*ProductionGrowthLimit(f,y)*sum((t),ProductionByTechnologyAnnual(y-1,t,f,r))-sum((t)$(TagTechnologyToSubsets(t,'StorageDummies')),ProductionByTechnologyAnnual(y-1,t,f,r));

equation SC4b_RelativeTechnologyPhaseInLimit_Transport(YEAR_FULL,REGION_FULL,FUEL,MODALTYPE);
SC4b_RelativeTechnologyPhaseInLimit_Transport(y,r,f,mt)$(Yearval(y) > 2025 and ProductionGrowthLimit(f,y)>0 and TagFuelToSubsets(f,'TransportFuels') and TagModalTypeToModalGroups(mt,'TransportModes'))..
sum((t)$(RETagTechnology(t,y)=1 and TagTechnologyToModalType(t,'1',mt)),ProductionByTechnologyAnnual(y,t,f,r)-ProductionByTechnologyAnnual(y-1,t,f,r)) =l=
YearlyDifferenceMultiplier(y-1)*ProductionGrowthLimit(f,y)*sum((t)$(TagTechnologyToModalType(t,'1',mt)),ProductionByTechnologyAnnual(y-1,t,f,r));


equation SC5_AnnualStorageChangeLimit(YEAR_FULL,REGION_FULL,FUEL);
SC5_AnnualStorageChangeLimit(y,r,f)$(Yearval(y) > %year% and ProductionGrowthLimit(f,y)>0).. sum(t$(TagTechnologyToSubsets(t,'StorageDummies')),ProductionByTechnologyAnnual(y,t,f,r)-ProductionByTechnologyAnnual(y-1,t,f,r)) =l= YearlyDifferenceMultiplier(y-1)*(ProductionGrowthLimit(f,y)+StorageLimitOffset)*sum((t),ProductionByTechnologyAnnual(y-1,t,f,r))

$endif


*
* ############## CCS-specific constraints #############
*
$ifthen %switch_ccs% == 1
equation CCS1_CCSAdditionLimit(YEAR_FULL,REGION_FULL,FUEL);
CCS1_CCSAdditionLimit(y,r,f)$(Yearval(y) > %year% and not sameas(f,'DAC_Dummy')).. sum(t$(TagTechnologyToSubsets(t,'CCS')),ProductionByTechnologyAnnual(y,t,f,r)-ProductionByTechnologyAnnual(y-1,t,f,r)) =l= YearlyDifferenceMultiplier(y-1)*(ProductionGrowthLimit('Air',y))*sum((t),ProductionByTechnologyAnnual(y-1,t,f,r));

equation CCS2_MaximumCCStorageLimit(REGION_FULL);
CCS2_MaximumCCStorageLimit(r)$(sum(rr,RegionalCCSLimit(rr)) > 0)..
sum((y,t)$(TagTechnologyToSubsets(t,'CCS')),
         sum((f,m,e),
                 TotalAnnualTechnologyActivityByMode(y,t,m,r)*EmissionContentPerFuel(f,e)*InputActivityRatio(r,t,f,m,y)*YearlyDifferenceMultiplier(y)*(((1-EmissionActivityRatio(r,t,m,e,y))$(EmissionActivityRatio(r,t,m,e,y)>0))+
                 ((-1)*EmissionActivityRatio(r,t,m,e,y))$(EmissionActivityRatio(r,t,m,e,y)<0))
         )
) =l= RegionalCCSLimit(r);
$endif



*
* ##############* Salvage Value #############
*
equation SV1_SalvageValueAtEndOfPeriod1(YEAR_FULL,TECHNOLOGY,REGION_FULL);
SV1_SalvageValueAtEndOfPeriod1(y,t,r)$(DepreciationMethod=1 and ((YearVal(y) + OperationalLife(t)-1 > smax(yy, YearVal(yy))) and (TechnologyDiscountRate(r,t) > 0)))..
SalvageValue(y,t,r) =e= CapitalCost(r,t,y)*NewCapacity(y,t,r)*(1-(((1+TechnologyDiscountRate(r,t))**(smax(yy, YearVal(yy)) - YearVal(y)+1) -1)
/((1+TechnologyDiscountRate(r,t))**OperationalLife(t)-1)));

equation SV2_SalvageValueAtEndOfPeriod2(YEAR_FULL,TECHNOLOGY,REGION_FULL);
SV2_SalvageValueAtEndOfPeriod2(y,t,r)$((((YearVal(y) + OperationalLife(t)-1 > smax(yy, YearVal(yy))) and (TechnologyDiscountRate(r,t) = 0)) or (DepreciationMethod=2 and (YearVal(y) + OperationalLife(t)-1 > smax(yy, YearVal(yy))))))..
SalvageValue(y,t,r) =e= CapitalCost(r,t,y)*NewCapacity(y,t,r)*(1-(smax(yy, YearVal(yy))- YearVal(y)+1)/OperationalLife(t));
equation SV3_SalvageValueAtEndOfPeriod3(YEAR_FULL,TECHNOLOGY,REGION_FULL);
SV3_SalvageValueAtEndOfPeriod3(y,t,r)$(YearVal(y) + OperationalLife(t)-1 <= smax(yy, YearVal(yy)))..
SalvageValue(y,t,r) =e= 0;
equation SV1b_SalvageValueAtEndOfPeriod1(YEAR_FULL,REGION_FULL);
SV1b_SalvageValueAtEndOfPeriod1(y,r)$(DepreciationMethod=1 and ((YearVal(y) + 40 > smax(yy, YearVal(yy)))))..
DiscountedSalvageValueTransmission(y,r) =e= (sum((f,rr),TradeCapacityGrowthCosts(r,f,rr)*TradeRoute(r,f,y,rr)*NewTradeCapacity(y,f,r,rr)*(1-(((1+GeneralDiscountRate(r))**(smax(yy, YearVal(yy)) - YearVal(y)+1) -1)
/((1+GeneralDiscountRate(r))**40)))))/((1+GeneralDiscountRate(r))**(1+smax(yy, YearVal(yy)) - smin(yy, YearVal(yy))));
DiscountedSalvageValueTransmission.fx(y,r)$(DepreciationMethod=1 and not ((YearVal(y) + 40 > smax(yy, YearVal(yy))))) = 0;

equation SV4_SalvageValueDiscToStartYr(YEAR_FULL,TECHNOLOGY,REGION_FULL);
SV4_SalvageValueDiscToStartYr(y,t,r)..
DiscountedSalvageValue(y,t,r) =e= SalvageValue(y,t,r)/((1+TechnologyDiscountRate(r,t))**(1+smax(yy, YearVal(yy)) - smin(yy, YearVal(yy))));

*
* ############### Operating Costs #############
*
equation OC1_OperatingCostsVariable(YEAR_FULL,TECHNOLOGY,REGION_FULL);
OC1_OperatingCostsVariable(y,t,r)$(sum(m,VariableCost(r,t,m,y) > 0) and CanBuildTechnology(y,t,r) > 0).. sum(m, (TotalAnnualTechnologyActivityByMode(y,t,m,r)*VariableCost(r,t,m,y))) =e= AnnualVariableOperatingCost(y,t,r);
AnnualVariableOperatingCost.fx(y,t,r)$(CanBuildTechnology(y,t,r) = 0) = 0;

equation OC2_OperatingCostsFixedAnnual(YEAR_FULL,TECHNOLOGY,REGION_FULL);
OC2_OperatingCostsFixedAnnual(y,t,r)$(FixedCost(r,t,y) > 0 and CanBuildTechnology(y,t,r) > 0).. sum(yy$((YearVal(y)-YearVal(yy) < OperationalLife(t)) AND (YearVal(y)-YearVal(yy) >= 0)), NewCapacity(yy,t,r)*FixedCost(r,t,yy))+ResidualCapacity(r,t,y)*FixedCost(r,t,y) =e= AnnualFixedOperatingCost(y,t,r);
AnnualFixedOperatingCost.fx(y,t,r)$(CanBuildTechnology(y,t,r) = 0) = 0;

equation OC3_OperatingCostsTotalAnnual(YEAR_FULL,TECHNOLOGY,REGION_FULL);
OC3_OperatingCostsTotalAnnual(y,t,r)$(AnnualVariableOperatingCost.up(y,t,r) > 0 and AnnualFixedOperatingCost.up(y,t,r)  > 0).. (AnnualFixedOperatingCost(y,t,r) + AnnualVariableOperatingCost(y,t,r))*YearlyDifferenceMultiplier(y) =e= OperatingCost(y,t,r);
OperatingCost.fx(y,t,r)$(AnnualVariableOperatingCost.up(y,t,r) = 0 and AnnualFixedOperatingCost.up(y,t,r)  = 0) = 0;

equation OC4_DiscountedOperatingCostsTotalAnnual(YEAR_FULL,TECHNOLOGY,REGION_FULL);
OC4_DiscountedOperatingCostsTotalAnnual(y,t,r)$(OperatingCost.up(y,t,r) > 0).. OperatingCost(y,t,r)/((1+TechnologyDiscountRate(r,t))**(YearVal(y)-smin(yy, YearVal(yy))+0.5)) =e= DiscountedOperatingCost(y,t,r);
DiscountedOperatingCost.fx(y,t,r)$(OperatingCost.up(y,t,r) = 0) = 0;

*
* ############### Total Discounted Costs #############
*
equation TDC1_TotalDiscountedCostByTechnology(YEAR_FULL,TECHNOLOGY,REGION_FULL);
TDC1_TotalDiscountedCostByTechnology(y,t,r).. DiscountedOperatingCost(y,t,r)+DiscountedCapitalInvestment(y,t,r)+DiscountedTechnologyEmissionsPenalty(y,t,r)-DiscountedSalvageValue(y,t,r)
$ifthen %switch_ramping% == 1
+DiscountedAnnualProductionChangeCost(y,t,r)
$endif
=e= TotalDiscountedCostByTechnology(y,t,r);


equation TDC2_TotalDiscountedCost(YEAR_FULL,REGION_FULL);
TDC2_TotalDiscountedCost(y,r).. sum(t,TotalDiscountedCostByTechnology(y,t,r))+sum(s,TotalDiscountedStorageCost(s,y,r)) =e= TotalDiscountedCost(y,r);

*
* ############### Total Capacity Constraints ##############
*
equation TCC1_TotalAnnualMaxCapacityConstraint(YEAR_FULL,TECHNOLOGY,REGION_FULL);
TCC1_TotalAnnualMaxCapacityConstraint(y,t,r)$(TotalAnnualMaxCapacity(r,t,y) < 999999 and TotalAnnualMaxCapacity(r,t,y) > 0).. TotalCapacityAnnual(y,t,r) =l= TotalAnnualMaxCapacity(r,t,y);
TotalCapacityAnnual.fx(y,t,r)$(TotalAnnualMaxCapacity(r,t,y) = 0) = 0;

equation TCC2_TotalAnnualMinCapacityConstraint(YEAR_FULL,TECHNOLOGY,REGION_FULL);
TCC2_TotalAnnualMinCapacityConstraint(y,t,r)$(TotalAnnualMinCapacity(r,t,y)>0).. TotalCapacityAnnual(y,t,r) =g= TotalAnnualMinCapacity(r,t,y);

*
* ############### New Capacity Constraints ##############
*
equation NCC1_AnnualMaxNewCapacityConstraint(YEAR_FULL,TECHNOLOGY,REGION_FULL);
NCC1_AnnualMaxNewCapacityConstraint(y,t,r)$(AnnualMaxNewCapacity(r,t,y) < 999999).. NewCapacity(y,t,r) =l= AnnualMaxNewCapacity(r,t,y);
equation NCC2_AnnualMinNewCapacityConstraint(YEAR_FULL,TECHNOLOGY,REGION_FULL);
NCC2_AnnualMinNewCapacityConstraint(y,t,r)$(AnnualMinNewCapacity(r,t,y) > 0).. NewCapacity(y,t,r) =g= AnnualMinNewCapacity(r,t,y);

NewCapacity.fx(y,t,r)$(YearVal(y)>NewCapacityExpansionStop(r,t) and NewCapacityExpansionStop(r,t) and not TotalAnnualMinCapacity(r,t,y) and not AnnualMinNewCapacity(r,t,y)) = 0;

equation NCC3_TotalAnnualMaxInvestmentConstraint(YEAR_FULL,TECHNOLOGY,REGION_FULL);
NCC3_TotalAnnualMaxInvestmentConstraint(y,t,r)$(TotalAnnualMaxCapacityInvestment(r,t,y) < 999999).. CapitalInvestment(y,t,r) =l= TotalAnnualMaxCapacityInvestment(r,t,y);
equation NCC4_TotalAnnualMinInvestmentConstraint(YEAR_FULL,TECHNOLOGY,REGION_FULL);
NCC4_TotalAnnualMinInvestmentConstraint(y,t,r)$(TotalAnnualMinCapacityInvestment(r,t,y) > 0).. CapitalInvestment(y,t,r) =g= TotalAnnualMinCapacityInvestment(r,t,y);

*
* ################ Annual Activity Constraints ##############
*

equation AAC1_TotalAnnualTechnologyActivity(YEAR_FULL,TECHNOLOGY,REGION_FULL);
AAC1_TotalAnnualTechnologyActivity(y,t,r)$(CanBuildTechnology(y,t,r) > 0 and sum(f,ProductionByTechnologyAnnual.up(y,t,f,r)) > 0).. sum(f,ProductionByTechnologyAnnual(y,t,f,r)) =e= TotalTechnologyAnnualActivity(y,t,r);
TotalTechnologyAnnualActivity.fx(y,t,r)$(CanBuildTechnology(y,t,r) = 0 or sum(f,ProductionByTechnologyAnnual.up(y,t,f,r)) = 0) = 0;

equation AAC2_TotalAnnualTechnologyActivityUpperLimit(YEAR_FULL,TECHNOLOGY,REGION_FULL);
AAC2_TotalAnnualTechnologyActivityUpperLimit(y,t,r)$(TotalTechnologyAnnualActivityUpperLimit(r,t,y) < 999999).. TotalTechnologyAnnualActivity(y,t,r) =l= TotalTechnologyAnnualActivityUpperLimit(r,t,y);


equation AAC3_TotalAnnualTechnologyActivityLowerLimit(YEAR_FULL,TECHNOLOGY,REGION_FULL);
AAC3_TotalAnnualTechnologyActivityLowerLimit(y,t,r)$(TotalTechnologyAnnualActivityLowerLimit(r,t,y) > 0).. TotalTechnologyAnnualActivity(y,t,r) =g= TotalTechnologyAnnualActivityLowerLimit(r,t,y);

*
* ################ Total Activity Constraints ##############
*
equation TAC1_TotalModelHorizonTechnologyActivity(TECHNOLOGY,REGION_FULL);
TAC1_TotalModelHorizonTechnologyActivity(t,r).. sum(y, TotalTechnologyAnnualActivity(y,t,r)*YearlyDifferenceMultiplier(y)) =e= TotalTechnologyModelPeriodActivity(t,r);


equation TAC2_TotalModelHorizonTechnologyActivityUpperLimit(TECHNOLOGY,REGION_FULL);
TAC2_TotalModelHorizonTechnologyActivityUpperLimit(t,r)$(TotalTechnologyModelPeriodActivityUpperLimit(r,t) < 999999).. TotalTechnologyModelPeriodActivity(t,r) =l= TotalTechnologyModelPeriodActivityUpperLimit(r,t);


equation TAC3_TotalModelHorizonTechnologyActivityLowerLimit(YEAR_FULL,TECHNOLOGY,REGION_FULL);
TAC3_TotalModelHorizonTechnologyActivityLowerLimit(y,t,r)$(TotalTechnologyModelPeriodActivityLowerLimit(r,t) > 0).. TotalTechnologyModelPeriodActivity(t,r) =g= TotalTechnologyModelPeriodActivityLowerLimit(r,t);

*
* ############### Reserve Margin Constraint #############* NTS: Should change demand for production
*
equation RM1_ReserveMargin_TechologiesIncluded_In_Activity_Units(YEAR_FULL,TIMESLICE_FULL,REGION_FULL);
RM1_ReserveMargin_TechologiesIncluded_In_Activity_Units(y,l,r).. sum ((t,f), (sum(m$(OutputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity(y,l,t,m,r)*OutputActivityRatio(r,t,f,m,y)) * YearSplit(l,y) *ReserveMarginTagTechnology(r,t,y) * ReserveMarginTagFuel(r,f,y))) =e= TotalActivityInReserveMargin(r,y,l);
equation RM2_ReserveMargin_FuelsIncluded(YEAR_FULL,TIMESLICE_FULL,REGION_FULL);
RM2_ReserveMargin_FuelsIncluded(y,l,r).. sum (f, (sum((t,m)$(OutputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity(y,l,t,m,r)*OutputActivityRatio(r,t,f,m,y)) * YearSplit(l,y) * ReserveMarginTagFuel(r,f,y))) =e= DemandNeedingReserveMargin(y,l,r);
equation RM3_ReserveMargin_Constraint(YEAR_FULL,TIMESLICE_FULL,REGION_FULL);
RM3_ReserveMargin_Constraint(y,l,r)$(ReserveMargin(r,y) > 0).. DemandNeedingReserveMargin(y,l,r) * ReserveMargin(r,y) =l= TotalActivityInReserveMargin(r,y,l);

*
* ############### RE Production Target #############* NTS: Should change demand for production
*

equation RE1_ComputeTotalAnnualREProduction(YEAR_FULL,REGION_FULL,FUEL);
RE1_ComputeTotalAnnualREProduction(y,r,f).. sum(t$(TagTechnologyToSubsets(t,'Renewables')),ProductionByTechnologyAnnual(y,t,f,r)) =e= TotalREProductionAnnual(y,r,f);

equation RE2_AnnualREProductionLowerLimit(YEAR_FULL,REGION_FULL,FUEL);
RE2_AnnualREProductionLowerLimit(y,r,f).. REMinProductionTarget(r,f,y)*sum((l,t,m)$(OutputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity(y,l,t,m,r)*OutputActivityRatio(r,t,f,m,y)*YearSplit(l,y))*RETagFuel(f,y) =l= TotalREProductionAnnual(y,r,f);

equation RE3_RETargetPath(YEAR_FULL,REGION_FULL,FUEL);
RE3_RETargetPath(y,r,f)$(YearVal(y)>%year% and SpecifiedAnnualDemand(r,f,y) and SpecifiedAnnualDemand(r,f,y-1)).. TotalREProductionAnnual(y,r,f) =g= TotalREProductionAnnual(y-1,r,f)*((SpecifiedAnnualDemand(r,f,y)/SpecifiedAnnualDemand(r,f,y-1)));

*
* ################ Emissions Accounting ##############
*
equation E1_AnnualEmissionProductionByMode(YEAR_FULL,TECHNOLOGY,EMISSION,MODE_OF_OPERATION,REGION_FULL);
E1_AnnualEmissionProductionByMode(y,t,e,m,r)$(CanBuildTechnology(y,t,r) > 0).. EmissionActivityRatio(r,t,m,e,y)*sum(f,(TotalAnnualTechnologyActivityByMode(y,t,m,r)*EmissionContentPerFuel(f,e)*InputActivityRatio(r,t,f,m,y))) =e= AnnualTechnologyEmissionByMode(y,t,e,m,r);
AnnualTechnologyEmissionByMode.fx(y,t,e,m,r)$(CanBuildTechnology(y,t,r) = 0) = 0;

equation E2_AnnualEmissionProduction(YEAR_FULL,TECHNOLOGY,EMISSION,REGION_FULL);
E2_AnnualEmissionProduction(y,t,e,r).. sum(m, AnnualTechnologyEmissionByMode(y,t,e,m,r)) =e= AnnualTechnologyEmission(y,t,e,r);

equation E3_EmissionsPenaltyByTechAndEmission(YEAR_FULL,TECHNOLOGY,EMISSION,REGION_FULL);
E3_EmissionsPenaltyByTechAndEmission(y,t,e,r).. (AnnualTechnologyEmission(y,t,e,r)*EmissionsPenalty(r,e,y)*EmissionsPenaltyTagTechnology(r,t,e,y))*YearlyDifferenceMultiplier(y) =e= AnnualTechnologyEmissionPenaltyByEmission(y,t,e,r);
equation E4_EmissionsPenaltyByTechnology(YEAR_FULL,TECHNOLOGY,REGION_FULL);
E4_EmissionsPenaltyByTechnology(y,t,r).. sum(e, AnnualTechnologyEmissionPenaltyByEmission(y,t,e,r)) =e= AnnualTechnologyEmissionsPenalty(y,t,r);
equation E5_DiscountedEmissionsPenaltyByTechnology(YEAR_FULL,TECHNOLOGY,REGION_FULL);
E5_DiscountedEmissionsPenaltyByTechnology(y,t,r).. AnnualTechnologyEmissionsPenalty(y,t,r)/((1+SocialDiscountRate(r))**(YearVal(y)-smin(yy, YearVal(yy))+0.5)) =e= DiscountedTechnologyEmissionsPenalty(y,t,r);
equation E6_AnnualEmissionsAccounting(YEAR_FULL,EMISSION,REGION_FULL);
E6_AnnualEmissionsAccounting(y,e,r).. sum(t, AnnualTechnologyEmission(y,t,e,r)) =e= AnnualEmissions(y,e,r);

equation E7_ModelPeriodEmissionsAccounting(EMISSION,REGION_FULL);
$ifthen %switch_weighted_emissions% == 1
E7_ModelPeriodEmissionsAccounting(e,r)..
  sum(y$(YearVal(y+1)-YearVal(y) > 0), WeightedAnnualEmissions(y,e,r)*(YearVal(y+1)-YearVal(y)))
+ sum(y$(YearVal(y)=smax(yy,YearVal(yy))),  WeightedAnnualEmissions(y,e,r))
=e= ModelPeriodEmissions(r,e)- ModelPeriodExogenousEmission(r,e);
equation E7a_WeightedEmissions(year_full,EMISSION,REGION_FULL);
E7a_WeightedEmissions(y,e,r)$(YearVal(y)<smax(yy,YearVal(yy))).. (AnnualEmissions(y,e,r)+AnnualEmissions(y+1,e,r))/2 =e= WeightedAnnualEmissions(y,e,r);
equation E7b_WeightedLastYearEmissions(year_full,EMISSION,REGION_FULL);
E7b_WeightedLastYearEmissions(y,e,r)$(YearVal(y)=smax(yy,YearVal(yy))).. AnnualEmissions(y,e,r) =e= WeightedAnnualEmissions(y,e,r);

$else
E7_ModelPeriodEmissionsAccounting(e,r)..
sum(y$(YearVal(y+1)-YearVal(y) > 0), AnnualEmissions(y,e,r)*(YearVal(y+1)-YearVal(y)))
+ sum(y$(YearVal(y)=smax(yy,YearVal(yy))),  AnnualEmissions(y,e,r))
=e= ModelPeriodEmissions(r,e)- ModelPeriodExogenousEmission(r,e);
$endif

equation E8_RegionalAnnualEmissionsLimit(YEAR_FULL,EMISSION,REGION_FULL);
E8_RegionalAnnualEmissionsLimit(y,e,r).. AnnualEmissions(y,e,r)+AnnualExogenousEmission(r,e,y) =l= RegionalAnnualEmissionLimit(r,e,y);
equation E9_AnnualEmissionsLimit(YEAR_FULL,EMISSION);
E9_AnnualEmissionsLimit(y,e).. sum(r,AnnualEmissions(y,e,r)+AnnualExogenousEmission(r,e,y)) =l= AnnualEmissionLimit(e,y);
equation E10_ModelPeriodEmissionsLimit(EMISSION);
E10_ModelPeriodEmissionsLimit(e).. sum(r,ModelPeriodEmissions(r,e)) =l= ModelPeriodEmissionLimit(e);
equation E11_RegionalModelPeriodEmissionsLimit(REGION_FULL,EMISSION);
E11_RegionalModelPeriodEmissionsLimit(r,e)$(RegionalModelPeriodEmissionLimit(r,e) < 999999).. ModelPeriodEmissions(r,e) =l= RegionalModelPeriodEmissionLimit(r,e);

equation E12_AnnualSectorEmissions(YEAR_FULL,EMISSION,SECTOR,REGION_FULL);
E12_AnnualSectorEmissions(y,e,se,r).. sum(t$(TagTechnologyToSector(t,se) <> 0), AnnualTechnologyEmission(y,t,e,r)) =e= AnnualSectoralEmissions(y,e,se,r);

equation E13_AnnualSectorEmissionsLimit(YEAR_FULL,EMISSION,SECTOR);
E13_AnnualSectorEmissionsLimit(y,e,se).. sum(r, AnnualSectoralEmissions(y,e,se,r)) =l= AnnualSectoralEmissionLimit(e,se,y);

*
* ######### Storage Constraints #############
*

equation S1a_StorageLevelYearStartUpperLimit(REGION_FULL, STORAGE, YEAR_FULL);
S1a_StorageLevelYearStartUpperLimit(r,s,y).. StorageLevelYearStart(s,y,r) =l=  StorageLevelYearStartUpperLimit *
((sum(yy$(OperationalLifeStorage(s) >= Yearval(y)-Yearval(yy) and Yearval(y)-Yearval(yy) >= 0), NewStorageCapacity(s,yy,r))) + ResidualStorageCapacity(r,s,y));

equation S1b_StorageLevelYearStartLowerLimit(REGION_FULL, STORAGE, YEAR_FULL);
S1b_StorageLevelYearStartLowerLimit(r,s,y).. StorageLevelYearStart(s,y,r) =g=  StorageLevelYearStartLowerLimit *
((sum(yy$(OperationalLifeStorage(s) >= Yearval(y)-Yearval(yy) and Yearval(y)-Yearval(yy) >= 0), NewStorageCapacity(s,yy,r))) + ResidualStorageCapacity(r,s,y));

equation S2_StorageLevelTSStart(REGION_FULL, STORAGE, YEAR_FULL, TIMESLICE_FULL);
S2_StorageLevelTSStart(r,s,y, l)..  (StorageLevelTSStart(s,y,l-1,r) +
      (sum((t,m)$(TechnologyToStorage(t,s,m,y)>0), RateOfActivity(y,l-1,t,m,r) * TechnologyToStorage(t,s,m,y))
     - sum((t,m)$(TechnologyFromStorage(t,s,m,y)>0), RateOfActivity(y,l-1,t,m,r) / TechnologyFromStorage(t,s,m,y))) * YearSplit(l-1,y))$(ord(l) > 1)
     + (StorageLevelYearStart(s,y,r))$(ord(l) = 1)
=e= StorageLevelTSStart(s,y,l,r);

equation S3_StorageRefilling(REGION_FULL, STORAGE, YEAR_FULL);
S3_StorageRefilling(r,s,y)..
sum((l), (sum((t,m)$(TechnologyToStorage(t,s,m,y)>0), RateOfActivity(y,l,t,m,r) * TechnologyToStorage(t,s,m,y))
          - sum((t,m)$(TechnologyFromStorage(t,s,m,y)>0), RateOfActivity(y,l,t,m,r) / TechnologyFromStorage(t,s,m,y)))) =e= 0;

equation S4_StorageLevelYearFinish(STORAGE,YEAR_FULL,REGION_FULL);
S4_StorageLevelYearFinish(s,y,r).. StorageLevelYearStart(s,y,r) =e=  StorageLevelYearFinish(s,y,r);

equation S5a_StorageChargeLowerLimit(STORAGE,YEAR_FULL,TIMESLICE_FULL,REGION_FULL);
S5a_StorageChargeLowerLimit(s,y,l,r)$(MinStorageCharge(r,s,y) > 0)..
MinStorageCharge(r,s,y)*sum(yy$(yearval(y)-yearval(yy) < OperationalLifeStorage(s) and yearval(y)-yearval(yy) >= 0), NewStorageCapacity(s,y,r) + ResidualStorageCapacity(r,s,y))
=l= StorageLevelTSStart(s,y,l,r);

equation S5b_StorageChargeUpperLimit(STORAGE,YEAR_FULL,TIMESLICE_FULL,REGION_FULL);
S5b_StorageChargeUpperLimit(s,y,l,r)..
sum(yy$(yearval(y)-yearval(yy) < OperationalLifeStorage(s) and yearval(y)-yearval(yy) >= 0), NewStorageCapacity(s,y,r) + ResidualStorageCapacity(r,s,y))
=g= StorageLevelTSStart(s,y,l,r);

equation S6_StorageActivityLimit(STORAGE,TECHNOLOGY,YEAR_FULL,TIMESLICE_FULL,REGION_FULL,MODE_OF_OPERATION);
S6_StorageActivityLimit(s,t,y,l,r,m)$(TechnologyFromStorage(t,s,m,y)>0)..
RateOfActivity(y,l,t,m,r)/TechnologyFromStorage(t,s,m,y)*YearSplit(l,y) =l= StorageLevelTSStart(s,y,l,r);

equation SI1_UndiscountedCapitalInvestmentStorage(STORAGE,YEAR_FULL,REGION_FULL);
SI1_UndiscountedCapitalInvestmentStorage(s,y,r).. CapitalCostStorage(r,s,y) * NewStorageCapacity(s,y,r) =e= CapitalInvestmentStorage(s,y,r);
equation SI2_DiscountingCapitalInvestmentStorage(STORAGE,YEAR_FULL,REGION_FULL);
SI2_DiscountingCapitalInvestmentStorage(s,y,r)..  CapitalInvestmentStorage(s,y,r)/((1+GeneralDiscountRate(r))**(YearVal(y)-smin(yy, YearVal(yy))+0.5)) =e= DiscountedCapitalInvestmentStorage(s,y,r);
equation SI3a_SalvageValueStorageAtEndOfPeriod1(STORAGE,YEAR_FULL,REGION_FULL);
SI3a_SalvageValueStorageAtEndOfPeriod1(s,y,r)$((yearval(y)+OperationalLifeStorage(s)-1) le smax(yy, YearVal(yy)) )..    0 =e= SalvageValueStorage(s,y,r);
equation SI3b_SalvageValueStorageAtEndOfPeriod2(STORAGE,YEAR_FULL,REGION_FULL);
SI3b_SalvageValueStorageAtEndOfPeriod2(s,y,r)$((DepreciationMethod=1 and (yearval(y)+OperationalLifeStorage(s)-1) > smax(yy, YearVal(yy)) and GeneralDiscountRate(r)=0) or (DepreciationMethod=2 and (yearval(y)+OperationalLifeStorage(s)-1) > smax(yy, YearVal(yy)) and GeneralDiscountRate(r)=0)).. CapitalInvestmentStorage(s,y,r)*(1- smax(yy, YearVal(yy))  - yearval(y)+1)/OperationalLifeStorage(s) =e= SalvageValueStorage(s,y,r);
equation SI3c_SalvageValueStorageAtEndOfPeriod3(STORAGE,YEAR_FULL,REGION_FULL);
SI3c_SalvageValueStorageAtEndOfPeriod3(s,y,r)$(DepreciationMethod=1 and ((yearval(y)+OperationalLifeStorage(s)-1) > smax(yy, YearVal(yy)) and GeneralDiscountRate(r)>0)).. CapitalInvestmentStorage(s,y,r)*(1-(((1+GeneralDiscountRate(r))**(smax(yy, YearVal(yy)) - yearval(y)+1)-1)/((1+GeneralDiscountRate(r))**OperationalLifeStorage(s)-1))) =e= SalvageValueStorage(s,y,r);
equation SI4_SalvageValueStorageDiscountedToStartYear(STORAGE,YEAR_FULL,REGION_FULL);
SI4_SalvageValueStorageDiscountedToStartYear(s,y,r).. SalvageValueStorage(s,y,r)/((1+GeneralDiscountRate(r))**(1+smax(yy, YearVal(yy)) - smin(yy, YearVal(yy)))) =e= DiscountedSalvageValueStorage(s,y,r);
equation SI5_TotalDiscountedCostByStorage(STORAGE,YEAR_FULL,REGION_FULL);
SI5_TotalDiscountedCostByStorage(s,y,r).. DiscountedCapitalInvestmentStorage(s,y,r)-DiscountedSalvageValueStorage(s,y,r) =e= TotalDiscountedStorageCost(s,y,r);


*
* ######### Transportation Equations #############
*
equation T1_SpecifiedAnnualDemandByModalSplit(MODALTYPE,TIMESLICE_FULL,REGION_FULL,FUEL,YEAR_FULL);
T1_SpecifiedAnnualDemandByModalSplit(mt,l,r,f,y)$(SpecifiedAnnualDemand(r,f,y) and TagFuelToSubsets(f,'TransportFuels'))..  SpecifiedAnnualDemand(r,f,y)*ModalSplitByFuelAndModalType(r,f,mt,y)*SpecifiedDemandProfile(r,f,l,y) =e= DemandSplitByModalType(mt,l,r,f,y);

equation T2_ProductionOfTechnologyByModalSplit(MODALTYPE,TIMESLICE_FULL,REGION_FULL,FUEL,YEAR_FULL);
T2_ProductionOfTechnologyByModalSplit(mt,l,r,f,y)$(sum((t,m),TagTechnologyToModalType(t,m,mt)) and TagFuelToSubsets(f,'TransportFuels'))..  sum((t,m)$(OutputActivityRatio(r,t,f,m,y) <> 0),TagTechnologyToModalType(t,m,mt)*RateOfActivity(y,l,t,m,r)*OutputActivityRatio(r,t,f,m,y)*YearSplit(l,y)) =e= ProductionSplitByModalType(mt,l,r,f,y);

equation T3_ModalSplitBalance(MODALTYPE,TIMESLICE_FULL,REGION_FULL,FUEL,YEAR_FULL);
T3_ModalSplitBalance(mt,l,r,f,y)$(sum((t,m),TagTechnologyToModalType(t,m,mt)) and sum((t,m),OutputActivityRatio(r,t,f,m,y)) and TagFuelToSubsets(f,'TransportFuels')).. ProductionSplitByModalType(mt,l,r,f,y) =g= DemandSplitByModalType(mt,l,r,f,y);


$ifthen %switch_ramping% == 1
*
* ##############* Ramping #############
*
equation R1_ProductionChange(YEAR_FULL,TIMESLICE_FULL,FUEL,TECHNOLOGY,REGION_FULL);
R1_ProductionChange(y,l,f,t,r)$(ord(l) > 1 and TagDispatchableTechnology(t)=1 and (RampingUpFactor(t,y) <> 0 or RampingDownFactor(t,y) <> 0 and AvailabilityFactor(r,t,y) > 0 and TotalAnnualMaxCapacity(r,t,y) > 0 and TotalTechnologyModelPeriodActivityUpperLimit(r,t) > 0)).. ((sum(m$(OutputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity(y,l,t,m,r)*OutputActivityRatio(r,t,f,m,y))*YearSplit(l,y)) - ((sum(m$(OutputActivityRatio(r,t,f,m,y) <> 0),RateOfActivity(y,l-1,t,m,r)*OutputActivityRatio(r,t,f,m,y))*YearSplit(l-1,y)))) =e= ProductionUpChangeInTimeslice(y,l,f,t,r) - ProductionDownChangeInTimeslice(y,l,f,t,r);
equation R2_RampingUpLimit(YEAR_FULL,TIMESLICE_FULL,FUEL,TECHNOLOGY,REGION_FULL);
R2_RampingUpLimit(y,l,f,t,r)$(ord(l) > 1 and TagDispatchableTechnology(t)=1 and RampingUpFactor(t,y) <> 0 and AvailabilityFactor(r,t,y) > 0 and TotalAnnualMaxCapacity(r,t,y) > 0 and TotalTechnologyModelPeriodActivityUpperLimit(r,t) > 0).. ProductionUpChangeInTimeslice(y,l,f,t,r) =l= TotalCapacityAnnual(y,t,r)*AvailabilityFactor(r,t,y)*CapacityToActivityUnit(t)*RampingUpFactor(t,y)*YearSplit(l,y);
equation R3_RampingDownLimit(YEAR_FULL,TIMESLICE_FULL,FUEL,TECHNOLOGY,REGION_FULL);
R3_RampingDownLimit(y,l,f,t,r)$(ord(l) > 1 and TagDispatchableTechnology(t)=1 and RampingDownFactor(t,y) <> 0 and AvailabilityFactor(r,t,y) > 0 and TotalAnnualMaxCapacity(r,t,y) > 0 and TotalTechnologyModelPeriodActivityUpperLimit(r,t) > 0).. ProductionDownChangeInTimeslice(y,l,f,t,r) =l= TotalCapacityAnnual(y,t,r)*AvailabilityFactor(r,t,y)*CapacityToActivityUnit(t)*RampingDownFactor(t,y)*YearSplit(l,y);

*
* ##############* Ramping Costs #############
*
equation RC1_AnnualProductionChangeCosts(YEAR_FULL,FUEL,TECHNOLOGY,REGION_FULL);
RC1_AnnualProductionChangeCosts(y,f,t,r)$(TagDispatchableTechnology(t)=1 and ProductionChangeCost(t,y) <> 0 and AvailabilityFactor(r,t,y) > 0 and TotalAnnualMaxCapacity(r,t,y) > 0 and TotalTechnologyModelPeriodActivityUpperLimit(r,t) > 0).. sum(l,(ProductionUpChangeInTimeslice(y,l,f,t,r) + ProductionDownChangeInTimeslice(y,l,f,t,r))*ProductionChangeCost(t,y)) =e= AnnualProductionChangeCost(y,t,r);
equation RC2_DiscountedAnnualProductionChangeCost(YEAR_FULL,FUEL,TECHNOLOGY,REGION_FULL);
RC2_DiscountedAnnualProductionChangeCost(y,f,t,r)$(TagDispatchableTechnology(t)=1 and ProductionChangeCost(t,y) <> 0 and AvailabilityFactor(r,t,y) > 0 and TotalAnnualMaxCapacity(r,t,y) > 0 and TotalTechnologyModelPeriodActivityUpperLimit(r,t) > 0).. AnnualProductionChangeCost(y,t,r)/((1+TechnologyDiscountRate(r,t))**(YearVal(y)-smin(yy, YearVal(yy))+0.5)) =e= DiscountedAnnualProductionChangeCost(y,t,r);

DiscountedAnnualProductionChangeCost.fx(y,t,r)$(TagDispatchableTechnology(t) = 0 or sum((m,f), OutputActivityRatio(r,t,f,m,y)) = 0 or ProductionChangeCost(t,y) = 0 or AvailabilityFactor(r,t,y) = 0 or TotalAnnualMaxCapacity(r,t,y) = 0 or TotalTechnologyModelPeriodActivityUpperLimit(r,t) = 0) = 0;
AnnualProductionChangeCost.fx(y,t,r)$(TagDispatchableTechnology(t) = 0 or sum((m,f), OutputActivityRatio(r,t,f,m,y)) = 0 or ProductionChangeCost(t,y) = 0 or AvailabilityFactor(r,t,y) = 0 or TotalAnnualMaxCapacity(r,t,y) = 0 or TotalTechnologyModelPeriodActivityUpperLimit(r,t) = 0) = 0;

*
* ##############* Min Runing Constraint #############
*
equation MRC1_MinRunningConstraint(YEAR_FULL,TIMESLICE_FULL,FUEL,TECHNOLOGY,REGION_FULL);
MRC1_MinRunningConstraint(y,l,f,t,r)$(MinActiveProductionPerTimeslice(y,l,f,t,r) > 0).. sum(m$(OutputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity(y,l,t,m,r)*OutputActivityRatio(r,t,f,m,y)) =g= TotalCapacityAnnual(y,t,r)*AvailabilityFactor(r,t,y)*CapacityToActivityUnit(t)*MinActiveProductionPerTimeslice(y,l,f,t,r);

$endif


*
* ##############* Curtailment Costs #############
*

equation CC1_AnnualCurtailmentCosts(YEAR_FULL,FUEL,REGION_FULL);
CC1_AnnualCurtailmentCosts(y,f,r).. CurtailedEnergyAnnual(y,f,r)*CurtailmentCostFactor =e= AnnualCurtailmentCost(y,f,r);
equation CC2_DiscountedAnnualCurtailmentCosts(YEAR_FULL,FUEL,REGION_FULL);
CC2_DiscountedAnnualCurtailmentCosts(y,f,r).. AnnualCurtailmentCost(y,f,r)/((1+GeneralDiscountRate(r))**(YearVal(y)-smin(yy, YearVal(yy))+0.5)) =e= DiscountedAnnualCurtailmentCost(y,f,r);



$ifthen %switch_base_year_bounds% == 1
*
* ##############* General BaseYear Limits and trajectories #############
*

$ifthen %switch_base_year_bounds_debugging% == 0
BaseYearBounds_TooHigh.fx(y,r,t,f) = 0;
BaseYearBounds_TooLow.fx(y,r,t,f) = 0;
$endif

equation BYB1_RegionalBaseYearProductionLowerBound(YEAR_FULL,REGION_FULL,t,f);
BYB1_RegionalBaseYearProductionLowerBound(y,r,t,f)$(RegionalBaseYearProduction(r,t,f,y) <> 0).. ProductionByTechnologyAnnual(y,t,f,r) =g= RegionalBaseYearProduction(r,t,f,y)*(1-BaseYearSlack(f))  - BaseYearBounds_TooHigh(y,r,t,f);

equation BYB2_RegionalBaseYearProductionUpperBound(YEAR_FULL,REGION_FULL,t,f);
BYB2_RegionalBaseYearProductionUpperBound(y,r,t,f)$(RegionalBaseYearProduction(r,t,f,y) <> 0).. ProductionByTechnologyAnnual(y,t,f,r) =l= RegionalBaseYearProduction(r,t,f,y) + BaseYearBounds_TooLow(y,r,t,f);

$endif

*
* ######### Peaking Equations #############
*
$ifthen.equ_peaking_capacity %switch_peaking_capacity% == 1
positive variable PeakingDemand(YEAR_FULL,REGION_FULL);
positive variable PeakingCapacity(YEAR_FULL,REGION_FULL);
scalar GWh_to_PJ /0.0036/;
scalar PeakingSlack /%set_peaking_slack%/;
scalar MinRunShare /%set_peaking_minrun_share%/;
scalar RenewableCapacityFactorReduction /%set_peaking_res_cf%/;
scalar MinThermalShare /%set_peaking_min_thermal%/;

equation PC1_PowerPeakingDemand(YEAR_FULL,REGION_FULL);
PC1_PowerPeakingDemand(y,r)..
PeakingDemand(y,r) =e=
  sum((se,t)$(x_peakingDemand(r,se) and TagTechnologyToSector(t,se) and sum((s,m),TechnologyToStorage(t,s,m,y)) = 0),
    UseByTechnologyAnnual(y,t,'power',r)/GWh_to_PJ*x_peakingDemand(r,se)/8760
*     Demand per Year in PJ             to Gwh     Highest peak hour value   /number hours per year
  ) + SpecifiedAnnualDemand(r,'power',y)/GWh_to_PJ*x_peakingDemand(r,'power')/8760
;

equation PC2_PowerPeakingCapacity(YEAR_FULL,REGION_FULL);
PC2_PowerPeakingCapacity(y,r)..
PeakingCapacity(y,r) =e=
  sum((t)$(sum(m,OutputActivityRatio(r,t,'power',m,y)) and sum((s,m),TechnologyToStorage(t,s,m,y)) = 0),
    (TotalCapacityAnnual(y,t,r)*AvailabilityFactor(r,t,y)*RenewableCapacityFactorReduction*(sum(l,CapacityFactor(r,t,l,y))/card(l)))$(sum(l,CapacityFactor(r,t,l,y)) < card(l))
  + (TotalCapacityAnnual(y,t,r)*AvailabilityFactor(r,t,y))$(sum(l,CapacityFactor(r,t,l,y)) >= card(l))
  )
;

equation PC3_PeakingConstraint(YEAR_FULL,REGION_FULL);
PC3_PeakingConstraint(y,r)$(YearVal(y) > %set_peaking_startyear%)..
  PeakingCapacity(y,r)
$ifthen.equ_peaking_with_trade %switch_peaking_with_trade% == 1
+ sum(rr,TotalTradeCapacity(y,'Power',rr,r))
$endif.equ_peaking_with_trade
$ifthen.equ_peaking_with_storages %switch_peaking_with_storages% == 1
+ sum(t$(sum(m,OutputActivityRatio(r,t,'power',m,y)) and sum((s,m),TechnologyToStorage(t,s,m,y))), TotalCapacityAnnual(y,t,r))
$endif.equ_peaking_with_storages
=g= PeakingDemand(y,r)*PeakingSlack
;

*$ifthen.equ_peaking_minThermal %switch_peaking_with_storages% == 1
*equation PC3b_PeakingConstraint_Thermal(YEAR_FULL,REGION_FULL);
*PC3b_PeakingConstraint_Thermal(y,r).. PeakingCapacity(y,r) =g= MinThermalShare*PeakingDemand(y,r)*PeakingSlack;
*$endif.equ_peaking_minThermal

$ifthen.equ_peaking_minrun %switch_peaking_minrun% == 1
equation PC4_MinRunConstraint(YEAR_FULL,TECHNOLOGY,REGION_FULL);
PC4_MinRunConstraint(y,t,r)$(TagTechnologyToSector(t,'Power')=1 and AvailabilityFactor(r,t,y)<=1 and TagDispatchableTechnology(t)=1 and AvailabilityFactor(r,t,y) > 0 and TotalAnnualMaxCapacity(r,t,y) > 0 and TotalTechnologyModelPeriodActivityUpperLimit(r,t) > 0 and TotalCapacityAnnual.up(y,t,r) > 0 and YearVal(y) > %set_peaking_startyear%)..
sum(l, sum(m, RateOfActivity(y,l,t,m,r))*YearSplit(l,y)) =g= sum(l,TotalCapacityAnnual(y,t,r)*CapacityFactor(r,t,l,y)*YearSplit(l,y)*AvailabilityFactor(r,t,y)*CapacityToActivityUnit(t))*MinRunShare;
$endif.equ_peaking_minrun

$endif.equ_peaking_capacity

*
* ##############* Employment effects #############
*
$ifthen %switch_endogenous_employment% == 1
positive variable TotalJobs(r_full,y_full);

$include genesysmod_employment.gms

equation ADD_Employment(r_full,y_full);
ADD_Employment(r,y)..  sum((t,f),((NewCapacity(y,t,r)*EFactorManufacturing(t,y)*RegionalAdjustmentFactor('%model_region%',y)*LocalManufacturingFactor('%model_region%',y))
                 +(NewCapacity(y,t,r)*EFactorConstruction(t,y)*RegionalAdjustmentFactor('%model_region%',y))
                 +(TotalCapacityAnnual(y,t,r)*EFactorOM(t,y)*RegionalAdjustmentFactor('%model_region%',y))
                 +(UseByTechnologyAnnual(y,t,f,r)*EFactorFuelSupply(t,y)))*(1-DeclineRate(t,y))**YearlyDifferenceMultiplier(y)
                 +((UseByTechnologyAnnual(y,'HLI_Hardcoal','Hardcoal',r)+UseByTechnologyAnnual(y,'HMI_HardCoal','Hardcoal',r)
                 +(UseByTechnologyAnnual(y,'HHI_BF_BOF','Hardcoal',r))*EFactorCoalJobs('Coal_Heat',y)*CoalSupply(r,y)))
                 +(CoalSupply(r,y)*CoalDigging('%model_region%','Coal_Export','%emissionPathway%_%emissionScenario%',y)*EFactorCoalJobs('Coal_Export',y)))
                 =e= TotalJobs(r,y);
$endif


