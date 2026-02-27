* ============================================================
* GENeSYS-MOD v3.1 — RESULTS (COMPUTATION ONLY)
* - NO declarations (moved to genesysmod_dec.gms)
* - NO execute_unload / NO CSV export
* Safe to include inside AUGMECON loop
* ============================================================

* -------------------------------
* Trade & capacity diagnostics
* -------------------------------
check_tradecapacityusage(y,l,f,r,rr)$(Import.l(y,l,f,rr,r) and TagFuelToSubsets(f,'GasFuels')) =
    (TotalTradeCapacity.l(y,f,r,rr)*YearSplit(l,y)) - Import.l(y,l,f,rr,r);

check_tradecapacityfull(y,l,r,rr)$(
    sum(f$(TagFuelToSubsets(f,'GasFuels')),Import.l(y,l,f,rr,r))
      = (TotalTradeCapacity.l(y,'Gas_Natural',r,rr)*YearSplit(l,y))
    and TotalTradeCapacity.l(y,'Gas_Natural',r,rr)
) = 1;

output_pipeline_data('Percentage used of Pipeline network',f,l,r,rr,y)$(TotalTradeCapacity.l(y,'Gas_Natural',r,rr) and TagFuelToSubsets(f,'GasFuels')) =
    1 - (Import.l(y,l,f,rr,r)/(TotalTradeCapacity.l(y,'Gas_Natural',r,rr)*YearSplit(l,y)));

output_pipeline_data('Percentage used of Pipeline network','Unused',l,r,rr,y)$(TotalTradeCapacity.l(y,'Gas_Natural',r,rr)) =
    1 - sum(f$(TagFuelToSubsets(f,'GasFuels')),
            (Import.l(y,l,f,rr,r)/(TotalTradeCapacity.l(y,'Gas_Natural',r,rr)*YearSplit(l,y))));

output_pipeline_data('Percentage used of Pipeline network',f,'Yearly Average',r,rr,y)$(TotalTradeCapacity.l(y,'Gas_Natural',r,rr) and TagFuelToSubsets(f,'GasFuels')) =
    sum(l,Import.l(y,l,f,rr,r))/sum(l,(TotalTradeCapacity.l(y,'Gas_Natural',r,rr)*YearSplit(l,y)));

output_pipeline_data('Percentage used of Pipeline network','Unused','Yearly Average',r,rr,y)$(TotalTradeCapacity.l(y,'Gas_Natural',r,rr)) =
    1 - (sum((l,f)$(TagFuelToSubsets(f,'GasFuels')),Import.l(y,l,f,rr,r))
         /sum(l,(TotalTradeCapacity.l(y,'Gas_Natural',r,rr)*YearSplit(l,y))));

* -------------------------------
* Optional cost breakdowns (as original)
* -------------------------------
$ifthen.res_full %switch_only_write_results% == 0

z_fuelcosts('Hardcoal',y,r)    = VariableCost(r,'Z_Import_Hardcoal','1',y);
z_fuelcosts('Lignite',y,r)     = VariableCost(r,'R_Coal_Lignite','1',y);
z_fuelcosts('Nuclear',y,r)     = VariableCost(r,'R_Nuclear','1',y);
z_fuelcosts('Biomass',y,r)     = sum(t$(TagTechnologyToSubsets(t,'Biomass')),VariableCost(r,t,'1',y))/card(t);
z_fuelcosts('Gas_Natural',y,r) = VariableCost(r,'Z_Import_Gas','1',y);
z_fuelcosts('Oil',y,r)         = VariableCost(r,'Z_Import_Oil','1',y);
z_fuelcosts('H2',y,r)          = VariableCost(r,'Z_Import_H2','1',y);

* -------------------------------
* Energy balances (FULL, incl. transport, demand, trade)
* -------------------------------
output_energy_balance(r,se,t,m,f,l,'Production','PJ','%emissionPathway%_%emissionScenario%',y)$(
    TagTechnologyToSector(t,se) and not TagTechnologyToSector(t,'Transportation')
) = RateOfProductionByTechnologyByMode(y,l,t,m,f,r) * YearSplit(l,y);

output_energy_balance(r,'Transportation',t,m,f,l,'Production','billion km','%emissionPathway%_%emissionScenario%',y)$(
    TagTechnologyToSector(t,'Transportation')
) = RateOfProductionByTechnologyByMode(y,l,t,m,f,r) * YearSplit(l,y);

output_energy_balance(r,se,t,m,f,l,'Use','PJ','%emissionPathway%_%emissionScenario%',y)$(TagTechnologyToSector(t,se)) =
    -RateOfUseByTechnologyByMode(y,l,t,m,f,r) * YearSplit(l,y);

output_energy_balance(r,'Demand','Demand','1',f,l,'Use','PJ','%emissionPathway%_%emissionScenario%',y)$(
    Demand(y,l,f,r) > 0 and not TagDemandFuelToSector(f,'Transportation')
) = -Demand(y,l,f,r);

output_energy_balance(r,'Demand','Demand','1',f,l,'Use','billion km','%emissionPathway%_%emissionScenario%',y)$(
    Demand(y,l,f,r) > 0 and TagDemandFuelToSector(f,'Transportation')
) = -Demand(y,l,f,r);

output_energy_balance(r,'Trade','Trade','1',f,l,'Import','PJ','%emissionPathway%_%emissionScenario%',y) =
    sum(rr, Import.l(y,l,f,r,rr));

output_energy_balance(r,'Trade','Trade','1',f,l,'Export','PJ','%emissionPathway%_%emissionScenario%',y) =
    -sum(rr, Export.l(y,l,f,r,rr));

* -------------------------------
* Annual aggregation (FULL, incl. transport unit split, demand, trade)
* -------------------------------
output_energy_balance_annual(r,se,t,f,'Production','PJ','%emissionPathway%_%emissionScenario%',y)$(
    TagTechnologyToSector(t,se) and not TagTechnologyToSector(t,'Transportation')
) = sum((l,m), output_energy_balance(r,se,t,m,f,l,'Production','PJ','%emissionPathway%_%emissionScenario%',y));

output_energy_balance_annual(r,se,t,f,'Production','billion km','%emissionPathway%_%emissionScenario%',y)$(
    TagTechnologyToSector(t,se) and TagTechnologyToSector(t,'Transportation')
) = sum((l,m), output_energy_balance(r,se,t,m,f,l,'Production','billion km','%emissionPathway%_%emissionScenario%',y));

output_energy_balance_annual(r,se,t,f,'Use','PJ','%emissionPathway%_%emissionScenario%',y)$(TagTechnologyToSector(t,se)) =
    sum((l,m), output_energy_balance(r,se,t,m,f,l,'Use','PJ','%emissionPathway%_%emissionScenario%',y));

output_energy_balance_annual(r,'Demand','Demand',f,'Use','PJ','%emissionPathway%_%emissionScenario%',y)$(
    sum(l, Demand(y,l,f,r) > 0) and not TagDemandFuelToSector(f,'Transportation')
) = sum(l, output_energy_balance(r,'Demand','Demand','1',f,l,'Use','PJ','%emissionPathway%_%emissionScenario%',y));

output_energy_balance_annual(r,'Demand','Demand',f,'Use','billion km','%emissionPathway%_%emissionScenario%',y)$(
    sum(l, Demand(y,l,f,r) > 0) and TagDemandFuelToSector(f,'Transportation')
) = sum(l, output_energy_balance(r,'Demand','Demand','1',f,l,'Use','billion km','%emissionPathway%_%emissionScenario%',y));

output_energy_balance_annual(r,'Trade','Trade',f,'Import','PJ','%emissionPathway%_%emissionScenario%',y) =
    sum(l, output_energy_balance(r,'Trade','Trade','1',f,l,'Import','PJ','%emissionPathway%_%emissionScenario%',y));

output_energy_balance_annual(r,'Trade','Trade',f,'Export','PJ','%emissionPathway%_%emissionScenario%',y) =
    sum(l, output_energy_balance(r,'Trade','Trade','1',f,l,'Export','PJ','%emissionPathway%_%emissionScenario%',y));

* -------------------------------
* Capacity (FULL: peak/new/residual/total)
* -------------------------------
CapacityUsedByTechnologyEachTS(y,l,t,r)$(
    AvailabilityFactor(r,t,y) <> 0 and CapacityToActivityUnit(t) <> 0 and CapacityFactor(r,t,l,y) <> 0
) = RateOfProductionByTechnology(y,l,t,'Power',r)*YearSplit(l,y)
  / (AvailabilityFactor(r,t,y)*CapacityToActivityUnit(t)*CapacityFactor(r,t,l,y));

PeakCapacityByTechnology(r,t,y)$(sum(l,CapacityUsedByTechnologyEachTS(y,l,t,r)) <> 0) =
    smax(l, CapacityUsedByTechnologyEachTS(y,l,t,r));

output_capacity(r,se,t,'PeakCapacity','%emissionPathway%_%emissionScenario%',y)$(TagTechnologyToSector(t,se)) =
    PeakCapacityByTechnology(r,t,y);

output_capacity(r,se,t,'NewCapacity','%emissionPathway%_%emissionScenario%',y)$(TagTechnologyToSector(t,se)) =
    NewCapacity.l(y,t,r);

output_capacity(r,se,t,'ResidualCapacity','%emissionPathway%_%emissionScenario%',y)$(TagTechnologyToSector(t,se)) =
    ResidualCapacity(r,t,y);

output_capacity(r,se,t,'TotalCapacity','%emissionPathway%_%emissionScenario%',y)$(TagTechnologyToSector(t,se)) =
    TotalCapacityAnnual.l(y,t,r);

* -------------------------------
* Emissions (incl. exogenous)
* -------------------------------
output_emissions(r,se,e,t,'Emissions','%emissionPathway%_%emissionScenario%',y)$(TagTechnologyToSector(t,se)) =
    AnnualTechnologyEmission.l(y,t,e,r);

output_emissions(r,'ExogenousEmissions',e,'ExogenousEmissions','ExogenousEmissions','%emissionPathway%_%emissionScenario%',y) =
    AnnualExogenousEmission(r,e,y);

* -------------------------------
* Objectives (FULL, incl zBi)
* -------------------------------
output_z('z_system_costs','%emissionPathway%_%emissionScenario%') = z.l;
output_z('zBi_scalarized_objective','%emissionPathway%_%emissionScenario%') = zBi.l;
output_z('zAcc_acceptance_objective','%emissionPathway%_%emissionScenario%') = zAcc.l;

* -------------------------------
* Meta (FULL)
* -------------------------------
output_model('Objective Value','%emissionPathway%_%emissionScenario%','%emissionPathway%','%emissionScenario%') = z.l;
output_model('Heapsize Before Solve','%emissionPathway%_%emissionScenario%','%emissionPathway%','%emissionScenario%') = heapSizeBeforSolve;
*output_model('Heapsize After Solve','%emissionPathway%_%emissionScenario%','%emissionPathway%','%emissionScenario%') = heapSizeAfterSolve;
output_model('Elapsed Time','%emissionPathway%_%emissionScenario%','%emissionPathway%','%emissionScenario%') = elapsed;

* -------------------------------
* Detailed technology costs (as original)
* -------------------------------
z_maxgenerationperyear(r,t,y) =
    CapacityToActivityUnit(t) * smax(yy,AvailabilityFactor(r,t,yy)) * sum(l,CapacityFactor(r,t,l,y)/card(l));

output_technology_costs_detailed(r,t,f,'Capital Costs','MEUR/GW',y)$(
    TagTechnologyToSector(t,'Power') and sum(m,InputActivityRatio(r,t,f,m,y))
) = CapitalCost(r,t,y);

output_technology_costs_detailed(r,t,f,'Fixed Costs','MEUR/GW',y)$(
    TagTechnologyToSector(t,'Power') and sum(m,InputActivityRatio(r,t,f,m,y))
) = FixedCost(r,t,y);

output_technology_costs_detailed(r,t,f,'Variable Costs [excl. Fuel Costs]','MEUR/PJ',y)$(
    z_maxgenerationperyear(r,t,y) and TagTechnologyToSector(t,'Power') and sum(m,InputActivityRatio(r,t,f,m,y))
) = sum(m$(InputActivityRatio(r,t,f,m,y)),VariableCost(r,t,m,y));

output_technology_costs_detailed(r,t,f,'Variable Costs [incl. Fuel Costs]','MEUR/PJ',y)$(
    z_maxgenerationperyear(r,t,y) and TagTechnologyToSector(t,'Power') and sum(m,InputActivityRatio(r,t,f,m,y))
) = sum(m$(InputActivityRatio(r,t,f,m,y)),VariableCost(r,t,m,y))
  + sum(m$(InputActivityRatio(r,t,f,m,y)),InputActivityRatio(r,t,f,m,y));

output_technology_costs_detailed(r,t,f,'Levelized Costs [Emissions]','MEUR/PJ',y)$(
    z_maxgenerationperyear(r,t,y) and TagTechnologyToSector(t,'Power') and sum(m,InputActivityRatio(r,t,f,m,y))
) = EmissionsPenalty(r,'CO2',y)
  * sum(m$(InputActivityRatio(r,t,f,m,y)),
        InputActivityRatio(r,t,f,m,y)*EmissionContentPerFuel(f,'CO2')*EmissionActivityRatio(r,t,m,'CO2',y));

output_technology_costs_detailed(r,t,f,'Levelized Costs [Capex]','MEUR/PJ',y)$(
    z_maxgenerationperyear(r,t,y) and TagTechnologyToSector(t,'Power') and sum(m,InputActivityRatio(r,t,f,m,y))
) = CapitalCost(r,t,y)/(z_maxgenerationperyear(r,t,y)*OperationalLife(t));

output_technology_costs_detailed(r,t,f,'Levelized Costs [Generation]','MEUR/PJ',y)$(
    z_maxgenerationperyear(r,t,y) and TagTechnologyToSector(t,'Power') and sum(m,InputActivityRatio(r,t,f,m,y))
) = sum(m$(InputActivityRatio(r,t,f,m,y)),VariableCost(r,t,m,y))
  + sum(m,InputActivityRatio(r,t,f,m,y));

output_technology_costs_detailed(r,t,f,'Levelized Costs [Total]','MEUR/PJ',y)$(
    TagTechnologyToSector(t,'Power') and sum(m,InputActivityRatio(r,t,f,m,y))
) = output_technology_costs_detailed(r,t,f,'Levelized Costs [Generation]','MEUR/PJ',y)
  + output_technology_costs_detailed(r,t,f,'Levelized Costs [Capex]','MEUR/PJ',y)
  + output_technology_costs_detailed(r,t,f,'Levelized Costs [Emissions]','MEUR/PJ',y);

output_technology_costs_detailed(r,t,f,'Levelized Costs [Total w/o Emissions]','MEUR/PJ',y)$(
    TagTechnologyToSector(t,'Power') and sum(m,InputActivityRatio(r,t,f,m,y))
) = output_technology_costs_detailed(r,t,f,'Levelized Costs [Generation]','MEUR/PJ',y)
  + output_technology_costs_detailed(r,t,f,'Levelized Costs [Capex]','MEUR/PJ',y);

output_technology_costs_detailed(r,t,f,'Levelized Costs [Total]','EUR/MWh',y)$(
    TagTechnologyToSector(t,'Power') and sum(m,InputActivityRatio(r,t,f,m,y))
) = output_technology_costs_detailed(r,t,f,'Levelized Costs [Total]','MEUR/PJ',y)*3.6;

output_technology_costs_detailed(r,t,f,'Levelized Costs [Total w/o Emissions]','EUR/MWh',y)$(
    TagTechnologyToSector(t,'Power') and sum(m,InputActivityRatio(r,t,f,m,y))
) = output_technology_costs_detailed(r,t,f,'Levelized Costs [Total w/o Emissions]','MEUR/PJ',y)*3.6;

output_technology_costs_detailed(r,'Carbon','Carbon','Carbon Price','EUR/t CO2',y) =
    EmissionsPenalty(r,'CO2',y);

* Renewables / no input fuel (as original)
output_technology_costs_detailed(r,t,'none','Capital Costs','MEUR/GW',y)$(
    TagTechnologyToSector(t,'Power') and not sum((f,m),InputActivityRatio(r,t,f,m,y))
) = CapitalCost(r,t,y);

output_technology_costs_detailed(r,t,'none','Fixed Costs','MEUR/GW',y)$(
    TagTechnologyToSector(t,'Power') and not sum((f,m),InputActivityRatio(r,t,f,m,y))
) = FixedCost(r,t,y);

output_technology_costs_detailed(r,t,'none','Variable Costs [excl. Fuel Costs]','MEUR/PJ',y)$(
    z_maxgenerationperyear(r,t,y) and TagTechnologyToSector(t,'Power') and not sum((f,m),InputActivityRatio(r,t,f,m,y))
) = VariableCost(r,t,'1',y);

output_technology_costs_detailed(r,t,'none','Variable Costs [incl. Fuel Costs]','MEUR/PJ',y)$(
    z_maxgenerationperyear(r,t,y) and TagTechnologyToSector(t,'Power') and not sum((f,m),InputActivityRatio(r,t,f,m,y))
) = VariableCost(r,t,'1',y);

output_technology_costs_detailed(r,t,'none','Levelized Costs [Capex]','MEUR/PJ',y)$(
    z_maxgenerationperyear(r,t,y) and TagTechnologyToSector(t,'Power') and not sum((f,m),InputActivityRatio(r,t,f,m,y))
) = CapitalCost(r,t,y)/(z_maxgenerationperyear(r,t,y)*OperationalLife(t));

output_technology_costs_detailed(r,t,'none','Levelized Costs [Generation]','MEUR/PJ',y)$(
    z_maxgenerationperyear(r,t,y) and TagTechnologyToSector(t,'Power') and not sum((f,m),InputActivityRatio(r,t,f,m,y))
) = VariableCost(r,t,'1',y);

output_technology_costs_detailed(r,t,'none','Levelized Costs [Total]','MEUR/PJ',y)$(
    TagTechnologyToSector(t,'Power') and not sum((f,m),InputActivityRatio(r,t,f,m,y))
) = output_technology_costs_detailed(r,t,'none','Levelized Costs [Generation]','MEUR/PJ',y)
  + output_technology_costs_detailed(r,t,'none','Levelized Costs [Capex]','MEUR/PJ',y);

output_technology_costs_detailed(r,t,'none','Levelized Costs [Total w/o Emissions]','MEUR/PJ',y)$(
    TagTechnologyToSector(t,'Power') and not sum((f,m),InputActivityRatio(r,t,f,m,y))
) = output_technology_costs_detailed(r,t,'none','Levelized Costs [Generation]','MEUR/PJ',y)
  + output_technology_costs_detailed(r,t,'none','Levelized Costs [Capex]','MEUR/PJ',y);

output_technology_costs_detailed(r,t,'none','Levelized Costs [Total]','EUR/MWh',y)$(
    TagTechnologyToSector(t,'Power') and not sum((f,m),InputActivityRatio(r,t,f,m,y))
) = output_technology_costs_detailed(r,t,'none','Levelized Costs [Total]','MEUR/PJ',y)*3.6;

output_technology_costs_detailed(r,t,'none','Levelized Costs [Total w/o Emissions]','EUR/MWh',y)$(
    TagTechnologyToSector(t,'Power') and not sum((f,m),InputActivityRatio(r,t,f,m,y))
) = output_technology_costs_detailed(r,t,'none','Levelized Costs [Total w/o Emissions]','MEUR/PJ',y)*3.6;

* -------------------------------
* Exogenous costs + trade capacity outputs (as original)
* -------------------------------
output_exogenous_costs(r,t,'Capital Costs',y) = CapitalCost(r,t,y);
output_exogenous_costs(r,t,'Fixed Costs',y) = FixedCost(r,t,y);
output_exogenous_costs(r,t,'Variable Costs',y) = VariableCost(r,t,'1',y) + sum(f,InputActivityRatio(r,t,f,'1',y)*z_fuelcosts(f,y,r));
output_exogenous_costs(r,'Carbon','Carbon Price',y) = EmissionsPenalty(r,'CO2',y);

output_trade_capacity(r,rr,'Power Transmissions Capacity',y) = TotalTradeCapacity.l(y,'power',r,rr);
output_trade_capacity(r,rr,'Transmission Expansion Costs in MEUR/GW',y) = TradeCapacityGrowthCosts(r,'Power',rr)*TradeRoute(r,'Power',y,rr);

* -------------------------------
* Other indicators (as original)
* -------------------------------
SelfSufficiencyRate(r,y)$(SpecifiedAnnualDemand(r,'Power',y)>0) =
    ProductionAnnual(y,'Power',r)/(SpecifiedAnnualDemand(r,'Power',y)+UseAnnual(y,'Power',r));

ElectrificationRate(Sector,y)$(
    sum((f,r)$(TagDemandFuelToSector(f,Sector)>0),TagDemandFuelToSector(f,Sector)*ProductionAnnual(y,f,r)) > 0
) =
    sum((f,t,r)$(ProductionByTechnologyAnnual.l(y,t,f,r) > 0),
        TagDemandFuelToSector(f,Sector)*TagElectricTechnology(t)*ProductionByTechnologyAnnual.l(y,t,f,r))
  / sum((f,r)$(TagDemandFuelToSector(f,Sector)>0),TagDemandFuelToSector(f,Sector)*ProductionAnnual(y,f,r));

FinalEnergy(f) = no;
FinalEnergy('Power') = yes;
FinalEnergy('Biomass') = yes;
FinalEnergy('Hardcoal') = yes;
FinalEnergy('Lignite') = yes;
FinalEnergy('H2') = yes;
FinalEnergy('Gas_Natural') = yes;
FinalEnergy('Oil') = yes;
FinalEnergy('Nuclear') = yes;

EU27(r) = yes;
EU27('World') = no;

TagFinalDemandSector('Power')=1;
TagFinalDemandSector('Transportation')=1;
TagFinalDemandSector('Industry')=1;
TagFinalDemandSector('Buildings')=1;
TagFinalDemandSector('CHP')=1;

output_other('SelfSufficiencyRate',r,'X','X',y) = SelfSufficiencyRate(r,y);
output_other('ElectrificationRate','X',Sector,'X',y) = ElectrificationRate(Sector,y);
output_other('FinalEnergyConsumption',r,t,f,y) = UseByTechnologyAnnual.l(y,t,f,r)/3.6;
output_other('FinalEnergyConsumption',r,'InputDemand',f,y) = (SpecifiedAnnualDemand(r,f,y))/3.6;

output_other('ElectricityShareOfFinalEnergy',r,'X','X',y)$(SpecifiedAnnualDemand(r,'Power',y)>0) =
    (UseAnnual(y,'Power',r)+SpecifiedAnnualDemand(r,'Power',y))
    /(sum(FinalEnergy,UseAnnual(y,FinalEnergy,r))+SpecifiedAnnualDemand(r,'Power',y));

output_other('ElectricityShareOfFinalEnergy','Total','X','X',y) =
    sum(r,(UseAnnual(y,'Power',r)+SpecifiedAnnualDemand(r,'Power',y)))
    /sum(r,(sum(FinalEnergy,UseAnnual(y,FinalEnergy,r))+SpecifiedAnnualDemand(r,'Power',y)));

* -------------------------------
* Energy demand statistics (as original)
* -------------------------------
output_energydemandstatistics('Final Energy Demand [TWh]',se,r,f,y)$(
    TagFinalDemandSector(se) and not (diag(f,'Area_Rooftop_Residential')+diag(f,'Area_Rooftop_Commercial')+diag(f,'Heat_District'))
) = sum(t$(TagTechnologyToSector(t,se)),UseByTechnologyAnnual.l(y,t,f,r))/3.6;

output_energydemandstatistics('Final Energy Demand [TWh]','Exogenous',r,'Power',y) =
    SpecifiedAnnualDemand(r,'Power',y)/3.6;

output_energydemandstatistics('Final Energy Demand [TWh]',se,'Total',f,y)$(
    TagFinalDemandSector(se) and not (diag(f,'Area_Rooftop_Residential')+diag(f,'Area_Rooftop_Commercial')+diag(f,'Heat_District'))
) = sum(r,output_energydemandstatistics('Final Energy Demand [TWh]',se,r,f,y));

output_energydemandstatistics('Final Energy Demand [TWh]','Exogenous','Total','Power',y) =
    sum(r,output_energydemandstatistics('Final Energy Demand [TWh]','Exogenous',r,'Power',y));

output_energydemandstatistics('Final Energy Demand [TWh]',se,'EU27',f,y)$(
    TagFinalDemandSector(se) and not (diag(f,'Area_Rooftop_Residential')+diag(f,'Area_Rooftop_Commercial')+diag(f,'Heat_District'))
) = sum(EU27,output_energydemandstatistics('Final Energy Demand [TWh]',se,EU27,f,y));

output_energydemandstatistics('Final Energy Demand [TWh]','Exogenous','EU27','Power',y) =
    sum(EU27,output_energydemandstatistics('Final Energy Demand [TWh]','Exogenous',EU27,'Power',y));

output_energydemandstatistics('Final Energy Demand [TWh]','Total','Total',f,y) =
    sum(r, sum(se,output_energydemandstatistics('Final Energy Demand [TWh]',se,r,f,y))
          + output_energydemandstatistics('Final Energy Demand [TWh]','Exogenous',r,f,y));

output_energydemandstatistics('Final Energy Demand [TWh]','Total','EU27',f,y) =
    sum(EU27, sum(se,output_energydemandstatistics('Final Energy Demand [TWh]',se,EU27,f,y))
            + output_energydemandstatistics('Final Energy Demand [TWh]','Exogenous',EU27,f,y));

output_energydemandstatistics('Final Energy Demand [% of Total]','Total','EU27',f,y) =
    output_energydemandstatistics('Final Energy Demand [TWh]','Total','EU27',f,y)
    /sum(ff,output_energydemandstatistics('Final Energy Demand [TWh]','Total','EU27',ff,y));

output_energydemandstatistics('Final Energy Demand [% of Total]','Total','Total',f,y) =
    output_energydemandstatistics('Final Energy Demand [TWh]','Total','Total',f,y)
    /sum(ff,output_energydemandstatistics('Final Energy Demand [TWh]','Total','Total',ff,y));

output_energydemandstatistics('Primary Energy [TWh]','Total',r,f,y)$(not (diag(f,'Area_Rooftop_Residential')+diag(f,'Area_Rooftop_Commercial'))) =
    sum(t,ProductionByTechnologyAnnual.l(y,t,f,r)$(not sum((m,ff),InputActivityRatio(r,t,ff,m,y))))/3.6;

output_energydemandstatistics('Primary Energy [TWh]','Total','Total',f,y)$(not (diag(f,'Area_Rooftop_Residential')+diag(f,'Area_Rooftop_Commercial'))) =
    sum((t,r),ProductionByTechnologyAnnual.l(y,t,f,r)$(not sum((m,ff),InputActivityRatio(r,t,ff,m,y))))/3.6;

output_energydemandstatistics('Primary Energy [TWh]','Total','EU27',f,y)$(not (diag(f,'Area_Rooftop_Residential')+diag(f,'Area_Rooftop_Commercial'))) =
    sum((t,EU27),ProductionByTechnologyAnnual.l(y,t,f,EU27)$(not sum((m,ff),InputActivityRatio(EU27,t,ff,m,y))))/3.6;

output_energydemandstatistics('Primary Energy [% of Total]','Total',r,f,y)$(output_energydemandstatistics('Primary Energy [TWh]','Total',r,f,y)) =
    output_energydemandstatistics('Primary Energy [TWh]','Total',r,f,y)
    /sum(ff,output_energydemandstatistics('Primary Energy [TWh]','Total',r,ff,y));

output_energydemandstatistics('Primary Energy [% of Total]','Total','Total',f,y) =
    sum(r,output_energydemandstatistics('Primary Energy [TWh]','Total',r,f,y))
    /sum((r,ff),output_energydemandstatistics('Primary Energy [TWh]','Total',r,ff,y));

output_energydemandstatistics('Primary Energy [% of Total]','Total','EU27',f,y) =
    sum(EU27,output_energydemandstatistics('Primary Energy [TWh]','Total',EU27,f,y))
    /sum((EU27,ff),output_energydemandstatistics('Primary Energy [TWh]','Total',EU27,ff,y));

output_energydemandstatistics('Electricity Generation [TWh]','Power',r,f,y) =
    sum((t,m)$(not TagTechnologyToSector(t,'Storages')),
        sum(l, RateOfProductionByTechnologyByMode(y,l,t,m,'Power',r)$(InputActivityRatio(r,t,f,m,y)) * YearSplit(l,y)))/3.6;

output_energydemandstatistics('Electricity Generation [TWh]','Power',r,'Solar',y) =
    sum(t$(TagTechnologyToSubsets(t,'Solar')),ProductionByTechnologyAnnual.l(y,t,'Power',r))/3.6;

output_energydemandstatistics('Electricity Generation [TWh]','Power',r,'Wind',y) =
    sum(t$(TagTechnologyToSubsets(t,'Wind')),ProductionByTechnologyAnnual.l(y,t,'Power',r))/3.6;

output_energydemandstatistics('Electricity Generation [TWh]','Power',r,'Hydro',y) =
    sum(t$(TagTechnologyToSubsets(t,'Hydro')),ProductionByTechnologyAnnual.l(y,t,'Power',r))/3.6;

output_energydemandstatistics('Electricity Mix [%]','Power',r,'Solar',y)$(
    sum(t,ProductionByTechnologyAnnual.l(y,t,'Power',r)$(not TagTechnologyToSector(t,'Storages'))) > 0
) = output_energydemandstatistics('Electricity Generation [TWh]','Power',r,'Solar',y)
  /(sum(t,ProductionByTechnologyAnnual.l(y,t,'Power',r)$(not TagTechnologyToSector(t,'Storages')))/3.6);

output_energydemandstatistics('Electricity Mix [%]','Power',r,'Wind',y)$(
    sum(t,ProductionByTechnologyAnnual.l(y,t,'Power',r)$(not TagTechnologyToSector(t,'Storages'))) > 0
) = output_energydemandstatistics('Electricity Generation [TWh]','Power',r,'Wind',y)
  /(sum(t,ProductionByTechnologyAnnual.l(y,t,'Power',r)$(not TagTechnologyToSector(t,'Storages')))/3.6);

output_energydemandstatistics('Electricity Mix [%]','Power',r,'Hydro',y)$(
    sum(t,ProductionByTechnologyAnnual.l(y,t,'Power',r)$(not TagTechnologyToSector(t,'Storages'))) > 0
) = output_energydemandstatistics('Electricity Generation [TWh]','Power',r,'Hydro',y)
  /(sum(t,ProductionByTechnologyAnnual.l(y,t,'Power',r)$(not TagTechnologyToSector(t,'Storages')))/3.6);

output_energydemandstatistics('Electricity Mix [%]','Power',r,f,y)$(
    sum(t,ProductionByTechnologyAnnual.l(y,t,'Power',r)$(not TagTechnologyToSector(t,'Storages'))) > 0
    and output_energydemandstatistics('Electricity Generation [TWh]','Power',r,f,y)
) = output_energydemandstatistics('Electricity Generation [TWh]','Power',r,f,y)
  /(sum(t,ProductionByTechnologyAnnual.l(y,t,'Power',r)$(not TagTechnologyToSector(t,'Storages')))/3.6);

output_energydemandstatistics('Electricity Mix [%]','Power',r,'Other',y)$(
    sum(t,ProductionByTechnologyAnnual.l(y,t,'Power',r)$(not TagTechnologyToSector(t,'Storages'))) > 0
) =
    1
    - sum(f,output_energydemandstatistics('Electricity Mix [%]','Power',r,f,y))
    - output_energydemandstatistics('Electricity Mix [%]','Power',r,'Hydro',y)
    - output_energydemandstatistics('Electricity Mix [%]','Power',r,'Wind',y)
    - output_energydemandstatistics('Electricity Mix [%]','Power',r,'Solar',y);

output_energydemandstatistics('Import Share of Primary Energy [%]','Total',r,f,y)$(
    sum((t,m)$(TagTechnologyToSubsets(t,'ImportTechnology')),OutputActivityRatio(r,t,f,m,y))
    and output_energydemandstatistics('Primary Energy [TWh]','Total',r,f,y)>0
) = (sum(t,ProductionByTechnologyAnnual.l(y,t,f,r))/3.6)
  /sum(ff,output_energydemandstatistics('Primary Energy [TWh]','Total',r,ff,y));

output_energydemandstatistics('Import Share of Primary Energy [%]','Total','Total',f,y)$(
    sum((t,m,r)$(TagTechnologyToSubsets(t,'ImportTechnology')),OutputActivityRatio(r,t,f,m,y))
) = (sum((t,r),ProductionByTechnologyAnnual.l(y,t,f,r))/3.6)
  /sum(ff,output_energydemandstatistics('Primary Energy [TWh]','Total','Total',ff,y));

output_energydemandstatistics('Import Share of Primary Energy [%]','Total','EU27',f,y)$(
    sum((t,m,EU27)$(TagTechnologyToSubsets(t,'ImportTechnology')),OutputActivityRatio(EU27,t,f,m,y))
) = (sum((t,EU27),ProductionByTechnologyAnnual.l(y,t,f,EU27))/3.6)
  /sum(ff,output_energydemandstatistics('Primary Energy [TWh]','Total','EU27',ff,y));

$endif.res_full