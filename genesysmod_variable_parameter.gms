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

RateOfTotalActivity(y,l,t,r) = sum(m, RateOfActivity.l(y,l,t,m,r));

RateOfProductionByTechnologyByMode(y,l,t,m,f,r) = RateOfActivity.l(y,l,t,m,r)*OutputActivityRatio(r,t,f,m,y);

RateOfUseByTechnologyByMode(y,l,t,m,f,r) = RateOfActivity.l(y,l,t,m,r)*InputActivityRatio(r,t,f,m,y);

RateOfProductionByTechnology(y,l,t,f,r) = sum(m$(OutputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity.l(y,l,t,m,r)*OutputActivityRatio(r,t,f,m,y));

RateOfUseByTechnology(y,l,t,f,r) = sum(m$(InputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity.l(y,l,t,m,r)*InputActivityRatio(r,t,f,m,y));

ProductionByTechnology(y,l,t,f,r) = sum(m$(OutputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity.l(y,l,t,m,r)*OutputActivityRatio(r,t,f,m,y)) * YearSplit(l,y);

UseByTechnology(y,l,t,f,r) = sum(m$(InputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity.l(y,l,t,m,r)*InputActivityRatio(r,t,f,m,y)) * YearSplit(l,y);

RateOfProduction(y,l,f,r) = sum((t,m)$(OutputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity.l(y,l,t,m,r)*OutputActivityRatio(r,t,f,m,y));

RateOfUse(y,l,f,r) = sum((t,m)$(InputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity.l(y,l,t,m,r)*InputActivityRatio(r,t,f,m,y));

Production(y,l,f,r) = sum((t,m)$(OutputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity.l(y,l,t,m,r)*OutputActivityRatio(r,t,f,m,y))*YearSplit(l,y);

Use(y,l,f,r) = sum((t,m)$(InputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity.l(y,l,t,m,r)*InputActivityRatio(r,t,f,m,y))*YearSplit(l,y);

ProductionAnnual(y,f,r) = sum((l,t,m)$(OutputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity.l(y,l,t,m,r)*OutputActivityRatio(r,t,f,m,y)*YearSplit(l,y));

UseAnnual(y,f,r) = sum((l,t,m)$(InputActivityRatio(r,t,f,m,y) <> 0), RateOfActivity.l(y,l,t,m,r)*InputActivityRatio(r,t,f,m,y)*YearSplit(l,y));

ModelPeriodCostByRegion(r) = sum((y), TotalDiscountedCost.l(y,r));

CurtailedEnergy(y,l,f,r) = sum((t,m),CurtailedCapacity.l(r,l,t,y)*OutputActivityRatio(r,t,f,m,y)*YearSplit(l,y)*CapacityToActivityUnit(t));
