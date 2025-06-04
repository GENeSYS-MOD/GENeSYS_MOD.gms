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

parameter check_tradecapacityusage;
check_tradecapacityusage(y,l,f,r,rr)$(Import.l(y,l,f,rr,r) and TagFuelToSubsets(f,'GasFuels')) = (TotalTradeCapacity.l(y,f,r,rr)*YearSplit(l,y))-Import.l(y,l,f,rr,r);
parameter check_tradecapacityfull;
check_tradecapacityfull(y,l,r,rr)$(sum(f$(TagFuelToSubsets(f,'GasFuels')),Import.l(y,l,f,rr,r))=(TotalTradeCapacity.l(y,'Gas_Natural',r,rr)*YearSplit(l,y)) and TotalTradeCapacity.l(y,'Gas_Natural',r,rr)) = 1;
parameter output_pipeline_data;
output_pipeline_data('Percentage used of Pipeline network',f,l,r,rr,y)$(TotalTradeCapacity.l(y,'Gas_Natural',r,rr) and TagFuelToSubsets(f,'GasFuels')) = 1-(Import.l(y,l,f,rr,r)/(TotalTradeCapacity.l(y,'Gas_Natural',r,rr)*YearSplit(l,y)));
parameter output_pipeline_data;
output_pipeline_data('Percentage used of Pipeline network','Unused',l,r,rr,y)$(TotalTradeCapacity.l(y,'Gas_Natural',r,rr)) = 1-sum(f$(TagFuelToSubsets(f,'GasFuels')),(Import.l(y,l,f,rr,r)/(TotalTradeCapacity.l(y,'Gas_Natural',r,rr)*YearSplit(l,y))));
parameter output_pipeline_data;
output_pipeline_data('Percentage used of Pipeline network',f,'Yearly Average',r,rr,y)$(TotalTradeCapacity.l(y,'Gas_Natural',r,rr) and TagFuelToSubsets(f,'GasFuels')) = sum(l,Import.l(y,l,f,rr,r))/sum(l,(TotalTradeCapacity.l(y,'Gas_Natural',r,rr)*YearSplit(l,y)));
parameter output_pipeline_data;
output_pipeline_data('Percentage used of Pipeline network','Unused','Yearly Average',r,rr,y)$(TotalTradeCapacity.l(y,'Gas_Natural',r,rr)) = 1-(sum((l,f)$(TagFuelToSubsets(f,'GasFuels')),Import.l(y,l,f,rr,r))/sum(l,(TotalTradeCapacity.l(y,'Gas_Natural',r,rr)*YearSplit(l,y))));


$ifthen %switch_only_write_results% == 0
parameter z_fuelcosts;
z_fuelcosts('Hardcoal',y,r) = VariableCost(r,'Z_Import_Hardcoal','1',y);
z_fuelcosts('Lignite',y,r) = VariableCost(r,'R_Coal_Lignite','1',y);
z_fuelcosts('Nuclear',y,r) = VariableCost(r,'R_Nuclear','1',y);
z_fuelcosts('Biomass',y,r) = sum(t$(TagTechnologyToSubsets(t,'Biomass')),VariableCost(r,t,'1',y))/card(t) ;
z_fuelcosts('Gas_Natural',y,r) = VariableCost(r,'Z_Import_Gas','1',y);
z_fuelcosts('Oil',y,r) = VariableCost(r,'Z_Import_Oil','1',y);
z_fuelcosts('H2',y,r) = VariableCost(r,'Z_Import_H2','1',y);
$include genesysmod_levelizedcosts.gms

parameter output_energy_balance(*,*,*,*,*,*,*,*,*,*);
output_energy_balance(r,se,t,m,f,l,'Production','PJ','%emissionPathway%_%emissionScenario%',y)$(TagTechnologyToSector(t,se) and not TagTechnologyToSector(t,'Transportation'))= round(RateOfProductionByTechnologyByMode(y,l,t,m,f,r) * YearSplit(l,y),4);
output_energy_balance(r,'Transportation',t,m,f,l,'Production','billion km','%emissionPathway%_%emissionScenario%',y)$(TagTechnologyToSector(t,'Transportation'))= round(RateOfProductionByTechnologyByMode(y,l,t,m,f,r) * YearSplit(l,y),4);
output_energy_balance(r,se,t,m,f,l,'Use','PJ','%emissionPathway%_%emissionScenario%',y)$(TagTechnologyToSector(t,se)) = round(- RateOfUseByTechnologyByMode(y,l,t,m,f,r) * YearSplit(l,y),4);
output_energy_balance(r,'Demand','Demand','1',f,l,'Use','PJ','%emissionPathway%_%emissionScenario%',y)$(Demand(y,l,f,r) > 0 and not TagDemandFuelToSector(f,'Transportation')) = round(- Demand(y,l,f,r),4) ;
output_energy_balance(r,'Demand','Demand','1',f,l,'Use','billion km','%emissionPathway%_%emissionScenario%',y)$(Demand(y,l,f,r) > 0 and TagDemandFuelToSector(f,'Transportation')) = round(- Demand(y,l,f,r),4) ;
output_energy_balance(r,'Trade','Trade','1',f,l,'Import','PJ','%emissionPathway%_%emissionScenario%',y) = round(sum(rr, Import.l(y,l,f,r,rr)),4) ;
output_energy_balance(r,'Trade','Trade','1',f,l,'Export','PJ','%emissionPathway%_%emissionScenario%',y) = round(- sum(rr, Export.l(y,l,f,r,rr)),4) ;
$include genesysmod_baseyear_2020.gms

parameter output_energy_balance_annual(*,*,*,*,*,*,*,*);
output_energy_balance_annual(r,se,t,f,'Production','PJ','%emissionPathway%_%emissionScenario%',y)$(TagTechnologyToSector(t,se)  and not TagTechnologyToSector(t,'Transportation')) = sum((l,m),output_energy_balance(r,se,t,m,f,l,'Production','PJ','%emissionPathway%_%emissionScenario%',y));
output_energy_balance_annual(r,se,t,f,'Production','billion km','%emissionPathway%_%emissionScenario%',y)$(TagTechnologyToSector(t,se) and TagTechnologyToSector(t,'Transportation')) = sum((l,m),output_energy_balance(r,se,t,m,f,l,'Production','billion km','%emissionPathway%_%emissionScenario%',y));
output_energy_balance_annual(r,se,t,f,'Use','PJ','%emissionPathway%_%emissionScenario%',y)$(TagTechnologyToSector(t,se)) = sum((l,m),output_energy_balance(r,se,t,m,f,l,'Use','PJ','%emissionPathway%_%emissionScenario%',y));
output_energy_balance_annual(r,'Demand','Demand',f,'Use','PJ','%emissionPathway%_%emissionScenario%',y)$(sum(l,Demand(y,l,f,r) > 0) and not TagDemandFuelToSector(f,'Transportation')) = sum(l,output_energy_balance(r,'Demand','Demand','1',f,l,'Use','PJ','%emissionPathway%_%emissionScenario%',y)) ;
output_energy_balance_annual(r,'Demand','Demand',f,'Use','billion km','%emissionPathway%_%emissionScenario%',y)$(sum(l,Demand(y,l,f,r) > 0) and TagDemandFuelToSector(f,'Transportation')) = sum(l,output_energy_balance(r,'Demand','Demand','1',f,l,'Use','billion km','%emissionPathway%_%emissionScenario%',y)) ;
output_energy_balance_annual(r,'Trade','Trade',f,'Import','PJ','%emissionPathway%_%emissionScenario%',y) = sum(l, output_energy_balance(r,'Trade','Trade','1',f,l,'Import','PJ','%emissionPathway%_%emissionScenario%',y)) ;
output_energy_balance_annual(r,'Trade','Trade',f,'Export','PJ','%emissionPathway%_%emissionScenario%',y) = sum(l, output_energy_balance(r,'Trade','Trade','1',f,l,'Export','PJ','%emissionPathway%_%emissionScenario%',y)) ;

parameter CapacityUsedByTechnologyEachTS, PeakCapacityByTechnology;
CapacityUsedByTechnologyEachTS(y,l,t,r)$(AvailabilityFactor(r,t,y) <> 0 and CapacityToActivityUnit(t) <> 0 and CapacityFactor(r,t,l,y) <> 0) = RateOfProductionByTechnology(y,l,t,'Power',r)*YearSplit(l,y)/(AvailabilityFactor(r,t,y)*CapacityToActivityUnit(t)*CapacityFactor(r,t,l,y));
PeakCapacityByTechnology(r,t,y)$(sum(l,CapacityUsedByTechnologyEachTS(y,l,t,r)) <> 0) = smax(l, CapacityUsedByTechnologyEachTS(y,l,t,r));

parameter output_capacity(*,*,*,*,*,*);
output_capacity(r,se,t,'PeakCapacity','%emissionPathway%_%emissionScenario%',y)$(TagTechnologyToSector(t,se)) = round(PeakCapacityByTechnology(y,t,r),4) ;
output_capacity(r,se,t,'NewCapacity','%emissionPathway%_%emissionScenario%',y)$(TagTechnologyToSector(t,se)) = round(NewCapacity.l(y,t,r),4) ;
output_capacity(r,se,t,'ResidualCapacity','%emissionPathway%_%emissionScenario%',y)$(TagTechnologyToSector(t,se)) = round(ResidualCapacity(r,t,y),4) ;
output_capacity(r,se,t,'TotalCapacity','%emissionPathway%_%emissionScenario%',y)$(TagTechnologyToSector(t,se)) = round(TotalCapacityAnnual.l(y,t,r),4) ;

parameter output_emissions(*,*,*,*,*,*,*);
output_emissions(r,se,e,t,'Emissions','%emissionPathway%_%emissionScenario%',y)$(TagTechnologyToSector(t,se))  = AnnualTechnologyEmission.l(y,t,e,r);
output_emissions(r,'ExogenousEmissions',e,'ExogenousEmissions','ExogenousEmissions','%emissionPathway%_%emissionScenario%',y)  = AnnualExogenousEmission(r,e,y);

parameter output_model(*,*,*,*);
output_model('Objective Value','%emissionPathway%_%emissionScenario%','%emissionPathway%','%emissionScenario%') = z.l;
output_model('Heapsize Before Solve','%emissionPathway%_%emissionScenario%','%emissionPathway%','%emissionScenario%') = heapSizeBeforSolve;
output_model('Heapsize After Solve','%emissionPathway%_%emissionScenario%','%emissionPathway%','%emissionScenario%') = heapSizeAfterSolve;
output_model('Elapsed Time','%emissionPathway%_%emissionScenario%','%emissionPathway%','%emissionScenario%') = elapsed;

parameter z_maxgenerationperyear(r_full,t,y_full);
z_maxgenerationperyear(r,t,y) = CapacityToActivityUnit(t)*smax(yy,AvailabilityFactor(r,t,yy))*sum(l,CapacityFactor(r,t,l,y)/card(l));

parameter output_technology_costs_detailed;
output_technology_costs_detailed(r,t,f,'Capital Costs','MEUR/GW',y)$(TagTechnologyToSector(t,'Power') and sum(m,InputActivityRatio(r,t,f,m,y))) = CapitalCost(r,t,y);
output_technology_costs_detailed(r,t,f,'Fixed Costs','MEUR/GW',y)$(TagTechnologyToSector(t,'Power') and sum(m,InputActivityRatio(r,t,f,m,y))) = FixedCost(r,t,y);
output_technology_costs_detailed(r,t,f,'Variable Costs [excl. Fuel Costs]','MEUR/PJ',y)$(z_maxgenerationperyear(r,t,y) and TagTechnologyToSector(t,'Power') and sum(m,InputActivityRatio(r,t,f,m,y))) = sum(m$(InputActivityRatio(r,t,f,m,y)),VariableCost(r,t,m,y));
output_technology_costs_detailed(r,t,f,'Variable Costs [incl. Fuel Costs]','MEUR/PJ',y)$(z_maxgenerationperyear(r,t,y) and TagTechnologyToSector(t,'Power') and sum(m,InputActivityRatio(r,t,f,m,y))) = sum(m$(InputActivityRatio(r,t,f,m,y)),VariableCost(r,t,m,y)) + sum(m$(InputActivityRatio(r,t,f,m,y)),InputActivityRatio(r,t,f,m,y)*resourcecosts(r,f,y));
output_technology_costs_detailed(r,t,f,'Levelized Costs [Emissions]','MEUR/PJ',y)$(z_maxgenerationperyear(r,t,y) and TagTechnologyToSector(t,'Power') and sum(m,InputActivityRatio(r,t,f,m,y))) = EmissionsPenalty(r,'CO2',y)*sum((m)$(InputActivityRatio(r,t,f,m,y)),InputActivityRatio(r,t,f,m,y)*EmissionContentPerFuel(f,'CO2')*EmissionActivityRatio(r,t,m,'CO2',y));
output_technology_costs_detailed(r,t,f,'Levelized Costs [Capex]','MEUR/PJ',y)$(z_maxgenerationperyear(r,t,y) and TagTechnologyToSector(t,'Power') and sum(m,InputActivityRatio(r,t,f,m,y))) = CapitalCost(r,t,y)/(z_maxgenerationperyear(r,t,y)*OperationalLife(t));
output_technology_costs_detailed(r,t,f,'Levelized Costs [Generation]','MEUR/PJ',y)$(z_maxgenerationperyear(r,t,y) and TagTechnologyToSector(t,'Power') and sum(m,InputActivityRatio(r,t,f,m,y))) = sum(m$(InputActivityRatio(r,t,f,m,y)),VariableCost(r,t,m,y)) + sum((m),InputActivityRatio(r,t,f,m,y)*resourcecosts(r,f,y));
output_technology_costs_detailed(r,t,f,'Levelized Costs [Total]','MEUR/PJ',y)$(TagTechnologyToSector(t,'Power') and sum(m,InputActivityRatio(r,t,f,m,y))) = output_technology_costs_detailed(r,t,f,'Levelized Costs [Generation]','MEUR/PJ',y)+output_technology_costs_detailed(r,t,f,'Levelized Costs [Capex]','MEUR/PJ',y)+output_technology_costs_detailed(r,t,f,'Levelized Costs [Emissions]','MEUR/PJ',y);
output_technology_costs_detailed(r,t,f,'Levelized Costs [Total w/o Emissions]','MEUR/PJ',y)$(TagTechnologyToSector(t,'Power') and sum(m,InputActivityRatio(r,t,f,m,y))) = output_technology_costs_detailed(r,t,f,'Levelized Costs [Generation]','MEUR/PJ',y)+output_technology_costs_detailed(r,t,f,'Levelized Costs [Capex]','MEUR/PJ',y);
output_technology_costs_detailed(r,t,f,'Levelized Costs [Total]','EUR/MWh',y)$(TagTechnologyToSector(t,'Power') and sum(m,InputActivityRatio(r,t,f,m,y))) = output_technology_costs_detailed(r,t,f,'Levelized Costs [Total]','MEUR/PJ',y)*3.6;
output_technology_costs_detailed(r,t,f,'Levelized Costs [Total w/o Emissions]','EUR/MWh',y)$(TagTechnologyToSector(t,'Power') and sum(m,InputActivityRatio(r,t,f,m,y))) = output_technology_costs_detailed(r,t,f,'Levelized Costs [Total w/o Emissions]','MEUR/PJ',y)*3.6;
output_technology_costs_detailed(r,'Carbon','Carbon','Carbon Price','EUR/t CO2',y) = EmissionsPenalty(r,'CO2',y);
output_technology_costs_detailed(r,t,f,'Levelized Costs [Total]','MEUR/PJ',y)$(TagTechnologyToSector(t,'Storages') and OutputActivityRatio(r,t,'Power','2',y) and sum(m,InputActivityRatio(r,t,f,m,y))) = VariableCost(r,t,'1',y)*5;
output_technology_costs_detailed(r,t,f,'Levelized Costs [Total]','EUR/MWh',y)$(TagTechnologyToSector(t,'Storages') and sum(m,InputActivityRatio(r,t,f,m,y))) = output_technology_costs_detailed(r,t,f,'Levelized Costs [Total]','MEUR/PJ',y)*3.6;


** For Renewables, since they don't have an input fuel
output_technology_costs_detailed(r,t,'none','Capital Costs','MEUR/GW',y)$(TagTechnologyToSector(t,'Power') and not sum((f,m),InputActivityRatio(r,t,f,m,y))) = CapitalCost(r,t,y);
output_technology_costs_detailed(r,t,'none','Fixed Costs','MEUR/GW',y)$(TagTechnologyToSector(t,'Power') and not sum((f,m),InputActivityRatio(r,t,f,m,y))) = FixedCost(r,t,y);
output_technology_costs_detailed(r,t,'none','Variable Costs [excl. Fuel Costs]','MEUR/PJ',y)$(z_maxgenerationperyear(r,t,y) and TagTechnologyToSector(t,'Power') and not sum((f,m),InputActivityRatio(r,t,f,m,y))) = VariableCost(r,t,'1',y);
output_technology_costs_detailed(r,t,'none','Variable Costs [incl. Fuel Costs]','MEUR/PJ',y)$(z_maxgenerationperyear(r,t,y) and TagTechnologyToSector(t,'Power') and not sum((f,m),InputActivityRatio(r,t,f,m,y))) = VariableCost(r,t,'1',y);

output_technology_costs_detailed(r,t,'none','Levelized Costs [Capex]','MEUR/PJ',y)$(z_maxgenerationperyear(r,t,y) and TagTechnologyToSector(t,'Power') and not sum((f,m),InputActivityRatio(r,t,f,m,y))) = CapitalCost(r,t,y)/(z_maxgenerationperyear(r,t,y)*OperationalLife(t));
output_technology_costs_detailed(r,t,'none','Levelized Costs [Generation]','MEUR/PJ',y)$(z_maxgenerationperyear(r,t,y) and TagTechnologyToSector(t,'Power') and not sum((f,m),InputActivityRatio(r,t,f,m,y))) = VariableCost(r,t,'1',y);
output_technology_costs_detailed(r,t,'none','Levelized Costs [Total]','MEUR/PJ',y)$(TagTechnologyToSector(t,'Power') and  not sum((f,m),InputActivityRatio(r,t,f,m,y))) = output_technology_costs_detailed(r,t,'none','Levelized Costs [Generation]','MEUR/PJ',y)+output_technology_costs_detailed(r,t,'none','Levelized Costs [Capex]','MEUR/PJ',y);
output_technology_costs_detailed(r,t,'none','Levelized Costs [Total w/o Emissions]','MEUR/PJ',y)$(TagTechnologyToSector(t,'Power') and  not sum((f,m),InputActivityRatio(r,t,f,m,y))) = output_technology_costs_detailed(r,t,'none','Levelized Costs [Generation]','MEUR/PJ',y)+output_technology_costs_detailed(r,t,'none','Levelized Costs [Capex]','MEUR/PJ',y);
output_technology_costs_detailed(r,t,'none','Levelized Costs [Total]','EUR/MWh',y)$(TagTechnologyToSector(t,'Power') and not sum((f,m),InputActivityRatio(r,t,f,m,y))) = output_technology_costs_detailed(r,t,'none','Levelized Costs [Total]','MEUR/PJ',y)*3.6;
output_technology_costs_detailed(r,t,'none','Levelized Costs [Total w/o Emissions]','EUR/MWh',y)$(TagTechnologyToSector(t,'Power') and not sum((f,m),InputActivityRatio(r,t,f,m,y))) = output_technology_costs_detailed(r,t,'none','Levelized Costs [Total w/o Emissions]','MEUR/PJ',y)*3.6;


parameter output_exogenous_costs;
output_exogenous_costs(r,t,'Capital Costs',y) = CapitalCost(r,t,y);
output_exogenous_costs(r,t,'Fixed Costs',y) = FixedCost(r,t,y);
output_exogenous_costs(r,t,'Variable Costs',y) = VariableCost(r,t,'1',y) + sum((f),InputActivityRatio(r,t,f,'1',y)*z_fuelcosts(f,y,r));
output_exogenous_costs(r,'Carbon','Carbon Price',y) = EmissionsPenalty(r,'CO2',y);

parameter output_trade;
output_trade(r,rr,f,'Transmissions Capacity',y) = TotalTradeCapacity.l(y, f, r, rr);
output_trade(r,rr,f,'Transmission Expansion Costs in MEUR/GW',y) = TradeCapacityGrowthCosts(r,f,rr)*TradeRoute(r,f,y,rr);
output_trade('General','General',f,'Transmission Expansion Costs in MEUR/GW/km',y) = TradeCapacityGrowthCosts('%data_base_region%',f,'%data_base_region%');
output_trade(r,rr,f,'Export',y) = sum(l,Export.l(y,l,f,r,rr));
output_trade(r,rr,f,'Import',y) = sum(l,Import.l(y,l,f,r,rr));

parameters SelfSufficiencyRate,ElectrificationRate,output_other;
SelfSufficiencyRate(r,y) = ProductionAnnual(y,'Power',r)/(SpecifiedAnnualDemand(r,'Power',y)+UseAnnual(y,'Power',r));
ElectrificationRate(Sector,y)$(sum((f,r)$(TagDemandFuelToSector(f,Sector)>0),TagDemandFuelToSector(f,Sector)*ProductionAnnual(y,f,r)) > 0) = sum((f,t,r)$(ProductionByTechnologyAnnual.l(y,t,f,r) > 0), TagDemandFuelToSector(f,Sector)*TagElectricTechnology(t)*ProductionByTechnologyAnnual.l(y,t,f,r))/sum((f,r)$(TagDemandFuelToSector(f,Sector)>0),TagDemandFuelToSector(f,Sector)*ProductionAnnual(y,f,r));

Set FinalEnergy(f);
FinalEnergy(f) = no;
FinalEnergy('Power') = yes;
FinalEnergy('Biomass') = yes;
FinalEnergy('Hardcoal') = yes;
FinalEnergy('Lignite') = yes;
FinalEnergy('H2') = yes;
FinalEnergy('H2_Blend') = yes;
FinalEnergy('Gas_Natural') = yes;
FinalEnergy('Oil') = yes;
FinalEnergy('Nuclear') = yes;


Set EU27(r_full);
EU27(r) = yes;
EU27('World') = no;
$ifthen %model_region% == europe
EU27('CH') = no;
EU27('NO') = no;
EU27('NONEU_Balkan') = no;
EU27('TR') = no;
EU27('UK') = no;
$endif

parameter TagFinalDemandSector(se);
TagFinalDemandSector('Power')=1;
TagFinalDemandSector('Transportation')=1;
TagFinalDemandSector('Industry')=1;
TagFinalDemandSector('Buildings')=1;
TagFinalDemandSector('CHP')=1;


output_other('SelfSufficiencyRate',r,'X','X',y) = SelfSufficiencyRate(r,y) ;
output_other('ElectrificationRate','X',Sector,'X',y)  = ElectrificationRate(Sector,y) ;
output_other('FinalEnergyConsumption',r,t,f,y) =  UseByTechnologyAnnual.l(y,t,f,r)/3.6;
output_other('FinalEnergyConsumption',r,'InputDemand',f,y) = (SpecifiedAnnualDemand(r,f,y))/3.6;
output_other('ElectricityShareOfFinalEnergy',r,'X','X',y) = (UseAnnual(y,'Power',r)+SpecifiedAnnualDemand(r,'Power',y)) /  (sum(FinalEnergy,UseAnnual(y,FinalEnergy,r))+SpecifiedAnnualDemand(r,'Power',y));
output_other('ElectricityShareOfFinalEnergy','Total','X','X',y) = sum(r,(UseAnnual(y,'Power',r)+SpecifiedAnnualDemand(r,'Power',y))) /  sum(r,(sum(FinalEnergy,UseAnnual(y,FinalEnergy,r))+SpecifiedAnnualDemand(r,'Power',y)));

parameter output_energydemandstatistics;
*** Final Energy for all regions per sector
output_energydemandstatistics('Final Energy Demand [TWh]',se,r,f,y)$(TagFinalDemandSector(se) and not (diag(f,'Area_Rooftop_Residential')+diag(f,'Area_Rooftop_Commercial')+diag(f,'Heat_District'))) = sum(t$(TagTechnologyToSector(t,se)),UseByTechnologyAnnual.l(y,t,f,r))/3.6;
output_energydemandstatistics('Final Energy Demand [TWh]','Exogenous',r,'Power',y) = SpecifiedAnnualDemand(r,'Power',y)/3.6;
*** Final Energy per sector; regional aggregates
output_energydemandstatistics('Final Energy Demand [TWh]',se,'Total',f,y)$(TagFinalDemandSector(se) and not (diag(f,'Area_Rooftop_Residential')+diag(f,'Area_Rooftop_Commercial')+diag(f,'Heat_District'))) = sum((r),output_energydemandstatistics('Final Energy Demand [TWh]',se,r,f,y));
output_energydemandstatistics('Final Energy Demand [TWh]','Exogenous','Total','Power',y) = sum(r,output_energydemandstatistics('Final Energy Demand [TWh]','Exogenous',r,'Power',y));
output_energydemandstatistics('Final Energy Demand [TWh]',se,'EU27',f,y)$(TagFinalDemandSector(se) and not (diag(f,'Area_Rooftop_Residential')+diag(f,'Area_Rooftop_Commercial')+diag(f,'Heat_District'))) = sum((EU27),output_energydemandstatistics('Final Energy Demand [TWh]',se,EU27,f,y));
output_energydemandstatistics('Final Energy Demand [TWh]','Exogenous','EU27','Power',y) = sum((EU27),output_energydemandstatistics('Final Energy Demand [TWh]','Exogenous',EU27,'Power',y));
*** Final Energy; aggregation across region & sector
output_energydemandstatistics('Final Energy Demand [TWh]','Total','Total',f,y) = sum((r),sum(se,output_energydemandstatistics('Final Energy Demand [TWh]',se,r,f,y))+output_energydemandstatistics('Final Energy Demand [TWh]','Exogenous',r,f,y));
*output_energydemandstatistics('Final Energy Demand [TWh]','Total','Total',f,y) = sum((r),sum(se,output_energydemandstatistics('Final Energy Demand [TWh]',se,r,f,y))+output_energydemandstatistics('Final Energy Demand [TWh]','Exogenous',r,'Power',y));
output_energydemandstatistics('Final Energy Demand [TWh]','Total','EU27',f,y) = sum((EU27),sum(se,output_energydemandstatistics('Final Energy Demand [TWh]',se,EU27,f,y))+output_energydemandstatistics('Final Energy Demand [TWh]','Exogenous',EU27,f,y));
*output_energydemandstatistics('Final Energy Demand [TWh]','Total','EU27',f,y) = sum((EU27),sum(se,output_energydemandstatistics('Final Energy Demand [TWh]',se,EU27,f,y))+output_energydemandstatistics('Final Energy Demand [TWh]','Exogenous',EU27,'Power',y));
*** Share of Fuel in Final Energy
output_energydemandstatistics('Final Energy Demand [% of Total]','Total','EU27',f,y) = output_energydemandstatistics('Final Energy Demand [TWh]','Total','EU27',f,y)/sum(ff,output_energydemandstatistics('Final Energy Demand [TWh]','Total','EU27',ff,y));
output_energydemandstatistics('Final Energy Demand [% of Total]','Total','Total',f,y) = output_energydemandstatistics('Final Energy Demand [TWh]','Total','Total',f,y)/sum(ff,output_energydemandstatistics('Final Energy Demand [TWh]','Total','Total',ff,y));

*** Primary Energy Demand
output_energydemandstatistics('Primary Energy [TWh]','Total',r,f,y)$(not (diag(f,'Area_Rooftop_Residential')+diag(f,'Area_Rooftop_Commercial'))) = sum(t,ProductionByTechnologyAnnual.l(y,t,f,r)$(not sum((m,ff),InputActivityRatio(r,t,ff,m,y))))/3.6;
output_energydemandstatistics('Primary Energy [TWh]','Total','Total',f,y)$(not (diag(f,'Area_Rooftop_Residential')+diag(f,'Area_Rooftop_Commercial'))) = sum((t,r),ProductionByTechnologyAnnual.l(y,t,f,r)$(not sum((m,ff),InputActivityRatio(r,t,ff,m,y))))/3.6;
output_energydemandstatistics('Primary Energy [TWh]','Total','EU27',f,y)$(not (diag(f,'Area_Rooftop_Residential')+diag(f,'Area_Rooftop_Commercial'))) = sum((t,EU27),ProductionByTechnologyAnnual.l(y,t,f,EU27)$(not sum((m,ff),InputActivityRatio(EU27,t,ff,m,y))))/3.6;
*** Primary Energy Demand Shares
output_energydemandstatistics('Primary Energy [% of Total]','Total',r,f,y) = output_energydemandstatistics('Primary Energy [TWh]','Total',r,f,y)/sum(ff,output_energydemandstatistics('Primary Energy [TWh]','Total',r,ff,y));
output_energydemandstatistics('Primary Energy [% of Total]','Total','Total',f,y) = sum(r,output_energydemandstatistics('Primary Energy [TWh]','Total',r,f,y))/sum((r,ff),output_energydemandstatistics('Primary Energy [TWh]','Total',r,ff,y));
output_energydemandstatistics('Primary Energy [% of Total]','Total','EU27',f,y) = sum(EU27,output_energydemandstatistics('Primary Energy [TWh]','Total',EU27,f,y))/sum((EU27,ff),output_energydemandstatistics('Primary Energy [TWh]','Total',EU27,ff,y));

*** Share of Fuel in Electricity Mix
output_energydemandstatistics('Electricity Generation [TWh]','Power',r,f,y) = sum((t,m)$(not TagTechnologyToSector(t,'Storages')),(sum(l,RateOfProductionByTechnologyByMode(y,l,t,m,'Power',r)$(InputActivityRatio(r,t,f,m,y)) * YearSplit(l,y))))/3.6;
output_energydemandstatistics('Electricity Generation [TWh]','Power',r,'Solar',y) = sum(t$(TagTechnologyToSubsets(t,'Solar')),ProductionByTechnologyAnnual.l(y,t,'Power',r))/3.6;
output_energydemandstatistics('Electricity Generation [TWh]','Power',r,'Wind',y) = sum(t$(TagTechnologyToSubsets(t,'Wind')),ProductionByTechnologyAnnual.l(y,t,'Power',r))/3.6;
output_energydemandstatistics('Electricity Generation [TWh]','Power',r,'Hydro',y) = sum(t$(TagTechnologyToSubsets(t,'Hydro')),ProductionByTechnologyAnnual.l(y,t,'Power',r))/3.6;

output_energydemandstatistics('Electricity Mix [%]','Power',r,'Solar',y) = output_energydemandstatistics('Electricity Generation [TWh]','Power',r,'Solar',y)/(sum(t,ProductionByTechnologyAnnual.l(y,t,'Power',r)$(not TagTechnologyToSector(t,'Storages')))/3.6);
output_energydemandstatistics('Electricity Mix [%]','Power',r,'Wind',y) = output_energydemandstatistics('Electricity Generation [TWh]','Power',r,'Wind',y)/(sum(t,ProductionByTechnologyAnnual.l(y,t,'Power',r)$(not TagTechnologyToSector(t,'Storages')))/3.6);
output_energydemandstatistics('Electricity Mix [%]','Power',r,'Hydro',y) = output_energydemandstatistics('Electricity Generation [TWh]','Power',r,'Hydro',y)/(sum(t,ProductionByTechnologyAnnual.l(y,t,'Power',r)$(not TagTechnologyToSector(t,'Storages')))/3.6);
output_energydemandstatistics('Electricity Mix [%]','Power',r,f,y) = output_energydemandstatistics('Electricity Generation [TWh]','Power',r,f,y)/(sum(t,ProductionByTechnologyAnnual.l(y,t,'Power',r)$(not TagTechnologyToSector(t,'Storages')))/3.6);
output_energydemandstatistics('Electricity Mix [%]','Power',r,'Other',y) = 1-sum(f,output_energydemandstatistics('Electricity Mix [%]','Power',r,f,y))-output_energydemandstatistics('Electricity Mix [%]','Power',r,'Hydro',y)-output_energydemandstatistics('Electricity Mix [%]','Power',r,'Wind',y)-output_energydemandstatistics('Electricity Mix [%]','Power',r,'Solar',y);
*** Imports as Share of Primary Energy
output_energydemandstatistics('Import Share of Primary Energy [%]','Total',r,f,y)$(sum((t,m)$(TagTechnologyToSubsets(t,'ImportTechnology')),OutputActivityRatio(r,t,f,m,y))) = (sum(t,ProductionByTechnologyAnnual.l(y,t,f,r))/3.6)/sum(ff,output_energydemandstatistics('Primary Energy [TWh]','Total',r,ff,y));
output_energydemandstatistics('Import Share of Primary Energy [%]','Total','Total',f,y)$(sum((t,m,r)$(TagTechnologyToSubsets(t,'ImportTechnology')),OutputActivityRatio(r,t,f,m,y))) = (sum((t,r),ProductionByTechnologyAnnual.l(y,t,f,r))/3.6)/sum(ff,output_energydemandstatistics('Primary Energy [TWh]','Total','Total',ff,y));
output_energydemandstatistics('Import Share of Primary Energy [%]','Total','EU27',f,y)$(sum((t,m,EU27)$(TagTechnologyToSubsets(t,'ImportTechnology')),OutputActivityRatio(EU27,t,f,m,y))) = (sum((t,EU27),ProductionByTechnologyAnnual.l(y,t,f,EU27))/3.6)/sum(ff,output_energydemandstatistics('Primary Energy [TWh]','Total','EU27',ff,y));


$ifthen set Info
execute_unload "%gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%_%info%.gdx"
$else
execute_unload "%gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%.gdx"
$endif
output_energy_balance
output_energy_balance_annual
output_capacity
output_emissions
output_model
output_technology_costs_detailed
output_exogenous_costs
output_trade
output_other
output_energydemandstatistics
output_fuelcosts
output_emissionintensity
;

$endif

$ifthen %switch_write_output% == csv
$ifthen set Info
execute "echo 'Region','Sector','Technology','Mode','Fuel','Timeslice','Type','Unit','PathwayScenario','Year','Value' > %resultdir%Output_Prodcution_%model_region%_%emissionPathway%_%emissionScenario%_%info%.csv"
execute "gdxdump %gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%_%info%.gdx symb=output_energy_balance format=csv noHeader >> %resultdir%Output_Prodcution_%model_region%_%emissionPathway%_%emissionScenario%_%info%.csv"

execute "echo 'Region','Sector','Technology','Mode','Fuel','Type','Unit','PathwayScenario','Year','Value' > %resultdir%Output_AnnualProdcution_%model_region%_%emissionPathway%_%emissionScenario%_%info%.csv"
execute "gdxdump %gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%_%info%.gdx symb=output_energy_balance_annual format=csv noHeader >> %resultdir%Output_AnnualProdcution_%model_region%_%emissionPathway%_%emissionScenario%_%info%.csv"

execute "echo 'File','Region','Sector','Technology','Type','PathwayScenario','Year','Value' > %resultdir%Output_Capacity_%model_region%_%emissionPathway%_%emissionScenario%_%info%.csv"
execute "gdxdump %gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%_%info%.gdx symb=output_capacity format=csv noHeader >> %resultdir%Output_Capacity_%model_region%_%emissionPathway%_%emissionScenario%_%info%.csv"

execute "echo 'File','Region','Sector','Emission','Technology','Type','PathwayScenario','Year','Value' > %resultdir%Output_Emission_%model_region%_%emissionPathway%_%emissionScenario%_%info%.csv"
execute "gdxdump %gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%_%info%.gdx symb=output_emissions format=csv noHeader >> %resultdir%Output_Emission_%model_region%_%emissionPathway%_%emissionScenario%_%info%.csv"

execute "echo 'File','Name','Region','Sector/Technology','Fuel','Year','Value' > %resultdir%Output_Other_%model_region%_%emissionPathway%_%emissionScenario%_%info%.csv"
execute "gdxdump %gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%_%info%.gdx symb=output_other format=csv noHeader >> %resultdir%Output_Other_%model_region%_%emissionPathway%_%emissionScenario%_%info%.csv"

$else
execute "echo 'Region','Sector','Technology','Mode','Fuel','Timeslice','Type','Unit','PathwayScenario','Year','Value' > %resultdir%Output_Prodcution_%model_region%_%emissionPathway%_%emissionScenario%.csv"
execute "gdxdump %gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%.gdx symb=output_energy_balance format=csv noHeader >> %resultdir%Output_Prodcution_%model_region%_%emissionPathway%_%emissionScenario%.csv"

execute "echo 'Region','Sector','Technology','Mode','Fuel','Type','Unit','PathwayScenario','Year','Value' > %resultdir%Output_AnnualProdcution_%model_region%_%emissionPathway%_%emissionScenario%.csv"
execute "gdxdump %gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%.gdx symb=output_energy_balance_annual format=csv noHeader >> %resultdir%Output_AnnualProdcution_%model_region%_%emissionPathway%_%emissionScenario%.csv"

execute "echo 'File','Region','Sector','Technology','Type','PathwayScenario','Year','Value' > %resultdir%Output_Capacity_%model_region%_%emissionPathway%_%emissionScenario%.csv"
execute "gdxdump %gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%.gdx symb=output_capacity format=csv noHeader >> %resultdir%Output_Capacity_%model_region%_%emissionPathway%_%emissionScenario%.csv"

execute "echo 'File','Region','Sector','Emission','Technology','Type','PathwayScenario','Year','Value' > %resultdir%Output_Emission_%model_region%_%emissionPathway%_%emissionScenario%.csv"
execute "gdxdump %gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%.gdx symb=output_emissions format=csv noHeader >> %resultdir%Output_Emission_%model_region%_%emissionPathway%_%emissionScenario%.csv"

execute "echo 'File','Name','Region','Sector/Technology','Fuel','Year','Value' > %resultdir%Output_Other_%model_region%_%emissionPathway%_%emissionScenario%.csv"
execute "gdxdump %gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%.gdx symb=output_other format=csv noHeader >> %resultdir%Output_Other_%model_region%_%emissionPathway%_%emissionScenario%.csv"
$endif
$endif


$ifthen %switch_write_output% == xls

* Write gdxxrw option file
$onecho >%tempdir%temp_exceloutput.tmp
se=0
        par=output_capacity              Rng=Capacity!A1    rdim=5        cdim=1
text="Region"                            Rng=Capacity!A1
text="Category"                          Rng=Capacity!B1
text="Technology"                        Rng=Capacity!C1
text="Type"                              Rng=Capacity!D1
text="Scenario"                          Rng=Capacity!E1



        par=output_energy_balance        Rng=Production!A1  rdim=9        cdim=1
text="Region"                            Rng=Production!A1
text="Category"                          Rng=Production!B1
text="Technology"                        Rng=Production!C1
text="Mode"                              Rng=Production!D1
text="Fuel"                              Rng=Production!E1
text="Timeslice"                         Rng=Production!F1
text="Type"                              Rng=Production!G1
text="Unit"                              Rng=Production!H1
text="Scenario"                          Rng=Production!I1

        par=output_energy_balance_annual        Rng=AnnualProduction!A1  rdim=7        cdim=1
text="Region"                            Rng=AnnualProduction!A1
text="Category"                          Rng=AnnualProduction!B1
text="Technology"                        Rng=AnnualProduction!C1
text="Fuel"                              Rng=AnnualProduction!D1
text="Type"                              Rng=AnnualProduction!E1
text="Unit"                              Rng=AnnualProduction!F1
text="Scenario"                          Rng=AnnualProduction!G1

        par=output_emissions             Rng=Emissions!A1   rdim=6        cdim=1
text="Region"                            Rng=Emissions!A1
text="Category"                          Rng=Emissions!B1
text="Emission"                          Rng=Emissions!C1
text="Technology"                        Rng=Emissions!D1
text="Timeslice"                         Rng=Emissions!E1
text="Scenario"                          Rng=Emissions!F1
$offecho


$ifthen set info
execute 'gdxxrw.exe i=%gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%_%info%.gdx UpdLinks=3 o=%resultdir%Pivot_Output_%model_region%_%emissionPathway%_%emissionScenario%_%info%.xlsx @%tempdir%temp_exceloutput.tmp';
$else
execute 'gdxxrw.exe i=%gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%.gdx UpdLinks=3 o=%resultdir%Pivot_Output_%model_region%_%emissionPathway%_%emissionScenario%.xlsx @%tempdir%temp_exceloutput.tmp';
$endif
$endif
