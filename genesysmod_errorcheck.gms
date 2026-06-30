* GENeSYS-MOD v4.0 [Global Energy System Model]  ~ August 2025
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

* switch_errorcheck: 0 = skip, 1 = report only, 2 = abort on hard errors (default)
$ifthen.errorcheck not %switch_errorcheck% == 0

scalar errorcheck_level Level of input data error checking /%switch_errorcheck%/;

**************************************************************
****************   ERROR HANDLING BLOCK   ********************
**************************************************************

* Check if Technologies are missing from the Sector list
parameter error_TechMissingFromSectorList(TECHNOLOGY);
error_TechMissingFromSectorList(t)$(not sum(se,TagTechnologyToSector(t,se))) = 1;
if(sum(t,error_TechMissingFromSectorList(t)),
   display error_TechMissingFromSectorList;
   abort$(errorcheck_level = 2) "Technology missing from Sector list. Please check TagTechnologyToSector to include all Technologies.";
);

* Check if TradeCosts are missing from a defined TradeRoute
parameter error_TradeCostsMissingFromTradeRoute(r_full,f,rr_full);
error_TradeCostsMissingFromTradeRoute(r,f,rr)$(sum(y,TradeRoute(r,f,y,rr)) and TagCanFuelBeTraded(f) and not sum(y,TradeCosts(r,f,y,rr))) = 1;
if(sum((f,r,rr),error_TradeCostsMissingFromTradeRoute(r,f,rr)),
   display error_TradeCostsMissingFromTradeRoute;
   abort$(errorcheck_level = 2) "TradeCosts are missing from a defined TradeRoute. Please check your TradeCosts to include all defined TradeRoutes.";
);

* Check for errors in ModalSplit definitions
parameter error_ModalSplitByModalTypeDefinition(f,*,r_full,y_full);
error_ModalSplitByModalTypeDefinition(f,'Error in ModalGroup',r,y)$(round(sum(mt$(TagModalTypeToModalGroups(mt,'TransportModes')),ModalSplitByFuelAndModalType(r,f,mt,y)),4)>1) = 1;
error_ModalSplitByModalTypeDefinition(f,'Error in SubGroup',r,y)$(round(sum(mt$(TagModalTypeToModalGroups(mt,'ModalSubgroups')),ModalSplitByFuelAndModalType(r,f,mt,y)),4)>1) = 1;
if(sum((f,r,y),error_ModalSplitByModalTypeDefinition(f,'Error in ModalGroup',r,y)+error_ModalSplitByModalTypeDefinition(f,'Error in SubGroup',r,y)),
   display error_ModalSplitByModalTypeDefinition;
   abort$(errorcheck_level = 2) "ModalSplit is wrongly defined for a ModalGroup or SubGroup. The sum of ModalTypes cannot exceed 1. Please check your data.";
);

* Check for errors in OperationalLife data
parameter error_OperationalLifeMissing(t);
$ifthen %switch_infeasibility_tech% == 0
error_OperationalLifeMissing(t)$(not OperationalLife(t) and not TagTechnologyToSector(t,'Infeasibility')) = 1;
$else
error_OperationalLifeMissing(t)$(not OperationalLife(t)) = 1;
$endif
if(sum((t),error_OperationalLifeMissing(t)),
   display error_OperationalLifeMissing;
   abort$(errorcheck_level = 2) "OperationalLife is missing from a Technology. Please check your OperationalLife data to account for all technologies.";
);

* Check for errors in CapacityFactor data
parameter error_CapacityFactorDataMissing(r_full,t,y_full);
error_CapacityFactorDataMissing(r,t,y)$(not sum(l,CapacityFactor(r,t,l,y)) and AvailabilityFactor(r,t,y) and TotalAnnualMaxCapacity(r,t,y)) = 1;
if(sum((r,t,y),error_CapacityFactorDataMissing(r,t,y)),
   display error_CapacityFactorDataMissing;
   abort$(errorcheck_level = 2) "CapacityFactor is missing from a Technology. Please check your Hourly data file to account for all technologies.";
);

* Check for missing entries in CapacityToActivityUnit
parameter error_CapacityToActivityUnitDataMissing(r_full,t);
error_CapacityToActivityUnitDataMissing(r,t)$(sum(y,AvailabilityFactor(r,t,y)) and not CapacityToActivityUnit(t)) = 1;
if(sum((r,t),error_CapacityToActivityUnitDataMissing(r,t)),
   display error_CapacityToActivityUnitDataMissing;
   abort$(errorcheck_level = 2) "CapacityToActivityUnit is missing from a Technology. Please check your CapacityToActivityUnit data.";
);

* Check for errors in TradeRoutes, if they have a capacity given
parameter error_TradeCapacityMismatch(*,r_full,f,y_full,rr_full);
error_TradeCapacityMismatch('TradeCapacity',r,f,y,rr)$(TradeCapacity(r,f,y,rr) and not TradeRoute(r,f,y,rr))  = 1;
error_TradeCapacityMismatch('CommissionedTradeCapacity',r,f,y,rr)$(CommissionedTradeCapacity(r,f,y,rr) and not TradeRoute(r,f,y,rr))  = 1;
if(sum((r,f,y,rr),error_TradeCapacityMismatch('TradeCapacity',r,f,y,rr)+error_TradeCapacityMismatch('CommissionedTradeCapacity',r,f,y,rr)),
   display error_TradeCapacityMismatch;
   abort$(errorcheck_level = 2) "TradeRoute is missing for some trade connections where a TradeCapacity has been set. Please check your TradeRoute and TradeCapacity data.";
);

* Check for a demanded fuel that no technology produces and that cannot be imported
parameter error_DemandWithoutProducer(r_full,f);
error_DemandWithoutProducer(r,f)$(sum(y,SpecifiedAnnualDemand(r,f,y)) and not sum((t,m,y),OutputActivityRatio(r,t,f,m,y)) and not (TagCanFuelBeTraded(f) and sum((rr,y),TradeRoute(r,f,y,rr)+TradeRoute(rr,f,y,r)))) = 1;
if(sum((r,f),error_DemandWithoutProducer(r,f)),
   display error_DemandWithoutProducer;
   abort$(errorcheck_level = 2) "SpecifiedAnnualDemand is set but no technology produces the fuel in the region and no TradeRoute can import it.";
);

* Check for minimum bounds exceeding their maximum counterparts
parameter error_MinAboveMax(*,r_full,t,y_full);
error_MinAboveMax('TotalAnnualMinAboveMax',r,t,y)$(TotalAnnualMaxCapacity(r,t,y) < 999999 and TotalAnnualMinCapacity(r,t,y) > TotalAnnualMaxCapacity(r,t,y)) = 1;
error_MinAboveMax('AnnualNewMinAboveMax',r,t,y)$(AnnualMaxNewCapacity(r,t,y) < 999999 and AnnualMinNewCapacity(r,t,y) > AnnualMaxNewCapacity(r,t,y)) = 1;
error_MinAboveMax('ActivityLowerAboveUpper',r,t,y)$(TotalTechnologyAnnualActivityUpperLimit(r,t,y) < 999999 and TotalTechnologyAnnualActivityLowerLimit(r,t,y) > TotalTechnologyAnnualActivityUpperLimit(r,t,y)) = 1;
parameter error_GroupMinAboveMax(*,*,y_full);
error_GroupMinAboveMax(tg,rg,y)$(GroupTotalAnnualMaxCapacity(tg,rg,y) < 999999 and GroupTotalAnnualMinCapacity(tg,rg,y) > GroupTotalAnnualMaxCapacity(tg,rg,y)) = 1;
if(sum((r,t,y),error_MinAboveMax('TotalAnnualMinAboveMax',r,t,y)+error_MinAboveMax('AnnualNewMinAboveMax',r,t,y)+error_MinAboveMax('ActivityLowerAboveUpper',r,t,y))+sum((tg,rg,y),error_GroupMinAboveMax(tg,rg,y)),
   display error_MinAboveMax, error_GroupMinAboveMax;
   abort$(errorcheck_level = 2) "A minimum bound exceeds its maximum counterpart, making the model infeasible.";
);

* Check if an annual emission limit lies below the exogenous emission floor
parameter error_EmissionLimitBelowExogenous(*,e,y_full);
error_EmissionLimitBelowExogenous('Global',e,y)$(AnnualEmissionLimit(e,y) > 0 and AnnualEmissionLimit(e,y) < 999999 and sum(r,AnnualExogenousEmission(r,e,y)) > AnnualEmissionLimit(e,y)) = 1;
error_EmissionLimitBelowExogenous(r,e,y)$(RegionalAnnualEmissionLimit(r,e,y) > 0 and RegionalAnnualEmissionLimit(r,e,y) < 999999 and AnnualExogenousEmission(r,e,y) > RegionalAnnualEmissionLimit(r,e,y)) = 1;
if(sum((e,y),error_EmissionLimitBelowExogenous('Global',e,y))+sum((r,e,y),error_EmissionLimitBelowExogenous(r,e,y)),
   display error_EmissionLimitBelowExogenous;
   abort$(errorcheck_level = 2) "An AnnualEmissionLimit is below the exogenous emissions and cannot be met.";
);

* Check if the SpecifiedDemandProfile sums to 1 over the timeslices for a demanded fuel
parameter error_DemandProfileNotNormalized(r_full,f,y_full);
error_DemandProfileNotNormalized(r,f,y)$(SpecifiedAnnualDemand(r,f,y) and round(sum(l_full,SpecifiedDemandProfile(r,f,l_full,y)),3) <> 0 and round(sum(l_full,SpecifiedDemandProfile(r,f,l_full,y)),3) <> 1) = 1;
if(sum((r,f,y),error_DemandProfileNotNormalized(r,f,y)),
   display error_DemandProfileNotNormalized;
   abort$(errorcheck_level = 2) "SpecifiedDemandProfile does not sum to 1 over the timeslices for a demanded fuel.";
);

* Check if YearSplit sums to 1 over the timeslices
parameter error_YearSplitNotNormalized(y_full);
error_YearSplitNotNormalized(y)$(round(sum(l_full,YearSplit(l_full,y)),6) <> 1) = 1;
if(sum(y,error_YearSplitNotNormalized(y)),
   display error_YearSplitNotNormalized;
   abort$(errorcheck_level = 2) "YearSplit does not sum to 1 over the timeslices.";
);

* Check for inconsistent storage charge or discharge links
parameter error_StorageLinkOrphan(s,*);
error_StorageLinkOrphan(s,'ChargeableNotDischargeable')$(sum((t,m,y),TechnologyToStorage(t,s,m,y)) and not sum((t,m,y),TechnologyFromStorage(t,s,m,y))) = 1;
error_StorageLinkOrphan(s,'DischargeableNotChargeable')$(not sum((t,m,y),TechnologyToStorage(t,s,m,y)) and sum((t,m,y),TechnologyFromStorage(t,s,m,y))) = 1;
error_StorageLinkOrphan(s,'OperationalLifeStorageMissing')$((sum((t,m,y),TechnologyToStorage(t,s,m,y)) or sum((t,m,y),TechnologyFromStorage(t,s,m,y))) and not OperationalLifeStorage(s)) = 1;
if(sum(s,error_StorageLinkOrphan(s,'ChargeableNotDischargeable')+error_StorageLinkOrphan(s,'DischargeableNotChargeable')+error_StorageLinkOrphan(s,'OperationalLifeStorageMissing')),
   display error_StorageLinkOrphan;
   abort$(errorcheck_level = 2) "Inconsistent storage charge or discharge links, or a missing OperationalLifeStorage. Please check Par_TechnologyToStorage and Par_TechnologyFromStorage.";
);

* Check for negative values in physically nonnegative parameters
set NonNegativeParameter / CapitalCost, FixedCost, VariableCost, SpecifiedAnnualDemand, ResidualCapacity, TotalAnnualMaxCapacity, TotalAnnualMinCapacity, AnnualMinNewCapacity, AnnualMaxNewCapacity, CapacityFactor, AvailabilityFactor, OperationalLife, CapitalCostStorage, ResidualStorageCapacity, CapacityToActivityUnit /;
parameter error_NegativeValues(NonNegativeParameter);
error_NegativeValues('CapitalCost')$(smin((r,t,y),CapitalCost(r,t,y)) < 0) = 1;
error_NegativeValues('FixedCost')$(smin((r,t,y),FixedCost(r,t,y)) < 0) = 1;
error_NegativeValues('VariableCost')$(smin((r,t,m,y),VariableCost(r,t,m,y)) < 0) = 1;
error_NegativeValues('SpecifiedAnnualDemand')$(smin((r,f,y),SpecifiedAnnualDemand(r,f,y)) < 0) = 1;
error_NegativeValues('ResidualCapacity')$(smin((r,t,y),ResidualCapacity(r,t,y)) < 0) = 1;
error_NegativeValues('TotalAnnualMaxCapacity')$(smin((r,t,y),TotalAnnualMaxCapacity(r,t,y)) < 0) = 1;
error_NegativeValues('TotalAnnualMinCapacity')$(smin((r,t,y),TotalAnnualMinCapacity(r,t,y)) < 0) = 1;
error_NegativeValues('AnnualMinNewCapacity')$(smin((r,t,y),AnnualMinNewCapacity(r,t,y)) < 0) = 1;
error_NegativeValues('AnnualMaxNewCapacity')$(smin((r,t,y),AnnualMaxNewCapacity(r,t,y)) < 0) = 1;
error_NegativeValues('CapacityFactor')$(smin((r,t,l,y),CapacityFactor(r,t,l,y)) < 0) = 1;
error_NegativeValues('AvailabilityFactor')$(smin((r,t,y),AvailabilityFactor(r,t,y)) < 0) = 1;
error_NegativeValues('OperationalLife')$(smin(t,OperationalLife(t)) < 0) = 1;
error_NegativeValues('CapitalCostStorage')$(smin((r,s,y),CapitalCostStorage(r,s,y)) < 0) = 1;
error_NegativeValues('ResidualStorageCapacity')$(smin((r,s,y),ResidualStorageCapacity(r,s,y)) < 0) = 1;
error_NegativeValues('CapacityToActivityUnit')$(smin(t,CapacityToActivityUnit(t)) < 0) = 1;
if(sum(NonNegativeParameter,error_NegativeValues(NonNegativeParameter)),
   display error_NegativeValues;
   abort$(errorcheck_level = 2) "Negative entries found in physically nonnegative parameters.";
);

* Check the base-year residual fleet against the group capacity cone
parameter error_BaseYearGroupCapacityCone(*,*,*);
error_BaseYearGroupCapacityCone(tg,rg,'ResidualBelowGroupMin')$(GroupTotalAnnualMinCapacity(tg,rg,'%year%') > 0 and sum((t,r)$(TagTechnologyToSubsets(t,tg) and TagRegionToSubsets(r,rg)),ResidualCapacity(r,t,'%year%')) < GroupTotalAnnualMinCapacity(tg,rg,'%year%')) = 1;
error_BaseYearGroupCapacityCone(tg,rg,'ResidualAboveGroupMax')$(GroupTotalAnnualMaxCapacity(tg,rg,'%year%') < 999999 and sum((t,r)$(TagTechnologyToSubsets(t,tg) and TagRegionToSubsets(r,rg)),ResidualCapacity(r,t,'%year%')) > GroupTotalAnnualMaxCapacity(tg,rg,'%year%')) = 1;
if(sum((tg,rg),error_BaseYearGroupCapacityCone(tg,rg,'ResidualBelowGroupMin')+error_BaseYearGroupCapacityCone(tg,rg,'ResidualAboveGroupMax')),
   display error_BaseYearGroupCapacityCone;
   abort$(errorcheck_level = 2) "Summed ResidualCapacity in the start year lies outside the group capacity cone, making the model infeasible.";
);


**************************************************************
*********************   WARNING BLOCK   **********************
**************************************************************

* Warning if AvailabilityFactor is missing for a Technology with ResidualCapacity
parameter warning_AvailabilityFactorMissing(r_full,t,y_full);
warning_AvailabilityFactorMissing(r,t,y)$(ResidualCapacity(r,t,y) and not AvailabilityFactor(r,t,y)) = 1;
if(sum((r,t,y),warning_AvailabilityFactorMissing(r,t,y)),
   display "WARNING: AvailabilityFactor is missing for a Technology with ResidualCapacity. Please check Par_AvailabilityFactor.", warning_AvailabilityFactorMissing;
);

* Warning if a Technology efficiency is above 1 outside the Resources and Transportation sectors
parameter warning_TechnologyEfficiencies(r_full,t,m,y_full);
warning_TechnologyEfficiencies(r,t,m,y)$(not sum(se,TagTechnologyToSector(t,'Resources')) and not sum(se,TagTechnologyToSector(t,'Transportation')) and sum(f,OutputActivityRatio(r,t,f,m,y)) and ((sum(f,InputActivityRatio(r,t,f,m,y))/sum(f,OutputActivityRatio(r,t,f,m,y)))<1)$(sum(f,OutputActivityRatio(r,t,f,m,y)) and sum(f,InputActivityRatio(r,t,f,m,y)))) = 1;
if(sum((r,t,m,y),warning_TechnologyEfficiencies(r,t,m,y)),
   display "WARNING: A Technology efficiency is above 1 (input sum below output sum) outside Resources and Transportation.", warning_TechnologyEfficiencies;
);

* Warning if ResidualCapacity exceeds TotalAnnualMaxCapacity
parameter warning_ResidualAboveMaxCapacity(r_full,t,y_full);
warning_ResidualAboveMaxCapacity(r,t,y)$(TotalAnnualMaxCapacity(r,t,y) < 999999 and ResidualCapacity(r,t,y) > TotalAnnualMaxCapacity(r,t,y)) = 1;
if(sum((r,t,y),warning_ResidualAboveMaxCapacity(r,t,y)),
   display "WARNING: ResidualCapacity exceeds TotalAnnualMaxCapacity. The capacity bound will clip existing capacity.", warning_ResidualAboveMaxCapacity;
);

* Warning if demand is set in the start year but zero in a later year
parameter warning_DemandYearGap(r_full,f,y_full);
warning_DemandYearGap(r,f,y)$(SpecifiedAnnualDemand(r,f,'%year%') and YearVal(y) > %year% and not SpecifiedAnnualDemand(r,f,y)) = 1;
if(sum((r,f,y),warning_DemandYearGap(r,f,y)),
   display "WARNING: Demand is set in the start year but zero in a later year. Missing per-year rows are silently zero.", warning_DemandYearGap;
);

* Warning if a TradeRoute is defined in one direction only
parameter warning_AsymmetricTradeRoute(r_full,rr_full,f);
warning_AsymmetricTradeRoute(r,rr,f)$(TagCanFuelBeTraded(f) and not sameas(r,rr) and sum(y,TradeRoute(r,f,y,rr)) and not sum(y,TradeRoute(rr,f,y,r))) = 1;
if(sum((r,rr,f),warning_AsymmetricTradeRoute(r,rr,f)),
   display "WARNING: A TradeRoute is defined in one direction only. Please check Par_TradeRoute for the reverse direction.", warning_AsymmetricTradeRoute;
);

* Warning if share-type parameters contain values above 1
set ShareParameter / AvailabilityFactor, CapacityFactor, MinStorageCharge, ModalSplit /;
parameter warning_ShareAboveOne(ShareParameter);
warning_ShareAboveOne('AvailabilityFactor')$(smax((r,t,y),AvailabilityFactor(r,t,y)) > 1) = 1;
warning_ShareAboveOne('CapacityFactor')$(smax((r,t,l,y),CapacityFactor(r,t,l,y)) > 1) = 1;
warning_ShareAboveOne('MinStorageCharge')$(smax((r,s,y),MinStorageCharge(r,s,y)) > 1) = 1;
warning_ShareAboveOne('ModalSplit')$(smax((r,f,mt,y),ModalSplitByFuelAndModalType(r,f,mt,y)) > 1) = 1;
if(sum(ShareParameter,warning_ShareAboveOne(ShareParameter)),
   display "WARNING: Share-type parameters contain values above 1.", warning_ShareAboveOne;
);

* Warning if a REMinProductionTarget exists without any RE-tagged technology producing the fuel
parameter warning_RETargetWithoutRETech(r_full,f,y_full);
warning_RETargetWithoutRETech(r,f,y)$(REMinProductionTarget(r,f,y) > 0 and not sum(t$(RETagTechnology(t,y)),sum(m,OutputActivityRatio(r,t,f,m,y)))) = 1;
if(sum((r,f,y),warning_RETargetWithoutRETech(r,f,y)),
   display "WARNING: REMinProductionTarget is set but no RE-tagged technology produces the fuel in the region.", warning_RETargetWithoutRETech;
);

* Warning for capacity data given to a technology that has no activity ratio anywhere
parameter warning_DeadCapacity(t,*);
warning_DeadCapacity(t,'ResidualCapacitySet')$(not sum((r,f,m,y),OutputActivityRatio(r,t,f,m,y)+InputActivityRatio(r,t,f,m,y)) and sum((r,y),ResidualCapacity(r,t,y)) and not DummyTechnology(t)) = 1;
warning_DeadCapacity(t,'MaxCapacitySet')$(not sum((r,f,m,y),OutputActivityRatio(r,t,f,m,y)+InputActivityRatio(r,t,f,m,y)) and sum((r,y)$(TotalAnnualMaxCapacity(r,t,y) < 999999),TotalAnnualMaxCapacity(r,t,y)) and not DummyTechnology(t)) = 1;
if(sum(t,warning_DeadCapacity(t,'ResidualCapacitySet')+warning_DeadCapacity(t,'MaxCapacitySet')),
   display "WARNING: Capacity data is given for a technology that has no input or output activity ratio anywhere.", warning_DeadCapacity;
);

$endif.errorcheck
