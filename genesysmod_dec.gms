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
$offOrder

set TIMESLICE_FULL Every hour of the year /1*8760/;
alias (l_full,ll_full,TIMESLICE_FULL);

set TIMESLICE(l_full) Subset of hours that got chosen via the timeseries reduction algorithm;
alias (l,ll,TIMESLICE);

Set YEAR_FULL All possible years inside GENeSYS-MOD /2015*2100/;
alias (y_full, yy_full, YEAR_FULL);

set YEAR(y_full) All years for which computation should actually happen;
alias (y,yy,YEAR);

set REGION_FULL All regions included in the input data;
alias (REGION_FULL,r_full,rr_full);

set REGION(REGION_FULL) Subset of regions for which computation should actually happen;
alias (REGION,r,rr)

set TECHNOLOGY List of all available technologies
               /Infeasibility_Power,
                Infeasibility_H2,
                Infeasibility_HLI,
                Infeasibility_HMI,
                Infeasibility_HHI,
                Infeasibility_HRI,
                Infeasibility_Mob_Passenger,
                Infeasibility_Mob_Freight,
                Infeasibility_Natural_Gas /;
alias (t,TECHNOLOGY);

set DummyTechnology(TECHNOLOGY) Subset of technologies that serve as infeasibility helpers;

set FUEL List of all fuels or energy carriers;
alias (f,ff,FUEL);
set SECTOR List of all sectors /Infeasibility/;
alias (se,sse,SECTOR);
set EMISSION All considered emissions;
alias (e,EMISSION);
set MODE_OF_OPERATION List of possible operation modes for the different technologies;
alias (m,MODE_OF_OPERATION);
set STORAGE List of different storage technologies in GENeSYS-MOD;
alias (s,STORAGE);

set MODALTYPE List of all modal types for transport;
alias (mt,MODALTYPE);

*
* ####################
* # Parameters #
* ####################
*
* ####### Global #############
*
parameter StartYear Defines the first year of the modeling horizon;
parameter YearSplit(TIMESLICE_FULL,y_full) Defines the length of one timeslice as a fraction of the year. Unit: Percent;
parameter GeneralDiscountRate(REGION_FULL) Defines the discountrate to be used for general infrastructure investments. Unit: Percent;
parameter SocialDiscountRate(REGION_FULL) Defines the discountrate to be used for negative externalities for emissions. Unit: Percent;
parameter TechnologyDiscountRate(REGION_FULL,TECHNOLOGY) Defines the discountrate to be used for technology investments. Unit: Percent;
parameter DepreciationMethod Defines the method to use for depreciation of assets. Options: 1 or 2;

*
* ####### Demands #############
*
parameter SpecifiedAnnualDemand(REGION_FULL,FUEL,y_full) Defines the total demand for a fuel (either in energy or a proxy) across the year. Unit: PJ or km;
parameter SpecifiedDemandDevelopment(REGION_FULL,FUEL,y_full) Defines the change in energy demand per year between modeled years;
parameter SpecifiedDemandProfile(REGION_FULL,FUEL,TIMESLICE_FULL,y_full) Defines the relative demand per timeslice as a fraction of the total annual demand. Unit: Percent;
parameter RateOfDemand(y_full,TIMESLICE_FULL,FUEL,REGION_FULL) Rate of demand in given timeslice. Unit: GW;
parameter Demand(y_full,TIMESLICE_FULL,FUEL,REGION_FULL) Fuel demand for each timeslice. Unit: PJ (except for transport);

*
* ######## Technology Performance #############
*
parameter CapacityToActivityUnit(TECHNOLOGY);
parameter CapacityFactor(REGION_FULL,TECHNOLOGY,TIMESLICE_FULL,y_full);
parameter AvailabilityFactor(REGION_FULL,TECHNOLOGY,y_full);
parameter OperationalLife(TECHNOLOGY);
parameter ResidualCapacity(REGION_FULL,TECHNOLOGY,y_full);
parameter InputActivityRatio(REGION_FULL,TECHNOLOGY,FUEL,MODE_OF_OPERATION,y_full);
parameter OutputActivityRatio(REGION_FULL,TECHNOLOGY,FUEL,MODE_OF_OPERATION,y_full);
parameter CapacityOfOneTechnologyUnit(y_full, TECHNOLOGY, REGION_FULL);
parameter TagDispatchableTechnology(TECHNOLOGY);
parameter BaseYearProduction(TECHNOLOGY,FUEL,YEAR_FULL);
parameter RegionalBaseYearProduction(REGION_FULL,TECHNOLOGY,FUEL,YEAR_FULL);
parameter TagElectricTechnology(TECHNOLOGY);
parameter TagTechnologyToSubsets(TECHNOLOGY,*);
parameter TagFuelToSubsets(FUEL,*);
parameter TimeDepEfficiency(REGION_FULL,TECHNOLOGY,TIMESLICE_FULL,YEAR_FULL) Time dependent efficiency for technologies like heatpumps;


parameter RegionalCCSLimit(REGION_FULL);

*
* ######## Technology Costs #############
*
parameter CapitalCost(REGION_FULL,TECHNOLOGY,YEAR_FULL);
parameter VariableCost(REGION_FULL,TECHNOLOGY,MODE_OF_OPERATION,YEAR_FULL);
parameter FixedCost(REGION_FULL,TECHNOLOGY,YEAR_FULL);

*
* ######## Storage Parameters #############
*
parameter StorageLevelStart(REGION_FULL,STORAGE);
parameter MinStorageCharge(REGION_FULL,STORAGE,YEAR_FULL);
parameter OperationalLifeStorage(STORAGE);
parameter CapitalCostStorage(REGION_FULL,STORAGE,YEAR_FULL);
parameter ResidualStorageCapacity(REGION_FULL,STORAGE,YEAR_FULL);
parameter TechnologyToStorage(TECHNOLOGY,STORAGE,MODE_OF_OPERATION,YEAR_FULL);
parameter TechnologyFromStorage(TECHNOLOGY,STORAGE,MODE_OF_OPERATION,YEAR_FULL);

parameter StorageMaxCapacity(REGION_FULL,STORAGE,YEAR_FULL);
parameter StorageE2PRatio(STORAGE);

*
* ######## Capacity Constraints #############
*
parameter TotalAnnualMaxCapacity(REGION_FULL,TECHNOLOGY,YEAR_FULL);
parameter TotalAnnualMinCapacity(REGION_FULL,TECHNOLOGY,YEAR_FULL);
parameter NewCapacityExpansionStop(REGION_FULL,TECHNOLOGY);
parameter AnnualMinNewCapacity(REGION_FULL,TECHNOLOGY,YEAR_FULL);
parameter AnnualMaxNewCapacity(REGION_FULL,TECHNOLOGY,YEAR_FULL);

*
* ######### SectoralEmissions #############
*
parameter TagTechnologyToSector(TECHNOLOGY,SECTOR);
parameter AnnualSectoralEmissionLimit(EMISSION,SECTOR,YEAR_FULL);
parameter TagDemandFuelToSector(FUEL,SECTOR);

*
* ######## Investment Constraints #############
*
parameter TotalAnnualMaxCapacityInvestment(REGION_FULL,TECHNOLOGY,YEAR_FULL);
parameter TotalAnnualMinCapacityInvestment(REGION_FULL,TECHNOLOGY,YEAR_FULL);

*
* ######## Activity Constraints #############
*
parameter TotalTechnologyAnnualActivityUpperLimit(REGION_FULL,TECHNOLOGY,YEAR_FULL);
parameter TotalTechnologyAnnualActivityLowerLimit(REGION_FULL,TECHNOLOGY,YEAR_FULL);
parameter TotalTechnologyModelPeriodActivityUpperLimit(REGION_FULL,TECHNOLOGY);
parameter TotalTechnologyModelPeriodActivityLowerLimit(REGION_FULL,TECHNOLOGY);

*
* ######## Reserve Margin ############
*
parameter ReserveMarginTagTechnology(REGION_FULL,TECHNOLOGY,YEAR_FULL);
parameter ReserveMarginTagFuel(REGION_FULL,FUEL,YEAR_FULL);
parameter ReserveMargin(REGION_FULL,YEAR_FULL);

*
* ######## RE Generation Target ############
*
parameter RETagTechnology(TECHNOLOGY,YEAR_FULL);
parameter RETagFuel(FUEL,YEAR_FULL);
parameter REMinProductionTarget(REGION_FULL,FUEL,YEAR_FULL);

*
* ######### Emissions & Penalties #############
*
parameter EmissionActivityRatio(REGION_FULL,TECHNOLOGY,MODE_OF_OPERATION,EMISSION,YEAR_FULL);
parameter EmissionContentPerFuel(FUEL,EMISSION);
parameter EmissionsPenalty(REGION_FULL,EMISSION,YEAR_FULL);
parameter EmissionsPenaltyTagTechnology(REGION_FULL,TECHNOLOGY,EMISSION,YEAR_FULL);
parameter AnnualExogenousEmission(REGION_FULL,EMISSION,YEAR_FULL);
parameter AnnualEmissionLimit(EMISSION,YEAR_FULL);
parameter RegionalAnnualEmissionLimit(REGION_FULL,EMISSION,YEAR_FULL);
parameter ModelPeriodExogenousEmission(REGION_FULL,EMISSION);
parameter ModelPeriodEmissionLimit(EMISSION);
parameter RegionalModelPeriodEmissionLimit(REGION_FULL,EMISSION);
parameter CurtailmentCostFactor;

*
* ######### Trade #############
*
parameter TradeRoute(REGION_FULL,FUEL,y_full,rr_full);
parameter TagCanFuelBeTraded(FUEL);
parameter TradeCostFactor(FUEL, YEAR_FULL);
parameter TradeCosts(REGION_FULL,FUEL,YEAR_FULL,rr_full);
parameter TradeLossFactor(FUEL, YEAR_FULL);
parameter TradeRouteInstalledCapacity(y_full,f,r_full,rr_full);
parameter TradeLossBetweenRegions(REGION_FULL,FUEL,y_full,RR_FULL);


parameter CommissionedTradeCapacity(r_full,f,y_full,rr_full);
parameter TradeCapacity(r_full, f, y_full, rr_full);
parameter TradeCapacityGrowthCosts(r_full, f, rr_full);
parameter GrowthRateTradeCapacity(r_full, f, y_full, rr_full);

parameter SelfSufficiency(y_full, fuel, r_full);

*
* ######### Transportation #############
*
parameter ModalSplitByFuelAndModalType(REGION_FULL,FUEL,MODALTYPE,YEAR_FULL);
parameter TagTechnologyToModalType(TECHNOLOGY,MODE_OF_OPERATION,MODALTYPE);
parameter TagModalTypeToModalGroups(MODALTYPE,*);

parameter ProductionGrowthLimit(FUEL,YEAR_FULL);

* #####################
* # Model Variables #
* #####################
*
* ############### Capacity Variables ############*
*
positive variable NewCapacity(y_full,TECHNOLOGY,REGION_FULL);
positive variable AccumulatedNewCapacity(y_full,TECHNOLOGY,REGION_FULL);
positive variable TotalCapacityAnnual(y_full,TECHNOLOGY,REGION_FULL);

*
* ############### Activity Variables #############
*
positive variable RateOfActivity(y_full,TIMESLICE_FULL,TECHNOLOGY,MODE_OF_OPERATION,REGION_FULL);

positive variable TotalTechnologyAnnualActivity(y_full,TECHNOLOGY,REGION_FULL);

positive variable TotalAnnualTechnologyActivityByMode(y_full,TECHNOLOGY,MODE_OF_OPERATION,REGION_FULL);

positive variable ProductionByTechnologyAnnual(y_full,TECHNOLOGY,FUEL,REGION_FULL);
positive variable UseByTechnologyAnnual(y_full,TECHNOLOGY,FUEL,REGION_FULL);

positive variable TotalActivityPerYear(REGION_FULL,TIMESLICE_FULL,TECHNOLOGY,YEAR_FULL);
positive variable CurtailedEnergyAnnual(y_full,f,r_full);
positive variable CurtailedCapacity(REGION_FULL,TIMESLICE_FULL,TECHNOLOGY,YEAR_FULL);
positive variable DispatchDummy(r_full,TIMESLICE_FULL,t,y_full);

*
* ############### Costing Variables #############
*
positive variable CapitalInvestment(y_full,TECHNOLOGY,REGION_FULL);
positive variable DiscountedCapitalInvestment(y_full,TECHNOLOGY,REGION_FULL);
positive variable SalvageValue(y_full,TECHNOLOGY,REGION_FULL);
positive variable DiscountedSalvageValue(y_full,TECHNOLOGY,REGION_FULL);
positive variable OperatingCost(y_full,TECHNOLOGY,REGION_FULL);
positive variable DiscountedOperatingCost(y_full,TECHNOLOGY,REGION_FULL);
positive variable AnnualVariableOperatingCost(y_full,TECHNOLOGY,REGION_FULL);
positive variable AnnualFixedOperatingCost(y_full,TECHNOLOGY,REGION_FULL);
positive variable VariableOperatingCost(y_full,TIMESLICE_FULL,TECHNOLOGY,REGION_FULL);
positive variable TotalDiscountedCost(y_full,REGION_FULL);
positive variable TotalDiscountedCostByTechnology(y_full,TECHNOLOGY,REGION_FULL)

positive variable AnnualCurtailmentCost(YEAR_FULL,FUEL,REGION_FULL);
positive variable DiscountedAnnualCurtailmentCost(YEAR_FULL,FUEL,REGION_FULL);


*
* ############### Storage Variables #############
positive variable StorageLevelYearStart(s,y_full,REGION_FULL);
positive variable StorageLevelTSStart(s,y_full,TIMESLICE_FULL,REGION_FULL);

positive variable StorageLevelYearFinish(s,y_full,REGION_FULL);
positive variable StorageLowerLimit(s,y_full,REGION_FULL);
positive variable StorageUpperLimit(s,y_full,REGION_FULL);
positive variable AccumulatedNewStorageCapacity(s,y_full,REGION_FULL);
positive variable NewStorageCapacity(s,y_full,REGION_FULL);
positive variable CapitalInvestmentStorage(s,y_full,REGION_FULL);
positive variable DiscountedCapitalInvestmentStorage(s,y_full,REGION_FULL);
positive variable SalvageValueStorage(s,y_full,REGION_FULL);
positive variable DiscountedSalvageValueStorage(s,y_full,REGION_FULL);
positive variable TotalDiscountedStorageCost(s,y_full,REGION_FULL);

*
* ######## Reserve Margin #############
*
positive variable TotalActivityInReserveMargin(REGION_FULL,y_full,TIMESLICE_FULL);
positive variable DemandNeedingReserveMargin(y_full,TIMESLICE_FULL,REGION_FULL);

*
* ######## RE Gen Target #############
*
free variable TotalREProductionAnnual(y_full,REGION_FULL,FUEL);
free variable RETotalDemandOfTargetFuelAnnual(y_full,REGION_FULL,FUEL);
free variable TotalTechnologyModelPeriodActivity(TECHNOLOGY,REGION_FULL);
positive variable RETargetMin(YEAR_FULL,REGION_FULL);

*
* ######## Emissions #############
*
variable AnnualTechnologyEmissionByMode(y_full,TECHNOLOGY,EMISSION,MODE_OF_OPERATION,REGION_FULL);
variable AnnualTechnologyEmission(y_full,TECHNOLOGY,EMISSION,REGION_FULL);
variable AnnualTechnologyEmissionPenaltyByEmission(y_full,TECHNOLOGY,EMISSION,REGION_FULL);
variable AnnualTechnologyEmissionsPenalty(y_full,TECHNOLOGY,REGION_FULL);
variable DiscountedTechnologyEmissionsPenalty(y_full,TECHNOLOGY,REGION_FULL);
variable AnnualEmissions(y_full,EMISSION,REGION_FULL);
variable ModelPeriodEmissions(REGION_FULL,EMISSION);
variable WeightedAnnualEmissions(year_full,emission,region_full);


*
* ######### SectoralEmissions #############
*
variable AnnualSectoralEmissions(y_full,EMISSION,SECTOR,REGION_FULL);

*
* ######### Trade #############
*
positive variable Import(y_full,TIMESLICE_FULL,FUEL,REGION_FULL,rr_full);
positive variable Export(y_full,TIMESLICE_FULL,FUEL,REGION_FULL,rr_full);

positive variable NewTradeCapacity(YEAR_FULL, FUEL, REGION_FULL, rr_full);
positive variable TotalTradeCapacity(YEAR_FULL, FUEL, REGION_FULL, rr_full);
positive variable NewTradeCapacityCosts(YEAR_FULL, FUEL, REGION_FULL, rr_full);
positive variable DiscountedNewTradeCapacityCosts(YEAR_FULL, FUEL, REGION_FULL, rr_full);

free variable NetTrade(y_full,TIMESLICE_FULL,FUEL,REGION_FULL);
free variable NetTradeAnnual(y_full,FUEL,REGION_FULL);
free variable TotalTradeCosts(y_full,TIMESLICE_FULL,REGION_FULL);
free variable AnnualTotalTradeCosts(y_full,REGION_FULL);
free variable DiscountedAnnualTotalTradeCosts(y_full,REGION_FULL);

*
* ######### Transportation #############
*

positive variable DemandSplitByModalType(MODALTYPE,TIMESLICE_FULL,REGION_FULL,FUEL,YEAR_FULL);
positive variable ProductionSplitByModalType(MODALTYPE,TIMESLICE_FULL,REGION_FULL,FUEL,YEAR_FULL);

$ifthen.dec_ramping %switch_ramping% == 1
*
* ######## Ramping #############
*
parameter RampingUpFactor(TECHNOLOGY,y_full);
parameter RampingDownFactor(TECHNOLOGY,y_full);

parameter ProductionChangeCost(TECHNOLOGY,y_full);

parameter MinActiveProductionPerTimeslice(YEAR_FULL,TIMESLICE_FULL,FUEL,TECHNOLOGY,REGION_FULL);

positive variable ProductionUpChangeInTimeslice(YEAR_FULL,TIMESLICE_FULL,FUEL,TECHNOLOGY,REGION_FULL);
positive variable ProductionDownChangeInTimeslice(YEAR_FULL,TIMESLICE_FULL,FUEL,TECHNOLOGY,REGION_FULL);

positive variable AnnualProductionChangeCost(y_full,TECHNOLOGY,REGION_FULL);
positive variable DiscountedAnnualProductionChangeCost(y_full,TECHNOLOGY,REGION_FULL);

$endif.dec_ramping

Parameter PhaseOut(YEAR_FULL) this is an upper limit for fossil generation based on the previous year - to remove choose large value
/        2020    3
         2025    3
         2030    3
         2035    2.5
         2040    2.5
         2045    2
         2050    2
         2055    1.5
         2060    1.25
/
PhaseIn(YEAR_FULL) this is a lower bound for renewable integration based on the previous year - to remove choose 0
/        2020    1
         2025    0.8
         2030    0.8
         2035    0.8
         2040    0.8
         2045    0.8
         2050    0.6
         2055    0.5
         2060    0.5
/;


Parameter BaseYearSlack(f);
positive Variable BaseYearBounds_TooLow(y_full,r_full,t,f);
positive variable BaseYearBounds_TooHigh(y_full,r_full,t,f);
positive variable heatingslack(y_full,r_full);  

$ifthen %switch_baseyear_bounds_debugging% == 0
BaseYearBounds_TooHigh.fx(y,r,t,f) = 0;
BaseYearBounds_TooLow.fx(r,t,f,y) = 0;
$endif

positive variable DiscountedSalvageValueTransmission(y_full,r_full);

Parameter StorageLevelYearStartUpperLimit;
Parameter StorageLevelYearStartLowerLimit;
StorageLevelYearStartUpperLimit = %set_storagelevelstart_up%;
StorageLevelYearStartLowerLimit = %set_storagelevelstart_low%;
if((StorageLevelYearStartUpperLimit-StorageLevelYearStartLowerLimit)<0,abort "StorageLevelYearStart upper limit cannot be smaller than lower limit. Please check your values for set_storagelevelstart_up and set_storagelevelstart_low.");



$ifthen %switch_employment_calculation% == 1
set JobType  this set contains job types /ConstructionJobs,ManufacturingJobs,OMJobs,SupplyJobs/
alias (JobType,jt);


* ########## Declaration of Employment Parameters ##########

parameter EFactorConstruction;
parameter EFactorOM;
parameter EFactorManufacturing;
parameter EFactorFuelSupply;
parameter EFactorCoalJobs;
parameter CoalSupply
parameter CoalDigging
parameter RegionalAdjustmentFactor;
parameter LocalManufacturingFactor;
parameter DeclineRate;

parameter ConstructionJobs;
parameter ManufacturingJobs;
parameter OMJobs;
parameter SupplyJobs;
parameter CoalJobs;
parameter output_energyjobs;
$endif


