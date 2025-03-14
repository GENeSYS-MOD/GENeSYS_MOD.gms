* ###################### genesysmod_employment.gms #######################
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



* ######### Reading of Output GDX ##########

$ifthen %switch_only_write_results% == 1
* ########## Declaration of Output Parameters ##########

parameter excel_production;
parameter excel_capacity;




$GDXin %gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%.gdx
*$load excel_production excel_capacity
$load output_capacity output_energy_balance
$endif



*##äää Additions for working paper Germany
*parameter output_capacity;
*parameter output_energy_balance;
*set emissionpath / %emissionPathway%_%emissionScenario% /;

$ifthen %switch_endogenous_employment% == 0

EFactorConstruction(t,y)$(EFactorConstruction(t,y) = 0) = (EFactorConstruction(t,y-1)+EFactorConstruction(t,y+1))/2;
EFactorOM(t,y)$(EFactorOM(t,y) = 0) = (EFactorOM(t,y-1)+EFactorOM(t,y+1))/2;
EFactorManufacturing(t,y)$(EFactorManufacturing(t,y) = 0) = (EFactorManufacturing(t,y-1)+EFactorManufacturing(t,y+1))/2;
EFactorFuelSupply(t,y)$(EFactorFuelSupply(t,y) = 0) = (EFactorFuelSupply(t,y-1)+EFactorFuelSupply(t,y+1))/2;
EFactorCoalJobs(t,y)$(EFactorCoalJobs(t,y) = 0) = (EFactorCoalJobs(t,y-1)+EFactorCoalJobs(t,y+1))/2;
CoalSupply(r,y)$(CoalSupply(r,y) = 0) = (CoalSupply(r,y-1)+CoalSupply(r,y+1))/2;
CoalDigging('%model_region%','Coal_Export','%emissionPathway%_%emissionScenario%',y)$(CoalDigging('%model_region%','Coal_Export','%emissionPathway%_%emissionScenario%',y) = 0) = (CoalDigging('%model_region%','Coal_Export','%emissionPathway%_%emissionScenario%',y-1)+CoalDigging('%model_region%','Coal_Export','%emissionPathway%_%emissionScenario%',y+1))/2;
RegionalAdjustmentFactor('%model_region%',y)$(RegionalAdjustmentFactor('%model_region%',y) = 0) = (RegionalAdjustmentFactor('%model_region%',y+1)+RegionalAdjustmentFactor('%model_region%',y+1))/2;
LocalManufacturingFactor('%model_region%',t,y)$(LocalManufacturingFactor('%model_region%',t,y) = 0) = (LocalManufacturingFactor('%model_region%',t,y-1)+LocalManufacturingFactor('%model_region%',t,y+1))/2;
DeclineRate(t,y)$(DeclineRate(t,y) = 0) = (DeclineRate(t,y-1)+DeclineRate(t,y+1))/2;

*######################### OLD #####################
*ManufacturingJobs(r,c,t,y,'%emissionPathway%_%emissionScenario%') = excel_capacity(r,c,t,y,'NewCapacity','%emissionPathway%_%emissionScenario%')*EFactorManufacturing(t,y)*RegionalAdjustmentFactor('%model_region%',y)*LocalManufacturingFactor('%model_region%',t,y)*(1-DeclineRate(t,y))**YearlyDifferenceMultiplier(y);
*ConstructionJobs(r,c,t,y,'%emissionPathway%_%emissionScenario%') = excel_capacity(r,c,t,y,'NewCapacity','%emissionPathway%_%emissionScenario%')*EFactorConstruction(t,y)*RegionalAdjustmentFactor('%model_region%',y)*(1-DeclineRate(t,y))**YearlyDifferenceMultiplier(y);
*OMJobs(r,c,t,y,'%emissionPathway%_%emissionScenario%') = excel_capacity(r,c,t,y,'TotalCapacity','%emissionPathway%_%emissionScenario%')*EFactorOM(t,y)*RegionalAdjustmentFactor('%model_region%',y)*(1-DeclineRate(t,y))**YearlyDifferenceMultiplier(y);
*SupplyJobs(r,c,t,y,'Production','%emissionPathway%_%emissionScenario%') = sum((f,m,l),excel_production(r,c,t,m,f,y,l,'Production','PJ','%emissionPathway%_%emissionScenario%'))*EFactorFuelSupply(t,y)*RegionalAdjustmentFactor('%model_region%',y)*(1-DeclineRate(t,y))**YearlyDifferenceMultiplier(y);

*output_energyjobs(r,t,'ManufacturingJobs','%emissionPathway%_%emissionScenario%',y) = sum((se),output_capacity(r,se,t,'NewCapacity','%emissionPathway%_%emissionScenario%',y)*EFactorManufacturing(t,y)*RegionalAdjustmentFactor('%model_region%',y)*LocalManufacturingFactor('%model_region%',y)*(1-DeclineRate(t,y))**YearlyDifferenceMultiplier(y));
*output_energyjobs(r,t,'ConstructionJobs','%emissionPathway%_%emissionScenario%',y) =  sum((se),output_capacity(r,se,t,'NewCapacity','%emissionPathway%_%emissionScenario%',y)*EFactorConstruction(t,y)*RegionalAdjustmentFactor('%model_region%',y)*(1-DeclineRate(t,y))**YearlyDifferenceMultiplier(y));
*output_energyjobs(r,t,'OMJobs','%emissionPathway%_%emissionScenario%',y) =  sum((se),output_capacity(r,se,t,'TotalCapacity','%emissionPathway%_%emissionScenario%',y)*EFactorOM(t,y)*RegionalAdjustmentFactor('%model_region%',y)*(1-DeclineRate(t,y))**YearlyDifferenceMultiplier(y));
*output_energyjobs(r,t,'SupplyJobs','%emissionPathway%_%emissionScenario%',y) = (sum((se),sum((f,m,l),output_energy_balance(r,se,t,m,f,l,'Use','PJ','%emissionPathway%_%emissionScenario%',y))*EFactorFuelSupply(t,y)*(1-DeclineRate(t,y))**YearlyDifferenceMultiplier(y)))*(-1);
*EnergyJobs(r,'P_Coal_Hardcoal','SupplyJobs','%emissionPathway%_%emissionScenario%',y) = sum((c),sum((f,m,l),excel_production(r,c,'P_Coal_Hardcoal',m,f,y,l,'Production','PJ','%emissionPathway%_%emissionScenario%')))*RegionalAdjustmentFactor('southafrica',y)*EFactorCoalJobs('P_Coal_Hardcoal',y);

*output_energyjobs(r,'Coal_Heat','SupplyJobs','%emissionPathway%_%emissionScenario%',y) = (sum(rr,sum((m,l,se),(output_energy_balance(rr,se,'HLI_Hardcoal',m,'Hardcoal',l,'Use','PJ','%emissionPathway%_%emissionScenario%',y)+output_energy_balance(rr,se,'HMI_HardCoal',m,'Hardcoal',l,'Use','PJ','%emissionPathway%_%emissionScenario%',y)+output_energy_balance(rr,se,'HHI_BF_BOF',m,'Hardcoal',l,'Use','PJ','%emissionPathway%_%emissionScenario%',y))))*EFactorCoalJobs('Coal_Heat',y)*CoalSupply(r,y))*(-1);
*output_energyjobs(r,'Coal_Export','SupplyJobs','%emissionPathway%_%emissionScenario%',y) = CoalSupply(r,y)*CoalDigging('%model_region%','Coal_Export','%emissionPathway%_%emissionScenario%',y)*EFactorCoalJobs('Coal_Export',y);
*######################### OLD #####################

ManufacturingJobs(r,t,y,'%emissionPathway%_%emissionScenario%') = NewCapacity.l(y,t,r)*EFactorManufacturing(t,y)*RegionalAdjustmentFactor('%model_region%',y)*LocalManufacturingFactor('%model_region%',t,y)*(1-DeclineRate(t,y))**YearlyDifferenceMultiplier(y);
ConstructionJobs(r,t,y,'%emissionPathway%_%emissionScenario%') = NewCapacity.l(y,t,r)*EFactorConstruction(t,y)*RegionalAdjustmentFactor('%model_region%',y)*(1-DeclineRate(t,y))**YearlyDifferenceMultiplier(y);
OMJobs(r,t,y,'%emissionPathway%_%emissionScenario%') = TotalCapacityAnnual.l(y,t,r)*EFactorOM(t,y)*RegionalAdjustmentFactor('%model_region%',y)*(1-DeclineRate(t,y))**YearlyDifferenceMultiplier(y);
* Supply of input fuels 
*###### Wieder auskommentieren - nur zum Testen --
*SupplyJobs(r,c,t,y,'Production','%emissionPathway%_%emissionScenario%') = sum((f,m,l),excel_production(r,c,t,m,f,y,l,'Production','PJ','%emissionPathway%_%emissionScenario%'))*EFactorFuelSupply(t,y)*RegionalAdjustmentFactor('%model_region%',y)*(1-DeclineRate(t,y))**YearlyDifferenceMultiplier(y);


output_energyjobs(r,t,'ManufacturingJobs','%emissionPathway%_%emissionScenario%',y) = sum((se),output_capacity(r,se,t,'NewCapacity','%emissionPathway%_%emissionScenario%',y)*EFactorManufacturing(t,y)*RegionalAdjustmentFactor('%model_region%',y)*LocalManufacturingFactor('%model_region%',y)*(1-DeclineRate(t,y))**YearlyDifferenceMultiplier(y));
output_energyjobs(r,t,'ConstructionJobs','%emissionPathway%_%emissionScenario%',y) =  sum((se),output_capacity(r,se,t,'NewCapacity','%emissionPathway%_%emissionScenario%',y)*EFactorConstruction(t,y)*RegionalAdjustmentFactor('%model_region%',y)*(1-DeclineRate(t,y))**YearlyDifferenceMultiplier(y));
output_energyjobs(r,t,'OMJobs','%emissionPathway%_%emissionScenario%',y) =  sum((se),output_capacity(r,se,t,'TotalCapacity','%emissionPathway%_%emissionScenario%',y)*EFactorOM(t,y)*RegionalAdjustmentFactor('%model_region%',y)*(1-DeclineRate(t,y))**YearlyDifferenceMultiplier(y));
output_energyjobs(r,t,'SupplyJobs','%emissionPathway%_%emissionScenario%',y) = (sum((se),sum((f,m,l),output_energy_balance(r,se,t,m,f,l,'Use','PJ','%emissionPathway%_%emissionScenario%',y))*EFactorFuelSupply(t,y)*(1-DeclineRate(t,y))**YearlyDifferenceMultiplier(y)))*(-1);

*###### Wieder auskommentieren - nur zum Testen --
*EnergyJobs(r,'P_Coal_Hardcoal','SupplyJobs','%emissionPathway%_%emissionScenario%',y) = sum((c),sum((f,m,l),excel_production(r,c,'P_Coal_Hardcoal',m,f,y,l,'Production','PJ','%emissionPathway%_%emissionScenario%')))*RegionalAdjustmentFactor('southafrica',y)*EFactorCoalJobs('P_Coal_Hardcoal',y);

output_energyjobs(r,'Coal_Heat','SupplyJobs','%emissionPathway%_%emissionScenario%',y) = (sum(rr,sum((m,l,se),(output_energy_balance(rr,se,'HLI_Hardcoal',m,'Hardcoal',l,'Use','PJ','%emissionPathway%_%emissionScenario%',y)+output_energy_balance(rr,se,'HMI_HardCoal',m,'Hardcoal',l,'Use','PJ','%emissionPathway%_%emissionScenario%',y)+output_energy_balance(rr,se,'HHI_BF_BOF',m,'Hardcoal',l,'Use','PJ','%emissionPathway%_%emissionScenario%',y))))*EFactorCoalJobs('Coal_Heat',y)*CoalSupply(r,y))*(-1);
output_energyjobs(r,'Coal_Export','SupplyJobs','%emissionPathway%_%emissionScenario%',y) = CoalSupply(r,y)*CoalDigging('%model_region%','Coal_Export','%emissionPathway%_%emissionScenario%',y)*EFactorCoalJobs('Coal_Export',y);


$ontext
Positive Variables
Jobs_Manufacturing
Jobs_Construction
Jobs_OM
Jobs_Supply
Jobs_Total
;


equation EJ1_ManufacturingJobs(REGION_FULL,TECHNOLOGY,YEAR_FULL);
EJ1_ManufacturingJobs(r,t,y).. Jobs_Manufacturing =e= NewCapacity(y,t,r)*EFactorManufacturing(t,y)*RegionalAdjustmentFactor('southafrica',y)*LocalManufacturingFactor('southafrica',y)*(1-DeclineRate(t,y))**YearlyDifferenceMultiplier(y));

equation EJ4_SupplyJobsJobs(REGION_FULL,TECHNOLOGY,YEAR_FULL);
EJ4_SupplyJobs(r,t,y).. Jobs_Supply =e= (UseByTechnology(l,t,f,r)*EFactorFuelSupply(t,y)*(1-DeclineRate(t,y))**YearlyDifferenceMultiplier(y)))*(-1)) +
CoalSupply(r,y)*CoalDigging('southafrica','Coal_Export','%emissionPathway%_%emissionScenario%',y)*EFactorCoalJobs('Coal_Export',y);


equation EJX_TotalJobs(r_full,y_full);
EJX_TotalJobs(r,y).. Jobs_Total(r,y) =e=  Jobs_Manufacturing + Jobs_Construction   + Jobs_OM + Jobs_Supply;
$offtext


execute_unload "%gdxdir%employment_%model_region%_%emissionPathway%_%emissionScenario%.gdx"
OMJobs
ConstructionJobs
ManufacturingJobs
SupplyJobs
output_energyjobs
;



* ##########Employment Output Excel Inhalt##########

$onecho >%tempdir%temp_%employment_data_file%.tmp
        +par=output_energyjobs                       Rng=EnergyJobs!A1     rdim=4        cdim=1
text="Region"                            Rng=EnergyJobs!A1
text="Technology"                        Rng=EnergyJobs!B1
text="JobType"                           Rng=EnergyJobs!C1
text="Scenario"                          Rng=EnergyJobs!D1

$offecho





$ifthen %switch_write_output_excel% == 1
execute 'gdxxrw.exe i=employment.gdx UpdLinks=3 o=%resultdir%Employment_Results_%model_region%_%emissionPathway%_%emissionScenario%.xlsx @%tempdir%temp_%employment_data_file%.tmp';
$endif


$endif
