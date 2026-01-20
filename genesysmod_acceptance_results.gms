* ###################### genesysmod_acceptance_results.gms #######################
*
* GENeSYS-MOD v3.1 [Global Energy System Model]  ~ March 2022
*
* Based on OSEMOSYS 2011.07.07 conversion to GAMS by Ken Noble, Noble-Soft Systems - August 2012
*
* Updated to newest OSeMOSYS-Version (2016.08) and further improved with additional equations 2016 - 2022
* by Konstantin L�ffler, Thorsten Burandt, Karlo Hainsch
*
* #############################################################
*
* Copyright 2020 Technische Universit�t Berlin and DIW Berlin
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


Parameter AverageYearlyAcceptancePerRegion(r_full,y_full);
AverageYearlyAcceptancePerRegion(r,y)$(TotalNCapacityperRegion.l(r,y) > 0) = (TotalAcceptanceperRegion.l(r,y)+TotalAcceptanceperRegion_PowerLines.l(r,y))/(TotalNCapacityperRegion.l(r,y)+TotalNCapacityperRegion_PowerLines.l(r,y));

Parameter AverageYearlyAcceptance(y_full);
AverageYearlyAcceptance(y)$(TotalNCapacity.l(y) > 0) = (TotalAcceptance.l(y)+TotalAcceptance_PowerLines.l(y))/(TotalNCapacity.l(y)+TotalNCapacity_PowerLines.l(y));

Parameter ShareofTotalAcceptanceperRegion(r_full,y_Full);
ShareofTotalAcceptanceperRegion(r,y)$(TotalAcceptance.l(y) > 0) = (TotalAcceptanceperRegion.l(r,y)+TotalAcceptanceperRegion_PowerLines.l(r,y))/(TotalAcceptance.l(y)+TotalAcceptance_PowerLines.l(y))

Parameter ShareofNCapacity(r_full,y_Full);
ShareofNCapacity(r,y)$(TotalNCapacity.l(y) > 0) = (TotalNCapacityperRegion.l(r,y)+TotalNCapacityperRegion_PowerLines.l(r,y))/(TotalNCapacity.l(y)+TotalNCapacity_PowerLines.l(y))

*######AcceptanceFactor
execute_unload "%gdxdir%Acceptance_%model_region%_%emissionPathway%_%emissionScenario%.gdx"
Acceptance
Acceptance_Powerlines
TotalAcceptanceperRegion
TotalAcceptanceperRegion_Powerlines
TotalAcceptance
TotalAcceptance_Powerlines
TotalNCapacityperRegion
TotalNCapacityperRegion_Powerlines
TotalNCapacity
TotalNCapacity_Powerlines
AverageYearlyAcceptance
AverageYearlyAcceptancePerRegion
ShareofTotalAcceptanceperRegion
ShareofNCapacity
Z
;

$onecho >%tempdir%temp_%Acceptance_data_file%.tmp
se=0   
    var=Acceptance                            Rng=Acceptance!A1     rdim=3        cdim=0
    text="Region"                             Rng=Acceptance!A1
    text="Technology"                         Rng=Acceptance!B1
    text="Year"                               Rng=Acceptance!C1
    text="Acceptance"                         Rng=Acceptance!D1
    
    var=Acceptance_Powerlines                 Rng=Acceptance_Powerlines!A1     rdim=4        cdim=0
    text="Region"                             Rng=Acceptance_Powerlines!B1
    text="Region_2"                           Rng=Acceptance_Powerlines!C1
    text="Fuel"                               Rng=Acceptance_Powerlines!D1
    text="Year"                               Rng=Acceptance_Powerlines!E1
    text="Acceptance"                         Rng=Acceptance_Powerlines!F1

    var=TotalAcceptanceperRegion              Rng=TotalAcceptanceperRegion!A1     rdim=2        cdim=0
    text="Region"                             Rng=TotalAcceptanceperRegion!A1
    text="Year"                               Rng=TotalAcceptanceperRegion!B1
    text="TotalAcceptanceperRegion"           Rng=TotalAcceptanceperRegion!C1
    
    var=TotalAcceptanceperRegion_Powerlines   Rng=TotalAcceptanceperRegion_P!A1     rdim=2        cdim=0
    text="Region"                             Rng=TotalAcceptanceperRegion_P!B1
    text="Year"                               Rng=TotalAcceptanceperRegion_P!C1
    text="TotalAcceptanceperRegion"           Rng=TotalAcceptanceperRegion_P!D1
    
    var=TotalAcceptance                       Rng=TotalAcceptance!A1     rdim=1        cdim=0
    text="Year"                               Rng=TotalAcceptance!A1
    text="TotalAcceptance"                    Rng=TotalAcceptance!B1
    
    var=TotalAcceptance_Powerlines            Rng=TotalAcceptance_Powerlines!A1     rdim=1        cdim=0
    text="Year"                               Rng=TotalAcceptance_Powerlines!A1
    text="TotalAcceptance"                    Rng=TotalAcceptance_Powerlines!B1


    var=TotalNCapacityperRegion               Rng=TotalNCapacityperRegion!A1     rdim=2        cdim=0
    text="Region"                             Rng=TotalNCapacityperRegion!A1
    text="Year"                               Rng=TotalNCapacityperRegion!B1
    text="TotalNCapacityperRegion"            Rng=TotalNCapacityperRegion!C1
    
    var=TotalNCapacityperRegion_Powerlines    Rng=TotalNCapacityperRegion_P!A1     rdim=2        cdim=0
    text="Region"                             Rng=TotalNCapacityperRegion_P!A1
    text="Year"                               Rng=TotalNCapacityperRegion_P!B1
    text="TotalNCapacityperRegion"            Rng=TotalNCapacityperRegion_P!C1
        
    var=TotalNCapacity                        Rng=TotalNCapacity!A1     rdim=1        cdim=0
    text="Year"                               Rng=TotalNCapacity!A1
    text="TotalNCapacity"                     Rng=TotalNCapacity!B1
    
    var=TotalNCapacity_Powerlines             Rng=TotalNCapacity!A1     rdim=1        cdim=0
    text="Year"                               Rng=TotalNCapacity!A1
    text="TotalNCapacity"                     Rng=TotalNCapacity!B1
    
    par=AverageYearlyAcceptance               Rng=AverageYearlyAcceptance!A1     rdim=1        cdim=0
    text="Year"                               Rng=AverageYearlyAcceptance!A1
    text="AverageYearlyAcceptance"            Rng=AverageYearlyAcceptance!B1
    
    par=AverageYearlyAcceptancePerRegion      Rng=AvgYearlyAcceptancePerRegion!A1     rdim=2        cdim=0
    text="Region"                             Rng=AvgYearlyAcceptancePerRegion!A1
    text="Year"                               Rng=AvgYearlyAcceptancePerRegion!B1
    text="AverageYearlyAcceptancePerRegion"   Rng=AvgYearlyAcceptancePerRegion!C1
    
    par=ShareofTotalAcceptanceperRegion       Rng=ShareofTotalAcceptanceperRegion!A1     rdim=2        cdim=0
    text="Region"                             Rng=ShareofTotalAcceptanceperRegion!A1
    text="Year"                               Rng=ShareofTotalAcceptanceperRegion!B1
    text="ShareofTotalAcceptanceperRegion"    Rng=ShareofTotalAcceptanceperRegion!C1
    
    par=ShareofNCapacity                      Rng=ShareofNCapacity!A1     rdim=2        cdim=0
    text="Region"                             Rng=ShareofNCapacity!A1
    text="Year"                               Rng=ShareofNCapacity!B1
    text="ShareofNCapacity"                   Rng=ShareofNCapacity!C1

$offecho

execute 'gdxxrw.exe i=%gdxdir%Acceptance_%model_region%_%emissionPathway%_%emissionScenario%.gdx UpdLinks=3 o=%resultdir%Acceptance_Results_%model_region%_%emissionPathway%_%emissionScenario%.xlsx @%tempdir%temp_%Acceptance_data_file%.tmp';


$endif