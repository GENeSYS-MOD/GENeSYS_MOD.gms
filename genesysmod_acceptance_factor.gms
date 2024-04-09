* ###################### genesysmod_acceptance_factor.gms #######################
*
* GENeSYS-MOD v3.1 [Global Energy System Model]  ~ March 2022
*
* Based on OSEMOSYS 2011.07.07 conversion to GAMS by Ken Noble, Noble-Soft Systems - August 2012
*
* Updated to newest OSeMOSYS-Version (2016.08) and further improved with additional equations 2016 - 2022
* by Konstantin L?ffler, Thorsten Burandt, Karlo Hainsch
*
* #############################################################
*
* Copyright 2020 Technische Universit?t Berlin and DIW Berlin
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

**VariableCost(r,'X_Alkaline_Electrolysis',m,y) = 100;

*$ifthen %switch_endogenous_justice% == 1
$ifthen %switch_acceptance_factor% == 1

*
* ############## Acceptance Factor #############
* 
* ######Acceptance######

positive variable Acceptance;

equation Acceptance1_Acceptance(r_full,TECHNOLOGY,y_full);
Acceptance1_Acceptance(r,t,y)..
                 NewCapacity(y,t,r)*AcceptanceFactor(r,t,y)
                 =e= Acceptance(r,t,y);
                 

positive variable TotalAcceptanceperRegion(r_full,y_full);

equation Acceptance2_TotalAcceptanceperRegion(r_full,y_full);
Acceptance2_TotalAcceptanceperRegion(r,y)..
                 sum(t, Acceptance(r,t,y))
                 =e= TotalAcceptanceperRegion(r,y);

positive variable TotalAcceptance(y_full);

equation Acceptance3_TotalAcceptance(y_full);
Acceptance3_TotalAcceptance(y)..
                 sum(r, TotalAcceptanceperRegion(r,y))
                 =e= TotalAcceptance(y);
                 
positive variable TotalNCapacityperRegion(r_full,y_full);

equation Acceptance4_TotalNCapacityperRegion(r_full,y_full);
Acceptance4_TotalNCapacityperRegion(r,y)..
                 sum(t$(AcceptanceFactor(r,t,y) > 0), NewCapacity(y,t,r))
                 =e= TotalNCapacityperRegion(r,y);

positive variable TotalNCapacity(y_full);

equation Acceptance5_TotalNCapacity(y_full);
Acceptance5_TotalNCapacity(y)..
                 sum(r, TotalNCapacityperRegion(r,y))
                 =e= TotalNCapacity(y);

*positive variable TotalAcceptanceBase(r_full);
*equation Acceptance4_TotalAcceptanceBase(r_full);
*Acceptance4_TotalAcceptanceBase(r)..
*                 TotalAcceptance(r,'2018')/TotalNCapacity(r,'2018')
*                 =e= TotalAcceptanceBase(r);


$ifthen %switch_acceptance_constraint% == 1

**If Justice should not be reduced, can also be turned upside down
*$ifthen %Info% == SA2dgJOBS

Parameter StartingAcceptance(y_full);
*StartingAcceptance('2025') = 70.30363194;
*StartingAcceptance('2030') = 67.9662792602794;
*StartingAcceptance('2035') = 67.8527606551304;
*StartingAcceptance('2040') = 67.340590703187;
*StartingAcceptance('2045') = 66.8937244905644;
*StartingAcceptance('2050') = 66.896608484273;


*StartingAcceptance('2030') = 0.843702;
*StartingAcceptance('2035') = 0.844454;
*StartingAcceptance('2040') = 0.844709;
*StartingAcceptance('2045') = 0.847219;
*StartingAcceptance('2050') = 0.851116;

StartingAcceptance('2025') = 84.85667641;
StartingAcceptance('2030') = 84.85667641;
StartingAcceptance('2035') = 84.85667641;
StartingAcceptance('2040') = 84.85667641;
StartingAcceptance('2045') = 84.85667641;
StartingAcceptance('2050') = 84.85667641;

Parameter YearlyAcceptanceChange(y_full);

YearlyAcceptanceChange('2025') = 1;
YearlyAcceptanceChange('2030') = 1.01;
YearlyAcceptanceChange('2035') = 1.0125;
YearlyAcceptanceChange('2040') = 1.015;
YearlyAcceptanceChange('2045') = 1.02;
YearlyAcceptanceChange('2050') = 1.025;



*equation Acceptance4_TotalAverageAcceptance(r_full,y_full); 
*Acceptance4_TotalAverageAcceptance(r,y)$(YearVal(y) > 2030).. TotalAcceptance('2040') =g= TotalAcceptance('2030')*TotalNCapacity('2040');

****old formulation before April, 24
equation Acceptance4_TotalAverageAcceptance(r_full,y_full); 
Acceptance4_TotalAverageAcceptance(r,y)$(YearVal(y) > 2025).. TotalAcceptance(y) =g= (YearlyAcceptanceChange(y)*StartingAcceptance(y)) * TotalNCapacity(y);


***equation NoJusticeLost(r_full,y_full);
***NoJusticeLost(r,y)$(YearVal(y) > 2025).. TotalAcceptance(r,y) =l=  TotalAcceptance(r,y-1);
*$elseif %Info% == SA2dgJOBS2015
*equation NoJusticeLost(r_full,y_full);
*NoJusticeLost(r,y)$(YearVal(y) > 2015).. TotalJustice(r,y) =g=  TotalJustice(r,'2018');

$endif

****GINI COEFFICIENT 


$endif