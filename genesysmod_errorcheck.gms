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

**************************************************************
****************   ERROR HANDLING BLOCK   ********************
**************************************************************

* Check if Technologies are missing from the Sector list -> if yes, then exit
parameter error_TechMissingFromSectorList(TECHNOLOGY);
error_TechMissingFromSectorList(t)$(not sum(se,TagTechnologyToSector(t,se))) = 1;
if(sum(t,error_TechMissingFromSectorList(t)),abort "Technology missing from Sector list. Please check TagTechnologyToSector to include all Technologies. Missing Technologies are listed in the parameter error_TechMissingFromSectorList.");

* Check if TradeCosts are missing from a defined TradeRoute -> if yes, then exit
parameter error_TradeCostsMissingFromTradeRoute(r_full,f,rr_full);
error_TradeCostsMissingFromTradeRoute(r,f,rr)$(sum(y,TradeRoute(r,f,y,rr)) and TagCanFuelBeTraded(f) and not sum(y,TradeCosts(r,f,y,rr))) = 1;
if(sum((f,r,rr),error_TradeCostsMissingFromTradeRoute(r,f,rr)),abort "TradeCosts are missing from a defined TradeRoute. Please check your TradeCosts to include all defined TradeRoutes. Missing TradeCosts are listed in the parameter error_TradeCostsMissingFromTradeRoute.");

* Check for errors in ModalSplit definitions -> if yes, then exit
parameter error_ModalSplitByModalTypeDefinition(f,*,r_full,y_full);
error_ModalSplitByModalTypeDefinition(f,'Error in ModalGroup',r,y)$(round(sum(mt$(TagModalTypeToModalGroups(mt,'TransportModes')),ModalSplitByFuelAndModalType(r,f,mt,y)),4)>1) = 1;
error_ModalSplitByModalTypeDefinition(f,'Error in SubGroup',r,y)$(round(sum(mt$(TagModalTypeToModalGroups(mt,'ModalSubgroups')),ModalSplitByFuelAndModalType(r,f,mt,y)),4)>1) = 1;
if(sum((f,r,y),error_ModalSplitByModalTypeDefinition(f,'Error in ModalGroup',r,y)),abort "ModalSplit is wrongly defined for a ModalGroup (e.g., MT_FRT_Road). The sum of ModalTypes cannot exceed 1. Please check your data. Problematic regions and years are listed in the parameter error_ModalSplitByModalTypeDefinition.");
if(sum((f,r,y),error_ModalSplitByModalTypeDefinition(f,'Error in SubGroup',r,y)),abort "ModalSplit is wrongly defined for a subgroup in the ModalSplit (e.g., MT_FRT_Road_RE). The sum of ModalTypes cannot exceed 1. Please check your data. Problematic regions and years are listed in the parameter error_ModalSplitByModalTypeDefinition.");

* Check for errors in OperationalLife data -> if yes, then exit
parameter error_OperationalLifeMissing(t);
$ifthen %switch_infeasibility_tech% == 0
error_OperationalLifeMissing(t)$(not OperationalLife(t) and not TagTechnologyToSector(t,'Infeasibility')) = 1;
$else
error_OperationalLifeMissing(t)$(not OperationalLife(t)) = 1;
$endif
if(sum((t),error_OperationalLifeMissing(t)),abort "OperationalLife is missing from a Technology. Please check your OperationalLife data to account for all technologies. Missing values are listed in the parameter error_OperationalLifeMissing.");

* Check for errors in CapacityFactor data -> if yes, then exit
parameter error_CapacityFactorDataMissing(r_full,t,y_full);
error_CapacityFactorDataMissing(r,t,y)$(not sum(l,CapacityFactor(r,t,l,y)) and AvailabilityFactor(r,t,y) and TotalAnnualMaxCapacity(r,t,y)) = 1;
if(sum((r,t,y),error_CapacityFactorDataMissing(r,t,y)),abort "CapacityFactor is missing from a Technology. Please check your Hourly data file to account for all technologies. Technologies where values are missing are listed in the parameter error_CapacityFactorDataMissing.");

* Check for missing entries in CapacityToActivityUnit -> if yes, then exit
parameter error_CapacityToActivityUnitDataMissing(r_full,t);
error_CapacityToActivityUnitDataMissing(r,t)$(sum(y,AvailabilityFactor(r,t,y)) and not CapacityToActivityUnit(t)) = 1;
if(sum((r,t),error_CapacityToActivityUnitDataMissing(r,t)),abort "CapacityToActivityUnit is missing from a Technology. Please check your CapacityToActivityUnit data in Excel to account for all technologies. Technologies where values are missing are listed in the parameter error_CapacityToActivityUnitDataMissing.");

* Check for errors in TradeRoutes, if they have a capacity given
parameter error_TradeCapacityMismatch(*,r_full,f,y_full,rr_full);
error_TradeCapacityMismatch('TradeCapacity',r,f,y,rr)$(TradeCapacity(r,f,y,rr) and not TradeRoute(r,f,y,rr))  = 1;
error_TradeCapacityMismatch('CommissionedTradeCapacity',r,f,y,rr)$(CommissionedTradeCapacity(r,f,y,rr) and not TradeRoute(r,f,y,rr))  = 1;
if(sum((r,f,y,rr),error_TradeCapacityMismatch('TradeCapacity',r,f,y,rr)+error_TradeCapacityMismatch('CommissionedTradeCapacity',r,f,y,rr)),abort "TradeRoute is missing for some trade connections where a TradeCapacity has been set. Please check your TradeRoute and TradeCapacity data in Excel. Technologies where values are missing are listed in the parameter error_TradeCapacityMismatch.");

* Check for missing entries in AvailabilityFactor -> if yes, then exit
parameter error_AvailabilityFactorMissing(r_full,t,y_full);
error_AvailabilityFactorMissing(r,t,y)$(ResidualCapacity(r,t,y) and not AvailabilityFactor(r,t,y)) = 1;
if(sum((r,t,y),error_AvailabilityFactorMissing(r,t,y)),display "WARNING: AvailabilityFactor is missing from a Technology. Please check your AvailabilityFactor data in Excel to account for all technologies. Technologies where values are missing are listed in the parameter error_AvailabilityFactorMissing.");



**************************************************************
*********************   WARNING BLOCK   **********************
**************************************************************

parameter warning_TechnologyEfficiencies(r_full,t,m,y_full);
warning_TechnologyEfficiencies(r,t,m,y)$(not sum(se,TagTechnologyToSector(t,'Resources')) and not sum(se,TagTechnologyToSector(t,'Transportation')) and sum(f,OutputActivityRatio(r,t,f,m,y)) and ((sum(f,InputActivityRatio(r,t,f,m,y))/sum(f,OutputActivityRatio(r,t,f,m,y)))<1)$(sum(f,OutputActivityRatio(r,t,f,m,y)) and sum(f,InputActivityRatio(r,t,f,m,y)))) = 1;

parameter error_tradelines(r_full,rr_full,f);
error_tradelines(r,rr,f)$(TradeRoute(r,f,'2018',rr)-TradeRoute(r,f,'2018',rr))=1

* If residual capacity is greater than max allowed annual capacity, set max capacity to residual capacity
parameter ToSmallResidualCapacity;
ToSmallResidualCapacity(r,t,y)$(ResidualCapacity(r,t,y) > TotalAnnualMaxCapacity(r,t,y)) = ResidualCapacity(r,t,y);
