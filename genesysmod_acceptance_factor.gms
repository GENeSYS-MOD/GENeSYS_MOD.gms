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
AcceptanceFactor(r,t,y)$(AcceptanceFactor(r,t,y)=0)=78;
AcceptanceFactor(r,t,y)$(AcceptanceFactor(r,t,y)>0)=100-AcceptanceFactor(r,t,y);

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
                 
positive variable TotalAcceptanceperregion_all(r_full,y_full);

equation Acceptance2_2_TotalAcceptanceperregion(r_full,y_full);
Acceptance2_2_TotalAcceptanceperregion(r,y)..
                 (TotalAcceptanceperRegion(r,y)+TotalAcceptanceperRegion_Powerlines(r,y))
                 =e= TotalAcceptanceperregion_all(r,y);


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

*******Capacity Calculation           
                 
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
                 

positive variable TotalCapacityperRegionAcceptance(r_full,y_full);

equation Acceptance5_2_TotalCapacityAcceptance(r_full,y_full);
Acceptance5_2_TotalCapacityAcceptance(r,y)..
                 (TotalNCapacityperRegion_Powerlines(r,y)+TotalNCapacityperRegion(r,y))
                 =e= TotalCapacityperRegionAcceptance(r,y);
                 

positive variable TotalCapacityAcceptance(y_full);

equation Acceptance6_TotalCapacityAcceptance(y_full);
Acceptance6_TotalCapacityAcceptance(y)..
                 (TotalNCapacity_PowerLines(y)+TotalNCapacity(y))
                 =e= TotalCapacityAcceptance(y);
                 

*positive variable TotalAcceptanceBase(r_full);
*equation Acceptance4_TotalAcceptanceBase(r_full);
*Acceptance4_TotalAcceptanceBase(r)..
*                 TotalAcceptance(r,'2018')/TotalNCapacity(r,'2018')
*                 =e= TotalAcceptanceBase(r);


$ifthen %switch_acceptance_constraint% == 1

**If Justice should not be reduced, can also be turned upside down
*$ifthen %Info% == SA2dgJOBS

Parameter StartingAcceptance(y_full);
StartingAcceptance('2025') = 84.2868;
StartingAcceptance('2030') = 80.9835;
*StartingAcceptance('2035') = 69.92079191;
*StartingAcceptance('2040') = 73.9586288971845;
*StartingAcceptance('2045') = 80.2401257973244;
*StartingAcceptance('2050') = 64.4564353835634;

Parameter YearlyAcceptanceChange(y_full);
YearlyAcceptanceChange('2025') = 1;
YearlyAcceptanceChange('2030') = 1.01;
*YearlyAcceptanceChange('2035') = 1.005;
*YearlyAcceptanceChange('2040') = 1.005;
*YearlyAcceptanceChange('2045') = 1.005;
*YearlyAcceptanceChange('2050') = 1.005;

Parameter YearlyAcceptanceChangeRegion(r_full,y_full);
YearlyAcceptanceChange('2025') = 1;
YearlyAcceptanceChange('2030') = 1.01;
*YearlyAcceptanceChange('2035') = 1.005;
*YearlyAcceptanceChange('2040') = 1.005;
*YearlyAcceptanceChange('2045') = 1.005;
*YearlyAcceptanceChange('2050') = 1.005;


*equation Acceptance4_TotalAverageAcceptance(r_full,y_full); 
*Acceptance4_TotalAverageAcceptance(r,y)$(YearVal(y) > 2030).. TotalAcceptance('2040') =g= TotalAcceptance('2030')*TotalNCapacity('2040');

****old formulation before April, 24
**equation Acceptance4_TotalAverageAcceptance(r_full,y_full); 
**Acceptance4_TotalAverageAcceptance(r,y)$(YearVal(y) > 2025).. TotalAcceptance(y) =g= (YearlyAcceptanceChange(y)*StartingAcceptance(y)) * TotalCapacityAcceptance(y);

**equation Acceptance5_TotalAverageAcceptance_set(r_full,y_full); 
**Acceptance5_TotalAverageAcceptance_set(r,y)$(YearVal(y) = 2025).. TotalAcceptanceperregion(y) =e= (YearlyAcceptanceChange(r,y)*StartingAcceptance(r,y)) * TotalCapacityperRegionAcceptance(r,y);

***Include Regions
Parameter StartingAcceptanceRegional(r_full,y_full);
StartingAcceptanceRegional('DE_HE','2025') = 91.3498;
StartingAcceptanceRegional('DE_BY','2025') = 89.7811;
StartingAcceptanceRegional('DE_TH','2025') = 89.37;
StartingAcceptanceRegional('DE_BW','2025') = 89.2143;
StartingAcceptanceRegional('DE_HB','2025') = 88.0497;
StartingAcceptanceRegional('DE_NI','2025') = 86.8953;
StartingAcceptanceRegional('DE_SH','2025') = 85.5355;
StartingAcceptanceRegional('DE_NRW','2025') = 85.4616;
StartingAcceptanceRegional('DE_HH','2025') = 83.4321;
StartingAcceptanceRegional('DE_RP','2025') = 80.9509;
StartingAcceptanceRegional('DE_SL','2025') = 79.8173;
StartingAcceptanceRegional('DE_BB','2025') = 76.9059;
StartingAcceptanceRegional('DE_ST','2025') = 76.1676;
StartingAcceptanceRegional('DE_MV','2025') = 72.5158;
StartingAcceptanceRegional('DE_SN','2025') = 69.8417;

Parameter StartingAcceptanceChanged(r_full,y_full);
StartingAcceptanceChanged(r,'2030')= (StartingAcceptanceRegional(r,'2025')+1);

*current version as of 21.10.2025
****old formulation before April, 24
*equation Acceptance7_AverageRegionalAcceptanceConstraintBaseYear(r_full,y_full); 
*Acceptance7_AverageRegionalAcceptanceConstraintBaseYear(r,y)$(YearVal(y) = 2025).. TotalAcceptanceperregion_all(r,y) =e= (StartingAcceptanceRegional(r,'2025')) * TotalCapacityperRegionAcceptance(r,y);

*equation Acceptance7_1_AverageRegionalAcceptanceConstraint(r_full,y_full); 
*Acceptance7_1_AverageRegionalAcceptanceConstraint(r,y)$(YearVal(y) = 2030).. TotalAcceptanceperregion_all(r,y) =e= (StartingAcceptanceChanged(r,'2030')) * TotalCapacityperRegionAcceptance(r,y);

***equation NoJusticeLost(r_full,y_full);
***NoJusticeLost(r,y)$(YearVal(y) > 2025).. TotalAcceptance(r,y) =l=  TotalAcceptance(r,y-1);
*$elseif %Info% == SA2dgJOBS2015
*equation NoJusticeLost(r_full,y_full);
*NoJusticeLost(r,y)$(YearVal(y) > 2015).. TotalJustice(r,y) =g=  TotalJustice(r,'2018');

$endif

****GINI COEFFICIENT 


$endif