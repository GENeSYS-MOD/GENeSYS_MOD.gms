* ###################### genesysmod_subsets.gms #######################
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


set ModalGroups(mt);
ModalGroups(mt) = no;
ModalGroups('MT_PSNG_ROAD') = yes;
ModalGroups('MT_PSNG_RAIL') = yes;
ModalGroups('MT_PSNG_AIR') = yes;
ModalGroups('MT_FRT_ROAD') = yes;
ModalGroups('MT_FRT_RAIL') = yes;
ModalGroups('MT_FRT_SHIP') = yes;



set Households(t);
Households(t) = no;
Households('RES_PV_Rooftop_Residential') = yes;
Households('HLR_Gas_Boiler') = yes;
Households('HLR_Biomass') = yes;
Households('HLR_Hardcoal') = yes;
Households('HLR_Direct_Electric') = yes;
Households('HLR_Solar_Thermal') = yes;
Households('HLR_Heatpump_Aerial') = yes;
Households('HLR_Heatpump_Ground') = yes;
Households('HLR_Oil_Boiler') = yes;


set Companies(t);
Companies(t) = yes;
Companies('RES_PV_Rooftop_Residential') = no;
Companies('HLR_Gas_Boiler') = no;
Companies('HLR_Biomass') = no;
Companies('HLR_Hardcoal') = no;
Companies('HLR_Direct_Electric') = no;
Companies('HLR_Solar_Thermal') = no;
Companies('HLR_Heatpump_Aerial') = no;
Companies('HLR_Heatpump_Ground') = no;
Companies('HLR_Oil_Boiler') = no;


set HydrogenTechnologies(t);
HydrogenTechnologies(t) = no;
HydrogenTechnologies('HLI_H2_Boiler') = yes;
HydrogenTechnologies('HMI_H2') = yes;
HydrogenTechnologies('P_H2_OCGT') = yes;
