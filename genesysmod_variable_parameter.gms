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


parameter RateOfTotalActivity(y_full,TIMESLICE_FULL,TECHNOLOGY,REGION_FULL);
RateOfTotalActivity(y,l,t,r) = sum(m, RateOfActivity.l(y,l,t,m,r));

parameter RateOfProductionByTechnologyByMode(y_full,TIMESLICE_FULL,TECHNOLOGY,MODE_OF_OPERATION,FUEL,REGION_FULL);
RateOfProductionByTechnologyByMode(y,l,t,m,f,r) = RateOfActivity.l(y,l,t,m,r)*OutputActivityRatio(r,t,f,m,y);

parameter RateOfUseByTechnologyByMode(y_full,TIMESLICE_FULL,TECHNOLOGY,MODE_OF_OPERATION,FUEL,REGION_FULL);
RateOfUseByTechnologyByMode(y,l,t,m,f,r) = RateOfActivity.l(y,l,t,m,r)*InputActivityRatio(r,t,f,m,y)*TimeDepEfficiency(r,t,l,y);

parameter RateOfProductionByTechnology(y_full,TIMESLICE_FULL,TECHNOLOGY,FUEL,REGION_FULL);
RateOfProductionByTechnology(y,l,t,f,r) = sum(m$(OutputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity.l(y,l,t,m,r)*OutputActivityRatio(r,t,f,m,y));

parameter RateOfUseByTechnology(y_full,TIMESLICE_FULL,TECHNOLOGY,FUEL,REGION_FULL);
RateOfUseByTechnology(y,l,t,f,r) = sum(m$(InputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity.l(y,l,t,m,r)*InputActivityRatio(r,t,f,m,y));

parameter ProductionByTechnology(y_full,TIMESLICE_FULL,TECHNOLOGY,FUEL,REGION_FULL);
ProductionByTechnology(y,l,t,f,r) = sum(m$(OutputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity.l(y,l,t,m,r)*OutputActivityRatio(r,t,f,m,y)) * YearSplit(l,y) * TimeDepEfficiency(r,t,l,y);

parameter UseByTechnology(y_full,TIMESLICE_FULL,TECHNOLOGY,FUEL,REGION_FULL);
UseByTechnology(y,l,t,f,r) = sum(m$(InputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity.l(y,l,t,m,r)*InputActivityRatio(r,t,f,m,y)) * YearSplit(l,y) * TimeDepEfficiency(r,t,l,y);

parameter RateOfProduction(y_full,TIMESLICE_FULL,FUEL,REGION_FULL);
RateOfProduction(y,l,f,r) = sum((t,m)$(OutputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity.l(y,l,t,m,r)*OutputActivityRatio(r,t,f,m,y));

parameter RateOfUse(y_full,TIMESLICE_FULL,FUEL,REGION_FULL);
RateOfUse(y,l,f,r) = sum((t,m)$(InputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity.l(y,l,t,m,r)*InputActivityRatio(r,t,f,m,y) * TimeDepEfficiency(r,t,l,y));

parameter Production(y_full,TIMESLICE_FULL,FUEL,REGION_FULL);
Production(y,l,f,r) = sum((t,m)$(OutputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity.l(y,l,t,m,r)*OutputActivityRatio(r,t,f,m,y))*YearSplit(l,y);

parameter Use(y_full,TIMESLICE_FULL,FUEL,REGION_FULL);
Use(y,l,f,r) = sum((t,m)$(InputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity.l(y,l,t,m,r)*InputActivityRatio(r,t,f,m,y)*TimeDepEfficiency(r,t,l,y))*YearSplit(l,y);

parameter ProductionAnnual(y_full,FUEL,REGION_FULL);
ProductionAnnual(y,f,r) = sum((l,t,m)$(OutputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity.l(y,l,t,m,r)*OutputActivityRatio(r,t,f,m,y)*YearSplit(l,y));

parameter UseAnnual(y_full,FUEL,REGION_FULL);
UseAnnual(y,f,r) = sum((l,t,m)$(InputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity.l(y,l,t,m,r)*InputActivityRatio(r,t,f,m,y)*YearSplit(l,y)*TimeDepEfficiency(r,t,l,y));


parameter ModelPeriodCostByRegion(REGION_FULL);
ModelPeriodCostByRegion(r) = sum((y), TotalDiscountedCost.l(y,r));


parameter CurtailedEnergy(y_full,TIMESLICE_FULL,f,r_full);
CurtailedEnergy(y,l,f,r) = sum((t,m),CurtailedCapacity.l(r,l,t,y)*OutputActivityRatio(r,t,f,m,y)*YearSplit(l,y)*CapacityToActivityUnit(t));
