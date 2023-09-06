* ###################### genesysmod_dataload.gms #######################
*
* GENeSYS-MOD v3.1 [Global Energy System Model]  ~ March 2022
*
* Based on OSEMOSYS 2011.07.07 conversion to GAMS by Ken Noble, Noble-Soft Systems - August 2012
*
* Updated to newest OSeMOSYS-Version (2016.08) and further improved with additional equations 2016 - 2022
* by Konstantin L�ffler, Thorsten Burandt, Karlo Hainsch
*
* #############################################################
*
* Copyright 2020 Technische Universit�t Berlin and DIW Berlin
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



$offorder

Parameter
Readin_TradeCosts
Readin_TradeRoute2015(f,r_full,rr_full)
Readin_PowerTradeCapacity(f,r_full,rr_full,y_full)
Readin_TotalTechnologyModelPeriodActivityUpperLimit(REGION_FULL,TECHNOLOGY)
;

* Step 1: REDONE - Now reads from combined data file

$onecho >%tempdir%temp_%data_file%_sets.tmp
se=0
        set=Emission                 Rng=Sets!A2                         rdim=1        cdim=0
        dset=Technology              Rng=Sets!B2                         rdim=1        cdim=0
        dset=Fuel                    Rng=Sets!C2                         rdim=1        cdim=0
        set=Year                     Rng=Sets!D2                         rdim=1        cdim=0
        set=Timeslice                Rng=Sets!E2                         rdim=1        cdim=0
        set=Mode_of_operation        Rng=Sets!F2                         rdim=1        cdim=0
        set=Region_full              Rng=Sets!G2                         rdim=1        cdim=0
        set=Storage                  Rng=Sets!K2                         rdim=1        cdim=0
        set=ModalType                Rng=Sets!L2                         rdim=1        cdim=0
        set=Sector                   Rng=Sets!N2                         rdim=1        cdim=0
$offecho

$ifi %switch_only_load_gdx%==0 $call "gdxxrw %inputdir%%data_file%.xlsx @%tempdir%temp_%data_file%_sets.tmp o=%gdxdir%%data_file%_sets.gdx MaxDupeErrors=99 CheckDate ";
$GDXin %gdxdir%%data_file%_sets.gdx
$onUNDF
$loadm Year
$loadm Sector
$loadm Emission Technology Fuel Timeslice Mode_of_operation Region_full Storage ModalType
$offUNDF


* Step 2: Read parameters from regional file  -> now includes World values


$onecho >%tempdir%temp_%data_file%_par.tmp
se=0
         par=SpecifiedAnnualDemand    Rng=Par_SpecifiedAnnualDemand!A5                   rdim=2  cdim=1
*        par=SpecifiedDemandProfile   Rng=Par_SpecifiedDemandProfile!A5                  rdim=3  cdim=1
        par=ReserveMarginTagFuel     Rng=Par_ReserveMarginTagFuel!A5                    rdim=2  cdim=1

        par=EmissionsPenalty         Rng=Par_EmissionsPenalty!A5                         rdim=2  cdim=1
        par=EmissionsPenaltyTagTechnology         Rng=Par_EmissionPenaltyTagTech!A5                         rdim=3  cdim=1
        par=ReserveMargin            Rng=Par_ReserveMargin!A5                            rdim=1  cdim=1
        par=AnnualExogenousEmission  Rng=Par_AnnualExogenousEmission!A5                  rdim=2  cdim=1
        par=RegionalAnnualEmissionLimit      Rng=Par_RegionalAnnualEmissionLimit!A5                      rdim=2  cdim=1
        par=AnnualEmissionLimit      Rng=Par_AnnualEmissionLimit!A5                      rdim=1  cdim=1
        par=Readin_TradeRoute2015    Rng=Par_TradeRoute!A5                          rdim=2  cdim=1
        par=Readin_TradeCosts               Rng=Par_TradeCosts!A5                           rdim=2  cdim=1
        par=Readin_PowerTradeCapacity  Rng=Par_TradeCapacity!A5            rdim=2  cdim=2

        par=GrowthRateTradeCapacity         Rng=Par_GrowthRateTradeCapacity!A5  rdim=3 cdim=1
        par=TradeCapacityGrowthCosts        Rng=Par_TradeCapacityGrowthCosts!A5  rdim=2 cdim=1
        par=CapacityToActivityUnit   Rng=Par_CapacityToActivityUnit!A5   rdim=1        cdim=1

        par=InputActivityRatio       Rng=Par_InputActivityRatio!A5                       rdim=4        cdim=1
        par=OutputActivityRatio      Rng=Par_OutputActivityRatio!A5                      rdim=4        cdim=1
        par=FixedCost                Rng=Par_FixedCost!A5                                rdim=2        cdim=1
        par=CapitalCost              Rng=Par_CapitalCost!A5                              rdim=2        cdim=1
        par=VariableCost             Rng=Par_VariableCost!A5                             rdim=3        cdim=1
        par=ResidualCapacity         Rng=Par_ResidualCapacity!A5                         rdim=2        cdim=1
        par=AvailabilityFactor       Rng=Par_AvailabilityFactor!A5                       rdim=2        cdim=1
        par=CapacityFactor           Rng=Par_CapacityFactor!A5                           rdim=3        cdim=1
        par=EmissionActivityRatio    Rng=Par_EmissionActivityRatio!A5                    rdim=4        cdim=1
        par=EmissionContentPerFuel   Rng=Par_EmissionContentPerFuel!A5                   rdim=2        cdim=0
        par=OperationalLife          Rng=Par_OperationalLife!A5                          rdim=2        cdim=0
        par=TotalAnnualMaxCapacity   Rng=Par_TotalAnnualMaxCapacity!A5                   rdim=2        cdim=1
        par=TotalAnnualMinCapacity   Rng=Par_TotalAnnualMinCapacity!A5                   rdim=2        cdim=1
        par=Readin_TotalTechnologyModelPeriodActivityUpperLimit   Rng=Par_ModelPeriodActivityMaxLimit!A5         rdim=2        cdim=0

        par=TotalTechnologyAnnualActivityUpperLimit   Rng=Par_TotalAnnualMaxActivity!A5                   rdim=2        cdim=1
        par=TotalTechnologyAnnualActivityLowerLimit   Rng=Par_TotalAnnualMinActivity!A5                   rdim=2        cdim=1

        par=ReserveMarginTagTechnology  Rng=Par_ReserveMarginTagTechnology!A5            rdim=2        cdim=1

        par=RegionalCCSLimit             Rng=Par_RegionalCCSLimit!A5               rdim=1        cdim=0

        par=TechnologyToStorage   Rng=Par_TechnologyToStorage!A5                         rdim=3        cdim=1
        par=TechnologyFromStorage Rng=Par_TechnologyFromStorage!A5                       rdim=3        cdim=1
        par=StorageLevelStart     Rng=Par_StorageLevelStart!A5                           rdim=1        cdim=1
        par=StorageMaxChargeRate  Rng=Par_StorageMaxChargeRate!A5                        rdim=1        cdim=1
        par=StorageMaxDischargeRate Rng=Par_StorageMaxDischargeRate!A5                   rdim=1        cdim=1
        par=MinStorageCharge      Rng=Par_MinStorageCharge!A5                            rdim=2        cdim=1
        par=OperationalLifeStorage Rng=Par_OperationalLifeStorage!A5                     rdim=2        cdim=1
        par=CapitalCostStorage    Rng=Par_CapitalCostStorage!A5                          rdim=2        cdim=1
        par=ResidualStorageCapacity Rng=Par_ResidualStorageCapacity!A5                   rdim=2        cdim=1

        par=ModalSplitByFuelAndModalType   Rng=Par_ModalSplitByFuel!A5                    rdim=3        cdim=1
        par=TagTechnologyToModalType       Rng=Par_TagTechnologyToModalType!A5                       rdim=2        cdim=1

        par=BaseYearProduction   Rng=Par_BaseYearProduction!A5                   rdim=2        cdim=1
        par=RegionalBaseYearProduction   Rng=Par_RegionalBaseYearProduction!A5                    rdim=3        cdim=1

        par=TagTechnologyToSector       Rng=Par_TagTechnologyToSector!A5                       rdim=1        cdim=1
        par=AnnualSectoralEmissionLimit      Rng=Par_AnnualSectoralEmissionLimit!A5                      rdim=2  cdim=1
        par=TagDemandFuelToSector       Rng=Par_TagDemandFuelToSector!A5                       rdim=1        cdim=1
        par=TagElectricTechnology       Rng=Par_TagElectricTechnology!A4                       rdim=1        cdim=0

$offecho

$ifi %switch_only_load_gdx%==0 $call "gdxxrw %inputdir%%data_file%.xlsx @%tempdir%temp_%data_file%_par.tmp o=%gdxdir%%data_file%_par.gdx MaxDupeErrors=99 CheckDate ";
$GDXin %gdxdir%%data_file%_par.gdx
$onUNDF
$loadm 
$loadm SpecifiedAnnualDemand ReserveMarginTagFuel
$loadm EmissionsPenalty ReserveMargin AnnualExogenousEmission  AnnualEmissionLimit RegionalAnnualEmissionLimit ReserveMarginTagTechnology
$loadm ReserveMarginTagFuel Readin_TradeRoute2015 Readin_PowerTradeCapacity GrowthRateTradeCapacity TradeCapacityGrowthCosts Readin_TradeCosts
$loadm InputActivityRatio OutputActivityRatio FixedCost CapitalCost VariableCost ResidualCapacity   EmissionsPenaltyTagTechnology
$loadm AvailabilityFactor CapacityFactor EmissionActivityRatio OperationalLife TotalAnnualMaxCapacity TotalAnnualMinCapacity EmissionContentPerFuel
$loadm TotalTechnologyAnnualActivityLowerLimit TotalTechnologyAnnualActivityUpperLimit
$loadm Readin_TotalTechnologyModelPeriodActivityUpperLimit
$loadm TechnologyToStorage TechnologyFromStorage StorageLevelStart StorageMaxChargeRate StorageMaxDischargeRate MinStorageCharge
$loadm CapitalCostStorage OperationalLifeStorage
$loadm  ResidualStorageCapacity CapacityToActivityUnit
$loadm  ModalSplitByFuelAndModalType TagTechnologyToModalType BaseYearProduction RegionalBaseYearProduction
$loadm TagTechnologyToSector AnnualSectoralEmissionLimit
$loadm RegionalCCSLimit TagDemandFuelToSector TagElectricTechnology
$offUNDF

*
* ####### Step 3: Set regional values, if only value given for base-region #############
*

CapitalCost(REGION_FULL,TECHNOLOGY,y)$(CapitalCost(REGION_FULL,TECHNOLOGY,y) = 0) = CapitalCost('%data_base_region%',TECHNOLOGY,y);
VariableCost(REGION_FULL,TECHNOLOGY,MODE_OF_OPERATION,y)$(VariableCost(REGION_FULL,TECHNOLOGY,MODE_OF_OPERATION,y) = 0) = VariableCost('%data_base_region%',TECHNOLOGY,MODE_OF_OPERATION,y);
FixedCost(REGION_FULL,TECHNOLOGY,y)$(FixedCost(REGION_FULL,TECHNOLOGY,y) = 0) = FixedCost('%data_base_region%',TECHNOLOGY,y);
AvailabilityFactor(REGION_FULL,TECHNOLOGY,y)$(AvailabilityFactor(REGION_FULL,TECHNOLOGY,y) = 0) = AvailabilityFactor('%data_base_region%',TECHNOLOGY,y);
InputActivityRatio(REGION_FULL,TECHNOLOGY,FUEL,MODE_OF_OPERATION,y)$(InputActivityRatio(REGION_FULL,TECHNOLOGY,FUEL,MODE_OF_OPERATION,y) = 0) = InputActivityRatio('%data_base_region%',TECHNOLOGY,FUEL,MODE_OF_OPERATION,y);
OutputActivityRatio(REGION_FULL,TECHNOLOGY,FUEL,MODE_OF_OPERATION,y)$(OutputActivityRatio(REGION_FULL,TECHNOLOGY,FUEL,MODE_OF_OPERATION,y) = 0) = OutputActivityRatio('%data_base_region%',TECHNOLOGY,FUEL,MODE_OF_OPERATION,y);
OperationalLife(REGION_FULL,TECHNOLOGY)$(OperationalLife(REGION_FULL,TECHNOLOGY) = 0) = OperationalLife('%data_base_region%',TECHNOLOGY);
OperationalLifeStorage(REGION_FULL,STORAGE,YEAR)$(OperationalLifeStorage(REGION_FULL,STORAGE,YEAR) = 0) = OperationalLifeStorage('%data_base_region%',STORAGE,YEAR);
EmissionsPenaltyTagTechnology(REGION_FULL,t,e,y)$(EmissionsPenaltyTagTechnology(REGION_FULL,t,e,y) = 0) = EmissionsPenaltyTagTechnology('%data_base_region%',t,e,y);

ReserveMarginTagTechnology(REGION_FULL,TECHNOLOGY,y)$(ReserveMarginTagTechnology(REGION_FULL,TECHNOLOGY,y) = 0) = ReserveMarginTagTechnology('%data_base_region%',TECHNOLOGY,y);

StorageMaxChargeRate(REGION_FULL,s)$(StorageMaxChargeRate(REGION_FULL,s)=0) = StorageMaxChargeRate('%data_base_region%',s);
StorageMaxDischargeRate(REGION_FULL,s)$(StorageMaxDischargeRate(REGION_FULL,s)=0) = StorageMaxDischargeRate('%data_base_region%',s);
EmissionActivityRatio(REGION_FULL,TECHNOLOGY,EMISSION,MODE_OF_OPERATION,YEAR)$(EmissionActivityRatio(REGION_FULL,TECHNOLOGY,EMISSION,MODE_OF_OPERATION,YEAR)=0) =  EmissionActivityRatio('%data_base_region%',TECHNOLOGY,EMISSION,MODE_OF_OPERATION,YEAR);

CapacityToActivityUnit(REGION_FULL,t)$(CapacityToActivityUnit(REGION_FULL,t) <> CapacityToActivityUnit('%data_base_region%',t)) = CapacityToActivityUnit('%data_base_region%',t);
EmissionsPenalty(REGION_FULL,e,y)$(EmissionsPenalty(REGION_FULL,e,y) <> EmissionsPenalty('%data_base_region%',e,y)) = EmissionsPenalty('%data_base_region%',e,y);


*
* ####### Step 4: Set values, if no regional data available #############
*

CapitalCost(REGION_FULL,TECHNOLOGY,y)$(CapitalCost(REGION_FULL,TECHNOLOGY,y) = 0) = CapitalCost('World',TECHNOLOGY,y);
VariableCost(REGION_FULL,TECHNOLOGY,MODE_OF_OPERATION,y)$(VariableCost(REGION_FULL,TECHNOLOGY,MODE_OF_OPERATION,y) = 0) = VariableCost('World',TECHNOLOGY,MODE_OF_OPERATION,y);
FixedCost(REGION_FULL,TECHNOLOGY,y)$(FixedCost(REGION_FULL,TECHNOLOGY,y) = 0) = FixedCost('World',TECHNOLOGY,y);
AvailabilityFactor(REGION_FULL,TECHNOLOGY,y)$(AvailabilityFactor(REGION_FULL,TECHNOLOGY,y) = 0) = AvailabilityFactor('World',TECHNOLOGY,y);
InputActivityRatio(REGION_FULL,TECHNOLOGY,FUEL,MODE_OF_OPERATION,y)$(InputActivityRatio(REGION_FULL,TECHNOLOGY,FUEL,MODE_OF_OPERATION,y) = 0) = InputActivityRatio('World',TECHNOLOGY,FUEL,MODE_OF_OPERATION,y);
OutputActivityRatio(REGION_FULL,TECHNOLOGY,FUEL,MODE_OF_OPERATION,y)$(OutputActivityRatio(REGION_FULL,TECHNOLOGY,FUEL,MODE_OF_OPERATION,y) = 0) = OutputActivityRatio('World',TECHNOLOGY,FUEL,MODE_OF_OPERATION,y);
OperationalLife(REGION_FULL,TECHNOLOGY)$(OperationalLife(REGION_FULL,TECHNOLOGY) = 0) = OperationalLife('World',TECHNOLOGY);
OperationalLifeStorage(REGION_FULL,STORAGE,YEAR)$(OperationalLifeStorage(REGION_FULL,STORAGE,YEAR) = 0) = OperationalLifeStorage('World',STORAGE,YEAR);
EmissionsPenaltyTagTechnology(REGION_FULL,t,e,y)$(EmissionsPenaltyTagTechnology(REGION_FULL,t,e,y) = 0) = EmissionsPenaltyTagTechnology('World',t,e,y);

ReserveMarginTagTechnology(REGION_FULL,TECHNOLOGY,y)$(ReserveMarginTagTechnology(REGION_FULL,TECHNOLOGY,y) = 0) = ReserveMarginTagTechnology('World',TECHNOLOGY,y);

StorageMaxChargeRate(REGION_FULL,s)$(StorageMaxChargeRate(REGION_FULL,s)=0) = StorageMaxChargeRate('World',s);
StorageMaxDischargeRate(REGION_FULL,s)$(StorageMaxDischargeRate(REGION_FULL,s)=0) = StorageMaxDischargeRate('World',s);
EmissionActivityRatio(REGION_FULL,TECHNOLOGY,EMISSION,MODE_OF_OPERATION,YEAR)$(EmissionActivityRatio(REGION_FULL,TECHNOLOGY,EMISSION,MODE_OF_OPERATION,YEAR)=0) =  EmissionActivityRatio('World',TECHNOLOGY,EMISSION,MODE_OF_OPERATION,YEAR);

CapacityToActivityUnit(r_full,t)$(CapacityToActivityUnit(r_full,t) = 0) = CapacityToActivityUnit('World',t);
ReserveMarginTagFuel(r_full,f,y)$(ReserveMarginTagFuel(r_full,f,y)=0) =  ReserveMarginTagFuel('World',f,y);
ReserveMargin(r_full,y)$(ReserveMargin(r_full,y)=0) = ReserveMargin('World',y);
ReserveMarginTagTechnology(r_full,t,y)$(ReserveMarginTagTechnology(r_full,t,y)=0) = ReserveMarginTagTechnology('World',t,y);
MinStorageCharge(r_full,s,y)$(MinStorageCharge(r_full,s,y)=0) = MinStorageCharge('World',s,y);
CapitalCostStorage(r_full,s,y)$(CapitalCostStorage(r_full,s,y)=0) = CapitalCostStorage('World',s,y);



*
* ####### Including Subsets #############
*


$onecho >%tempdir%temp_Tag_Subsets_par.tmp
se=0
        par=TagTechnologyToSubsets                Rng=Par_TagTechnologyToSubsets!A2                rdim=2        cdim=0
        par=TagFuelToSubsets                      Rng=Par_TagFuelToSubsets!A2                      rdim=2        cdim=0

        
$offecho

$ifi %switch_only_load_gdx%==0 $call "gdxxrw %inputdir%Tag_Subsets.xlsx @%tempdir%temp_Tag_Subsets_par.tmp o=%gdxdir%Tag_Subsets_par.gdx MaxDupeErrors=99 CheckDate ";
$GDXin %gdxdir%Tag_Subsets_par.gdx
$onUNDF
$loadm TagTechnologyToSubsets TagFuelToSubsets
$offUNDF

$include genesysmod_subsets.gms

StartYear = %year% ;

$ifthen %switch_all_regions% == 1
REGION(REGION_FULL) = yes;
REGION('World') = no;
$if set exclude_region1 REGION('%exclude_region1%') = no;
$if set exclude_region2 REGION('%exclude_region2%') = no;
$if set exclude_region3 REGION('%exclude_region3%') = no;
$else
REGION(REGION_FULL)$(ord(REGION_FULL) < 5) = yes;
REGION('World') = no;
$endif

$ifthen %switch_aggregate_region% == 1

$onmulti
Set REGION_FULL / %model_region% /;
$offmulti
REGION(REGION_FULL) = yes;
REGION('%model_region%') = no;
REGION('World') = no;
$endif


*
* ####### Assigning TradeRoutes depending on initialized Regions and Year #############
*
TradeRoute(y,f,r,rr) = Readin_TradeRoute2015(f,r,rr);
TradeCapacity(y,'Power',r,rr) = Readin_PowerTradeCapacity('power',r,rr,y);

TradeCosts(f,r,rr) = Readin_TradeCosts(f,r,rr);
GrowthRateTradeCapacity(y,'Power',r,rr) = GrowthRateTradeCapacity('%year%','Power',r,rr);

TradeLossFactor(y,'Power') = 0.00003;
TradeLossBetweenRegions(y,f,r,rr) = TradeLossFactor(y,f)*TradeRoute(y,f,r,rr);

*
* ######### Missing in Excel, Overwriten later in scenario data #############
*
ModelPeriodEmissionLimit(EMISSION) = 999999;
RegionalModelPeriodEmissionLimit(EMISSION,REGION_FULL) = 999999;

*
* ######### YearValue assignment #############
*
parameter YearVal(y_full);
YearVal(y) = y.val ;


*
* ####### Load from hourly Data #############
*
$ifthen %timeseries% == elmod
$offlisting
$include genesysmod_timeseries_reduction.gms

$elseif %timeseries% == classic
$offlisting
$include genesysmod_timeseries_timeslices.gms

CapacityFactor(r,t,'Q1N',y)$(TagTechnologyToSubset(t,'Solar')) = 0;
CapacityFactor(r,t,'Q2N',y)$(TagTechnologyToSubset(t,'Solar')) = 0;
CapacityFactor(r,t,'Q3N',y)$(TagTechnologyToSubset(t,'Solar')) = 0;
CapacityFactor(r,t,'Q4N',y)$(TagTechnologyToSubset(t,'Solar')) = 0;
$endif           



$ifthen %switch_employment_calculation% == 1
* ########## Dataload of Employment Excel ##########

$onecho >%tempdir%temp_%employment_data_file%.tmp
se=0
        dset=Technology              Rng=Sets!A2                         rdim=1        cdim=0
        set=Year                     Rng=Sets!B2                         rdim=1        cdim=0
        set=Region                   Rng=Sets!C2                         rdim=1        cdim=0


        par=EFactorConstruction      Rng=Par_EFactorConstruction!A5                rdim=1        cdim=1
        par=EFactorOM                Rng=Par_EFactorOM!A5                          rdim=1        cdim=1
        par=EFactorManufacturing     Rng=Par_EFactorManufacturing!A5               rdim=1        cdim=1
        par=EFactorFuelSupply        Rng=Par_EFactorFuelSupply!A5                  rdim=1        cdim=1
        par=EFactorCoalJobs          Rng=Par_EFactorCoalJobs!A5                    rdim=1        cdim=1
        par=CoalSupply               Rng=Par_CoalSupply!A5                    rdim=1        cdim=1
        par=CoalDigging              Rng=Par_CoalDigging!A5                    rdim=3        cdim=1
        par=RegionalAdjustmentFactor          Rng=Par_RegionalAdjustmentFactor!A5                    rdim=1        cdim=1
        par=LocalManufacturingFactor          Rng=Par_LocalManufacturingFactor!A5                    rdim=1        cdim=1
        par=DeclineRate                       Rng=Par_DeclineRate!A5                                 rdim=1        cdim=1




$offecho

$ifi %switch_only_load_gdx%==0 $call "gdxxrw %inputdir%%employment_data_file%.xlsx @%tempdir%temp_%employment_data_file%.tmp o=%gdxdir%%employment_data_file%.gdx MaxDupeErrors=999 ";
$GDXin %gdxdir%%employment_data_file%.gdx
$onUNDF
$loadm Region
$loadm EFactorConstruction
$loadm EFactorOM
$loadm EFactorManufacturing
$loadm EFactorFuelSupply
$loadm EFactorCoalJobs
$loadm CoalSupply
$loadm CoalDigging
$loadm RegionalAdjustmentFactor
$loadm LocalManufacturingFactor
$loadm DeclineRate

$offUNDF
$endif






