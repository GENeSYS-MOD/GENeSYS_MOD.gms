$if %task% == "load_sets" $goto task_sets
$if %task% == "load_params" $goto task_params
$if %task% == "load_timeseries" $goto task_time

$label task_sets
$onEmbeddedCode Connect:
- ExcelReader:
    file: %in_file%
    symbols:
      - name: Region_full
        range: "Sets!A2"
        type: set
        rowDimension: 1
        columnDimension: 0

      - name: Technology
        range: "Sets!B2"
        type: set
        rowDimension: 1
        columnDimension: 0

      - name: Storage
        range: "Sets!C2"
        type: set
        rowDimension: 1
        columnDimension: 0

      - name: Fuel
        range: "Sets!D2"
        type: set
        rowDimension: 1
        columnDimension: 0

      - name: Mode_of_operation
        range: "Sets!E2"
        type: set
        rowDimension: 1
        columnDimension: 0

      - name: Emission
        range: "Sets!F2"
        type: set
        rowDimension: 1
        columnDimension: 0

      - name: ModalType
        range: "Sets!G2"
        type: set
        rowDimension: 1
        columnDimension: 0

      - name: Sector
        range: "Sets!H2"
        type: set
        rowDimension: 1
        columnDimension: 0

      - name: Year
        range: "Sets!I2"
        type: set
        rowDimension: 1
        columnDimension: 0

- GDXWriter:
    file: %out_file%
    symbols: all
$offEmbeddedCode
$exit

$label task_params
$onEmbeddedCode Connect:
- ExcelReader:
    file: %in_file%
    symbols:
      - name: SpecifiedAnnualDemand
        range: "Par_SpecifiedAnnualDemand!A2"
        rowDimension: 3
        columnDimension: 0

      - name: SpecifiedDemandDevelopment
        range: "Par_SpecifiedDemandDevelopment!A2"
        rowDimension: 3
        columnDimension: 0

      # Commented out in tmp
      # - name: SpecifiedDemandProfile
      #   range: "Par_SpecifiedDemandProfile!A2"
      #   rowDimension: 4
      #   columnDimension: 0

      - name: ReserveMarginTagFuel
        range: "Par_ReserveMarginTagFuel!A2"
        rowDimension: 3
        columnDimension: 0

      - name: EmissionsPenalty
        range: "Par_EmissionsPenalty!A2"
        rowDimension: 3
        columnDimension: 0

      - name: EmissionsPenaltyTagTechnology
        range: "Par_EmissionPenaltyTagTech!A2"
        rowDimension: 4
        columnDimension: 0

      - name: ReserveMargin
        range: "Par_ReserveMargin!A2"
        rowDimension: 2
        columnDimension: 0

      - name: AnnualExogenousEmission
        range: "Par_AnnualExogenousEmission!A2"
        rowDimension: 3
        columnDimension: 0

      - name: RegionalAnnualEmissionLimit
        range: "Par_RegionalAnnualEmissionLimit!A2"
        rowDimension: 3
        columnDimension: 0

      - name: AnnualEmissionLimit
        range: "Par_AnnualEmissionLimit!A2"
        rowDimension: 2
        columnDimension: 0

      - name: Readin_TradeRoute
        range: "Par_TradeRoute!A2"
        rowDimension: 3
        columnDimension: 0

      - name: TradeCostFactor
        range: "Par_TradeCostFactor!A2"
        rowDimension: 2
        columnDimension: 0

      - name: Readin_TradeCapacity
        range: "Par_TradeCapacity!A2"
        rowDimension: 4
        columnDimension: 0

      - name: Readin_CommissionedTradeCapacity
        range: "Par_CommissionedTradeCapacity!A2"
        rowDimension: 4
        columnDimension: 0

      - name: REMinProductionTarget
        range: "Par_REMinProductionTarget!A2"
        rowDimension: 3
        columnDimension: 0

      - name: SelfSufficiency
        range: "Par_SelfSufficiency!A2"
        rowDimension: 3
        columnDimension: 0

      - name: ProductionGrowthLimit
        range: "Par_ProductionGrowthLimit!A2"
        rowDimension: 2
        columnDimension: 0

      - name: Readin_GrowthRateTradeCapacity
        range: "Par_GrowthRateTradeCapacity!A2"
        rowDimension: 4
        columnDimension: 0

      - name: Readin_TradeCapacityGrowthCosts
        range: "Par_TradeCapacityGrowthCosts!A2"
        rowDimension: 3
        columnDimension: 0

      - name: CapacityToActivityUnit
        range: "Par_CapacityToActivityUnit!A2"
        rowDimension: 1
        columnDimension: 0

      - name: InputActivityRatio
        range: "Par_InputActivityRatio!A2"
        rowDimension: 5
        columnDimension: 0

      - name: OutputActivityRatio
        range: "Par_OutputActivityRatio!A2"
        rowDimension: 5
        columnDimension: 0

      - name: FixedCost
        range: "Par_FixedCost!A2"
        rowDimension: 3
        columnDimension: 0

      - name: CapitalCost
        range: "Par_CapitalCost!A2"
        rowDimension: 3
        columnDimension: 0

      - name: VariableCost
        range: "Par_VariableCost!A2"
        rowDimension: 4
        columnDimension: 0

      - name: ResidualCapacity
        range: "Par_ResidualCapacity!A2"
        rowDimension: 3
        columnDimension: 0

      - name: AvailabilityFactor
        range: "Par_AvailabilityFactor!A2"
        rowDimension: 3
        columnDimension: 0

      - name: CapacityFactor
        range: "Par_CapacityFactor!A2"
        rowDimension: 4
        columnDimension: 0

      - name: EmissionActivityRatio
        range: "Par_EmissionActivityRatio!A2"
        rowDimension: 5
        columnDimension: 0

      - name: EmissionContentPerFuel
        range: "Par_EmissionContentPerFuel!A2"
        rowDimension: 2
        columnDimension: 0

      - name: OperationalLife
        range: "Par_OperationalLife!A2"
        rowDimension: 1
        columnDimension: 0

      - name: TotalAnnualMaxCapacity
        range: "Par_TotalAnnualMaxCapacity!A2"
        rowDimension: 3
        columnDimension: 0

      - name: TotalAnnualMinCapacity
        range: "Par_TotalAnnualMinCapacity!A2"
        rowDimension: 3
        columnDimension: 0

      - name: NewCapacityExpansionStop
        range: "Par_NewCapacityExpansionStop!A2"
        rowDimension: 2
        columnDimension: 0

      - name: Readin_TotalTechnologyModelPeriodActivityUpperLimit
        range: "Par_ModelPeriodActivityMaxLimit!A2"
        rowDimension: 2
        columnDimension: 0

      - name: TotalTechnologyAnnualActivityUpperLimit
        range: "Par_TotalAnnualMaxActivity!A2"
        rowDimension: 3
        columnDimension: 0

      - name: TotalTechnologyAnnualActivityLowerLimit
        range: "Par_TotalAnnualMinActivity!A2"
        rowDimension: 3
        columnDimension: 0

      - name: ReserveMarginTagTechnology
        range: "Par_ReserveMarginTagTechnology!A2"
        rowDimension: 3
        columnDimension: 0

      - name: RegionalCCSLimit
        range: "Par_RegionalCCSLimit!A2"
        rowDimension: 1
        columnDimension: 0

      - name: TechnologyToStorage
        range: "Par_TechnologyToStorage!A2"
        rowDimension: 4
        columnDimension: 0

      - name: TechnologyFromStorage
        range: "Par_TechnologyFromStorage!A2"
        rowDimension: 4
        columnDimension: 0

      - name: StorageLevelStart
        range: "Par_StorageLevelStart!A2"
        rowDimension: 2
        columnDimension: 0

      - name: MinStorageCharge
        range: "Par_MinStorageCharge!A2"
        rowDimension: 3
        columnDimension: 0

      - name: OperationalLifeStorage
        range: "Par_OperationalLifeStorage!A2"
        rowDimension: 1
        columnDimension: 0

      - name: CapitalCostStorage
        range: "Par_CapitalCostStorage!A2"
        rowDimension: 3
        columnDimension: 0

      - name: ResidualStorageCapacity
        range: "Par_ResidualStorageCapacity!A2"
        rowDimension: 3
        columnDimension: 0

      - name: Readin_ModalSplitByFuelAndModalType
        range: "Par_ModalSplitByFuel!A2"
        rowDimension: 4
        columnDimension: 0

      - name: TagTechnologyToModalType
        range: "Par_TagTechnologyToModalType!A2"
        rowDimension: 3
        columnDimension: 0

      - name: BaseYearProduction
        range: "Par_BaseYearProduction!A2"
        rowDimension: 3
        columnDimension: 0

      - name: RegionalBaseYearProduction
        range: "Par_RegionalBaseYearProduction!A2"
        rowDimension: 4
        columnDimension: 0

      - name: TagTechnologyToSector
        range: "Par_TagTechnologyToSector!A2"
        rowDimension: 2
        columnDimension: 0

      - name: AnnualSectoralEmissionLimit
        range: "Par_AnnualSectoralEmissionLimit!A2"
        rowDimension: 3
        columnDimension: 0

      - name: TagDemandFuelToSector
        range: "Par_TagDemandFuelToSector!A2"
        rowDimension: 2
        columnDimension: 0

      - name: TagElectricTechnology
        range: "Par_TagElectricTechnology!A2"
        rowDimension: 1
        columnDimension: 0

      - name: TagTechnologyToSubsets
        range: "Par_TagTechnologyToSubsets!A2"
        rowDimension: 2
        columnDimension: 0

      - name: TagModalTypeToModalGroups
        range: "Par_TagModalTypeToModalGroups!A2"
        rowDimension: 2
        columnDimension: 0

      - name: TagFuelToSubsets
        range: "Par_TagFuelToSubsets!A2"
        rowDimension: 2
        columnDimension: 0

      - name: StorageE2PRatio
        range: "Par_StorageE2PRatio!A2"
        rowDimension: 1
        columnDimension: 0

      - name: TagCanFuelBeTraded
        range: "Par_TagCanFuelBeTraded!A2"
        rowDimension: 1
        columnDimension: 0

      - name: ModelPeriodEmissionLimit
        range: "Par_ModelPeriodEmissionLimit!A2"
        rowDimension: 1
        columnDimension: 0

      - name: RegionalModelPeriodEmissionLimit
        range: "Par_RegionalModelPeriodEmission!A2"
        rowDimension: 2
        columnDimension: 0

      - name: ModelPeriodExogenousEmission
        range: "Par_ModelPeriodExogenousEmissio!A2"
        rowDimension: 2
        columnDimension: 0

      - name: AnnualMinNewCapacity
        range: "Par_AnnualMinNewCapacity!A2"
        rowDimension: 3
        columnDimension: 0

      - name: AnnualMaxNewCapacity
        range: "Par_AnnualMaxNewCapacity!A2"
        rowDimension: 3
        columnDimension: 0
        
      - name: DistrictHeatDemand
        range: "Par_DistrictHeatDemand!A2"
        rowDimension: 2
        columnDimension: 0

      - name: DistrictHeatSplit
        range: "Par_DistrictHeatSplit!A2"
        rowDimension: 3
        columnDimension: 0

- GDXWriter:
    file: %out_file%
    symbols: all
    duplicateRecords: "last"
$offEmbeddedCode
$exit

$label task_time
$onEmbeddedCode Connect:
- ExcelReader:
    file: %in_file%
    symbols:
      - name: CountryData_PV_inf
        range: "TS_PV_INF!A1"
        rowDimension: 1
        columnDimension: 1

      - name: CountryData_PV_avg
        range: "TS_PV_AVG!A1"
        rowDimension: 1
        columnDimension: 1

      - name: CountryData_PV_opt
        range: "TS_PV_OPT!A1"
        rowDimension: 1
        columnDimension: 1

      - name: CountryData_PV_tracking
        range: "TS_PV_TRA!A1"
        rowDimension: 1
        columnDimension: 1

      - name: CountryData_Wind_Onshore_inf
        range: "TS_WIND_ONSHORE_INF!A1"
        rowDimension: 1
        columnDimension: 1

      - name: CountryData_Wind_Onshore_avg
        range: "TS_WIND_ONSHORE_AVG!A1"
        rowDimension: 1
        columnDimension: 1

      - name: CountryData_Wind_Onshore_opt
        range: "TS_WIND_ONSHORE_OPT!A1"
        rowDimension: 1
        columnDimension: 1

      - name: CountryData_Wind_Offshore
        range: "TS_WIND_OFFSHORE!A1"
        rowDimension: 1
        columnDimension: 1

      - name: CountryData_Wind_Offshore_Shallow
        range: "TS_WIND_OFFSHORE_SHALLOW!A1"
        rowDimension: 1
        columnDimension: 1

      - name: CountryData_Wind_Offshore_Deep
        range: "TS_WIND_OFFSHORE_DEEP!A1"
        rowDimension: 1
        columnDimension: 1

      - name: CountryData_Heat_High
        range: "TS_HEAT_HIGH!A1"
        rowDimension: 1
        columnDimension: 1

      - name: CountryData_Heat_Low
        range: "TS_HEAT_LOW!A1"
        rowDimension: 1
        columnDimension: 1

      - name: CountryData_Mobility_Psng
        range: "TS_MOBILITY_PSNG!A1"
        rowDimension: 1
        columnDimension: 1

      - name: CountryData_Load
        range: "TS_LOAD!A1"
        rowDimension: 1
        columnDimension: 1

      - name: CountryData_HeatPump_GroundSource
        range: "TS_HP_GROUNDSOURCE!A1"
        rowDimension: 1
        columnDimension: 1

      - name: CountryData_HeatPump_AirSource
        range: "TS_HP_AIRSOURCE!A1"
        rowDimension: 1
        columnDimension: 1

      - name: CountryData_Hydro_RoR
        range: "TS_HYDRO_ROR!A1"
        rowDimension: 1
        columnDimension: 1

- GDXWriter:
    file: %out_file%
    symbols: all
    duplicateRecords: "last"
$offEmbeddedCode
$exit