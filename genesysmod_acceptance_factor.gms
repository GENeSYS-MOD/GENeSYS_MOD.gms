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
  
positive variable Acceptance_Powerlines;
** To account for acceptance for the lines going from a region and coming to a region.
equation Acceptance1_1_Acceptance_Powerlines(r_full,rr_full,FUEL,y_full);
Acceptance1_1_Acceptance_Powerlines(r,rr,'Power',y)..
                 (NewTradeCapacity(y,'Power',r,rr)*AcceptanceFactorPowerLines(r,rr,'Power',y)+NewTradeCapacity(y,'Power',rr,r)*AcceptanceFactorPowerLines(r,rr,'Power',y))
                 =e= Acceptance_Powerlines(r,rr,'Power',y);               

positive variable TotalAcceptanceperRegion(r_full,y_full);

equation Acceptance2_TotalAcceptanceperRegion(r_full,y_full);
Acceptance2_TotalAcceptanceperRegion(r,y)..
                 sum(t, Acceptance(r,t,y))
                 =e= TotalAcceptanceperRegion(r,y);
                 


*positive variable TotalAcceptanceperRegion_Powerlines(r_full,FUEL,y_full);

*equation Acceptance2_1_TotalAcceptanceperRegion_Powerlines(r_full,FUEL,y_full);
*Acceptance2_1_TotalAcceptanceperRegion_Powerlines(r,'Power',y)..
*                 (sum(rr,(Acceptance_Powerlines(r,rr,'Power',y)+Acceptance_Powerlines(rr,r,'Power',y))))
*                 =e= TotalAcceptanceperRegion_Powerlines(r,'Power',y);


positive variable TotalAcceptanceperRegion_Powerlines(r_full,y_full);

equation Acceptance2_1_TotalAcceptanceperRegion_Powerlines(r_full,y_full);
Acceptance2_1_TotalAcceptanceperRegion_Powerlines(r,y)..
                 sum(rr,(Acceptance_Powerlines(r,rr,'Power',y)))
                 =e= TotalAcceptanceperRegion_Powerlines(r,y);


positive variable TotalAcceptance(y_full);

equation Acceptance3_TotalAcceptance(y_full);
Acceptance3_TotalAcceptance(y)..
                 sum(r, TotalAcceptanceperRegion(r,y))
                 =e= TotalAcceptance(y);
                 
positive variable TotalAcceptance_Powerlines(y_full);

equation Acceptance3_1_TotalAcceptance_Powerlines(y_full);
Acceptance3_1_TotalAcceptance_Powerlines(y)..
                 sum(r, TotalAcceptanceperRegion_Powerlines(r,y))
                 =e= TotalAcceptance_Powerlines(y);
                
                 
positive variable TotalNCapacityperRegion(r_full,y_full);

equation Acceptance4_TotalNCapacityperRegion(r_full,y_full);
Acceptance4_TotalNCapacityperRegion(r,y)..
                 (sum(t$(AcceptanceFactor(r,t,y) > 0), NewCapacity(y,t,r)))
                 =e= TotalNCapacityperRegion(r,y);
                 
positive variable TotalNCapacityperRegion_Powerlines(r_full,y_full);

equation Acceptance4_1_TotalNCapacityperRegion_Powerlines(r_full,y_full);
Acceptance4_1_TotalNCapacityperRegion_Powerlines(r,y)..
                 (sum(rr,((NewTradeCapacity(y,'Power',rr,r)+NewTradeCapacity(y,'Power',r,rr)))))
                 =e= TotalNCapacityperRegion_Powerlines(r,y);

positive variable TotalNCapacity(y_full);

equation Acceptance5_TotalNCapacity(y_full);
Acceptance5_TotalNCapacity(y)..
                 sum(r, TotalNCapacityperRegion(r,y))
                 =e= TotalNCapacity(y);
                 
positive variable TotalNCapacity_PowerLines(y_full);

equation Acceptance5_1_TotalNCapacity_PowerLines(y_full);
Acceptance5_1_TotalNCapacity_PowerLines(y)..
                 sum(r, TotalNCapacityperRegion_Powerlines(r,y))
                 =e= TotalNCapacity_PowerLines(y);
*positive variable TotalAcceptanceBase(r_full);
*equation Acceptance4_TotalAcceptanceBase(r_full);
*Acceptance4_TotalAcceptanceBase(r)..
*                 TotalAcceptance(r,'2018')/TotalNCapacity(r,'2018')
*                 =e= TotalAcceptanceBase(r);


$ifthen %switch_acceptance_constraint% == 1

**If Justice should not be reduced, can also be turned upside down
*$ifthen %Info% == SA2dgJOBS

Parameter StartingAcceptance(y_full);
StartingAcceptance('2025') = 87.7805;
StartingAcceptance('2030') = 87.7805;
StartingAcceptance('2035') = 87.7805;
StartingAcceptance('2040') = 87.7805;
StartingAcceptance('2045') = 87.7805;
StartingAcceptance('2050') = 87.7805;

Parameter YearlyAcceptanceChange(y_full);
YearlyAcceptanceChange('2025') = 1.0;
YearlyAcceptanceChange('2030') = 1.0;
YearlyAcceptanceChange('2035') = 1.0;
YearlyAcceptanceChange('2040') = 1.0;
YearlyAcceptanceChange('2045') = 1.0;
YearlyAcceptanceChange('2050') = 1.0;



*equation Acceptance4_TotalAverageAcceptance(r_full,y_full); 
*Acceptance4_TotalAverageAcceptance(r,y)$(YearVal(y) > 2030).. TotalAcceptance('2040') =g= TotalAcceptance('2030')*TotalNCapacity('2040');

****old formulation before April, 24
equation Acceptance4_TotalAverageAcceptance(r_full,y_full); 
Acceptance4_TotalAverageAcceptance(r,y)$(YearVal(y) > 2020).. TotalAcceptance(y) =g= (YearlyAcceptanceChange(y)*StartingAcceptance(y)) * TotalNCapacity(y);


***equation NoJusticeLost(r_full,y_full);
***NoJusticeLost(r,y)$(YearVal(y) > 2025).. TotalAcceptance(r,y) =l=  TotalAcceptance(r,y-1);
*$elseif %Info% == SA2dgJOBS2015
*equation NoJusticeLost(r_full,y_full);
*NoJusticeLost(r,y)$(YearVal(y) > 2015).. TotalJustice(r,y) =g=  TotalJustice(r,'2018');

$endif

****GINI COEFFICIENT 


$endif