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

$if not set dispatch_year                $setglobal dispatch_year 2050
$if not set dispatch_base_region         $setglobal dispatch_base_region DE
$if not set model_region                 $setglobal model_region europe
$if not set switch_unixPath              $setglobal switch_unixPath 0
$if not set switch_threads               $setglobal switch_threads 6
$if not set switch_test_data_load        $setglobal switch_test_data_load 0

$if not set emissionPathway              $setglobal emissionPathway TechnoFriendly
$if not set emissionScenario             $setglobal emissionScenario GlobalLimit

**** Can be set to either "endogenous" (using value from GENeSYS-MOD run), or to a free value
$if not set emissionsPenalty              $setglobal emissionsPenalty endogenous


**** Price/Quantity Curve Calculations
**** choose between transmission or h2, or set to zero
$if not set switch_priceQuantityCurves    $setglobal switch_priceQuantityCurves h2

**** Offset for domestic demand to generate price/quantity curves
**** CAUTION: use positive/negative sign before the actual value; e.g. +1 / -2
**** Demand Offset of 0 disables it entirely
$if not set priceQuantity_region          $setglobal priceQuantity_region AT
$if not set priceQuantity_quantity        $setglobal priceQuantity_quantity 2

**** Settings for transmission price quantity curves
**** Set type for analysis; imports or exports
$if not set priceQuantity_type            $setglobal priceQuantity_type export

**** Settings for h2 price quantity curves
$if not set priceQuantity_use_base_file   $setglobal priceQuantity_use_base_file 1

$ifthen %switch_unixPath% == 1
$if not set inputdir                     $setglobal inputdir Inputdata/
$if not set gdxdir                       $setglobal gdxdir GdxFiles/
$if not set dispatchdir                  $setglobal dispatchdir Dispatch/
$if not set resultdir                    $setglobal resultdir Results/
$else
$if not set inputdir                     $setglobal inputdir Inputdata\
$if not set gdxdir                       $setglobal gdxdir GdxFiles\
$if not set dispatchdir                  $setglobal dispatchdir Dispatch\
$if not set resultdir                    $setglobal resultdir Results\
$endif
scalar priceQuantityCurvesActive;
$ifi %switch_priceQuantityCurves%=="h2"  priceQuantityCurvesActive=1;
$ifi %switch_priceQuantityCurves%=="transmission"  priceQuantityCurvesActive=1;


$gdxin dispatch_input

$offorder

set TECHNOLOGY;
set SECTOR;
set MODE_OF_OPERATION;
set YEAR_FULL;
set YEAR(YEAR_FULL);
set TIMESLICE;
sets
REGION_FULL region /world/
HOUR hour /1*8760/
;

$loadm TECHNOLOGY
$loadm SECTOR
$loadm YEAR_FULL
$loadm YEAR
$loadm TIMESLICE

alias(TECHNOLOGY,t);
alias(SECTOR,se);
alias(YEAR,y,yy);


$loadm REGION_FULL
set STORAGE storage technology
/
S_PHS
S_Battery_Li-Ion
S_Battery_Redox
S_CAES
/;

set DISPATCHABLE_GENERATOR dispatchable PP
/
P_Biomass
P_Biomass_CCS
P_Coal_Hardcoal
P_Coal_Lignite
P_Gas_CCGT
P_Gas_Engines
P_Gas_OCGT
P_H2_OCGT
P_Nuclear
P_Oil
CHP_Biomass_Solid
CHP_Biomass_Solid_CCS
CHP_Coal_Hardcoal
CHP_Coal_Hardcoal_CCS
CHP_Coal_Lignite
CHP_Coal_Lignite_CCS
CHP_Gas_CCGT_Biogas
CHP_Gas_CCGT_Biogas_CCS
CHP_Gas_CCGT_Natural
CHP_Gas_CCGT_Natural_CCS
CHP_Gas_CCGT_SynGas
CHP_Hydrogen_FuelCell
CHP_Oil
RES_Hydro_Large
RES_Geothermal
RES_Ocean
/;

set VARIABLE_GENERATOR variable PP /
RES_Hydro_Small
RES_PV_Rooftop_Commercial
RES_PV_Rooftop_Residential
RES_PV_Utility_Avg
RES_PV_Utility_Inf
RES_PV_Utility_Opt
RES_PV_Utility_Opt_H2
Res_PV_Utility_Tracking
RES_Wind_Offshore_Deep
RES_Wind_Offshore_Shallow
RES_Wind_Offshore_Shallow_H2
RES_Wind_Offshore_Transitional
RES_Wind_Onshore_Avg
RES_Wind_Onshore_Inf
RES_Wind_Onshore_Opt
RES_Wind_Onshore_Opt_H2
/;



alias(REGION_FULL,r_full,rr_full);
alias(HOUR,h,hh);
alias(STORAGE,sto);
alias(DISPATCHABLE_GENERATOR,d);
alias(VARIABLE_GENERATOR,v);

set REGION(r_full);
alias(REGION,r,rr);
r(r_full) = yes;

scalar co2_price /76/;
$ifthen %emissionsPenalty% == "endogenous"
parameter EmissionsPenalty;
$loadm EmissionsPenalty
co2_price = EmissionsPenalty('%dispatch_base_region%','CO2','%dispatch_year%');
$else
co2_price = %emissionsPenalty%;
$endif


parameter dispatchable_capacity(r_full,d) installed capacity of power plant p;
parameter variable_capacity(r_full,v) installed capacity of variable power generator i;
parameter availability_factor(r_full,d) yearly availability factor of power plant p;
parameter capacity_factor(r_full,v,h) capacity factor of var gen i in hour t;
parameter variable_costs(r_full,d) variable costs;
parameter ramping_factor(d) ramping factor;
parameter co2_activity_ratio(d) co2 acitivity ratio;

parameter transmission_capacity(r_full,rr_full) trade capacity from regions r to rr;

parameter storage_capacity_e(r_full,sto) installed storage energy capacity;
parameter storage_capacity_p(r_full,sto) installed storage power capacity;
parameter storage_efficiency(sto) storage roundtrip efficiency;
parameter storage_startlevel(r_full,sto) start-level of stored energy;

parameter demand(r_full,h) demand in hour t;

parameter dispatchable_capacity_minactivity(d) minimum activity (share of capacity) of dispatchable generator;

variable TotalCapacityAnnual, TotalTradeCapacity, UseByTechnologyAnnual, NewStorageCapacity, StorageLevelTSStart ;
$load TotalCapacityAnnual, TotalTradeCapacity, UseByTechnologyAnnual, NewStorageCapacity, StorageLevelTSStart

parameter resourcecosts, AvailabilityFactor, CountryData, EmissionActivityRatio, EmissionContentPerFuel, TagTechnologyToSector, InputActivityRatio, SpecifiedAnnualDemand, OutputActivityRatio, OperationalLifeStorage, Yearval;
$load resourcecosts, AvailabilityFactor, CountryData, EmissionActivityRatio, EmissionContentPerFuel, TagTechnologyToSector, InputActivityRatio, SpecifiedAnnualDemand, OutputActivityRatio, OperationalLifeStorage, Yearval

ramping_factor('P_Biomass') = 0.04;
ramping_factor('P_Biomass_CCS') = 0.04;
ramping_factor('P_Coal_Hardcoal') = 0.04;
ramping_factor('P_Coal_Lignite') = 0.03;
ramping_factor('P_Gas_CCGT') = 0.06;
ramping_factor('P_Gas_Engines') = 0.06;
ramping_factor('P_Gas_OCGT') = 0.2;
ramping_factor('P_H2_OCGT') = 0.2;
ramping_factor('P_Nuclear') = 0.01;
ramping_factor('P_Oil') = 0.2;
ramping_factor('CHP_Biomass_Solid') = 0.04;
ramping_factor('CHP_Biomass_Solid_CCS') = 0.04;
ramping_factor('CHP_Coal_Hardcoal') = 0.04;
ramping_factor('CHP_Coal_Hardcoal_CCS') = 0.04;
ramping_factor('CHP_Coal_Lignite') = 0.03;
ramping_factor('CHP_Coal_Lignite_CCS') = 0.03;
ramping_factor('CHP_Gas_CCGT_Biogas') = 0.06;
ramping_factor('CHP_Gas_CCGT_Biogas_CCS') = 0.06;
ramping_factor('CHP_Gas_CCGT_Natural') = 0.06;
ramping_factor('CHP_Gas_CCGT_Natural_CCS') = 0.06;
ramping_factor('CHP_Gas_CCGT_SynGas') = 0.06;
ramping_factor('CHP_Hydrogen_FuelCell') = 0.5;
ramping_factor('CHP_Oil') = 0.2;
ramping_factor('RES_Hydro_Large') = 0.25;

variable_costs(r,'P_Biomass') = resourcecosts(r,'biomass','%dispatch_year%')*InputActivityRatio(r,'P_Biomass','biomass','1','%dispatch_year%');
variable_costs(r,'P_Biomass_CCS') = resourcecosts(r,'biomass','%dispatch_year%')*InputActivityRatio(r,'P_Biomass_CCS','biomass','1','%dispatch_year%');
variable_costs(r,'P_Coal_Hardcoal') = resourcecosts(r,'hardcoal','%dispatch_year%')*InputActivityRatio(r,'P_Coal_Hardcoal','hardcoal','1','%dispatch_year%');
variable_costs(r,'P_Coal_Lignite') = resourcecosts(r,'lignite','%dispatch_year%')*InputActivityRatio(r,'P_Coal_Lignite','lignite','1','%dispatch_year%');
variable_costs(r,'P_Gas_CCGT') = resourcecosts(r,'Gas_Natural','%dispatch_year%')*InputActivityRatio(r,'P_Gas_CCGT','Gas_Natural','1','%dispatch_year%');
variable_costs(r,'P_Gas_Engines') = resourcecosts(r,'Gas_Natural','%dispatch_year%')*InputActivityRatio(r,'P_Gas_Engines','Gas_Natural','1','%dispatch_year%');
variable_costs(r,'P_Gas_OCGT') = resourcecosts(r,'Gas_Natural','%dispatch_year%')*InputActivityRatio(r,'P_Gas_OCGT','Gas_Natural','1','%dispatch_year%');
variable_costs(r,'P_H2_OCGT') = resourcecosts(r,'H2','%dispatch_year%')*InputActivityRatio(r,'P_H2_OCGT','H2','1','%dispatch_year%');
variable_costs(r,'P_Nuclear') = resourcecosts(r,'Nuclear','%dispatch_year%')*InputActivityRatio(r,'P_Nuclear','Nuclear','1','%dispatch_year%');
variable_costs(r,'P_Oil') = resourcecosts(r,'oil','%dispatch_year%')*InputActivityRatio(r,'P_Oil','oil','1','%dispatch_year%');
variable_costs(r,'CHP_Biomass_Solid') = resourcecosts(r,'biomass','%dispatch_year%')*InputActivityRatio(r,'CHP_Biomass_Solid','biomass','1','%dispatch_year%');
variable_costs(r,'CHP_Biomass_Solid_CCS') = resourcecosts(r,'biomass','%dispatch_year%')*InputActivityRatio(r,'CHP_Biomass_Solid_CCS','biomass','1','%dispatch_year%');
variable_costs(r,'CHP_Coal_Hardcoal') = resourcecosts(r,'hardcoal','%dispatch_year%')*InputActivityRatio(r,'CHP_Coal_Hardcoal','hardcoal','1','%dispatch_year%');
variable_costs(r,'CHP_Coal_Hardcoal_CCS') = resourcecosts(r,'hardcoal','%dispatch_year%')*InputActivityRatio(r,'CHP_Coal_Hardcoal_CCS','hardcoal','1','%dispatch_year%');
variable_costs(r,'CHP_Coal_Lignite') = resourcecosts(r,'lignite','%dispatch_year%')*InputActivityRatio(r,'CHP_Coal_Lignite','lignite','1','%dispatch_year%');
variable_costs(r,'CHP_Coal_Lignite_CCS') = resourcecosts(r,'lignite','%dispatch_year%')*InputActivityRatio(r,'CHP_Coal_Lignite_CCS','lignite','1','%dispatch_year%');
variable_costs(r,'CHP_Gas_CCGT_Biogas') = resourcecosts(r,'Gas_Bio','%dispatch_year%')*InputActivityRatio(r,'CHP_Gas_CCGT_Biogas','Gas_Bio','1','%dispatch_year%');
variable_costs(r,'CHP_Gas_CCGT_Biogas_CCS') = resourcecosts(r,'Gas_Bio','%dispatch_year%')*InputActivityRatio(r,'CHP_Gas_CCGT_Biogas_CCS','Gas_Bio','1','%dispatch_year%');
variable_costs(r,'CHP_Gas_CCGT_Natural') = resourcecosts(r,'Gas_Natural','%dispatch_year%')*InputActivityRatio(r,'CHP_Gas_CCGT_Natural','Gas_Natural','1','%dispatch_year%');
variable_costs(r,'CHP_Gas_CCGT_Natural_CCS') = resourcecosts(r,'Gas_Natural','%dispatch_year%')*InputActivityRatio(r,'CHP_Gas_CCGT_Natural_CCS','Gas_Natural','1','%dispatch_year%');
variable_costs(r,'CHP_Gas_CCGT_SynGas') = resourcecosts(r,'Gas_Synth','%dispatch_year%')*InputActivityRatio(r,'CHP_Gas_CCGT_SynGas','Gas_Synth','1','%dispatch_year%');
variable_costs(r,'CHP_Hydrogen_FuelCell') = resourcecosts(r,'H2','%dispatch_year%')*InputActivityRatio(r,'CHP_Hydrogen_FuelCell','H2','1','%dispatch_year%');
variable_costs(r,'CHP_Oil') = resourcecosts(r,'oil','%dispatch_year%')*InputActivityRatio(r,'CHP_Oil','oil','1','%dispatch_year%');

*                     to 1000eur/GWh
variable_costs(r,d) = variable_costs(r,d)*3.6;

dispatchable_capacity(r,d) = sum(t$(sameas(d,t)),TotalCapacityAnnual.l(r,t,'%dispatch_year%'));
variable_capacity(r,v) = sum(t$(sameas(v,t)),TotalCapacityAnnual.l(r,t,'%dispatch_year%'));

availability_factor(r,d) = sum(t$(sameas(d,t)),AvailabilityFactor(r,t,'%dispatch_year%'));

co2_activity_ratio('P_Coal_Hardcoal') = EmissionContentPerFuel('hardcoal','CO2')*InputActivityRatio('%dispatch_base_region%','P_Coal_Hardcoal','hardcoal','1','%dispatch_year%');
co2_activity_ratio('P_Coal_Lignite') = EmissionContentPerFuel('lignite','CO2')*InputActivityRatio('%dispatch_base_region%','P_Coal_Lignite','lignite','1','%dispatch_year%');
co2_activity_ratio('P_Gas_CCGT') = EmissionContentPerFuel('Gas_Natural','CO2')*InputActivityRatio('%dispatch_base_region%','P_Gas_CCGT','Gas_Natural','1','%dispatch_year%');
co2_activity_ratio('P_Gas_Engines') = EmissionContentPerFuel('Gas_Natural','CO2')*InputActivityRatio('%dispatch_base_region%','P_Gas_Engines','Gas_Natural','1','%dispatch_year%');
co2_activity_ratio('P_Gas_OCGT') = EmissionContentPerFuel('Gas_Natural','CO2')*InputActivityRatio('%dispatch_base_region%','P_Gas_OCGT','Gas_Natural','1','%dispatch_year%');
co2_activity_ratio('P_Oil') = EmissionContentPerFuel('oil','CO2')*InputActivityRatio('%dispatch_base_region%','P_Oil','oil','1','%dispatch_year%');
co2_activity_ratio('CHP_Coal_Hardcoal') = EmissionContentPerFuel('hardcoal','CO2')*InputActivityRatio('%dispatch_base_region%','CHP_Coal_Hardcoal','hardcoal','1','%dispatch_year%');
co2_activity_ratio('CHP_Coal_Hardcoal_CCS') = EmissionContentPerFuel('hardcoal','CO2')*InputActivityRatio('%dispatch_base_region%','CHP_Coal_Hardcoal_CCS','hardcoal','1','%dispatch_year%');
co2_activity_ratio('CHP_Coal_Lignite') = EmissionContentPerFuel('lignite','CO2')*InputActivityRatio('%dispatch_base_region%','CHP_Coal_Lignite','lignite','1','%dispatch_year%');
co2_activity_ratio('CHP_Coal_Lignite_CCS') = EmissionContentPerFuel('lignite','CO2')*InputActivityRatio('%dispatch_base_region%','CHP_Coal_Lignite_CCS','lignite','1','%dispatch_year%');
co2_activity_ratio('CHP_Gas_CCGT_Natural') = EmissionContentPerFuel('Gas_Natural','CO2')*InputActivityRatio('%dispatch_base_region%','CHP_Gas_CCGT_Natural','Gas_Natural','1','%dispatch_year%');
co2_activity_ratio('CHP_Gas_CCGT_Natural_CCS') = EmissionContentPerFuel('Gas_Natural','CO2')*InputActivityRatio('%dispatch_base_region%','CHP_Gas_CCGT_Natural_CCS','Gas_Natural','1','%dispatch_year%');
co2_activity_ratio('CHP_Oil') = EmissionContentPerFuel('oil','CO2')*InputActivityRatio('%dispatch_base_region%','CHP_Oil','oil','1','%dispatch_year%');
co2_activity_ratio(d) = co2_activity_ratio(d)*sum(t$(sameas(d,t)),EmissionActivityRatio('%dispatch_base_region%',t,'1','CO2','%dispatch_year%'));

capacity_factor(r,'RES_Hydro_Small',h) = CountryData(r, h, 'hydro_ror');
capacity_factor(r,'RES_PV_Rooftop_Commercial',h) = CountryData(r, h, 'pv_avg');
capacity_factor(r,'RES_PV_Rooftop_Residential',h) = CountryData(r, h, 'pv_avg');
capacity_factor(r,'RES_PV_Utility_Avg',h) = CountryData(r, h, 'pv_avg');
capacity_factor(r,'RES_PV_Utility_Inf',h) = CountryData(r, h, 'pv_inf');
capacity_factor(r,'RES_PV_Utility_Opt',h) = CountryData(r, h, 'pv_opt');
*capacity_factor(r,'RES_PV_Utility_Opt_H2',h) = CountryData(r, h, 'pv');
capacity_factor(r,'Res_PV_Utility_Tracking',h) = CountryData(r, h, 'pv_tracking');
capacity_factor(r,'RES_Wind_Offshore_Deep',h) = CountryData(r, h, 'wind_offshore_deep');
capacity_factor(r,'RES_Wind_Offshore_Shallow',h) = CountryData(r, h, 'wind_offshore_shallow');
*capacity_factor(r,'RES_Wind_Offshore_Shallow_H2',h) = CountryData(r, h, 'wind_offshore_2040');
capacity_factor(r,'RES_Wind_Offshore_Transitional',h) = CountryData(r, h, 'wind_offshore');
capacity_factor(r,'RES_Wind_Onshore_Avg',h) = CountryData(r, h, 'wind_onshore_avg');
capacity_factor(r,'RES_Wind_Onshore_Inf',h) = CountryData(r, h, 'wind_onshore_inf');
capacity_factor(r,'RES_Wind_Onshore_Opt',h) = CountryData(r, h, 'wind_onshore_opt');
*capacity_factor(r,'RES_Wind_Onshore_Opt_H2',h) = CountryData(r, h, 'pv');

capacity_factor(r,v,h) = capacity_factor(r,v,h)*sum(t$(sameas(v,t)),AvailabilityFactor(r,t,'%dispatch_year%'));

transmission_capacity(r,rr) = TotalTradeCapacity.l('%dispatch_year%', 'power', r, rr);

dispatchable_capacity_minactivity('RES_Hydro_Large') = 0.15;

storage_startlevel(r,sto) = sum(TIMESLICE$(ord(TIMESLICE)=1),StorageLevelTSStart.l(sto,'%dispatch_year%',TIMESLICE,r))/3.6*1000/10;

parameter sector_load_curve_raw(r_full,h,se);
  sector_load_curve_raw(r,h,'Power') = CountryData(r, h,'load');
  sector_load_curve_raw(r,h,'Transformation') = CountryData(r, h,'load');
  sector_load_curve_raw(r,h,'Industry') = CountryData(r, h,'heat_high');
  sector_load_curve_raw(r,h,'Buildings') = CountryData(r, h,'heat_low');
  sector_load_curve_raw(r,h,'Transportation') = CountryData(r, h,'mobility_psng');

parameter sector_load_curve_sum(r_full,se);
  sector_load_curve_sum(r,'Power') = sum(h,CountryData(r, h,'load'));
  sector_load_curve_sum(r,'Transformation') = sum(h,CountryData(r, h,'load'));
  sector_load_curve_sum(r,'Industry') = sum(h,CountryData(r, h,'heat_high'));
  sector_load_curve_sum(r,'Buildings') = sum(h,CountryData(r, h,'heat_low'));
  sector_load_curve_sum(r,'Transportation') = sum(h,CountryData(r, h,'mobility_psng'));

parameter sector_demand(r_full,se);
sector_demand(r,se) = sum((t)$TagTechnologyToSector(t,se), UseByTechnologyAnnual.l(r,t,'power','%dispatch_year%'))/3.6*1000;
sector_demand(r,'Power') = SpecifiedAnnualDemand(r,'power','%dispatch_year%')/3.6*1000;

parameter sector_load_curve;
sector_load_curve(r,h,se)$(sector_load_curve_sum(r,se)) = sector_demand(r,se)*sector_load_curve_raw(r,h,se)/sector_load_curve_sum(r,se);

$ifthen %switch_priceQuantityCurves% == "h2"
region('world') = no;
*** Version, dass die Mengen l�nder�bergreifend gemeinsam gesetzt werden
demand(r,h) = sum(se$(not sameas(se,'Transformation')),sector_load_curve(r,h,se))+%priceQuantity_quantity%;
*** Version, dass die Mengen je Land iteriert werden
*demand(r,h) = sum(se,sector_load_curve(r,h,se));
*demand('%priceQuantity_region%',h) = sum(se$(not sameas(se,'Transformation')),sector_load_curve('%priceQuantity_region%',h,se))+%priceQuantity_quantity%;
$else
demand(r,h) = sum(se,sector_load_curve(r,h,se));
$endif




storage_efficiency('S_PHS') = OutputActivityRatio('%dispatch_base_region%','D_PHS_Residual', 'Power', '2', '%dispatch_year%');
storage_efficiency('S_Battery_Li-Ion') = OutputActivityRatio('%dispatch_base_region%','D_Battery_Li-Ion', 'Power', '2', '%dispatch_year%');
storage_efficiency('S_Battery_Redox') = OutputActivityRatio('%dispatch_base_region%','D_Battery_Redox', 'Power', '2', '%dispatch_year%');
storage_efficiency('S_CAES') = OutputActivityRatio('%dispatch_base_region%','D_CAES', 'Power', '2', '%dispatch_year%');

storage_capacity_p(r,'S_PHS') = TotalCapacityAnnual.l(r, 'D_PHS', '%dispatch_year%') + TotalCapacityAnnual.l(r, 'D_PHS_Residual', '%dispatch_year%');
storage_capacity_p(r,'S_Battery_Li-Ion') = TotalCapacityAnnual.l(r, 'D_Battery_Li-Ion', '%dispatch_year%');
storage_capacity_p(r,'S_Battery_Redox') = TotalCapacityAnnual.l(r, 'D_Battery_Redox', '%dispatch_year%');
storage_capacity_p(r,'S_CAES') = TotalCapacityAnnual.l(r, 'D_CAES', '%dispatch_year%');

storage_capacity_e(r,'S_PHS') = storage_capacity_p(r,'S_PHS')*8*8760;
storage_capacity_e(r,'S_Battery_Li-Ion') = storage_capacity_p(r,'S_Battery_Li-Ion')*1*8760;
storage_capacity_e(r,'S_Battery_Redox') = storage_capacity_p(r,'S_Battery_Redox')*4*8760;
storage_capacity_e(r,'S_CAES') = storage_capacity_p(r,'S_CAES')*10*8760;

storage_capacity_e(r,sto)$(storage_startlevel(r,sto)>storage_capacity_e(r,sto)) = storage_startlevel(r,sto);

*storage_capacity_e(r,sto) = sum(yy$(yearval('%dispatch_year%')-yearval(yy) < OperationalLifeStorage(sto) and yearval('%dispatch_year%')-yearval(yy) >= 0), NewStorageCapacity.l(sto,'%dispatch_year%',r))/31.536;


positive variables
DispatchableGeneration(r_full,d,h) disp generation in hour t
DispatchableGeneration_up(r_full,d,h) disp generation upwards in hour t
DispatchableGeneration_down(r_full,d,h) disp generation downwards in hour t

VariableGeneration(r_full,v,h) var generation in hour t
Storage_In(r_full,sto,h) storage charge in hour t
Storage_Out(r_full,sto,h) storage discharge in hour t
Storage_SOC(r_full,sto,h) storage state of charge in hour t
Curtailment(r_full,h) lost load in hour t

PowerFlow_positive(r_full,rr_full,h) positive trade flow from regions r to rr
PowerFlow_negative(r_full,rr_full,h) negative trade flow from regions r to rr

InfeasibleGeneration(r_full,h) infeasibilty generation
InfeasibleGeneration_neg(r_full,h) infeasibilty generation (negative);
;

parameter StorageLosses(sto);
StorageLosses('S_PHS') = 0;
StorageLosses('S_CAES') = 0;
StorageLosses('S_Battery_Li-Ion') = 0.00417;
StorageLosses('S_Battery_Redox') = 0;

variables
PowerFlow(r_full,rr_full,h) net trade flow from regions r to rr
z objective value;

scalar infeasibility_penalty /9999/;

r(r_full) = yes;
*r('DE') = yes;
r('World') = no;

*r('DE') = yes;
*r('AT') = yes;
*r('IT') = yes;
*r('FR') = yes;
*r('PL') = yes;
*r('UK') = yes;
*r('NL') = yes;
*r('DK') = yes;
*r('SE') = yes;
*r('NO') = yes;
*r('CH') = yes;
*r('CZ') = yes;

parameter readin_transmission_capacity;
readin_transmission_capacity(r,rr) = 0;

transmission_capacity(r,rr)$(transmission_capacity(r,rr)<readin_transmission_capacity(r,rr)) = readin_transmission_capacity(r,rr);

$ifthen.h2 %switch_priceQuantityCurves% == "h2"
$ifthen.basefile %priceQuantity_use_base_file% == 1

$Ifthen exist 01_Baseline_%dispatch_year%.gdx $setglobal base_file_available 1
$gdxin 01_Baseline_%dispatch_year%.gdx
$onundf
$loadm PowerFlow
PowerFlow.fx(r,rr,h) = round(PowerFlow.l(r,rr,h),5);
transmission_capacity(r,rr) = transmission_capacity(r,rr)+0.001;
display "base file found, reading powerflows from base file...";
$else display "base file was not found, recomputing power flows...";
$setglobal base_file_available 2
$endif
$else.basefile
$setglobal base_file_available 2
display "base file will not be used, pre-computing power flows instead";
$endif.basefile
$endif.h2


$ifthen %switch_test_data_load% == 0



equation NE0_Obj;
NE0_Obj..
  sum((r,d,h),DispatchableGeneration(r,d,h)*variable_costs(r,d))
+ sum((r,d,h),DispatchableGeneration(r,d,h)*co2_activity_ratio(d)*co2_price)
+ sum((r,sto,h),Storage_Out(r,sto,h))*eps
+ sum((r,h),Curtailment(r,h))*eps
+ sum((r,rr,h),PowerFlow_positive(r,rr,h) + PowerFlow_negative(r,rr,h))*eps
+ infeasibility_penalty*sum((r,h),InfeasibleGeneration(r,h)+InfeasibleGeneration_neg(r,h))
  =e= z;

equation NE2a_DispGeneration1(r_full,d,h);
NE2a_DispGeneration1(r,d,h)$(dispatchable_capacity(r,d) <> 0 and availability_factor(r,d) <> 0)..
  DispatchableGeneration(r,d,h) =l= dispatchable_capacity(r,d)*availability_factor(r,d);
DispatchableGeneration.fx(r,d,h)$(dispatchable_capacity(r,d) = 0 or availability_factor(r,d) = 0) = 0;

equation NE2b_DispGenerationMinActivity(r_full,d,h);
NE2b_DispGenerationMinActivity(r,d,h)$(dispatchable_capacity_minactivity(d))..
  DispatchableGeneration(r,d,h) =g= dispatchable_capacity_minactivity(d)*dispatchable_capacity(r,d)*availability_factor(r,d);

equation NE2c_VarGeneration(r_full,v,h);
NE2c_VarGeneration(r,v,h)$(variable_capacity(r,v) <> 0 and capacity_factor(r,v,h) <> 0)..
  VariableGeneration(r,v,h) =e= variable_capacity(r,v)*capacity_factor(r,v,h);
VariableGeneration.fx(r,v,h)$(variable_capacity(r,v) = 0 or capacity_factor(r,v,h) = 0) = 0;

equation NE3_StorageSOC(r_full,sto,h);
NE3_StorageSOC(r,sto,h)$(storage_capacity_p(r,sto) and storage_capacity_e(r,sto))..
  Storage_StartLevel(r,sto)$(ord(h)=1) +
  Storage_SOC(r,sto,h-1)*(1-StorageLosses(sto))
+ Storage_In(r,sto,h)*(1+storage_efficiency(sto))/2
- Storage_Out(r,sto,h)/(1+storage_efficiency(sto))*2
=e=
  Storage_SOC(r,sto,h);

equation NE4a_StorageST_IN_p(r_full,sto,h);
NE4a_StorageST_IN_p(r,sto,h)$(storage_capacity_p(r,sto) and storage_capacity_e(r,sto))..
  Storage_In(r,sto,h) =l= storage_capacity_p(r,sto);

equation NE4b_StorageST_OUT_p(r_full,sto,h);
NE4b_StorageST_OUT_p(r,sto,h)$(storage_capacity_p(r,sto) and storage_capacity_e(r,sto))..
  Storage_Out(r,sto,h) =l= storage_capacity_p(r,sto);

equation NE5a_StorageST_OUT_soc(r_full,sto,h);
NE5a_StorageST_OUT_soc(r,sto,h)$(storage_capacity_p(r,sto) and storage_capacity_e(r,sto))..
  Storage_Out(r,sto,h) =l= Storage_SOC(r,sto,h-1);

equation NE5a_StorageST_IN_soc(r_full,sto,h);
NE5a_StorageST_IN_soc(r,sto,h)$(storage_capacity_p(r,sto) and storage_capacity_e(r,sto))..
  Storage_In(r,sto,h) =l= storage_capacity_e(r,sto) - Storage_SOC(r,sto,h-1);

Storage_SOC.fx(r,sto,h)$(storage_capacity_p(r,sto) = 0 or storage_capacity_e(r,sto) = 0) = 0;
Storage_In.fx(r,sto,h)$(storage_capacity_p(r,sto) = 0 or storage_capacity_e(r,sto) = 0) = 0;
Storage_Out.fx(r,sto,h)$(storage_capacity_p(r,sto) = 0 or storage_capacity_e(r,sto) = 0) = 0;

equation NR1_ProductionChange(r_full,d,h);
NR1_ProductionChange(r,d,h)$(ramping_factor(d) <> 0 and ord(h) > 1)..
  DispatchableGeneration(r,d,h)
- DispatchableGeneration(r,d,h-1)
=e=
  DispatchableGeneration_up(r,d,h)
- DispatchableGeneration_down(r,d,h);

DispatchableGeneration_up.fx(r,d,h)$(ramping_factor(d) = 0 or ord(h) = 1) = 0;
DispatchableGeneration_down.fx(r,d,h)$(ramping_factor(d) = 0 or ord(h) = 1) = 0;

equation NR2_RampingUpLimit(r_full,d,h);
NR2_RampingUpLimit(r,d,h)$(ramping_factor(d) <> 0 and ord(h) > 1)..
  DispatchableGeneration_up(r,d,h) =l= dispatchable_capacity(r,d)*ramping_factor(d);

equation NR3_RampingDownLimit(r_full,d,h);
NR3_RampingDownLimit(r,d,h)$(ramping_factor(d) <> 0 and ord(h) > 1)..
  DispatchableGeneration_down(r,d,h) =l= dispatchable_capacity(r,d)*ramping_factor(d);

equation NF1_ReverseFlow(r_full,rr_full,h);
NF1_ReverseFlow(r,rr,h)$(transmission_capacity(r,rr))..
  PowerFlow(r,rr,h) =e= -PowerFlow(rr,r,h);

equation NF2a_NtcPos(r_full,rr_full,h);
NF2a_NtcPos(r,rr,h)$(transmission_capacity(r,rr))..
  PowerFlow(r,rr,h) =l= transmission_capacity(r,rr);

equation NF2b_NtcNeg(r_full,rr_full,h);
NF2b_NtcNeg(r,rr,h)$(transmission_capacity(r,rr))..
  PowerFlow(r,rr,h) =g= -transmission_capacity(r,rr);

equation NF3_AbsoluteFlowHelper(r_full,rr_full,h);
NF3_AbsoluteFlowHelper(r,rr,h)$(transmission_capacity(r,rr))..
  PowerFlow(r,rr,h) =e= PowerFlow_positive(r,rr,h) - PowerFlow_negative(r,rr,h);

PowerFlow.fx(r,rr,h)$(transmission_capacity(r,rr) = 0) = 0;
PowerFlow_positive.fx(r,rr,h)$(transmission_capacity(r,rr) = 0) = 0;
PowerFlow_negative.fx(r,rr,h)$(transmission_capacity(r,rr) = 0) = 0;

*** Offset demand for one specific region if needed
$ifthen %switch_priceQuantityCurves% == "transmission"
parameter tag_import;
tag_import =
$ifi %priceQuantity_type% == "import" 1 +
$ifi %priceQuantity_type% == "export" -1 +
0;

demand('%priceQuantity_region%',h) = 0;


equation Add_PriceQuantityConstraint(h);
Add_PriceQuantityConstraint(h)..  sum(rr,PowerFlow(rr,'%priceQuantity_region%',h))+InfeasibleGeneration('%priceQuantity_region%',h)-InfeasibleGeneration_neg('%priceQuantity_region%',h) =e=  %priceQuantity_quantity%*tag_import;

$endif


equation NEB1_EnergyBalance(r_full,h);
NEB1_EnergyBalance(r,h)$(demand(r,h))..
  sum((d),DispatchableGeneration(r,d,h))
+ sum((v),VariableGeneration(r,v,h))
+ InfeasibleGeneration(r,h)
+ sum((sto),Storage_Out(r,sto,h))
- sum((sto),Storage_In(r,sto,h))
+ sum((rr),PowerFlow(rr,r,h))
=e=
  demand(r,h)
+ Curtailment(r,h);



option
lp = gurobi
limrow = 0
limcol = 0
solprint = off
sysout = off
profile=2
;

$onecho > gurobi.opt
method 2
*names no
barhomogeneous 1
timelimit 1000000
threads %switch_threads%
$offecho

$ifthen %base_file_available% == 2
demand(r,h) = sum(se,sector_load_curve(r,h,se));
display "Using baseline demands for all regions for first iteration"
$endif



model dispatch /
NE0_Obj
NE2a_DispGeneration1
NE2b_DispGenerationMinActivity
NE2c_VarGeneration
NE3_StorageSOC
NE4a_StorageST_IN_p
NE4b_StorageST_OUT_p
NE5a_StorageST_OUT_soc
NE5a_StorageST_IN_soc
NR1_ProductionChange
NR2_RampingUpLimit
NR3_RampingDownLimit
NF1_ReverseFlow
NF2a_NtcPos
NF2b_NtcNeg
NF3_AbsoluteFlowHelper
NEB1_EnergyBalance
$ifi %switch_priceQuantityCurves% == "transmission" Add_PriceQuantityConstraint
/;

dispatch.holdfixed = 1;
dispatch.optfile = 1;

solve dispatch using LP min z;

$ifthen %base_file_available% == 2
display "writing new base file to use for next time";
execute_unload "01_Baseline_%dispatch_year%.gdx"
demand
sector_load_curve
PowerFlow;

model dispatch2 /
NE0_Obj
NE2a_DispGeneration1
NE2b_DispGenerationMinActivity
NE2c_VarGeneration
NE3_StorageSOC
NE4a_StorageST_IN_p
NE4b_StorageST_OUT_p
NE5a_StorageST_OUT_soc
NE5a_StorageST_IN_soc
NR1_ProductionChange
NR2_RampingUpLimit
NR3_RampingDownLimit
NF1_ReverseFlow
NF2a_NtcPos
NF2b_NtcNeg
NF3_AbsoluteFlowHelper
NEB1_EnergyBalance
$ifi %switch_priceQuantityCurves% == "transmission" Add_PriceQuantityConstraint
/;

PowerFlow.fx(r_full,rr_full,h) = PowerFlow.l(r_full,rr_full,h);
demand(r,h) = sum(se$(not sameas(se,'Transformation')),sector_load_curve(r,h,se))+%priceQuantity_quantity%;

display "computing second stage with fixed power flows"
*dispatch2.holdfixed = 1;
*dispatch2.optfile = 1;
solve dispatch2 using LP min z;

$endif

parameter output;

output('prod',r,v,h) = VariableGeneration.l(r,v,h);
output('prod',r,d,h) = DispatchableGeneration.l(r,d,h);
output('dem',r,'dem',h) = demand(r,h);
output('cur',r,'cur',h) = -Curtailment.l(r,h);
output('inf',r,'inf',h) = InfeasibleGeneration.l(r,h);
output('s_in',r,sto,h) = -Storage_In.l(r,sto,h);
output('s_out',r,sto,h) = Storage_Out.l(r,sto,h);
output('flow',r,'flow',h) = sum(rr,PowerFlow.l(rr,r,h));

$ifthen %priceQuantity_quantity% == 0
execute_unload "%gdxdir%%dispatchdir%Output_dispatch_%dispatch_year%_%model_region%_%emissionPathway%_%emissionScenario%.gdx"
output;
execute_unload "%gdxdir%%dispatchdir%Output_marginalcosts_%dispatch_year%_%model_region%_%emissionPathway%_%emissionScenario%.gdx"
$ifi %switch_priceQuantityCurves%=="transmission" Add_PriceQuantityConstraint
NEB1_EnergyBalance;
$elseif set output_filename
execute_unload "%gdxdir%%dispatchdir%%output_filename%.gdx"
output
NEB1_EnergyBalance;
$elseif not set output_filename
execute_unload "%gdxdir%%dispatchdir%Output_dispatch_%dispatch_year%_%model_region%_%emissionPathway%_%emissionScenario%_%priceQuantity_region%_%priceQuantity_type%%priceQuantity_quantity%.gdx"
output;
execute_unload "%gdxdir%%dispatchdir%Output_marginalcosts_%dispatch_year%_%model_region%_%emissionPathway%_%emissionScenario%_%priceQuantity_region%_%priceQuantity_type%%priceQuantity_quantity%.gdx"
NEB1_EnergyBalance;
$endif

$ifthen %switch_unixPath% == 0
$ifthen %priceQuantity_quantity% == 0
execute "gdxdump %gdxdir%%dispatchdir%Output_dispatch_%dispatch_year%_%model_region%_%emissionPathway%_%emissionScenario%.gdx output=%resultdir%%dispatchdir%Output_dispatch_%dispatch_year%_%model_region%_%emissionPathway%_%emissionScenario%.csv symb=output format=csv"
$else
execute "gdxdump %gdxdir%%dispatchdir%Output_dispatch_%dispatch_year%_%model_region%_%emissionPathway%_%emissionScenario%_%priceQuantity_region%_%priceQuantity_type%%priceQuantity_quantity%.gdx output=%resultdir%%dispatchdir%Output_dispatch_%dispatch_year%_%model_region%_%emissionPathway%_%emissionScenario%_%priceQuantity_region%_%priceQuantity_type%%priceQuantity_quantity%.csv symb=output format=csv"
$endif
$endif
$endif
