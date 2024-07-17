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

*
* ###### Eventually move to input data file ######
*
* Adds (negligible) variable costs to transport technologies, since they only had fuel costs before
* This is to combat strange "curtailment" effects of some transportation technologies
VariableCost(r,t,m,y)$(TagTechnologyToSubsets(t,'Transport')) = 0.09;

* Relevant for Europe due to unimplemented data
*CommissionedTradeCapacity(y,f,r,rr) = 0;

TradeCosts('ETS',r,rr)$(not TradeCosts('ETS',r,rr)) = 0.01;
VariableCost(r,t,m,y)$(not VariableCost(r,t,m,y)) = 0.01;


ModelPeriodExogenousEmission(REGION,EMISSION) = 0;
REMinProductionTarget(r,f,y) = 0;

SelfSufficiency(y, f, r) = 0;
*
* ##############################################################


*
* ####### Default Values #############
*
*needs to be removed, now in data
RETagTechnology(t,y)$(TagTechnologyToSubsets(t,'Renewables')) = 1;
*needs to be removed, now in data
RETagFuel('Power',y) = 1;
RETagFuel('Heat_Low_Residential',y) = 1;
RETagFuel('Heat_Low_Industrial',y) = 1;
RETagFuel('Heat_Medium_Industrial',y) = 1;
RETagFuel('Heat_High_Industrial',y) = 1;

TotalAnnualMaxCapacityInvestment(r,t,y) = 999999;
TotalAnnualMinCapacityInvestment(r,t,y) = 0 ;
TotalTechnologyModelPeriodActivityUpperLimit(r,t) = 999999;
TotalTechnologyModelPeriodActivityLowerLimit(r,t) = 0;
TotalTechnologyAnnualActivityUpperLimit(r,t,y)$(TotalTechnologyAnnualActivityUpperLimit(r,t,y) = 0) = 999999;

*** Same thing, only for resource limits
TotalTechnologyModelPeriodActivityUpperLimit(r,t)$(TagTechnologyToSubsets(t,'FossilFuelGeneration') and not sameas('R_Nuclear',t)) = Readin_TotalTechnologyModelPeriodActivityUpperLimit(r,t);

parameter YearlyDifferenceMultiplier(YEAR_FULL);
YearlyDifferenceMultiplier(y) = max(1,YearVal(y+1)-YearVal(y));

scalar hour_steps;
hour_steps = mod(%elmod_nthhour%,24);
scalar start_hour /%elmod_starthour%/;

*marginal costs for better numerical stability
CapitalCost(r,t,y)$(CapitalCost(r,t,y) = 0) = 0.01;


*
* ####### Bounds for non-supply technologies #############
*
TotalAnnualMaxCapacity(r,t,y)$(TagTechnologyToSubsets(t,'Transformation')and not (sameas('HLR_Heatpump_Geo_Deep',t) or sameas('HLR_Heatpump_Geo_Surface',t) or sameas('D_SCS_H2',t))) = 999999;
TotalAnnualMaxCapacity(r,t,y)$(TagTechnologyToSubsets(t,'FossilPower')) = 999999;
TotalAnnualMaxCapacity(r,t,y)$(TagTechnologyToSubsets(t,'FossilFuelGeneration')) = 999999;
TotalAnnualMaxCapacity(r,t,y)$(TagTechnologyToSubsets(t,'CHP')) = 999999;
TotalAnnualMaxCapacity(r,t,y)$(TagTechnologyToSubsets(t,'Transport')) = 999999;
TotalAnnualMaxCapacity(r,t,y)$(TagTechnologyToSubsets(t,'ImportTechnology')) = 999999;
TotalAnnualMaxCapacity(r,t,y)$(TagTechnologyToSubsets(t,'Biomass')) = 999999;
TotalAnnualMaxCapacity(r,'P_Biomass',y) = 999999;
*TotalAnnualMaxCapacity(r,'X_H2_blend_to_H2',y) = 999999;
*TotalAnnualMaxCapacity(r,'X_H2_to_H2_blend',y) = 999999;

AvailabilityFactor(r,t,y)$(TagTechnologyToSubsets(t,'ImportTechnology')) = 1;
CapacityFactor(r,t,l,y)$(TagTechnologyToSubsets(t,'ImportTechnology')) = 1 ;
OperationalLife(t)$(TagTechnologyToSubsets(t,'ImportTechnology')) = 1 ;
TotalTechnologyModelPeriodActivityUpperLimit(r,t)$(TagTechnologyToSubsets(t,'ImportTechnology')) = 999999;

TotalAnnualMaxCapacity(r,t,y)$(ResidualCapacity(r,t,y) > TotalAnnualMaxCapacity(r,t,y)) = ResidualCapacity(r,t,y);

AnnualSectoralEmissionLimit(e,se,y)$(not AnnualSectoralEmissionLimit(e,se,y)) = 999999;

*** ReserveMargin initialization
ReserveMargin(r,y)$(not ReserveMargin(r,y)) = 0;


*
* ####### Bounds for storage technologies #############
*
StorageLevelTSStart.fx('S_Battery_Li-Ion',y,l,r)$(mod((ord(l)+(start_hour/hour_steps)),(24/hour_steps)) = 0) = 0;
StorageLevelTSStart.fx('S_Battery_Redox',y,l,r)$(mod((ord(l)+(start_hour/hour_steps)),(24/hour_steps)) = 0) = 0;
StorageLevelTSStart.fx('S_Heat_HLR',y,l,r)$(mod((ord(l)+(start_hour/hour_steps)),(24/hour_steps)) = 0) = 0;
StorageLevelTSStart.fx('S_Heat_HLI',y,l,r)$(mod((ord(l)+(start_hour/hour_steps)),(24/hour_steps)) = 0) = 0;
*StorageLevelTSStart.fx('S_CAES',y,l,r)$(mod((ord(l)+(start_hour/hour_steps)),(48/hour_steps)) = 0) = 0;


** This scales the capital cost of storage according to the number of days in the model.
*CapitalCostStorage(r,s,y) = CapitalCostStorage(r,s,y)/365*8760/%elmod_nthhour%/(24/hour_steps);

*equation Add_E2PRatio_up(STORAGE,YEAR_FULL,REGION_FULL);
*Add_E2PRatio_up(s,y,r).. StorageUpperLimit(s,y,r) =l=  sum((t,m)$(TechnologyToStorage(t,s,m,y)),  TotalCapacityAnnual(y,t,r) * StorageE2PRatio(s) * 0.0036 * 3);

*equation Add_E2PRatio_low(STORAGE,YEAR_FULL,REGION_FULL);
*Add_E2PRatio_low(s,y,r).. StorageUpperLimit(s,y,r) =g=  sum((t,m)$(TechnologyToStorage(t,s,m,y)),  TotalCapacityAnnual(y,t,r) * StorageE2PRatio(s) * 0.0036 * 0.5);


*
* ####### Capacity factor for heat technologies #############
*
CapacityFactor(r,t,l,y)$(sum(ll,CapacityFactor(r,t,ll,y) = 0 and TagTechnologyToSubsets(t,'Heat'))) = 1;
CapacityFactor(r,'RES_PV_Rooftop_Commercial',l,y) = CapacityFactor(r,'RES_PV_Utility_Avg',l,y) ;
CapacityFactor(r,'RES_PV_Rooftop_Residential',l,y) = CapacityFactor(r,'RES_PV_Utility_Avg',l,y) ;
CapacityFactor(r,'RES_CSP',l,y) = CapacityFactor(r,'RES_PV_Utility_Opt',l,y) ;
CapacityFactor(r,'HLR_Solar_Thermal',l,y) = CapacityFactor(r,'RES_PV_Utility_Avg',l,y) ;
CapacityFactor(r,'HLI_Solar_Thermal',l,y) = CapacityFactor(r,'RES_PV_Utility_Avg',l,y) ;

CapacityFactor(r,'HLR_Solar_Thermal',l,y)$(CapacityFactor(r,'RES_PV_Utility_Avg',l,y)=0) = 0.00001;
CapacityFactor(r,'HLI_Solar_Thermal',l,y)$(CapacityFactor(r,'RES_PV_Utility_Avg',l,y)=0) = 0.00001;


*
* ####### No new capacity construction in 2015 #############
*
NewCapacity.fx('%year%',t,r)$(TagTechnologyToSubsets(t,'Transformation')) = 0;
NewCapacity.fx('%year%',t,r)$(TagTechnologyToSubsets(t,'PowerSupply')) = 0;
NewCapacity.fx('%year%',t,r)$(TagTechnologyToSubsets(t,'SectorCoupling')) = 0;
NewCapacity.fx('%year%',t,r)$(TagTechnologyToSubsets(t,'StorageDummies')) = 0;

NewCapacity.up('%year%',t,r)$(TagTechnologyToSubsets(t,'Biomass')) = +INF;
NewCapacity.up('%year%','HLR_Gas_Boiler',r) = +INF;
NewCapacity.up('%year%','HLI_Gas_Boiler',r) = +INF;
NewCapacity.up('%year%','HHI_BF_BOF',r) = +INF;
NewCapacity.up('%year%','HHI_Bio_BF_BOF',r) = +INF;
NewCapacity.up('%year%','HHI_Scrap_EAF',r) = +INF;
NewCapacity.up('%year%','HHI_DRI_EAF',r) = +INF;
NewCapacity.up('%year%',t,r)$(TagTechnologyToSubsets(t,'CHP')) = +INF;
NewCapacity.up('%year%','D_Gas_Methane',r) = +INF;

ReserveMargin('DE_HB','2018') = 0;



*
* ####### Dispatch and Curtailment #############
*
TagDispatchableTechnology(TECHNOLOGY) = 1;
TagDispatchableTechnology(t)$(TagTechnologyToSubsets(t,'Solar')) = 0;
TagDispatchableTechnology(t)$(TagTechnologyToSubsets(t,'Wind')) = 0;
AvailabilityFactor(REGION,t,y)$(TagTechnologyToSubsets(t,'Solar')) = 1;
*TagDispatchableTechnology(t)$(TagTechnologyToSubsets(t,'Transport')) = 0;
TagDispatchableTechnology('RES_Hydro_Small') = 0;


CurtailmentCostFactor = 0.1;

*
* ####### Dummy-Technologies [enable for test purposes, if model runs infeasible] #############
*
DummyTechnology('Infeasibility_HLI') = yes;
DummyTechnology('Infeasibility_HMI') = yes;
DummyTechnology('Infeasibility_HHI') = yes;
DummyTechnology('Infeasibility_HRI') = yes;
DummyTechnology('Infeasibility_Power') = yes;
DummyTechnology('Infeasibility_Mob_Passenger') = yes;
DummyTechnology('Infeasibility_Mob_Freight') = yes;
TagTechnologyToSector(DummyTechnology,'Infeasibility') = 1;
AvailabilityFactor(r,DummyTechnology,y) = 0;


*
* ####### infeasibility technologies default values #############
*
$ifthen %switch_infeasibility_tech% == 1
OutputActivityRatio(REGION,'Infeasibility_HLI','Heat_Low_Industrial','1',y) = 1;
OutputActivityRatio(REGION,'Infeasibility_HMI','Heat_Medium_Industrial','1',y) = 1;
OutputActivityRatio(REGION,'Infeasibility_HHI','Heat_High_Industrial','1',y) = 1;
OutputActivityRatio(REGION,'Infeasibility_HRI','Heat_Low_Residential','1',y) = 1;
OutputActivityRatio(REGION,'Infeasibility_Power','Power','1',y) = 1;
OutputActivityRatio(REGION,'Infeasibility_Mob_Passenger','Mobility_Passenger','1',y) = 1 ;
OutputActivityRatio(REGION,'Infeasibility_Mob_Freight','Mobility_Freight','1',y) = 1 ;

CapacityToActivityUnit(DummyTechnology) = 31.56;
TotalAnnualMaxCapacity(r,DummyTechnology,y) = 999999;

FixedCost(r,DummyTechnology,y) = 999;
CapitalCost(r,DummyTechnology,y) = 999;
VariableCost(r,DummyTechnology,m,y) = 999;
AvailabilityFactor(r,DummyTechnology,y) = 1;
CapacityFactor(r,DummyTechnology,l,y) = 1 ;
OperationalLife(DummyTechnology) = 1 ;
EmissionActivityRatio(r,DummyTechnology,m,e,y) = 0;
$endif


*
* ####### CCS #############
*
$ifthen %switch_ccs% == 1
AvailabilityFactor(r,t,y)$(TagTechnologyToSubsets(t,'CCS')) = 0;
AvailabilityFactor(r,t,y)$(YearVal(y) > 2020 and RegionalCCSLimit(r) and TagTechnologyToSubsets(t,'CCS')) = 0.95;

TotalAnnualMaxCapacity(r,t,y)$(TagTechnologyToSubsets(t,'CCS')) = 99999;
TotalAnnualMaxCapacity(r,t,y)$(AvailabilityFactor(r,t,y) = 0 and TagTechnologyToSubsets(t,'CCS')) = 0;

TotalTechnologyAnnualActivityUpperLimit(r,t,y)$(TagTechnologyToSubsets(t,'CCS')) = 99999;
TotalTechnologyAnnualActivityUpperLimit(r,t,y)$(AvailabilityFactor(r,t,y) = 0 and TagTechnologyToSubsets(t,'CCS')) = 0;

ProductionByTechnologyAnnual.up(y,t,f,r)$(TagTechnologyToSubsets(t,'CCS')) = +INF;
ProductionByTechnologyAnnual.fx(y,t,f,r)$(AvailabilityFactor(r,t,y) = 0 and TagTechnologyToSubsets(t,'CCS')) = 0;

TotalAnnualMaxCapacity(r,'A_Air',y) = 99999;
TotalTechnologyAnnualActivityUpperLimit(r,'A_Air',y) = 99999;

EmissionActivityRatio(r,'X_DAC_HT',m,e,y) = -1;
EmissionActivityRatio(r,'X_DAC_LT',m,e,y) = -1;

$else

AvailabilityFactor(r,t,y)$(TagTechnologyToSubsets(t,'CCS')) = 0;
TotalAnnualMaxCapacity(r,t,y)$(TagTechnologyToSubsets(t,'CCS')) = 0;
ProductionByTechnologyAnnual.fx(y,t,f,r)$(TagTechnologyToSubsets(t,'CCS')) = 0;
$endif



