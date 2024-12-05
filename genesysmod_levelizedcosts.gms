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

$ifthen %test% == 1
$include genesysmod_results.gms
$include genesysmod_settings.gms
$endif

Set TierTwo(t);
TierTwo(t) = no;
TierTwo('X_Methanation') = yes;
TierTwo('X_SMR') = yes;

Set TierThree(f);
TierThree(f) = no;
TierThree('Gas_Bio') = yes;
TierThree('Biofuel') = yes;
TierThree('Gas_Synth') = yes;

Set TierFive(f);
TierFive(f) = no;
TierFive('Mobility_Passenger') = yes;
TierFive('Mobility_Freight') = yes;
TierFive('Heat_Buildings') = yes;
TierFive('Heat_Low_Industrial') = yes;
TierFive('Heat_MediumHigh_Industrial') = yes;
TierFive('Heat_MediumLow_Industrial') = yes;
TierFive('Heat_High_Industrial') = yes;

Set Resources(f);
Resources(f) = no;
Resources('Hardcoal') = yes;
Resources('Lignite') = yes;
Resources('Gas_Natural') = yes;
Resources('Oil') = yes;
Resources('Nuclear') = yes;
Resources('Biomass') = yes;
Resources('H2') = yes;

Set ResourceTechnologies(t);
ResourceTechnologies(t) = no;
ResourceTechnologies('R_Grass') = yes;
ResourceTechnologies('R_Wood') = yes;
ResourceTechnologies('R_Residues') = yes;
ResourceTechnologies('R_Paper_Cardboard') = yes;
ResourceTechnologies('R_Roundwood') = yes;
ResourceTechnologies('R_Biogas') = yes;
ResourceTechnologies('Z_Import_Hardcoal') = yes;
ResourceTechnologies('R_Coal_Hardcoal') = yes;
ResourceTechnologies('R_Coal_Lignite') = yes;
ResourceTechnologies('Z_Import_Oil') = yes;
ResourceTechnologies('Z_Import_Gas') = yes;
ResourceTechnologies('R_Nuclear') = yes;
ResourceTechnologies('R_Gas') = yes;
ResourceTechnologies('R_Oil') = yes;


set Time /0*110/;
alias (Time,o);
alias (FUEL,fff);
alias (t,tt);
alias (m,mm);

parameters
levelizedcostsPJ
levelizedcostskWh
maxgeneration
fuelcosts
resourcecosts
AnnualProduction
AnnualTechnologyProduction
emissioncosts
capitalcosts
omcosts
discountedfuelcosts
testlevelizedcostsPJ
AnnualTechnologyProductionByMode
output_costs
testcosts
output_fuelcosts
TechnologyEmissions
RegionalEmissionContentPerFuel
AnnualSectorEmissions
TechnologyEmissionsByMode
SectorEmissions
EmissionIntensity
output_emissionintensity;



$ifthen %switch_only_write_results% == 1
$gdxin  test.gdx
$load AnnualProduction = ProductionAnnual.l
$load AnnualTechnologyProduction = ProductionByTechnologyAnnual.l
$load AnnualTechnologyProductionByMode = z_ProductionByTechnologyByModeAnnual
$load TechnologyEmissions = AnnualTechnologyEmission.l
$load TechnologyEmissionsByMode = AnnualTechnologyEmissionByMode.l
$gdxin
$else
AnnualProduction(y,f,r) = ProductionAnnual(y,f,r);
AnnualTechnologyProduction(y,t,f,r) = ProductionByTechnologyAnnual.l(y,t,f,r) ;
AnnualTechnologyProductionByMode(r,t,m,f,y) = sum(l,RateOfProductionByTechnologyByMode(y,l,t,m,f,r)*YearSplit(l,y));
TechnologyEmissions(y,t,e,r) = AnnualTechnologyEmission.l(y,t,e,r)                         ;
AnnualSectorEmissions(r,e,se,y)  = AnnualSectoralEmissions.l(y,e,se,r)                         ;
TechnologyEmissionsByMode(y,t,e,m,r)   = AnnualTechnologyEmissionByMode.l(y,t,e,m,r)               ;
$endif

parameter Carbonprice(r_full,e,y_full);
CarbonPrice(r,e,y) = (-1)*E8_RegionalAnnualEmissionsLimit.m(y,'CO2',r);
CarbonPrice(r,e,y)$(CarbonPrice(r,e,y) = 0) = (-1)*E9_AnnualEmissionsLimit.m(y,'CO2');
CarbonPrice(r,e,y)$(CarbonPrice(r,e,y) = 0) = EmissionsPenalty(r,e,y);
CarbonPrice(r,e,y)$(CarbonPrice(r,e,y) = 0) = 15;


SectorEmissions(y,r,'Power',e) =  sum((m,t),TechnologyEmissionsByMode(y,t,e,m,r)*OutputActivityRatio(r,t,'Power',m,y));
SectorEmissions(y,r,TierFive,e) = sum((m,t),TechnologyEmissionsByMode(y,t,e,m,r)*OutputActivityRatio(r,t,TierFive,m,y));

Parameter test(YEAR_FULL,FUEL,REGION_FULL);
test(y,f,r) = sum(t,ProductionByTechnologyAnnual.l(y,t,'Power',r)$(not TagTechnologyToSector(t,'Storages')));

EmissionIntensity(y,r,'Power',e)$(sum(t,ProductionByTechnologyAnnual.l(y,t,'Power',r)$(not TagTechnologyToSector(t,'Storages')))) = SectorEmissions(y,r,'Power',e)/sum(t,ProductionByTechnologyAnnual.l(y,t,'Power',r)$(not TagTechnologyToSector(t,'Storages')));
EmissionIntensity(y,r,TierFive,e)$(AnnualProduction(y,TierFive,r)) = SectorEmissions(y,r,TierFive,e)/AnnualProduction(y,TierFive,r);


RegionalEmissionContentPerFuel(y,r,f,e) = EmissionContentPerFuel(f,e);
RegionalEmissionContentPerFuel(y,r,'Power',e)  =   EmissionIntensity(y,r,'Power',e);


****
**** Tier 0: Preliminary Calculations (Generation Factors, O&M Costs, Capital Costs, Resource Commodity Prices)
****

maxgeneration(r,t,y,m,f) =  sum(l,CapacityFactor(r,t,l,y)*YearSplit(l,y))*smax(yy,AvailabilityFactor(r,t,yy))*CapacityToActivityUnit(t)*OutputActivityRatio(r,t,f,m,y);
resourcecosts(r,Resources,y)$(AnnualProduction(y,Resources,r) > 0)= sum(ResourceTechnologies,(VariableCost(r,ResourceTechnologies,'1',y) * AnnualTechnologyProduction(y,ResourceTechnologies,Resources,r)/AnnualProduction(y,Resources,r)));
resourcecosts(r,Resources,y)$(not resourcecosts(r,Resources,y)) = z_fuelcosts(Resources,y,r);

fuelcosts(r,t,f,m,y)$(OutputActivityRatio(r,t,f,m,y) > 0) = sum(fff,InputActivityRatio(r,t,fff,m,y)*resourcecosts(r,fff,y))/OutputActivityRatio(r,t,f,m,y);
emissioncosts(r,t,f,m,y)$(OutputActivityRatio(r,t,f,m,y) > 0) = sum(fff,InputActivityRatio(r,t,fff,m,y)*sum(e,EmissionActivityRatio(r,t,m,e,y)*RegionalEmissionContentPerFuel(y,r,fff,e)*CarbonPrice(r,e,y)))/OutputActivityRatio(r,t,f,m,y);
capitalcosts(r,t,f,m,y)$(OutputActivityRatio(r,t,f,m,y) > 0 and maxgeneration(r,t,y,m,f) > 0)  = (CapitalCost(r,t,y)) / sum(o$(o.val <= OperationalLife(t)),(maxgeneration(r,t,y,m,f)/((1+GeneralDiscountRate(r))**o.val)));
omcosts(r,t,f,m,y)$(OutputActivityRatio(r,t,f,m,y) > 0 and maxgeneration(r,t,y,m,f) > 0) = (sum(o$(o.val <= OperationalLife(t)),((FixedCost(r,t,y)+(VariableCost(r,t,m,y))*maxgeneration(r,t,y,m,f))/((1+GeneralDiscountRate(r))**o.val)))) / sum(o$(o.val <= OperationalLife(t)),(maxgeneration(r,t,y,m,f)/((1+GeneralDiscountRate(r))**o.val)));

****
**** Tier 1: Power Prices WITHOUT Re-Electrification
****

discountedfuelcosts(r,t,'Power',m,y)$(OutputActivityRatio(r,t,'Power',m,y) > 0 and maxgeneration(r,t,y,m,'Power') > 0) = (sum(o$(o.val <= OperationalLife(t)),(((fuelcosts(r,t,'Power',m,y))*maxgeneration(r,t,y,m,'Power'))/((1+GeneralDiscountRate(r))**o.val)))) / sum(o$(o.val <= OperationalLife(t)),(maxgeneration(r,t,y,m,'Power')/((1+GeneralDiscountRate(r))**o.val)));
testlevelizedcostsPJ(r,t,'Power',m,y)$(OutputActivityRatio(r,t,'Power',m,y) > 0 and maxgeneration(r,t,y,m,'Power') > 0) = (CapitalCost(r,t,y)+sum(o$(o.val <= OperationalLife(t)),((FixedCost(r,t,y)+(VariableCost(r,t,m,y)+fuelcosts(r,t,'Power',m,y))*maxgeneration(r,t,y,m,'Power'))/((1+GeneralDiscountRate(r))**o.val)))) / sum(o$(o.val <= OperationalLife(t)),(maxgeneration(r,t,y,m,'Power')/((1+GeneralDiscountRate(r))**o.val)));
levelizedcostsPJ(r,t,'Power',m,y)$(OutputActivityRatio(r,t,'Power',m,y) > 0 and maxgeneration(r,t,y,m,'Power') > 0) = capitalcosts(r,t,'Power',m,y)+omcosts(r,t,'Power',m,y)+discountedfuelcosts(r,t,'Power',m,y)+emissioncosts(r,t,'Power',m,y);


resourcecosts(r,'Power',y)$(AnnualProduction(y,'Power',r) > 0)= sum((t),(levelizedcostsPJ(r,t,'Power','1',y) * AnnualTechnologyProductionByMode(r,t,'1','Power',y)/sum(tt,AnnualTechnologyProductionByMode(r,tt,'1','Power',y))));
testcosts(r,'Power',y) = resourcecosts(r,'Power',y)*3.6;


****
**** Tier 2: Hydrogen
****

fuelcosts(r,t,f,m,y)$(OutputActivityRatio(r,t,f,m,y) > 0) = sum(fff,InputActivityRatio(r,t,fff,m,y)*resourcecosts(r,fff,y))/OutputActivityRatio(r,t,f,m,y);
discountedfuelcosts(r,t,'H2',m,y)$(OutputActivityRatio(r,t,'H2',m,y) > 0 and maxgeneration(r,t,y,m,'H2') > 0) = (sum(o$(o.val <= OperationalLife(t)),(((fuelcosts(r,t,'H2',m,y))*maxgeneration(r,t,y,m,'H2'))/((1+GeneralDiscountRate(r))**o.val)))) / sum(o$(o.val <= OperationalLife(t)),(maxgeneration(r,t,y,m,'H2')/((1+GeneralDiscountRate(r))**o.val)));
levelizedcostsPJ(r,t,'H2',m,y)$(OutputActivityRatio(r,t,'H2',m,y) > 0 and maxgeneration(r,t,y,m,'H2') > 0) = capitalcosts(r,t,'H2',m,y)+omcosts(r,t,'H2',m,y)+discountedfuelcosts(r,t,'H2',m,y)+emissioncosts(r,t,'H2',m,y)$(emissioncosts(r,t,'H2',m,y)>0);

resourcecosts(r,'H2',y)$(sum(tt,AnnualTechnologyProductionByMode(r,tt,'1','H2',y) > 0)) = sum((t),(levelizedcostsPJ(r,t,'H2','1',y) * AnnualTechnologyProductionByMode(r,t,'1','H2',y)/sum(tt,AnnualTechnologyProductionByMode(r,tt,'1','H2',y))));
testcosts(r,'H2',y) = resourcecosts(r,'H2',y)*3.6;

****
**** Tier 3: Synth Nat Gas, Biogas, Biofuels
****

fuelcosts(r,t,f,m,y)$(OutputActivityRatio(r,t,f,m,y) > 0) = sum(fff,InputActivityRatio(r,t,fff,m,y)*resourcecosts(r,fff,y))/OutputActivityRatio(r,t,f,m,y);
discountedfuelcosts(r,t,TierThree,m,y)$(OutputActivityRatio(r,t,TierThree,m,y) > 0 and maxgeneration(r,t,y,m,TierThree) > 0) = (sum(o$(o.val <= OperationalLife(t)),(((fuelcosts(r,t,TierThree,m,y))*maxgeneration(r,t,y,m,TierThree))/((1+GeneralDiscountRate(r))**o.val)))) /sum(o$(o.val <= OperationalLife(t)),(maxgeneration(r,t,y,m,TierThree)/((1+GeneralDiscountRate(r))**o.val)));
levelizedcostsPJ(r,t,TierThree,m,y)$(OutputActivityRatio(r,t,TierThree,m,y) > 0 and maxgeneration(r,t,y,m,TierThree) > 0) = capitalcosts(r,t,TierThree,m,y)+omcosts(r,t,TierThree,m,y)+discountedfuelcosts(r,t,TierThree,m,y)+emissioncosts(r,t,TierThree,m,y)$(emissioncosts(r,t,TierThree,m,y)>0);

resourcecosts(r,TierThree,y)$(sum(tt,AnnualTechnologyProductionByMode(r,tt,'1',TierThree,y) > 0))= sum((t),(levelizedcostsPJ(r,t,TierThree,'1',y) * AnnualTechnologyProductionByMode(r,t,'1',TierThree,y)/sum(tt,AnnualTechnologyProductionByMode(r,tt,'1',TierThree,y))));
testcosts(r,TierThree,y) = resourcecosts(r,TierThree,y)*3.6;
resourcecosts(r,'Gas_Bio',y)$(not resourcecosts(r,'Gas_Bio',y)) = resourcecosts(r,'Biomass',y)*InputActivityRatio(r,'X_Methanation','Biomass','2',y);

****
**** Tier 4: Power Prices including Re-Electrification from e.g. Synth Nat Gas
****

fuelcosts(r,t,f,m,y)$(OutputActivityRatio(r,t,f,m,y) > 0) = sum(fff,InputActivityRatio(r,t,fff,m,y)*resourcecosts(r,fff,y))/OutputActivityRatio(r,t,f,m,y);
fuelcosts(r,t,f,'1',y)$(OutputActivityRatio(r,t,f,'2',y) > 0 and TagTechnologyToSubsets(t,'StorageDummies')) = sum(fff,InputActivityRatio(r,t,fff,'1',y)*resourcecosts(r,fff,y))/(OutputActivityRatio(r,t,f,'2',y)*sum(s,TechnologyToStorage(t,s,'1',y)**2));
discountedfuelcosts(r,t,'Power',m,y)$(OutputActivityRatio(r,t,'Power',m,y) > 0 and maxgeneration(r,t,y,m,'Power') > 0) = (sum(o$(o.val <= OperationalLife(t)),(((fuelcosts(r,t,'Power',m,y))*maxgeneration(r,t,y,m,'Power'))/((1+GeneralDiscountRate(r))**o.val)))) / sum(o$(o.val <= OperationalLife(t)),(maxgeneration(r,t,y,m,'Power')/((1+GeneralDiscountRate(r))**o.val)));
levelizedcostsPJ(r,t,'Power',m,y)$(OutputActivityRatio(r,t,'Power',m,y) > 0 and maxgeneration(r,t,y,m,'Power') > 0) = capitalcosts(r,t,'Power',m,y)+omcosts(r,t,'Power',m,y)+discountedfuelcosts(r,t,'Power',m,y)+emissioncosts(r,t,'Power',m,y)$(emissioncosts(r,t,'Power',m,y)>0);

resourcecosts(r,'Power',y)$(AnnualProduction(y,'Power',r) > 0)= sum((t,m),(levelizedcostsPJ(r,t,'Power',m,y) * AnnualTechnologyProductionByMode(r,t,m,'Power',y)/sum((tt,mm),AnnualTechnologyProductionByMode(r,tt,mm,'Power',y))));
testcosts(r,'Power2',y) = resourcecosts(r,'Power',y)*3.6;

****
**** Tier 4.5: Resource Costs for the Case of no Production
****

resourcecosts(r,'H2',y)$(resourcecosts(r,'H2',y) = 0) = levelizedcostsPJ(r,'Z_Import_H2','H2','1',y);
resourcecosts(r,'Biofuel',y)$(resourcecosts(r,'Biofuel',y) = 0) = levelizedcostsPJ(r,'X_Biofuel','Biofuel','1',y);
resourcecosts(r,'Gas_Synth',y) = levelizedcostsPJ(r,'X_Methanation','Gas_Synth','1',y);


****
**** Tier 2X: Hydrogen
****

fuelcosts(r,t,f,m,y)$(OutputActivityRatio(r,t,f,m,y) > 0) = sum(fff,InputActivityRatio(r,t,fff,m,y)*resourcecosts(r,fff,y))/OutputActivityRatio(r,t,f,m,y);
discountedfuelcosts(r,t,'H2',m,y)$(OutputActivityRatio(r,t,'H2',m,y) > 0 and maxgeneration(r,t,y,m,'H2') > 0) = (sum(o$(o.val <= OperationalLife(t)),(((fuelcosts(r,t,'H2',m,y))*maxgeneration(r,t,y,m,'H2'))/((1+GeneralDiscountRate(r))**o.val)))) / sum(o$(o.val <= OperationalLife(t)),(maxgeneration(r,t,y,m,'H2')/((1+GeneralDiscountRate(r))**o.val)));
levelizedcostsPJ(r,t,'H2',m,y)$(OutputActivityRatio(r,t,'H2',m,y) > 0 and maxgeneration(r,t,y,m,'H2') > 0) = capitalcosts(r,t,'H2',m,y)+omcosts(r,t,'H2',m,y)+discountedfuelcosts(r,t,'H2',m,y)+emissioncosts(r,t,'H2',m,y)$(emissioncosts(r,t,'H2',m,y)>0);

resourcecosts(r,'H2',y)$(sum(tt,AnnualTechnologyProductionByMode(r,tt,'1','H2',y)))= sum((t),(levelizedcostsPJ(r,t,'H2','1',y) * AnnualTechnologyProductionByMode(r,t,'1','H2',y)/sum(tt,AnnualTechnologyProductionByMode(r,tt,'1','H2',y))));
testcosts(r,'H22',y) = resourcecosts(r,'H2',y)*3.6;

****
**** Tier 3X: Synth Nat Gas, Biogas, Biofuels
****

fuelcosts(r,t,f,m,y)$(OutputActivityRatio(r,t,f,m,y) > 0) = sum(fff,InputActivityRatio(r,t,fff,m,y)*resourcecosts(r,fff,y))/OutputActivityRatio(r,t,f,m,y);
discountedfuelcosts(r,t,TierThree,m,y)$(OutputActivityRatio(r,t,TierThree,m,y) > 0 and maxgeneration(r,t,y,m,TierThree) > 0) = (sum(o$(o.val <= OperationalLife(t)),(((fuelcosts(r,t,TierThree,m,y))*maxgeneration(r,t,y,m,TierThree))/((1+GeneralDiscountRate(r))**o.val)))) / sum(o$(o.val <= OperationalLife(t)),(maxgeneration(r,t,y,m,TierThree)/((1+GeneralDiscountRate(r))**o.val)));
levelizedcostsPJ(r,t,TierThree,m,y)$(OutputActivityRatio(r,t,TierThree,m,y) > 0 and maxgeneration(r,t,y,m,TierThree) > 0) = capitalcosts(r,t,TierThree,m,y)+omcosts(r,t,TierThree,m,y)+discountedfuelcosts(r,t,TierThree,m,y)+emissioncosts(r,t,TierThree,m,y)$(emissioncosts(r,t,TierThree,m,y)>0);

resourcecosts(r,TierThree,y)$(sum((m,tt),AnnualTechnologyProductionByMode(r,tt,m,TierThree,y)>0))= sum((m,t),(levelizedcostsPJ(r,t,TierThree,m,y) * AnnualTechnologyProductionByMode(r,t,m,TierThree,y)/sum((mm,tt),AnnualTechnologyProductionByMode(r,tt,mm,TierThree,y))));
resourcecosts(r,'Gas_Synth',y) = levelizedcostsPJ(r,'X_Methanation','Gas_Synth','1',y);
testcosts(r,'Gas_Synth2',y) = resourcecosts(r,'Gas_Synth',y)*3.6;
testcosts(r,'Gas_Bio2',y) = resourcecosts(r,'Gas_Bio',y)*3.6;
testcosts(r,'Biofuel2',y) = resourcecosts(r,'Biofuel',y)*3.6;

****
**** Tier 4X: Power Prices including Re-Electrification from e.g. Synth Nat Gas
****

fuelcosts(r,t,f,m,y)$(OutputActivityRatio(r,t,f,m,y) > 0) = sum(fff,InputActivityRatio(r,t,fff,m,y)*resourcecosts(r,fff,y))/OutputActivityRatio(r,t,f,m,y);
fuelcosts(r,t,f,'1',y)$(OutputActivityRatio(r,t,f,'2',y) > 0 and TagTechnologyToSubsets(t,'StorageDummies')) = sum(fff,InputActivityRatio(r,t,fff,'1',y)*resourcecosts(r,fff,y))/(OutputActivityRatio(r,t,f,'2',y)*sum(s,TechnologyToStorage(t,s,'1',y)**2));
discountedfuelcosts(r,t,'Power',m,y)$(OutputActivityRatio(r,t,'Power',m,y) > 0 and maxgeneration(r,t,y,m,'Power') > 0) = (sum(o$(o.val <= OperationalLife(t)),(((fuelcosts(r,t,'Power',m,y))*maxgeneration(r,t,y,m,'Power'))/((1+GeneralDiscountRate(r))**o.val)))) / sum(o$(o.val <= OperationalLife(t)),(maxgeneration(r,t,y,m,'Power')/((1+GeneralDiscountRate(r))**o.val)));
levelizedcostsPJ(r,t,'Power',m,y)$(OutputActivityRatio(r,t,'Power',m,y) > 0 and maxgeneration(r,t,y,m,'Power') > 0) = capitalcosts(r,t,'Power',m,y)+omcosts(r,t,'Power',m,y)+discountedfuelcosts(r,t,'Power',m,y)+emissioncosts(r,t,'Power',m,y)$(emissioncosts(r,t,'Power',m,y)>0);

resourcecosts(r,'Power',y)$(AnnualProduction(y,'Power',r) > 0)= sum((t,m),(levelizedcostsPJ(r,t,'Power',m,y) * AnnualTechnologyProductionByMode(r,t,m,'Power',y)/sum((tt,mm),AnnualTechnologyProductionByMode(r,tt,mm,'Power',y))));
testcosts(r,'Power3',y) = resourcecosts(r,'Power',y)*3.6;


****
**** Tier 5: Heat, Transport, Final Tier
****

fuelcosts(r,t,f,m,y)$(OutputActivityRatio(r,t,f,m,y) > 0) = sum(fff,InputActivityRatio(r,t,fff,m,y)*resourcecosts(r,fff,y))/OutputActivityRatio(r,t,f,m,y);
discountedfuelcosts(r,t,TierFive,m,y)$(OutputActivityRatio(r,t,TierFive,m,y) > 0 and maxgeneration(r,t,y,m,TierFive) > 0) = (sum(o$(o.val <= OperationalLife(t)),(((fuelcosts(r,t,TierFive,m,y))*maxgeneration(r,t,y,m,TierFive))/((1+GeneralDiscountRate(r))**o.val)))) / sum(o$(o.val <= OperationalLife(t)),(maxgeneration(r,t,y,m,TierFive)/((1+GeneralDiscountRate(r))**o.val)));
levelizedcostsPJ(r,t,TierFive,m,y)$(OutputActivityRatio(r,t,TierFive,m,y) > 0 and maxgeneration(r,t,y,m,TierFive) > 0) = capitalcosts(r,t,TierFive,m,y)+omcosts(r,t,TierFive,m,y)+discountedfuelcosts(r,t,TierFive,m,y)+emissioncosts(r,t,TierFive,m,y)$(emissioncosts(r,t,TierFive,m,y)>0);

resourcecosts(r,TierFive,y)$(AnnualProduction(y,TierFive,r) > 0)= sum((t,m),(levelizedcostsPJ(r,t,TierFive,m,y) * AnnualTechnologyProductionByMode(r,t,m,TierFive,y)/sum((tt,mm),AnnualTechnologyProductionByMode(r,tt,mm,TierFive,y))));
testcosts(r,TierFive,y) = resourcecosts(r,TierFive,y)*3.6;


****
**** Tier X: Calculate Costs per MWh instead of PJ and prepare Excel Output
****

levelizedcostskWh(r,t,f,m,y)$(levelizedcostsPJ(r,t,f,m,y) > 0) = levelizedcostsPJ(r,t,f,m,y)*3.6;

output_costs('Capex',r,t,f,m,y) = capitalcosts(r,t,f,m,y)*3.6;
output_costs('OandM',r,t,f,m,y) = omcosts(r,t,f,m,y)*3.6;
output_costs('Fuelcosts',r,t,f,m,y) = discountedfuelcosts(r,t,f,m,y)*3.6;
output_costs('Emissions',r,t,f,m,y) = emissioncosts(r,t,f,m,y)*3.6;
output_costs('TotalLevelized',r,t,f,m,y) = levelizedcostskWh(r,t,f,m,y);
output_costs('Capex',r,t,f,m,y)$(TagTechnologyToSubsets(t,'Transport')) = capitalcosts(r,t,f,m,y)/3.6;
output_costs('OandM',r,t,f,m,y)$(TagTechnologyToSubsets(t,'Transport')) = omcosts(r,t,f,m,y)/3.6;
output_costs('Fuelcosts',r,t,f,m,y)$(TagTechnologyToSubsets(t,'Transport')) = discountedfuelcosts(r,t,f,m,y)/3.6;
output_costs('Emissions',r,t,f,m,y)$(TagTechnologyToSubsets(t,'Transport')) = emissioncosts(r,t,f,m,y)/3.6;
output_costs('TotalLevelized',r,t,f,m,y)$(TagTechnologyToSubsets(t,'Transport')) = levelizedcostskWh(r,t,f,m,y)/3.6;
output_fuelcosts('Fuel Costs in MEUR/PJ',r,f,y)$(not sum(se$(not sameas(se,'Power')),TagDemandFuelToSector(f,se))) = resourcecosts(r,f,y);
output_fuelcosts('Fuel Costs in EUR/MWh',r,f,y)$(not sum(se$(not sameas(se,'Power')),TagDemandFuelToSector(f,se))) = resourcecosts(r,f,y)*3.6;
output_fuelcosts('Fuel Costs in MEUR/PJ','Total',f,y)$(sum(r,ProductionAnnual(y,f,r)) and not sum(se$(not sameas(se,'Power')),TagDemandFuelToSector(f,se))) = sum(r,resourcecosts(r,f,y)*ProductionAnnual(y,f,r))/sum(r,ProductionAnnual(y,f,r));
output_fuelcosts('Fuel Costs in MEUR/PJ','Total',f,y)$(not sum(r,ProductionAnnual(y,f,r)) and sum(r,resourcecosts(r,f,y)) and not sum(se$(not sameas(se,'Power')),TagDemandFuelToSector(f,se))) = sum(r,resourcecosts(r,f,y))/card(r);
output_fuelcosts('Fuel Costs in EUR/MWh','Total',f,y)$(not sum(se$(not sameas(se,'Power')),TagDemandFuelToSector(f,se))) = output_fuelcosts('Fuel Costs in MEUR/PJ','Total',f,y)*3.6;
output_emissionintensity(y,r,'Power',e)  = EmissionIntensity(y,r,'Power',e);


****
**** Excel Output Sheet Definition and Export of GDX
****

execute_unload 'costsoutput.gdx', maxgeneration, levelizedcostsPJ, levelizedcostskWh, FixedCost, capitalcost,testcosts,EmissionActivityRatio, variablecost, resourcecosts,SectorEmissions,EmissionIntensity,AnnualTechnologyProductionByMode, output_costs, output_fuelcosts, fuelcosts, discountedfuelcosts, OutputActivityRatio, AnnualProduction, AnnualTechnologyProduction, emissioncosts,testlevelizedcostsPJ,capitalcosts,omcosts, TierThree ;

* Write gdxxrw option file
$onecho >%tempdir%temp_costsoutput.tmp
se=0
text="Type"                              Rng=Costs!A1
text="Region"                            Rng=Costs!B1
text="Technology"                        Rng=Costs!C1
text="Fuel"                              Rng=Costs!D1
text="Mode of Operation"                 Rng=Costs!E1
text="Year"                              Rng=Costs!F1
text="Value"                             Rng=Costs!G1
        par=output_costs                  Rng=Costs!A2                            rdim=6        cdim=0

text="Type"                              Rng=ResourceCosts!A1
text="Region"                            Rng=ResourceCosts!B1
text="Fuel"                              Rng=ResourceCosts!C1
text="Year"                              Rng=ResourceCosts!D1
text="Value"                             Rng=ResourceCosts!E1
        par=output_fuelcosts                  Rng=ResourceCosts!A2                    rdim=4        cdim=0

text="Year"                              Rng=EmissionIntensity!A1
text="Region"                            Rng=EmissionIntensity!B1
text="Fuel"                              Rng=EmissionIntensity!C1
text="Emission"                          Rng=EmissionIntensity!D1
text="Value"                             Rng=EmissionIntensity!E1
        par=output_emissionintensity                  Rng=EmissionIntensity!A2                    rdim=4        cdim=0



$offecho

execute_unload "%gdxdir%costsoutput.gdx"
output_costs
output_fuelcosts
output_emissionintensity
;

$ifthen %WriteCostExcel% == 1
execute 'gdxxrw.exe i=%gdxdir%costsoutput.gdx UpdLinks=3 o=%resultdir%Costs_Output.xlsx @%tempdir%temp_costsoutput.tmp';
$endif
