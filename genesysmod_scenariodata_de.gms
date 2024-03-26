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



* ################### CHOOSE CALCULATED YEARS ###################
***  TO LEAVE OUT A CERTAIN YEAR, REMOVE COMMENT OF RESPECTIVE LINE ***
*

*fix for offshore hub regions
CapacityFactor(r,'HLR_Solar_Thermal',l,y)$(CapacityFactor(r,'RES_PV_Utility_Avg',l,y)=0) = 0.00001;
CapacityFactor(r,'HLI_Solar_Thermal',l,y)$(CapacityFactor(r,'RES_PV_Utility_Avg',l,y)=0) = 0.00001;


*no free variable cost
VariableCost(r,t,m,y)$(not VariableCost(r,t,m,y)) = 0.01;

*nuclear phase out
TotalTechnologyAnnualActivityUpperLimit(r,'P_Nuclear',y)$(YearVal(y) >= 2025) = 0;


AvailabilityFactor('DE_Nord',t,y) = 0;
AvailabilityFactor('DE_Baltic',t,y) = 0;

*TotalTechnologyAnnualActivityUpperLimit('DE_Nord',t,y) = 0;
*TotalTechnologyAnnualActivityUpperLimit('DE_Baltic',t,y) = 0;

AvailabilityFactor('DE_Baltic','RES_Wind_Offshore_Deep',y) = 1;
AvailabilityFactor('DE_Baltic','X_Alkaline_Electrolysis',y) = 1;
AvailabilityFactor('DE_Baltic','X_PEM_Electrolysis',y) = 1;
AvailabilityFactor('DE_Baltic','X_SOEC_Electrolysis',y) = 1;
AvailabilityFactor('DE_Baltic','D_Battery_Li-Ion',y) = 1;
AvailabilityFactor('DE_Nord','RES_Wind_Offshore_Deep',y) = 1;
AvailabilityFactor('DE_Nord','X_Alkaline_Electrolysis',y) = 1;
AvailabilityFactor('DE_Nord','X_PEM_Electrolysis',y) = 1;
AvailabilityFactor('DE_Nord','X_SOEC_Electrolysis',y) = 1;
AvailabilityFactor('DE_Nord','D_Battery_Li-Ion',y) = 1;

ReserveMargin('DE_Nord',y) = 0;
ReserveMargin('DE_Baltic',y) = 0;

*NewCapacity.fx('2018','RES_Wind_Offshore_Deep','DE_Nord') = 1;
ResidualCapacity('DE_Nord','RES_Wind_Offshore_Deep',y) = 1;
ResidualCapacity('DE_Baltic','RES_Wind_Offshore_Deep',y) = 1;
*ProductionByTechnologyAnnual.fx('2018','RES_Wind_Offshore_Deep','Power','DE_Nord') = 1;
*TotalTechnologyAnnualActivityLowerLimit('DE_Nord','X_Alkaline_Electrolysis',y)$(YearVal(y)>2018) = 0.5;
*RateOfActivity.fx(y,l,'RES_Wind_Offshore_Deep','1','DE_Nord') = 0.015;

*TradeCapacity(r,'Power',y,'DE_Nord') = TradeCapacity('DE_Nord','Power',y,r); 
*Export.fx(y,l,'Power','DE_Nord',rr) = 0.01;

*TradeRoute(r,f,y,'DE_Nord') = 0;
Import.fx(y,l,f,'DE_Nord',rr) = 0;
*Import.fx(y,l,f,'DE_Baltic',rr) = 0;


TotalTechnologyAnnualActivityUpperLimit(r,'X_Alkaline_Electrolysis','2018') = 0.01*SpecifiedAnnualDemand(r,'H2','2018');
TotalTechnologyAnnualActivityUpperLimit(r,'X_SMR','2018') = 0.37*SpecifiedAnnualDemand(r,'H2','2018');
RegionalBaseYearProduction(r,'X_SMR','H2','2018') = 0.37*SpecifiedAnnualDemand(r,'H2','2018');
RegionalBaseYearProduction(r,'X_Alkaline_Electrolysis','H2','2018') = 0.01*SpecifiedAnnualDemand(r,'H2','2018');
*NewCapacity.up('2018','X_SMR',r) = 999999;
*NewCapacity.up('2018','X_Alkaline_Electrolysis',r) = 999999;




