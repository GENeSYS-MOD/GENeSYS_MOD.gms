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



$offorder

Parameter
Readin_TradeRoute(r_full,f,rr_full)
Readin_TradeCapacity(r_full,f,y_full,rr_full)
Readin_CommissionedTradeCapacity(r_full,f,y_full,rr_full)
Readin_TotalTechnologyModelPeriodActivityUpperLimit(REGION_FULL,TECHNOLOGY)
;

* Step 1: REDONE - Now reads from combined data file

$onecho >%tempdir%temp_%data_file%_sets.tmp
se=0
        set=Region_full            Rng=Sets!A2                         rdim=1        cdim=0
        set=Technology            Rng=Sets!B2                         rdim=1        cdim=0
        set=Storage               Rng=Sets!C2                         rdim=1        cdim=0
        set=Fuel                   Rng=Sets!D2                         rdim=1        cdim=0
        set=Mode_of_operation      Rng=Sets!E2                         rdim=1        cdim=0
        set=Emission               Rng=Sets!F2                         rdim=1        cdim=0
        set=ModalType              Rng=Sets!G2                         rdim=1        cdim=0
        set=Sector                 Rng=Sets!H2                         rdim=1        cdim=0
        set=Year                   Rng=Sets!I2                         rdim=1        cdim=0

$offecho

$ifi %switch_only_load_gdx%==0 $call "gdxxrw %inputdir%%data_file%.xlsx @%tempdir%temp_%data_file%_sets.tmp o=%gdxdir%%data_file%_sets.gdx MaxDupeErrors=99 CheckDate ";
$GDXin %gdxdir%%data_file%_sets.gdx
$onUNDF
$loadm Region_full Technology Storage Fuel
$loadm Mode_of_operation Emission ModalType
$loadm Sector Year
$offUNDF

* Step 2: Read parameters from regional file  -> now includes World values


$onecho >%tempdir%temp_%data_file%_par.tmp
se=0

        par=SpecifiedAnnualDemand    Rng=Par_SpecifiedAnnualDemand!A1                   rdim=2  cdim=1
        par=SpecifiedDemandDevelopment    Rng=Par_SpecifiedDemandDevelopment!A1         rdim=2  cdim=1
        par=ReserveMarginTagFuel     Rng=Par_ReserveMarginTagFuel!A1                    rdim=2  cdim=1

        par=EmissionsPenalty         Rng=Par_EmissionsPenalty!A1                         rdim=2  cdim=1
        par=EmissionsPenaltyTagTechnology         Rng=Par_EmissionPenaltyTagTech!A1                         rdim=3  cdim=1
        par=ReserveMargin            Rng=Par_ReserveMargin!A1                            rdim=1  cdim=1
        par=AnnualExogenousEmission  Rng=Par_AnnualExogenousEmission!A1                  rdim=2  cdim=1
        par=RegionalAnnualEmissionLimit      Rng=Par_RegionalAnnualEmissionLimit!A1                      rdim=2  cdim=1
        par=AnnualEmissionLimit      Rng=Par_AnnualEmissionLimit!A1                      rdim=1  cdim=1
        par=Readin_TradeRoute    Rng=Par_TradeRoute!A1                          rdim=2  cdim=1
        par=TradeCostFactor               Rng=Par_TradeCostFactor!A1                           rdim=1  cdim=1
        par=Readin_TradeCapacity  Rng=Par_TradeCapacity!A1            rdim=3  cdim=1
        par=Readin_CommissionedTradeCapacity  Rng=Par_CommissionedTradeCapacity!A1            rdim=3  cdim=1
        par=REMinProductionTarget         Rng=Par_REMinProductionTarget!A1               rdim=2 cdim=1
        par=SelfSufficiency         Rng=Par_SelfSufficiency!A1                           rdim=2 cdim=1
        par=ProductionGrowthLimit         Rng=Par_ProductionGrowthLimit!A1                           rdim=1 cdim=1

        par=GrowthRateTradeCapacity         Rng=Par_GrowthRateTradeCapacity!A1  rdim=3 cdim=1
        par=TradeCapacityGrowthCosts        Rng=Par_TradeCapacityGrowthCosts!A1  rdim=2 cdim=1
        par=CapacityToActivityUnit   Rng=Par_CapacityToActivityUnit!A2   rdim=1        cdim=0

        par=InputActivityRatio       Rng=Par_InputActivityRatio!A1                       rdim=4        cdim=1
        par=OutputActivityRatio      Rng=Par_OutputActivityRatio!A1                      rdim=4        cdim=1
        par=FixedCost                Rng=Par_FixedCost!A1                                rdim=2        cdim=1
        par=CapitalCost              Rng=Par_CapitalCost!A1                              rdim=2        cdim=1
        par=VariableCost             Rng=Par_VariableCost!A1                             rdim=3        cdim=1
        par=ResidualCapacity         Rng=Par_ResidualCapacity!A1                         rdim=2        cdim=1
        par=AvailabilityFactor       Rng=Par_AvailabilityFactor!A1                       rdim=2        cdim=1
        par=CapacityFactor           Rng=Par_CapacityFactor!A1                           rdim=3        cdim=1
        par=EmissionActivityRatio    Rng=Par_EmissionActivityRatio!A1                    rdim=4        cdim=1
        par=EmissionContentPerFuel   Rng=Par_EmissionContentPerFuel!A2                   rdim=2        cdim=0
        par=OperationalLife          Rng=Par_OperationalLife!A2                          rdim=1        cdim=0
        par=TotalAnnualMaxCapacity   Rng=Par_TotalAnnualMaxCapacity!A1                   rdim=2        cdim=1
        par=NewCapacityExpansionStop   Rng=Par_NewCapacityExpansionStop!A1                   rdim=2        cdim=0
        par=TotalAnnualMinCapacity   Rng=Par_TotalAnnualMinCapacity!A1                   rdim=2        cdim=1
        par=Readin_TotalTechnologyModelPeriodActivityUpperLimit   Rng=Par_ModelPeriodActivityMaxLimit!A2         rdim=2        cdim=0

        par=TotalTechnologyAnnualActivityUpperLimit   Rng=Par_TotalAnnualMaxActivity!A1                   rdim=2        cdim=1
        par=TotalTechnologyAnnualActivityLowerLimit   Rng=Par_TotalAnnualMinActivity!A1                   rdim=2        cdim=1

        par=ReserveMarginTagTechnology  Rng=Par_ReserveMarginTagTechnology!A1            rdim=2        cdim=1

        par=RegionalCCSLimit             Rng=Par_RegionalCCSLimit!A2               rdim=1        cdim=0

        par=TechnologyToStorage   Rng=Par_TechnologyToStorage!A1                         rdim=3        cdim=1
        par=TechnologyFromStorage Rng=Par_TechnologyFromStorage!A1                       rdim=3        cdim=1
        par=StorageLevelStart     Rng=Par_StorageLevelStart!A1                           rdim=1        cdim=1
        par=MinStorageCharge      Rng=Par_MinStorageCharge!A1                            rdim=2        cdim=1
        par=OperationalLifeStorage Rng=Par_OperationalLifeStorage!A2                     rdim=1        cdim=0
        par=CapitalCostStorage    Rng=Par_CapitalCostStorage!A1                          rdim=2        cdim=1
        par=ResidualStorageCapacity Rng=Par_ResidualStorageCapacity!A1                   rdim=2        cdim=1

        par=ModalSplitByFuelAndModalType   Rng=Par_ModalSplitByFuel!A1                    rdim=3        cdim=1
        par=TagTechnologyToModalType       Rng=Par_TagTechnologyToModalType!A2                       rdim=3        cdim=0

        par=BaseYearProduction   Rng=Par_BaseYearProduction!A1                   rdim=2        cdim=1
        par=RegionalBaseYearProduction   Rng=Par_RegionalBaseYearProduction!A1                    rdim=3        cdim=1

        par=TagTechnologyToSector       Rng=Par_TagTechnologyToSector!A2                       rdim=2        cdim=0
        par=AnnualSectoralEmissionLimit      Rng=Par_AnnualSectoralEmissionLimit!A1                      rdim=2  cdim=1
        par=TagDemandFuelToSector       Rng=Par_TagDemandFuelToSector!A2                       rdim=2        cdim=0
        par=TagElectricTechnology       Rng=Par_TagElectricTechnology!A2                       rdim=1        cdim=0

        par=TagTechnologyToSubsets                Rng=Par_TagTechnologyToSubsets!A2                rdim=2        cdim=0
        par=TagFuelToSubsets                      Rng=Par_TagFuelToSubsets!A2                      rdim=2        cdim=0
        par=TagModalTypeToModalGroups                Rng=Par_TagModalTypeToModalGroups!A2          rdim=2        cdim=0
        par=StorageE2PRatio                      Rng=Par_StorageE2PRatio!A2                      rdim=1          cdim=0
        par=TagCanFuelBeTraded                      Rng=Par_TagCanFuelBeTraded!A2                      rdim=1          cdim=0

        par=ModelPeriodEmissionLimit       Rng=Par_ModelPeriodEmissionLimit!A2                    rdim=1        cdim=0
        par=RegionalModelPeriodEmissionLimit       Rng=Par_RegionalModelPeriodEmission!A2         rdim=2        cdim=0
        par=ModelPeriodExogenousEmission       Rng=Par_ModelPeriodExogenousEmissio!A2            rdim=2        cdim=0

        par=AnnualMinNewCapacity         Rng=Par_AnnualMinNewCapacity!A1                         rdim=2        cdim=1
        par=AnnualMaxNewCapacity         Rng=Par_AnnualMaxNewCapacity!A1                         rdim=2        cdim=1

$offecho

$ifi %switch_only_load_gdx%==0 $call "gdxxrw %inputdir%%data_file%.xlsx @%tempdir%temp_%data_file%_par.tmp o=%gdxdir%%data_file%_par.gdx MaxDupeErrors=99 CheckDate ";
$GDXin %gdxdir%%data_file%_par.gdx
$onUNDF
$loadm
$loadm SpecifiedAnnualDemand ReserveMarginTagFuel
$loadm EmissionsPenalty ReserveMargin AnnualExogenousEmission AnnualEmissionLimit RegionalAnnualEmissionLimit ReserveMarginTagTechnology
$loadm ReserveMarginTagFuel Readin_TradeRoute Readin_TradeCapacity GrowthRateTradeCapacity TradeCapacityGrowthCosts TradeCostFactor Readin_CommissionedTradeCapacity
$loadm InputActivityRatio OutputActivityRatio FixedCost CapitalCost VariableCost ResidualCapacity   EmissionsPenaltyTagTechnology
$loadm AvailabilityFactor CapacityFactor EmissionActivityRatio OperationalLife TotalAnnualMaxCapacity TotalAnnualMinCapacity EmissionContentPerFuel
$loadm TotalTechnologyAnnualActivityLowerLimit TotalTechnologyAnnualActivityUpperLimit ModelPeriodExogenousEmission AnnualExogenousEmission
$loadm Readin_TotalTechnologyModelPeriodActivityUpperLimit SpecifiedDemandDevelopment ProductionGrowthLimit
$loadm TechnologyToStorage TechnologyFromStorage StorageLevelStart MinStorageCharge REMinProductionTarget
$loadm CapitalCostStorage OperationalLifeStorage SelfSufficiency NewCapacityExpansionStop
$loadm ResidualStorageCapacity CapacityToActivityUnit TagCanFuelBeTraded
$loadm ModalSplitByFuelAndModalType TagTechnologyToModalType BaseYearProduction RegionalBaseYearProduction
$loadm TagTechnologyToSector AnnualSectoralEmissionLimit AnnualMinNewCapacity AnnualMaxNewCapacity
$loadm RegionalCCSLimit TagDemandFuelToSector TagElectricTechnology TagModalTypeToModalGroups
$loadm TagTechnologyToSubsets TagFuelToSubsets  RegionalModelPeriodEmissionLimit  ModelPeriodEmissionLimit StorageE2PRatio
$offUNDF

*
* ####### Step 3: Set regional values, if only value given for base-region #############
*

*CapitalCost(REGION_FULL,TECHNOLOGY,y)$(CapitalCost(REGION_FULL,TECHNOLOGY,y) = 0) = CapitalCost('%data_base_region%',TECHNOLOGY,y);
*VariableCost(REGION_FULL,TECHNOLOGY,MODE_OF_OPERATION,y)$(VariableCost(REGION_FULL,TECHNOLOGY,MODE_OF_OPERATION,y) = 0) = VariableCost('%data_base_region%',TECHNOLOGY,MODE_OF_OPERATION,y);
*FixedCost(REGION_FULL,TECHNOLOGY,y)$(FixedCost(REGION_FULL,TECHNOLOGY,y) = 0) = FixedCost('%data_base_region%',TECHNOLOGY,y);
*AvailabilityFactor(REGION_FULL,TECHNOLOGY,y)$(AvailabilityFactor(REGION_FULL,TECHNOLOGY,y) = 0) = AvailabilityFactor('%data_base_region%',TECHNOLOGY,y);
*InputActivityRatio(REGION_FULL,TECHNOLOGY,FUEL,MODE_OF_OPERATION,y)$(InputActivityRatio(REGION_FULL,TECHNOLOGY,FUEL,MODE_OF_OPERATION,y) = 0) = InputActivityRatio('%data_base_region%',TECHNOLOGY,FUEL,MODE_OF_OPERATION,y);
*OutputActivityRatio(REGION_FULL,TECHNOLOGY,FUEL,MODE_OF_OPERATION,y)$(OutputActivityRatio(REGION_FULL,TECHNOLOGY,FUEL,MODE_OF_OPERATION,y) = 0) = OutputActivityRatio('%data_base_region%',TECHNOLOGY,FUEL,MODE_OF_OPERATION,y);
*EmissionsPenaltyTagTechnology(REGION_FULL,t,e,y)$(EmissionsPenaltyTagTechnology(REGION_FULL,t,e,y) = 0) = EmissionsPenaltyTagTechnology('%data_base_region%',t,e,y);
*
*ReserveMarginTagTechnology(REGION_FULL,TECHNOLOGY,y)$(ReserveMarginTagTechnology(REGION_FULL,TECHNOLOGY,y) = 0) = ReserveMarginTagTechnology('%data_base_region%',TECHNOLOGY,y);
*EmissionActivityRatio(REGION_FULL,TECHNOLOGY,MODE_OF_OPERATION,EMISSION,YEAR)$(EmissionActivityRatio(REGION_FULL,TECHNOLOGY,MODE_OF_OPERATION,EMISSION,YEAR)=0) =  EmissionActivityRatio('%data_base_region%',TECHNOLOGY,MODE_OF_OPERATION,EMISSION,YEAR);
*
*EmissionsPenalty(REGION_FULL,e,y)$(EmissionsPenalty(REGION_FULL,e,y) <> EmissionsPenalty('%data_base_region%',e,y)) = EmissionsPenalty('%data_base_region%',e,y);
*
*SpecifiedDemandDevelopment(r_full,f,y)$(SpecifiedDemandDevelopment(r_full,f,y) = 0) = SpecifiedDemandDevelopment('%data_base_region%',f,y);
*RegionalModelPeriodEmissionLimit(r,e)$(RegionalModelPeriodEmissionLimit(r,e) = 0) = RegionalModelPeriodEmissionLimit('%data_base_region%',e);
*ModelPeriodExogenousEmission(r,e)$(ModelPeriodExogenousEmission(r,e) = 0) = ModelPeriodExogenousEmission('%data_base_region%',e);
*
*
**
** ####### Step 4: Set values, if no regional data available #############
**
*
*CapitalCost(REGION_FULL,TECHNOLOGY,y)$(CapitalCost(REGION_FULL,TECHNOLOGY,y) = 0) = CapitalCost('World',TECHNOLOGY,y);
*VariableCost(REGION_FULL,TECHNOLOGY,MODE_OF_OPERATION,y)$(VariableCost(REGION_FULL,TECHNOLOGY,MODE_OF_OPERATION,y) = 0) = VariableCost('World',TECHNOLOGY,MODE_OF_OPERATION,y);
*FixedCost(REGION_FULL,TECHNOLOGY,y)$(FixedCost(REGION_FULL,TECHNOLOGY,y) = 0) = FixedCost('World',TECHNOLOGY,y);
*AvailabilityFactor(REGION_FULL,TECHNOLOGY,y)$(AvailabilityFactor(REGION_FULL,TECHNOLOGY,y) = 0) = AvailabilityFactor('World',TECHNOLOGY,y);
*InputActivityRatio(REGION_FULL,TECHNOLOGY,FUEL,MODE_OF_OPERATION,y)$(InputActivityRatio(REGION_FULL,TECHNOLOGY,FUEL,MODE_OF_OPERATION,y) = 0) = InputActivityRatio('World',TECHNOLOGY,FUEL,MODE_OF_OPERATION,y);
*OutputActivityRatio(REGION_FULL,TECHNOLOGY,FUEL,MODE_OF_OPERATION,y)$(OutputActivityRatio(REGION_FULL,TECHNOLOGY,FUEL,MODE_OF_OPERATION,y) = 0) = OutputActivityRatio('World',TECHNOLOGY,FUEL,MODE_OF_OPERATION,y);
*EmissionsPenaltyTagTechnology(REGION_FULL,t,e,y)$(EmissionsPenaltyTagTechnology(REGION_FULL,t,e,y) = 0) = EmissionsPenaltyTagTechnology('World',t,e,y);
*
*ReserveMarginTagTechnology(REGION_FULL,TECHNOLOGY,y)$(ReserveMarginTagTechnology(REGION_FULL,TECHNOLOGY,y) = 0) = ReserveMarginTagTechnology('World',TECHNOLOGY,y);
*EmissionActivityRatio(REGION_FULL,TECHNOLOGY,MODE_OF_OPERATION,EMISSION,YEAR)$(EmissionActivityRatio(REGION_FULL,TECHNOLOGY,MODE_OF_OPERATION,EMISSION,YEAR)=0) =  EmissionActivityRatio('World',TECHNOLOGY,MODE_OF_OPERATION,EMISSION,YEAR);
*
*ReserveMarginTagFuel(r_full,f,y)$(ReserveMarginTagFuel(r_full,f,y)=0) =  ReserveMarginTagFuel('World',f,y);
*ReserveMargin(r_full,y)$(ReserveMargin(r_full,y)=0) = ReserveMargin('World',y);
*ReserveMarginTagTechnology(r_full,t,y)$(ReserveMarginTagTechnology(r_full,t,y)=0) = ReserveMarginTagTechnology('World',t,y);
*MinStorageCharge(r_full,s,y)$(MinStorageCharge(r_full,s,y)=0) = MinStorageCharge('World',s,y);
*CapitalCostStorage(r_full,s,y)$(CapitalCostStorage(r_full,s,y)=0) = CapitalCostStorage('World',s,y);
*
*RegionalAnnualEmissionLimit(r,e,y)$(RegionalAnnualEmissionLimit(r,e,y) = 0) = RegionalAnnualEmissionLimit('World',e,y);
*RegionalModelPeriodEmissionLimit(r,e)$(RegionalModelPeriodEmissionLimit(r,e) = 0) = RegionalModelPeriodEmissionLimit('World',e);
*ModelPeriodExogenousEmission(r,e)$(ModelPeriodExogenousEmission(r,e) = 0) = ModelPeriodExogenousEmission('World',e);
*TotalAnnualMaxCapacity(r_full,t,y)$(TotalAnnualMaxCapacity(r_full,t,y) = 0) = TotalAnnualMaxCapacity('World',t,y);
*ModalSplitByFuelAndModalType(r_full,f,mt,y)$(ModalSplitByFuelAndModalType(r_full,f,mt,y) = 0) = ModalSplitByFuelAndModalType('World',f,mt,y);
*
*SpecifiedDemandDevelopment(r_full,f,y)$(SpecifiedDemandDevelopment(r_full,f,y) = 0) = SpecifiedDemandDevelopment('World',f,y);

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
TradeRoute(r,f,y,rr) = Readin_TradeRoute(r,f,rr);
TradeCapacity(r,f,y,rr) = Readin_TradeCapacity(r,f,y,rr);
CommissionedTradeCapacity(r,f,y,rr) = Readin_CommissionedTradeCapacity(r,f,y,rr);

TradeCosts(r,f,y,rr) = TradeCostFactor(f,y)*TradeRoute(r,f,y,rr);
GrowthRateTradeCapacity(r,f,y,rr)$(GrowthRateTradeCapacity(r,f,y,rr) = 0) = GrowthRateTradeCapacity(r,f,'%year%',rr);

TradeLossFactor('Power',y) = 0.00003;
TradeLossBetweenRegions(r,f,y,rr) = TradeLossFactor(f,y)*TradeRoute(r,f,y,rr);

*
* ######### YearValue assignment #############
*
parameter YearVal(y_full);
YearVal(y) = y.val ;

*
* ####### Load from hourly Data #############
*
$include genesysmod_timeseries_reduction.gms


*
* ####### Ramping #############
*
$ifthen %switch_ramping% == 1

$onecho >%tempdir%temp_%data_file%_par2.tmp
se=0
        par=RampingUpFactor                Rng=Par_RampingUpFactor!A5                      rdim=2        cdim=0
        par=RampingDownFactor              Rng=Par_RampingDownFactor!A5                    rdim=2        cdim=0
        par=ProductionChangeCost           Rng=Par_ProductionChangeCost!A5                 rdim=2        cdim=0


$offecho

$ifi %switch_only_load_gdx%==0 $call "gdxxrw %inputdir%%data_file%.xlsx @%tempdir%temp_%data_file%_par2.tmp o=%gdxdir%%data_file%_par2.gdx MaxDupeErrors=99 CheckDate ";
$GDXin %gdxdir%%data_file%_par2.gdx
$onUNDF
$loadm RampingUpFactor RampingDownFactor
$loadm ProductionChangeCost
$offUNDF


MinActiveProductionPerTimeslice(y,l,'Power','RES_Hydro_Large',R_FULL) = 0.1;
MinActiveProductionPerTimeslice(y,l,'Power','RES_Hydro_Small',R_FULL) = 0.05;
$endif



*
* ########## Dataload of Employment Excel ##########
*
$ifthen %switch_employment_calculation% == 1

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






