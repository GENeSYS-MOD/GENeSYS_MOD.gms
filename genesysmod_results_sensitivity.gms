* ###################### genesysmod_results_sensitivity.gms #######################
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


* #############################################################
* ###################### sensitivity outputs ##################
* #############################################################


$ifthen %switch_sensitivity_results_only% == 1

$if not setglobal gdxdir $setglobal gdxdir GdxFiles\

$if not set filename $set filename s_carbonprice_leader
$if not set sensitivity $set sensitivity carbonprice
$if not set sensitivity_identifier $set sensitivity_identifier leader
$if not set elmod_nthhour $set elmod_nthhour 244

$include genesysmod_dec.gms
parameters YearVal
ElectrificationRate
EmissionIntensity
z_ProductionByTechnologyByModeAnnual
YearlyDifferenceMultiplier
powerSubsectorShares;
$GDXin %filename%.gdx
$onUNDF
** Sets
$loadm Region_Full Region Sector Technology Mode_of_Operation Year Fuel ModalType Emission Timeslice Storage
$include genesysmod_subsets.gms
** Parameters
$loadm SpecifiedAnnualDemand EmissionIntensity EmissionsPenalty SpecifiedDemandProfile YearSplit TotalAnnualMaxCapacity CapacityFactor AvailabilityFactor TotalTechnologyModelPeriodActivityUpperLimit
$loadm TotalTechnologyAnnualActivityUpperLimit OperationalLife ResidualCapacity Curtailment GrowthRateTradeCapacity StorageLevelStart TechnologyToStorage
$loadm InputActivityRatio z_ProductionByTechnologyByModeAnnual OutputActivityRatio YearVal TradeRoute TagFuelToSector TagElectricTechnology TagTechnologyToSector powerSubsectorShares
** Variables
$load OperatingCost DiscountedOperatingCost
$loadm DiscountedCapitalInvestment DiscountedTechnologyEmissionsPenalty DiscountedNewTradeCapacityCosts  DiscountedAnnualTotalTradeCosts
$loadm CapitalInvestment AnnualTechnologyEmissionsPenalty NewTradeCapacityCosts TradeCosts Import GeneralDiscountRate  DiscountedSalvageValue SalvageValue
$loadm ElectrificationRate  ProductionAnnual ProductionByTechnologyAnnual  UseByTechnologyAnnual UseAnnual
$loadm TotalCapacityAnnual TotalTradeCapacity NetTradeAnnual AnnualTechnologyEmission AnnualTotalTradeCosts
** Marginals from Equations
equation E8_RegionalAnnualEmissionsLimit(YEAR_FULL,EMISSION,REGION_FULL);
equation E9_AnnualEmissionsLimit(YEAR_FULL,EMISSION);
$load E8_RegionalAnnualEmissionsLimit E9_AnnualEmissionsLimit


$offUNDF



$endif

* System Costs
* Split by sector and region
* DISCOUNTED
* Power costs - split generation, storage and transmission


parameter output_systemcosts;
output_systemcosts('Discounted System Costs',se,r,y) = sum((t)$(TagTechnologyToSector(t,se)),DiscountedCapitalInvestment.l(y,t,r)
+DiscountedOperatingCost.l(y,t,r)-DiscountedSalvageValue.l(y,t,r)+DiscountedTechnologyEmissionsPenalty.l(y,t,r));
output_systemcosts('Discounted System Costs',se,'Europe',y) = sum((t,r)$(TagTechnologyToSector(t,se)),DiscountedCapitalInvestment.l(y,t,r)
+DiscountedOperatingCost.l(y,t,r)-DiscountedSalvageValue.l(y,t,r)+DiscountedTechnologyEmissionsPenalty.l(y,t,r));
output_systemcosts('Discounted System Costs','Trade',r,y) = DiscountedAnnualTotalTradeCosts.l(r,y)+sum((f,rr),DiscountedNewTradeCapacityCosts.l(r,rr,f,y));
output_systemcosts('Discounted System Costs','Trade','Europe',y) = sum(r,output_systemcosts('Discounted System Costs','Trade',r,y));

output_systemcosts('Discounted System Cost Split','CAPEX',r,y) = sum((t),DiscountedCapitalInvestment.l(y,t,r));
output_systemcosts('Discounted System Cost Split','CAPEX','Europe',y) = sum((t,r),DiscountedCapitalInvestment.l(y,t,r));

output_systemcosts('Discounted System Cost Split','OPEX',r,y) = sum((t),DiscountedOperatingCost.l(y,t,r));
output_systemcosts('Discounted System Cost Split','OPEX','Europe',y) = sum((t,r),DiscountedOperatingCost.l(y,t,r));

output_systemcosts('Discounted System Cost Split','Trade',r,y) = DiscountedAnnualTotalTradeCosts.l(r,y)+sum((f,rr),DiscountedNewTradeCapacityCosts.l(r,rr,f,y));
output_systemcosts('Discounted System Cost Split','Trade','Europe',y) = sum(r,DiscountedAnnualTotalTradeCosts.l(r,y)+sum((f,rr),DiscountedNewTradeCapacityCosts.l(r,rr,f,y)));

output_systemcosts('Discounted Power Costs','Trade',r,y) = sum((l,rr)$(TradeRoute(r,rr,'Power',y)),Import.l(y,l,'Power',r,rr)*TradeCosts(r,rr,'Power'))/((1+GeneralDiscountRate(r))**(YearVal(y)-smin(yy, YearVal(yy))+0.5))+sum((rr),DiscountedNewTradeCapacityCosts.l(r,rr,'Power',y));
output_systemcosts('Discounted Power Costs','Trade','Europe',y) = sum(r,sum((l,rr)$(TradeRoute(r,rr,'Power',y)),Import.l(y,l,'Power',r,rr)*TradeCosts(r,rr,'Power'))/((1+GeneralDiscountRate(r))**(YearVal(y)-smin(yy, YearVal(yy))+0.5))+sum((rr),DiscountedNewTradeCapacityCosts.l(r,rr,'Power',y)));

output_systemcosts('Discounted Power Costs','Generation',r,y) = sum((t)$(TagTechnologyToSector(t,'Power')),DiscountedCapitalInvestment.l(y,t,r)
+DiscountedOperatingCost.l(y,t,r)-DiscountedSalvageValue.l(y,t,r)+DiscountedTechnologyEmissionsPenalty.l(y,t,r));
output_systemcosts('Discounted Power Costs','Generation','Europe',y) = sum((t,r)$(TagTechnologyToSector(t,'Power')),DiscountedCapitalInvestment.l(y,t,r)
+DiscountedOperatingCost.l(y,t,r)-DiscountedSalvageValue.l(y,t,r)+DiscountedTechnologyEmissionsPenalty.l(y,t,r));

output_systemcosts('Discounted Power Costs','Storage',r,y) = sum((t)$(TagTechnologyToSector(t,'Storages')),DiscountedCapitalInvestment.l(y,t,r)
+DiscountedOperatingCost.l(y,t,r)-DiscountedSalvageValue.l(y,t,r)+DiscountedTechnologyEmissionsPenalty.l(y,t,r));
output_systemcosts('Discounted Power Costs','Storage','Europe',y) = sum((t,r)$(TagTechnologyToSector(t,'Storages')),DiscountedCapitalInvestment.l(y,t,r)
+DiscountedOperatingCost.l(y,t,r)-DiscountedSalvageValue.l(y,t,r)+DiscountedTechnologyEmissionsPenalty.l(y,t,r));

output_systemcosts('Discounted Power Costs','Transmission',r,y) = (sum((l,rr)$(TradeRoute(r,rr,'Power',y)),Import.l(y,l,'Power',r,rr) * TradeCosts(r,rr,'Power'))/((1+GeneralDiscountRate(r))**(YearVal(y)-smin(yy, YearVal(yy))+0.5)))
+sum(rr,DiscountedNewTradeCapacityCosts.l(r,rr,'Power',y));
output_systemcosts('Discounted Power Costs','Transmission','Europe',y) = sum(r,(sum((l,rr)$(TradeRoute(r,rr,'Power',y)),Import.l(y,l,'Power',r,rr) * TradeCosts(r,rr,'Power'))/((1+GeneralDiscountRate(r))**(YearVal(y)-smin(yy, YearVal(yy))+0.5)))
+sum(rr,DiscountedNewTradeCapacityCosts.l(r,rr,'Power',y)));

output_systemcosts('Discounted System Costs','Power','Europe_AT',y)$(output_systemcosts('Discounted System Costs','Power','Europe_AT',y) = 0) = na;

* UNDISCOUNTED

output_systemcosts('Nominal System Costs',se,r,y) = sum((t)$(TagTechnologyToSector(t,se)),CapitalInvestment.l(y,t,r)
+OperatingCost.l(y,t,r)-SalvageValue.l(y,t,r)+AnnualTechnologyEmissionsPenalty.l(y,t,r));
output_systemcosts('Nominal System Costs',se,'Europe',y) = sum((t,r)$(TagTechnologyToSector(t,se)),CapitalInvestment.l(y,t,r)
+OperatingCost.l(y,t,r)-SalvageValue.l(y,t,r)+AnnualTechnologyEmissionsPenalty.l(y,t,r));
output_systemcosts('Nominal System Costs','Trade',r,y) = AnnualTotalTradeCosts.l(r,y)+sum((f,rr),NewTradeCapacityCosts.l(r,rr,f,y));
output_systemcosts('Nominal System Costs','Trade','Europe',y) = sum(r,output_systemcosts('Nominal System Costs','Trade',r,y));


output_systemcosts('Nominal System Cost Split','CAPEX',r,y) = sum((t),CapitalInvestment.l(y,t,r));
output_systemcosts('Nominal System Cost Split','CAPEX','Europe',y) = sum((t,r),CapitalInvestment.l(y,t,r));

output_systemcosts('Nominal System Cost Split','OPEX',r,y) = sum((t),OperatingCost.l(y,t,r));
output_systemcosts('Nominal System Cost Split','OPEX','Europe',y) = sum((t,r),OperatingCost.l(y,t,r));

output_systemcosts('Nominal System Cost Split','Trade',r,y) = AnnualTotalTradeCosts.l(r,y)+sum((f,rr),NewTradeCapacityCosts.l(r,rr,f,y));
output_systemcosts('Nominal System Cost Split','Trade','Europe',y) = sum(r,AnnualTotalTradeCosts.l(r,y)+sum((f,rr),NewTradeCapacityCosts.l(r,rr,f,y)));

output_systemcosts('Nominal Power Costs','Trade',r,y) = sum((l,rr)$(TradeRoute(r,rr,'Power',y)),Import.l(y,l,'Power',r,rr) * TradeCosts(r,rr,'Power')) + sum((rr),NewTradeCapacityCosts.l(r,rr,'Power',y));
output_systemcosts('Nominal Power Costs','Trade','Europe',y) = sum(r,sum((l,rr)$(TradeRoute(r,rr,'Power',y)),Import.l(y,l,'Power',r,rr) * TradeCosts(r,rr,'Power')) + sum((rr),NewTradeCapacityCosts.l(r,rr,'Power',y)));

output_systemcosts('Nominal Power Costs','Generation',r,y) = sum((t)$(TagTechnologyToSector(t,'Power')),CapitalInvestment.l(y,t,r)
+OperatingCost.l(y,t,r)-SalvageValue.l(y,t,r)+AnnualTechnologyEmissionsPenalty.l(y,t,r));
output_systemcosts('Nominal Power Costs','Generation','Europe',y) = sum((t,r)$(TagTechnologyToSector(t,'Power')),CapitalInvestment.l(y,t,r)
+OperatingCost.l(y,t,r)-SalvageValue.l(y,t,r)+AnnualTechnologyEmissionsPenalty.l(y,t,r));

output_systemcosts('Nominal Power Costs','Storage',r,y) = sum((t)$(TagTechnologyToSector(t,'Storages')),CapitalInvestment.l(y,t,r)
+OperatingCost.l(y,t,r)-SalvageValue.l(y,t,r)+AnnualTechnologyEmissionsPenalty.l(y,t,r));
output_systemcosts('Nominal Power Costs','Storage','Europe',y) = sum((t,r)$(TagTechnologyToSector(t,'Storages')),CapitalInvestment.l(y,t,r)
+OperatingCost.l(y,t,r)-SalvageValue.l(y,t,r)+AnnualTechnologyEmissionsPenalty.l(y,t,r));

output_systemcosts('Nominal Power Costs','Transmission',r,y) = (sum((l,rr)$(TradeRoute(r,rr,'Power',y)),Import.l(y,l,'Power',r,rr) * TradeCosts(r,rr,'Power')))
+sum(rr,NewTradeCapacityCosts.l(r,rr,'Power',y));
output_systemcosts('Nominal Power Costs','Transmission','Europe',y) = sum(r,(sum((l,rr)$(TradeRoute(r,rr,'Power',y)),Import.l(y,l,'Power',r,rr) * TradeCosts(r,rr,'Power')))
+sum(rr,NewTradeCapacityCosts.l(r,rr,'Power',y)));

output_systemcosts('Nominal System Costs','Total',r,y) = sum(se,output_systemcosts('Nominal System Costs',se,r,y))+output_systemcosts('Nominal System Costs','Trade',r,y);
output_systemcosts('Nominal System Costs','Total','Europe',y) = sum(r, output_systemcosts('Nominal System Costs','Total',r,y))+output_systemcosts('Nominal System Costs','Trade','Europe',y);

output_systemcosts('Discounted System Costs','Total',r,y) = sum(se,output_systemcosts('Discounted System Costs',se,r,y))+output_systemcosts('Discounted System Costs','Trade',r,y);
output_systemcosts('Discounted System Costs','Total','Europe',y) = sum(r, output_systemcosts('Discounted System Costs','Total',r,y))+output_systemcosts('Discounted System Costs','Trade','Europe',y);

output_systemcosts('Nominal System Costs','Industry','Europe_AT',y)$(output_systemcosts('Nominal System Costs','Industry','Europe_AT',y) = 0) = na;


* -------
* Electrification rates and volumes (%, TWh of electricity consumed [=production without storages])
* Split per sector and region

parameter output_electrificationrate;
output_electrificationrate('Electrification Rate [%]',se,'Europe',y) = ElectrificationRate(se,y);
output_electrificationrate('Electrification Rate [%]',se,r,y)$(sum(f$(TagFuelToSector(se,f)>0),TagFuelToSector(se,f)*ProductionAnnual.l(y,f,r)) > 0) = sum((f,t)$(ProductionByTechnologyAnnual.l(r,t,f,y) > 0), TagFuelToSector(se,f)*TagElectricTechnology(t)*ProductionByTechnologyAnnual.l(r,t,f,y))/sum((f)$(TagFuelToSector(se,f)>0),TagFuelToSector(se,f)*ProductionAnnual.l(y,f,r));

output_electrificationrate('Electrification Volumes [TWh]',se,r,y) = sum(t$(TagTechnologyToSector(t,se)),UseByTechnologyAnnual.l(r,t,'Power',y))/3.6;
output_electrificationrate('Electrification Volumes [TWh]',se,'Europe',y) = sum((t,r)$(TagTechnologyToSector(t,se)),UseByTechnologyAnnual.l(r,t,'Power',y))/3.6;

output_electrificationrate('Electrification Volumes [TWh]','Total',r,y) = sum(se,output_electrificationrate('Electrification Volumes [TWh]',se,r,y));
output_electrificationrate('Electrification Volumes [TWh]','Total','Europe',y) = sum(r,output_electrificationrate('Electrification Volumes [TWh]','Total',r,y));

output_electrificationrate('Electrification Rate [%]','Industry','Europe',y)$(output_electrificationrate('Electrification Rate [%]','Industry','Europe',y) = 0) = na;

* -------
* Final energy demand (TWh)
* Split per sector and region
* Split per technology within each sector

parameter output_finalenergydemand, output_finalenergydemandsector;
*output_finalenergydemand(r,'Final Energy Demand [TWh]',se,y) = sum(t$(TagTechnologyToSector(t,se)),UseByTechnologyAnnual.l(r,t,f,y))/3.6;
output_finalenergydemandsector(r,'Final Energy Demand [TWh]',se,f,y)$(not CCSFuel(f)) = sum(t$(TagTechnologyToSector(t,se)),UseByTechnologyAnnual.l(r,t,f,y))/3.6;
output_finalenergydemandsector(r,'Final Energy Demand [TWh]','Industry','Power',y) = output_finalenergydemandsector(r,'Final Energy Demand [TWh]','Industry','Power',y)+SpecifiedAnnualDemand(r,'Power',y)*powerSubsectorShares(r,'ind')/3.6;
output_finalenergydemandsector(r,'Final Energy Demand [TWh]','Buildings','Power',y) = output_finalenergydemandsector(r,'Final Energy Demand [TWh]','Buildings','Power',y)+SpecifiedAnnualDemand(r,'Power',y)*(powerSubsectorShares(r,'res')+powerSubsectorShares(r,'com'))/3.6;
output_finalenergydemandsector('Europe','Final Energy Demand [TWh]',se,f,y)$(not CCSFuel(f)) = sum((r),output_finalenergydemandsector(r,'Final Energy Demand [TWh]',se,f,y));

output_finalenergydemandsector(r,'Final Energy Demand [TWh]','Total',f,y) = sum(se,output_finalenergydemandsector(r,'Final Energy Demand [TWh]',se,f,y));
output_finalenergydemandsector('Europe','Final Energy Demand [TWh]','Total',f,y) = sum(r,output_finalenergydemandsector(r,'Final Energy Demand [TWh]','Total',f,y));

output_finalenergydemandsector('Europe_AT','Final Energy Demand [TWh]','Power','Power',y)$(output_finalenergydemandsector('Europe_AT','Final Energy Demand [TWh]','Power','Power',y) = 0) = na;

* -------
* Hydrogen use (% of hydrogen in final energy consumption and TWh)
* Split per sector and region

parameter output_hydrogenuse;
output_hydrogenuse('Hydrogen Use per Sector [TWh]',se,r,y) = (sum(t$(TagTechnologyToSector(t,se)),UseByTechnologyAnnual.l(r,t,'H2',y)))/3.6;
output_hydrogenuse('Hydrogen Share per Sector [% of Sector]',se,r,y)$(sum((t,f)$(TagTechnologyToSector(t,se)),UseByTechnologyAnnual.l(r,t,f,y))) = output_hydrogenuse('Hydrogen Use per Sector [TWh]',se,r,y)/sum((t,f)$(TagTechnologyToSector(t,se)),UseByTechnologyAnnual.l(r,t,f,y))*3.6;

output_hydrogenuse('Syn-Gas Use per Sector [TWh]',se,r,y) = sum(t$(TagTechnologyToSector(t,se)),UseByTechnologyAnnual.l(r,t,'Gas_Synth',y));
output_hydrogenuse('Syn-Gas Share per Sector [% of Sector]',se,r,y)$(sum((t,f)$(TagTechnologyToSector(t,se)),UseByTechnologyAnnual.l(r,t,f,y))) = output_hydrogenuse('Syn-Gas Use per Sector [TWh]',se,r,y)/sum((t,f)$(TagTechnologyToSector(t,se)),UseByTechnologyAnnual.l(r,t,f,y))*3.6;
output_hydrogenuse('Powerfuels Use per Sector [TWh]',se,r,y) = sum(t$(TagTechnologyToSector(t,se)),UseByTechnologyAnnual.l(r,t,'Powerfuel',y));
output_hydrogenuse('Powerfuels Share per Sector [% of Sector]',se,r,y)$(sum((t,f)$(TagTechnologyToSector(t,se)),UseByTechnologyAnnual.l(r,t,f,y))) = output_hydrogenuse('Powerfuels Use per Sector [TWh]',se,r,y)/sum((t,f)$(TagTechnologyToSector(t,se)),UseByTechnologyAnnual.l(r,t,f,y))*3.6;

output_hydrogenuse('Hydrogen Use per Sector [TWh]',se,'Europe',y) = sum(r,output_hydrogenuse('Hydrogen Use per Sector [TWh]',se,r,y));
output_hydrogenuse('Hydrogen Share per Sector [% of Sector]',se,'Europe',y)$(sum((r,t,f)$(TagTechnologyToSector(t,se)),UseByTechnologyAnnual.l(r,t,f,y))) = output_hydrogenuse('Hydrogen Use per Sector [TWh]',se,'Europe',y)/sum((r,t,f)$(TagTechnologyToSector(t,se)),UseByTechnologyAnnual.l(r,t,f,y))*3.6;

output_hydrogenuse('Syn-Gas Use per Sector [TWh]',se,'Europe',y) = sum(r,output_hydrogenuse('Syn-Gas Use per Sector [TWh]',se,r,y));
output_hydrogenuse('Syn-Gas Share per Sector [% of Sector]',se,'Europe',y)$(sum((r,t,f)$(TagTechnologyToSector(t,se)),UseByTechnologyAnnual.l(r,t,f,y))) = output_hydrogenuse('Syn-Gas Use per Sector [TWh]',se,'Europe',y)/sum((r,t,f)$(TagTechnologyToSector(t,se)),UseByTechnologyAnnual.l(r,t,f,y))*3.6;
output_hydrogenuse('Powerfuels Use per Sector [TWh]',se,'Europe',y) = sum(r,output_hydrogenuse('Powerfuels Use per Sector [TWh]',se,r,y));
output_hydrogenuse('Powerfuels Share per Sector [% of Sector]',se,'Europe',y)$(sum((r,t,f)$(TagTechnologyToSector(t,se)),UseByTechnologyAnnual.l(r,t,f,y))) = output_hydrogenuse('Powerfuels Use per Sector [TWh]',se,'Europe',y)/sum((r,t,f)$(TagTechnologyToSector(t,se)),UseByTechnologyAnnual.l(r,t,f,y))*3.6;


output_hydrogenuse('Hydrogen Use per Sector [TWh]','Total (Excl. Storages)',r,y) = sum(se$(not sameas(se, 'Storages')), output_hydrogenuse('Hydrogen Use per Sector [TWh]',se,r,y));
output_hydrogenuse('Hydrogen Use per Sector [TWh]','Total (Excl. Storages)','Europe',y) = sum(r, output_hydrogenuse('Hydrogen Use per Sector [TWh]','Total (Excl. Storages)',r,y));

output_hydrogenuse('Syn-Gas Use per Sector [TWh]','Total (Excl. Storages)',r,y) = sum(se$(not sameas(se, 'Storages')), output_hydrogenuse('Syn-Gas Use per Sector [TWh]',se,r,y));
output_hydrogenuse('Syn-Gas Use per Sector [TWh]','Total (Excl. Storages)','Europe',y) = sum(r, output_hydrogenuse('Syn-Gas Use per Sector [TWh]','Total (Excl. Storages)',r,y));
output_hydrogenuse('Powerfuels Use per Sector [TWh]','Total (Excl. Storages)',r,y) = sum(se$(not sameas(se, 'Storages')), output_hydrogenuse('Powerfuels Use per Sector [TWh]',se,r,y));
output_hydrogenuse('Powerfuels Use per Sector [TWh]','Total (Excl. Storages)','Europe',y) = sum(r, output_hydrogenuse('Powerfuels Use per Sector [TWh]','Total (Excl. Storages)',r,y));



output_hydrogenuse('Hydrogen Use per Sector [TWh]','Power','Europe_AT',y)$(output_hydrogenuse('Hydrogen Use per Sector [TWh]','Power','Europe_AT',y) = 0) = na;

* -------
* Hydrogen and derived production
* Volume by Type of hydrogen production (green grid, green off-grid, blue, import) per region
* Volume of synthetic gases and eFuels from H2"

parameter output_hydrogenproduction;
output_hydrogenproduction('Green Grid Hydrogen Production [TWh]',r,y) = ProductionByTechnologyAnnual.l(r,'X_Electrolysis','H2',y)/3.6;
output_hydrogenproduction('Green Off-grid Hydrogen Production [TWh]',r,y) = sum(OffgridHydrogen, ProductionByTechnologyAnnual.l(r,OffgridHydrogen,'H2',y))/3.6;
output_hydrogenproduction('Blue Hydrogen Production[TWh]',r,y) = ProductionByTechnologyAnnual.l(r,'X_SMR','H2',y)/3.6;
output_hydrogenproduction('Hydrogen Import [TWh]',r,y) = ProductionByTechnologyAnnual.l(r,'Z_Import_H2','H2',y)/3.6;
output_hydrogenproduction('Synthetic Gases from Hydrogen [TWh]',r,y) = sum(f,z_ProductionByTechnologyByModeAnnual(r,'X_Methanation','1',f,y))/3.6;
output_hydrogenproduction('E-Fuels from Hydrogen [TWh]',r,y) = ProductionByTechnologyAnnual.l(r,'X_Powerfuel','Powerfuel',y)/3.6;
output_hydrogenproduction('Losses from Storages [TWh]',r,y) = -1*UseByTechnologyAnnual.l(r,'D_Gas_H2','H2',y)*(1-OutputActivityRatio(r,'D_Gas_H2','H2','2',y))/3.6;

output_hydrogenproduction('Green Grid Hydrogen Production [TWh]','Europe',y) = sum(r,ProductionByTechnologyAnnual.l(r,'X_Electrolysis','H2',y)/3.6);
output_hydrogenproduction('Green Off-grid Hydrogen Production [TWh]','Europe',y) = sum((OffgridHydrogen,r), ProductionByTechnologyAnnual.l(r,OffgridHydrogen,'H2',y))/3.6;
output_hydrogenproduction('Blue Hydrogen Production[TWh]','Europe',y) = sum(r,ProductionByTechnologyAnnual.l(r,'X_SMR','H2',y)/3.6);
output_hydrogenproduction('Hydrogen Import [TWh]','Europe',y) = sum(r,ProductionByTechnologyAnnual.l(r,'Z_Import_H2','H2',y)/3.6);
output_hydrogenproduction('Synthetic Gases from Hydrogen [TWh]','Europe',y) = sum((f,r),z_ProductionByTechnologyByModeAnnual(r,'X_Methanation','1',f,y))/3.6;
output_hydrogenproduction('E-Fuels from Hydrogen [TWh]','Europe',y) = sum(r,ProductionByTechnologyAnnual.l(r,'X_Powerfuel','Powerfuel',y)/3.6);
output_hydrogenproduction('Losses from Storages [TWh]','Europe',y) = -1*sum(r,UseByTechnologyAnnual.l(r,'D_Gas_H2','H2',y)*(1-OutputActivityRatio(r,'D_Gas_H2','H2','2',y))/3.6);

output_hydrogenproduction('Total',r,y) =
output_hydrogenproduction('Green Grid Hydrogen Production [TWh]',r,y) +
output_hydrogenproduction('Green Off-grid Hydrogen Production [TWh]',r,y) +
output_hydrogenproduction('Blue Hydrogen Production[TWh]',r,y) +
output_hydrogenproduction('Hydrogen Import [TWh]',r,y) +
output_hydrogenproduction('Synthetic Gases from Hydrogen [TWh]',r,y) +
output_hydrogenproduction('E-Fuels from Hydrogen [TWh]',r,y) +
output_hydrogenproduction('Losses from Storages [TWh]',r,y);
output_hydrogenproduction('Total','Europe',y) = sum(r,output_hydrogenproduction('Total',r,y));

output_hydrogenproduction('Green Grid Hydrogen Production [TWh]','Europe_AT',y)$(output_hydrogenproduction('Green Grid Hydrogen Production [TWh]','Europe_AT',y) = 0) = na;

* -------
* Power generation
* % Generation from: Solar, wind, hydro, bio, coal, gas, nuclear (incl from CHP, with CCS etc)
* Capacity GW by technology"

parameter output_powergeneration;
output_powergeneration('Power Generation [%]','Solar',r,y) = sum((Solar),ProductionByTechnologyAnnual.l(r,Solar,'Power',y))/sum((t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y));
output_powergeneration('Power Generation [%]','Onshore Wind',r,y) = sum((Onshore),ProductionByTechnologyAnnual.l(r,Onshore,'Power',y))/sum((t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y));
output_powergeneration('Power Generation [%]','Offshore Wind',r,y) = sum((Offshore),ProductionByTechnologyAnnual.l(r,Offshore,'Power',y))/sum((t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y));
output_powergeneration('Power Generation [%]','Hydro',r,y) = sum((Hydro),ProductionByTechnologyAnnual.l(r,Hydro,'Power',y))/sum((t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y));
output_powergeneration('Power Generation [%]','Biomass',r,y) = sum((PowerBiomass),ProductionByTechnologyAnnual.l(r,PowerBiomass,'Power',y))/sum((t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y));
output_powergeneration('Power Generation [%]','Coal',r,y) = sum((Coal),ProductionByTechnologyAnnual.l(r,Coal,'Power',y))/sum((t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y));
output_powergeneration('Power Generation [%]','Oil',r,y) = sum((Oil),ProductionByTechnologyAnnual.l(r,Oil,'Power',y))/sum((t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y));
output_powergeneration('Power Generation [%]','Nuclear',r,y) = ProductionByTechnologyAnnual.l(r,'P_Nuclear','Power',y)/sum((t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y));
output_powergeneration('Power Generation [%]','Natural Gas',r,y) = sum((Gas),z_ProductionByTechnologyByModeAnnual(r,Gas,'1','Power',y))/sum((t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y));
output_powergeneration('Power Generation [%]','Biogas',r,y) = sum((Gas),z_ProductionByTechnologyByModeAnnual(r,Gas,'2','Power',y))/sum((t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y));
output_powergeneration('Power Generation [%]','Synthetic Gas',r,y) = sum((Gas),z_ProductionByTechnologyByModeAnnual(r,Gas,'3','Power',y))/sum((t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y));
output_powergeneration('Power Generation [%]','H2',r,y) = sum((Hydrogen),ProductionByTechnologyAnnual.l(r,Hydrogen,'Power',y))/sum((t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y));
output_powergeneration('Power Generation [%]','Other',r,y) = 1-(
output_powergeneration('Power Generation [%]','Solar',r,y)
+output_powergeneration('Power Generation [%]','Onshore Wind',r,y)
+output_powergeneration('Power Generation [%]','Offshore Wind',r,y)
+output_powergeneration('Power Generation [%]','Hydro',r,y)
+output_powergeneration('Power Generation [%]','Biomass',r,y)
+output_powergeneration('Power Generation [%]','Coal',r,y)
+output_powergeneration('Power Generation [%]','Oil',r,y)
+output_powergeneration('Power Generation [%]','Nuclear',r,y)
+output_powergeneration('Power Generation [%]','Natural Gas',r,y)
+output_powergeneration('Power Generation [%]','Biogas',r,y)
+output_powergeneration('Power Generation [%]','Synthetic Gas',r,y)
+output_powergeneration('Power Generation [%]','H2',r,y));

output_powergeneration('Power Generation [TWh]','Solar',r,y) = sum((Solar),ProductionByTechnologyAnnual.l(r,Solar,'Power',y))/3.6;
output_powergeneration('Power Generation [TWh]','Onshore Wind',r,y) = sum((Onshore),ProductionByTechnologyAnnual.l(r,Onshore,'Power',y))/3.6;
output_powergeneration('Power Generation [TWh]','Offshore Wind',r,y) = sum((Offshore),ProductionByTechnologyAnnual.l(r,Offshore,'Power',y))/3.6;
output_powergeneration('Power Generation [TWh]','Hydro',r,y) = sum((Hydro),ProductionByTechnologyAnnual.l(r,Hydro,'Power',y))/3.6;
output_powergeneration('Power Generation [TWh]','Biomass',r,y) = sum((PowerBiomass),ProductionByTechnologyAnnual.l(r,PowerBiomass,'Power',y))/3.6;
output_powergeneration('Power Generation [TWh]','Coal',r,y) = sum((Coal),ProductionByTechnologyAnnual.l(r,Coal,'Power',y))/3.6;
output_powergeneration('Power Generation [TWh]','Oil',r,y) = sum((Oil),ProductionByTechnologyAnnual.l(r,Oil,'Power',y))/3.6;
output_powergeneration('Power Generation [TWh]','Nuclear',r,y) = ProductionByTechnologyAnnual.l(r,'P_Nuclear','Power',y)/3.6;
output_powergeneration('Power Generation [TWh]','Natural Gas',r,y) = sum((Gas),z_ProductionByTechnologyByModeAnnual(r,Gas,'1','Power',y))/3.6;
output_powergeneration('Power Generation [TWh]','Biogas',r,y) = sum((Gas),z_ProductionByTechnologyByModeAnnual(r,Gas,'2','Power',y))/3.6;
output_powergeneration('Power Generation [TWh]','Synthetic Gas',r,y) = sum((Gas),z_ProductionByTechnologyByModeAnnual(r,Gas,'3','Power',y))/3.6;
output_powergeneration('Power Generation [TWh]','H2',r,y) = sum((Hydrogen),ProductionByTechnologyAnnual.l(r,Hydrogen,'Power',y))/3.6;
output_powergeneration('Power Generation [TWh]','Other',r,y) = sum((t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y))/3.6-(
output_powergeneration('Power Generation [TWh]','Solar',r,y)
+output_powergeneration('Power Generation [TWh]','Onshore Wind',r,y)
+output_powergeneration('Power Generation [TWh]','Offshore Wind',r,y)
+output_powergeneration('Power Generation [TWh]','Hydro',r,y)
+output_powergeneration('Power Generation [TWh]','Biomass',r,y)
+output_powergeneration('Power Generation [TWh]','Coal',r,y)
+output_powergeneration('Power Generation [TWh]','Oil',r,y)
+output_powergeneration('Power Generation [TWh]','Nuclear',r,y)
+output_powergeneration('Power Generation [TWh]','Natural Gas',r,y)
+output_powergeneration('Power Generation [TWh]','Biogas',r,y)
+output_powergeneration('Power Generation [TWh]','Synthetic Gas',r,y)
+output_powergeneration('Power Generation [TWh]','H2',r,y));

output_powergeneration('Capacity [GW]','Solar',r,y) = sum((Solar)$(sum(m,OutputActivityRatio(r,Solar,'Power',m,y))>0), TotalCapacityAnnual.l(r,Solar,y));
output_powergeneration('Capacity [GW]','Onshore Wind',r,y) = sum((Onshore)$(sum(m,OutputActivityRatio(r,Onshore,'Power',m,y))>0), TotalCapacityAnnual.l(r,Onshore,y));
output_powergeneration('Capacity [GW]','Offshore Wind',r,y) = sum((Offshore)$(sum(m,OutputActivityRatio(r,Offshore,'Power',m,y))>0), TotalCapacityAnnual.l(r,Offshore,y));
output_powergeneration('Capacity [GW]','Hydro',r,y) = sum((Hydro)$(sum(m,OutputActivityRatio(r,Hydro,'Power',m,y))>0), TotalCapacityAnnual.l(r,Hydro,y));
output_powergeneration('Capacity [GW]','Biomass',r,y) = sum((PowerBiomass)$(sum(m,OutputActivityRatio(r,PowerBiomass,'Power',m,y))>0), TotalCapacityAnnual.l(r,PowerBiomass,y));
output_powergeneration('Capacity [GW]','Coal',r,y) = sum((Coal)$(sum(m,OutputActivityRatio(r,Coal,'Power',m,y))>0), TotalCapacityAnnual.l(r,Coal,y));
output_powergeneration('Capacity [GW]','Oil',r,y) = sum((Oil)$(sum(m,OutputActivityRatio(r,Oil,'Power',m,y))>0), TotalCapacityAnnual.l(r,Oil,y));
output_powergeneration('Capacity [GW]','Nuclear',r,y) = TotalCapacityAnnual.l(r,'P_Nuclear',y);
output_powergeneration('Capacity [GW]','Gas',r,y) = sum((Gas)$(sum(m,OutputActivityRatio(r,Gas,'Power',m,y))>0), TotalCapacityAnnual.l(r,Gas,y));
output_powergeneration('Capacity [GW]','H2',r,y) = sum((Hydrogen)$(sum(m,OutputActivityRatio(r,Hydrogen,'Power',m,y))>0), TotalCapacityAnnual.l(r,Hydrogen,y));


output_powergeneration('Power Generation [%]','Solar','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Solar',r,y))/sum((r,t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y))*3.6;
output_powergeneration('Power Generation [%]','Onshore Wind','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Onshore Wind',r,y))/sum((r,t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y))*3.6;
output_powergeneration('Power Generation [%]','Offshore Wind','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Offshore Wind',r,y))/sum((r,t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y))*3.6;
output_powergeneration('Power Generation [%]','Hydro','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Hydro',r,y))/sum((r,t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y))*3.6;
output_powergeneration('Power Generation [%]','Biomass','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Biomass',r,y))/sum((r,t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y))*3.6;
output_powergeneration('Power Generation [%]','Coal','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Coal',r,y))/sum((r,t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y))*3.6;
output_powergeneration('Power Generation [%]','Oil','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Oil',r,y))/sum((r,t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y))*3.6;
output_powergeneration('Power Generation [%]','Nuclear','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Nuclear',r,y))/sum((r,t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y))*3.6;
output_powergeneration('Power Generation [%]','Natural Gas','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Natural Gas',r,y))/sum((r,t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y))*3.6;
output_powergeneration('Power Generation [%]','Biogas','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Biogas',r,y))/sum((r,t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y))*3.6;
output_powergeneration('Power Generation [%]','Synthetic Gas','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Synthetic Gas',r,y))/sum((r,t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y))*3.6;
output_powergeneration('Power Generation [%]','H2','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','H2',r,y))/sum((r,t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y))*3.6;
output_powergeneration('Power Generation [%]','Other','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Other',r,y))/sum((r,t)$(not StorageDummies(t)), ProductionByTechnologyAnnual.l(r,t,'Power',y))*3.6;

output_powergeneration('Power Generation [TWh]','Solar','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Solar',r,y));
output_powergeneration('Power Generation [TWh]','Onshore Wind','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Onshore Wind',r,y));
output_powergeneration('Power Generation [TWh]','Offshore Wind','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Offshore Wind',r,y));
output_powergeneration('Power Generation [TWh]','Hydro','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Hydro',r,y));
output_powergeneration('Power Generation [TWh]','Biomass','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Biomass',r,y));
output_powergeneration('Power Generation [TWh]','Coal','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Coal',r,y));
output_powergeneration('Power Generation [TWh]','Oil','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Oil',r,y));
output_powergeneration('Power Generation [TWh]','Nuclear','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Nuclear',r,y));
output_powergeneration('Power Generation [TWh]','Natural Gas','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Natural Gas',r,y));
output_powergeneration('Power Generation [TWh]','Biogas','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Biogas',r,y));
output_powergeneration('Power Generation [TWh]','Synthetic Gas','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Synthetic Gas',r,y));
output_powergeneration('Power Generation [TWh]','H2','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','H2',r,y));
output_powergeneration('Power Generation [TWh]','Other','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Other',r,y));

output_powergeneration('Power Generation [TWh]','Total',r,y) =
output_powergeneration('Power Generation [TWh]','Solar',r,y) +
output_powergeneration('Power Generation [TWh]','Onshore Wind',r,y) +
output_powergeneration('Power Generation [TWh]','Offshore Wind',r,y) +
output_powergeneration('Power Generation [TWh]','Hydro',r,y) +
output_powergeneration('Power Generation [TWh]','Biomass',r,y) +
output_powergeneration('Power Generation [TWh]','Coal',r,y) +
output_powergeneration('Power Generation [TWh]','Oil',r,y) +
output_powergeneration('Power Generation [TWh]','Nuclear',r,y) +
output_powergeneration('Power Generation [TWh]','Natural Gas',r,y) +
output_powergeneration('Power Generation [TWh]','Biogas',r,y) +
output_powergeneration('Power Generation [TWh]','Synthetic Gas',r,y) +
output_powergeneration('Power Generation [TWh]','H2',r,y) +
output_powergeneration('Power Generation [TWh]','Other',r,y);
output_powergeneration('Power Generation [TWh]','Total','Europe',y) = sum(r,output_powergeneration('Power Generation [TWh]','Total',r,y));

output_powergeneration('Capacity [GW]','Solar','Europe',y) = sum(r,output_powergeneration('Capacity [GW]','Solar',r,y));
output_powergeneration('Capacity [GW]','Onshore Wind','Europe',y) = sum(r,output_powergeneration('Capacity [GW]','Onshore Wind',r,y));
output_powergeneration('Capacity [GW]','Offshore Wind','Europe',y) = sum(r,output_powergeneration('Capacity [GW]','Offshore Wind',r,y));
output_powergeneration('Capacity [GW]','Hydro','Europe',y) = sum(r,output_powergeneration('Capacity [GW]','Hydro',r,y));
output_powergeneration('Capacity [GW]','Biomass','Europe',y) = sum(r,output_powergeneration('Capacity [GW]','Biomass',r,y));
output_powergeneration('Capacity [GW]','Coal','Europe',y) = sum(r,output_powergeneration('Capacity [GW]','Coal',r,y));
output_powergeneration('Capacity [GW]','Oil','Europe',y) = sum(r,output_powergeneration('Capacity [GW]','Oil',r,y));
output_powergeneration('Capacity [GW]','Nuclear','Europe',y) = sum(r,output_powergeneration('Capacity [GW]','Nuclear',r,y));
output_powergeneration('Capacity [GW]','Gas','Europe',y) = sum(r,output_powergeneration('Capacity [GW]','Gas',r,y));
output_powergeneration('Capacity [GW]','H2','Europe',y) = sum(r,output_powergeneration('Capacity [GW]','H2',r,y));

* -------
* Flexibility
* Build of battery + storage
* DSM if implemented"

parameter output_flexibility;
output_flexibility('Capacity [GW | Power]',r,StorageDummies,y) = TotalCapacityAnnual.l(r,StorageDummies,y);
output_flexibility('Capacity [GW | Power]','Europe',StorageDummies,y) = sum(r,TotalCapacityAnnual.l(r,StorageDummies,y));
output_flexibility('Capacity [GW | Power]','Europe_AT','D_PHS',y)$(output_flexibility('Capacity [GW | Power]','Europe_AT','D_PHS',y) = 0) = na;
*output_flexibility('Capacity [GWh | Energy]',r,StorageDummies,y) = TotalCapacityAnnual.l(r,StorageDummies,y)*sum(s,StorageMaxChargeRate(r,s)*TechnologyToStorage(y,'1',StorageDummies,s));
*output_flexibility('Capacity [GWh | Energy]','Europe',StorageDummies,y) = sum(r,TotalCapacityAnnual.l(r,StorageDummies,y)*sum(s,StorageMaxChargeRate(r,s)*TechnologyToStorage(y,'1',StorageDummies,s)));
output_flexibility('Capacity [GWh | Energy]','Europe_AT','D_PHS',y)$(output_flexibility('Capacity [GWh | Energy]','Europe_AT','D_PHS',y) = 0) = na;


* -------
* Interconnection
* Interconnection build GW
* Power trade volumes (%, TWh)
**** NET TRADE VOLUMES OR IMPORT / EXPORT?
* Level of import dependency per region"

parameter output_interconnection;
output_interconnection('Transmission Capacity [GW]',r,y) = sum(rr,TotalTradeCapacity.l(r,rr,'Power',y));
output_interconnection('Net Trade Volumes [TWh]',r,y) = NetTradeAnnual.l(y,'Power',r)/3.6;
output_interconnection('Absolute Import Volume [TWh]',r,y) = sum((l,rr), Import.l(y,l,'Power',r,rr));
output_interconnection('Import Dependency [%]',r,y) = (-1)*min(0,NetTradeAnnual.l(y,'Power',r))/(UseAnnual.l(y,'Power',r)-sum(StorageDummies,UseByTechnologyAnnual.l(r,StorageDummies,'Power',y))+SpecifiedAnnualDemand(r,'Power',y));
output_interconnection('Transmission Capacity [GW]','Europe_AT',y)$(output_interconnection('Transmission Capacity [GW]','Europe_AT',y) = 0) = na;

* -------
* Emissions
* Split by sector and region
* Emissions intensity for power per MWh, transport (per km), heat per MWh"

parameter output_emissions2;
output_emissions2('Emissions per Sector [Mt]',se,e,r,y) = sum(t$(TagTechnologyToSector(t,se)),AnnualTechnologyEmission.l(y,t,e,r));
output_emissions2('Emissions per Sector [Mt]',se,e,'Europe',y) = sum(r,output_emissions2('Emissions per Sector [Mt]',se,e,r,y));
output_emissions2('Emission intensity [kg/MWh|km]',se,e,r,y)$(sum(f$(TagFuelToSector(se,f)),SpecifiedAnnualDemand(r,f,y)) > 0) = sum(f$(TagFuelToSector(se,f)), EmissionIntensity(y,r,f,e)*SpecifiedAnnualDemand(r,f,y))/sum(f$(TagFuelToSector(se,f)),SpecifiedAnnualDemand(r,f,y))*(3.6$(not sameas (se,'Transportation'))+1$(sameas (se,'Transportation')));
output_emissions2('Emission intensity [kg/MWh|km]',se,e,'Europe',y)$(sum((r,f)$(TagFuelToSector(se,f)),SpecifiedAnnualDemand(r,f,y)) > 0) = sum((f,r)$(TagFuelToSector(se,f)), EmissionIntensity(y,r,f,e)*SpecifiedAnnualDemand(r,f,y))/sum((f,r)$(TagFuelToSector(se,f)),SpecifiedAnnualDemand(r,f,y))*(3.6$(not sameas (se,'Transportation'))+1$(sameas (se,'Transportation')));

output_emissions2('Emissions per Sector [Mt]','Total',e,r,y) = sum(se,output_emissions2('Emissions per Sector [Mt]',se,e,r,y));
output_emissions2('Emissions per Sector [Mt]','Total',e,'Europe',y) = sum(r,output_emissions2('Emissions per Sector [Mt]','Total',e,r,y));

output_emissions2('Emissions per Sector [Mt]','Power',e,'Europe_AT',y)$(output_emissions2('Emissions per Sector [Mt]','Power',e,'Europe_AT',y) = 0) = na;

* -------
* CO2 price
* CO2 prices (if not modelled as an input)"

parameter output_carbonprice;
output_carbonprice('CO2 price [�/Mt]',r,y) = (-1)*E8_RegionalAnnualEmissionsLimit.m(y,'CO2',r)+(-1)*E9_AnnualEmissionsLimit.m(y,'CO2')+EmissionsPenalty(r,'CO2',y);
output_carbonprice('CO2 price [�/Mt]',r,'2015') = 0;
output_carbonprice('CO2 price [�/Mt]','Europe',y) = (-1)*E9_AnnualEmissionsLimit.m(y,'CO2')+(sum(r,EmissionsPenalty(r,'CO2',y)+(-1)*E8_RegionalAnnualEmissionsLimit.m(y,'CO2',r))/card(r));
output_carbonprice('CO2 price [�/Mt]','Europe','2015') = 0;
output_carbonprice('CO2 price [�/Mt]','Europe_AT',y)$(output_carbonprice('CO2 price [�/Mt]','Europe_AT',y) = 0) = na;

* -------
* Levelized power prices compared to Reference case
* Split by region"
*** TO DO AS SOON AS REFERENCE CASE IS FIXED


* -------
* Some additional CCS statistics
*

parameter output_ccs_stats;
output_ccs_stats('Annual CO2 Sequestered [Mt]',r,t,y)$(UseByTechnologyAnnual.l(r,t,'CCS',y)>0) = UseByTechnologyAnnual.l(r,t,'CCS',y);
output_ccs_stats('Installed CCS Capacities [GW]',r,t,y)$(sum(m,InputActivityRatio(r,t,'CCS',m,y))>0) = TotalCapacityAnnual.l(r,t,y);
output_ccs_stats('Annual CO2 Sequestered [Mt]','Europe_AT','P_Biomass_CCS',y)$(output_ccs_stats('Annual CO2 Sequestered [Mt]','Europe_AT','P_Biomass_CCS',y) = 0) = na;
output_ccs_stats('Installed CCS Capacities [GW]','Europe_AT','P_Biomass_CCS',y)$(output_ccs_stats('Installed CCS Capacities [GW]','Europe_AT','P_Biomass_CCS',y) = 0) = na;

$ifthen %switch_unixPath% == 0
$ifthen %sensitivity% == reference
execute_unload "%gdxdir%\sensitivitydashboard\sensitivity_z_%sensitivity%_%sensitivity_identifier%_%elmod_nthhour%.gdx"
$else
execute_unload "%gdxdir%\sensitivitydashboard\sensitivity_%sensitivity%_%sensitivity_identifier%_%elmod_nthhour%.gdx"
$endif
$else
$ifthen %sensitivity% == reference
execute_unload "%gdxdir%/sensitivitydashboard/sensitivity_z_%sensitivity%_%sensitivity_identifier%_%elmod_nthhour%.gdx"
$else
execute_unload "%gdxdir%/sensitivitydashboard/sensitivity_%sensitivity%_%sensitivity_identifier%_%elmod_nthhour%.gdx"
$endif
$endif

output_systemcosts
output_electrificationrate
output_finalenergydemandsector
output_hydrogenuse
output_hydrogenproduction
output_powergeneration
output_flexibility
output_interconnection
output_emissions2
output_carbonprice
output_ccs_stats
;

