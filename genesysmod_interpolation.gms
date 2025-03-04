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


Yearsplit(l,y)$(Yearsplit(l,y) = 0) = Yearsplit(l,y-1);


ReserveMarginTagFuel(r,f,y)$(ReserveMarginTagFuel(r,f,y) = 0) = ReserveMarginTagFuel(r,f,y-1);
ReserveMargin(r,y)$(ReserveMargin(r,y) = 0) = ReserveMargin(r,y-1);
ReserveMarginTagTechnology(r,t,y)$(ReserveMarginTagTechnology(r,t,y) = 0) = ReserveMarginTagTechnology(r,t,y-1);

EmissionsPenaltyTagTechnology(r,t,e,y)$(EmissionsPenaltyTagTechnology(r,t,e,y) = 0) = EmissionsPenaltyTagTechnology(r,t,e,y-1);
RegionalAnnualEmissionLimit(r,e,y)$(RegionalAnnualEmissionLimit(r,e,y) = 0 and RegionalAnnualEmissionLimit(r,e,y+1) > 0) = (RegionalAnnualEmissionLimit(r,e,y-1)+RegionalAnnualEmissionLimit(r,e,y+1))/2;
AnnualEmissionLimit(e,y)$(AnnualEmissionLimit(e,y) = 0 and AnnualEmissionLimit(e,y+1) > 0) = (AnnualEmissionLimit(e,y-1)+AnnualEmissionLimit(e,y+1))/2;
AnnualSectoralEmissionLimit(e,se,y)$(AnnualSectoralEmissionLimit(e,se,y)=0 and AnnualSectoralEmissionLimit(e,se,y+1) > 0) =  (AnnualSectoralEmissionLimit(e,se,y-1)+AnnualSectoralEmissionLimit(e,se,y+1))/2;

ModalSplitByFuelandModalType(r,f,mt,y)$(ModalSplitByFuelandModalType(r,f,mt,y) = 0 and ModalSplitByFuelandModalType(r,f,mt,y+1) > 0) =  (ModalSplitByFuelandModalType(r,f,mt,y-1)+ModalSplitByFuelandModalType(r,f,mt,y+1))/2 ;


InputActivityRatio(r,t,f,m,y)$(InputActivityRatio(r,t,f,m,y) = 0) = InputActivityRatio(r,t,f,m,y-1);
OutputActivityRatio(r,t,f,m,y)$(OutputActivityRatio(r,t,f,m,y) = 0) = OutputActivityRatio(r,t,f,m,y-1);
FixedCost(r,t,y)$(FixedCost(r,t,y) = 0) = FixedCost(r,t,y-1);
CapitalCost(r,t,y)$(CapitalCost(r,t,y) = 0) = (CapitalCost(r,t,y-1)+CapitalCost(r,t,y+1))/2;
VariableCost(r,t,m,y)$(VariableCost(r,t,m,y) = 0) = (VariableCost(r,t,m,y-1)+VariableCost(r,t,m,y+1))/2;
*AvailabilityFactor(r,t,y)$(AvailabilityFactor(r,t,y) = 0) = AvailabilityFactor(r,t,y-1);
EmissionActivityRatio(r,t,m,e,y)$(EmissionActivityRatio(r,t,m,e,y) = 0) = EmissionActivityRatio(r,t,m,e,y-1);

PhaseIn(y)$(PhaseIn(y) = 0 and PhaseIn(y+1)>0) = PhaseIn(y+1);
PhaseOut(y)$(PhaseOut(y) = 0 and PhaseOut(y+1) > 0) = PhaseOut(y+1);

SpecifiedAnnualDemand(r,f,y)$(SpecifiedAnnualDemand(r,f,y) = 0) = (SpecifiedAnnualDemand(r,f,y-1)+SpecifiedAnnualDemand(r,f,y+1))/2;
SpecifiedDemandProfile(r,f,l,y)$(SpecifiedDemandProfile(r,f,l,y) = 0) = SpecifiedDemandProfile(r,f,l,y-1);


TechnologyToStorage(t,s,m,y)$(TechnologyToStorage(t,s,m,y) = 0) = TechnologyToStorage(t,s,m,y-1);
TechnologyFromStorage(t,s,m,y)$(TechnologyFromStorage(t,s,m,y) = 0) = TechnologyFromStorage(t,s,m,y-1);
MinStorageCharge(r,s,y)$(MinStorageCharge(r,s,y) = 0) = MinStorageCharge(r,s,y-1);
CapitalCostStorage(r,s,y)$(CapitalCostStorage(r,s,y) = 0) = CapitalCostStorage(r,s,y-1);

TotalAnnualMaxCapacity(r,t,y)$(TotalAnnualMaxCapacity(r,t,y) = 0) = TotalAnnualMaxCapacity(r,t,y-1);

ResidualCapacity(r,t,y)$(ResidualCapacity(r,t,y) = 0 and ResidualCapacity(r,t,y+1)>0) = (ResidualCapacity(r,t,y-1)+ResidualCapacity(r,t,y+1))/2;
TotalTechnologyAnnualActivityUpperLimit(r,t,y)$(TotalTechnologyAnnualActivityUpperLimit(r,t,y) = 0 and TotalTechnologyAnnualActivityUpperLimit(r,t,y+1)>0) = (TotalTechnologyAnnualActivityUpperLimit(r,t,y-1)+TotalTechnologyAnnualActivityUpperLimit(r,t,y+1))/2;

GrowthRateTradeCapacity(r,'Power',y,rr)$(GrowthRateTradeCapacity(r,'Power',y,rr) = 0) = GrowthRateTradeCapacity(r,'Power',y-1,rr);

$ifthen %switch_employment_calculation% == 1
EFactorConstruction(t,y)$(EFactorConstruction(t,y) = 0) = (EFactorConstruction(t,y-1)+EFactorConstruction(t,y+1))/2;
EFactorOM(t,y)$(EFactorOM(t,y) = 0) = (EFactorOM(t,y-1)+EFactorOM(t,y+1))/2;
EFactorManufacturing(t,y)$(EFactorManufacturing(t,y) = 0) = (EFactorManufacturing(t,y-1)+EFactorManufacturing(t,y+1))/2;
EFactorFuelSupply(t,y)$(EFactorFuelSupply(t,y) = 0) = (EFactorFuelSupply(t,y-1)+EFactorFuelSupply(t,y+1))/2;
EFactorCoalJobs(t,y)$(EFactorCoalJobs(t,y) = 0) = (EFactorCoalJobs(t,y-1)+EFactorCoalJobs(t,y+1))/2;
EFactorCoalJobs('Coal_Export',y)$(EFactorCoalJobs('Coal_Export',y) = 0) = (EFactorCoalJobs('Coal_Export',y-1)+EFactorCoalJobs('Coal_Export',y+1))/2;
EFactorCoalJobs('Coal_Heat',y)$(EFactorCoalJobs('Coal_Heat',y) = 0) = (EFactorCoalJobs('Coal_Heat',y-1)+EFactorCoalJobs('Coal_Heat',y+1))/2;
CoalSupply(r,y)$(CoalSupply(r,y) = 0) = (CoalSupply(r,y-1)+CoalSupply(r,y+1))/2;
CoalDigging('%model_region%','Coal_Export','%emissionPathway%_%emissionScenario%',y)$(CoalDigging('%model_region%','Coal_Export','%emissionPathway%_%emissionScenario%',y) = 0) = (CoalDigging('%model_region%','Coal_Export','%emissionPathway%_%emissionScenario%',y-1)+CoalDigging('%model_region%','Coal_Export','%emissionPathway%_%emissionScenario%',y+1))/2;
RegionalAdjustmentFactor('%model_region%',y)$(RegionalAdjustmentFactor('%model_region%',y) = 0) = (RegionalAdjustmentFactor('%model_region%',y+1)+RegionalAdjustmentFactor('%model_region%',y+1))/2;
LocalManufacturingFactor('%model_region%',y)$(LocalManufacturingFactor('%model_region%',y) = 0) = (LocalManufacturingFactor('%model_region%',y-1)+LocalManufacturingFactor('%model_region%',y+1))/2;
DeclineRate(t,y)$(DeclineRate(t,y) = 0) = (DeclineRate(t,y-1)+DeclineRate(t,y+1))/2;
$endif
