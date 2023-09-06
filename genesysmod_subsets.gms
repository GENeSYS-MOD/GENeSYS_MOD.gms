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


set PowerSupply(t);
PowerSupply(t) = no;
PowerSupply('Res_Wind_Offshore_Deep') = yes;
PowerSupply('Res_Wind_Offshore_Shallow') = yes;
PowerSupply('Res_Wind_Offshore_Transitional') = yes;
PowerSupply('Res_Wind_Onshore_opt') = yes;
PowerSupply('Res_Wind_Onshore_avg') = yes;
PowerSupply('Res_Wind_Onshore_inf') = yes;
PowerSupply('Res_PV_Rooftop_Residential') = yes;
PowerSupply('Res_PV_Rooftop_commercial') = yes;
PowerSupply('Res_PV_utility_opt') = yes;
PowerSupply('Res_PV_utility_avg') = yes;
PowerSupply('Res_PV_utility_inf') = yes;
PowerSupply('RES_PV_Utility_Tracking') = yes;
PowerSupply('Res_CSP') = yes;
PowerSupply('Res_Geothermal') = yes;
PowerSupply('Res_Hydro_Small') = yes;
PowerSupply('Res_Hydro_Large') = yes;
PowerSupply('Res_Ocean') = yes;
PowerSupply('P_Coal_Hardcoal') = yes;
PowerSupply('P_Coal_Lignite') = yes;
PowerSupply('P_Nuclear') = yes;
PowerSupply('P_Oil') = yes;
PowerSupply('P_Biomass') = yes;
PowerSupply('P_Biomass_CCS') = yes;
PowerSupply('P_Coal_Lignite_CCS') = yes;
PowerSupply('P_Coal_Hardcoal_CCS') = yes;
PowerSupply('P_Gas_CCS') = yes;
PowerSupply('P_H2_OCGT') = yes;
PowerSupply('P_Gas_CCGT') = yes;
PowerSupply('P_Gas_OCGT') = yes;
PowerSupply('P_Gas_Engines') = yes;

set PowerBiomass(t);
PowerBiomass(t) = no;
PowerBiomass('P_Biomass') = yes;
PowerBiomass('P_Biomass_CCS') = yes;
PowerBiomass('CHP_Biomass_Solid') = yes;
PowerBiomass('CHP_Biomass_Solid_CCS') = yes;

set Coal(t);
Coal(t) = no;
Coal('P_Coal_Hardcoal') = yes;
Coal('P_Coal_Lignite') = yes;
Coal('HLR_Hardcoal') = yes;
Coal('HLR_Lignite') = yes;
Coal('HLI_Hardcoal') = yes;
Coal('HLI_Lignite') = yes;
Coal('HMI_HardCoal') = yes;
Coal('HHI_BF_BOF') = yes;
Coal('HHI_BF_BOF_CCS') = yes;
Coal('HMI_HardCoal_CCS') = yes;
Coal('P_Coal_Hardcoal_CCS') = yes;
Coal('P_Coal_Lignite_CCS') = yes;
Coal('CHP_Coal_Hardcoal') = yes;
Coal('CHP_Coal_Lignite') = yes;
Coal('CHP_Coal_Hardcoal_CCS') = yes;
Coal('CHP_Coal_Lignite_CCS') = yes;
Coal('CHP_Coal_Lignite') = yes;
Coal('CHP_Coal_Lignite_CCS') = yes;

set Lignite(t);
Lignite(t) = no;
Lignite('P_Coal_Lignite') = yes;
Lignite('HLR_Lignite') = yes;
Lignite('HLI_Lignite') = yes;
Lignite('P_Coal_Lignite_CCS') = yes;



set Gas(t);
Gas(t) = no;
Gas('HLR_Gas_Boiler') = yes;
Gas('HLI_Gas_Boiler') = yes;
Gas('HMI_Gas') = yes;
Gas('HHI_DRI_EAF') = yes;
Gas('HHI_DRI_EAF_CCS') = yes;
Gas('HMI_Gas_CCS') = yes;
Gas('P_Gas_CCS') = yes;
Gas('P_Gas_CCGT') = yes;
Gas('P_Gas_OCGT') = yes;
Gas('P_Gas_Engines') = yes;
Gas('CHP_Gas_CCGT_Natural') = yes;
Gas('CHP_Gas_CCGT_Biogas') = yes;
Gas('CHP_Gas_CCGT_SynGas') = yes;
Gas('CHP_Gas_CCGT_Natural_CCS') = yes;
Gas('CHP_Gas_CCGT_Biogas_CCS') = yes;


set SectorCoupling(t);
SectorCoupling(t) = no;
SectorCoupling('X_FUEL_CELL') = yes;
SectorCoupling('X_Electrolysis') = yes;
SectorCoupling('X_Methanation') = yes;
SectorCoupling('HLI_Fuelcell') = yes;
SectorCoupling('X_SMR') = yes;
SectorCoupling('X_SMR_CCS') = yes;
SectorCoupling('X_Biofuel') = yes;
SectorCoupling('X_Powerfuel') = yes;
SectorCoupling('P_H2_OCGT') = yes;

set HeatFuels(f);
HeatFuels(f) = no;
HeatFuels('Heat_Low_Industrial') = yes;
HeatFuels('Heat_Medium_Industrial') = yes;
HeatFuels('Heat_High_Industrial') = yes;
HeatFuels('Heat_Low_Residential')  = yes;

set ModalGroups(mt);
ModalGroups(mt) = no;
ModalGroups('MT_PSNG_ROAD') = yes;
ModalGroups('MT_PSNG_RAIL') = yes;
ModalGroups('MT_PSNG_AIR') = yes;
ModalGroups('MT_FRT_ROAD') = yes;
ModalGroups('MT_FRT_RAIL') = yes;
ModalGroups('MT_FRT_SHIP') = yes;


Set HeatSlowRamper(t);
HeatSlowRamper(t) = no;
HeatSlowRamper('HLR_Oil_Boiler') = yes;
HeatSlowRamper('HLI_Oil_Boiler') = yes;
HeatSlowRamper('HHI_BF_BOF') = yes;
HeatSlowRamper('HHI_DRI_EAF') = yes;
HeatSlowRamper('HHI_Scrap_EAF') = yes;
HeatSlowRamper('HHI_H2DRI_EAF') = yes;
HeatSlowRamper('HHI_Molten_Electrolysis') = yes;
HeatSlowRamper('HHI_Bio_BF_BOF') = yes;
HeatSlowRamper('HHI_BF_BOF_CCS') = yes;
HeatSlowRamper('HHI_DRI_EAF_CCS') = yes;


Set HeatQuickRamper(t);
HeatQuickRamper(t) = no;
HeatQuickRamper('HLR_Hardcoal') = yes;
HeatQuickRamper('HLR_Lignite') = yes;
HeatQuickRamper('HLR_Biomass') = yes;
HeatQuickRamper('HLR_Gas_Boiler') = yes;
HeatQuickRamper('HLR_Direct_Electric') = yes;
HeatQuickRamper('HLR_H2_Boiler') = yes;
HeatQuickRamper('HLI_Hardcoal') = yes;
HeatQuickRamper('HLI_Lignite') = yes;
HeatQuickRamper('HLI_Biomass') = yes;
HeatQuickRamper('HLI_Gas_Boiler') = yes;
HeatQuickRamper('HLI_Direct_Electric') = yes;
HeatQuickRamper('HLI_H2_Boiler') = yes;
HeatQuickRamper('HMI_Gas') = yes;
HeatQuickRamper('HMI_Steam_Electric') = yes;
HeatQuickRamper('HMI_Gas_CCS') = yes;
HeatQuickRamper('HMI_Biomass') = yes;
HeatQuickRamper('HMI_HardCoal') = yes;
HeatQuickRamper('HMI_Oil') = yes;
HeatQuickRamper('HMI_HardCoal_CCS') = yes;

set Hydro(t);
Hydro(t) = no;
Hydro('Res_Hydro_large') = yes;
Hydro('Res_Hydro_small') = yes;

set Onshore(t);
Onshore(t) = no;
Onshore('Res_Wind_Onshore_opt') = yes;
Onshore('Res_Wind_Onshore_avg') = yes;
Onshore('Res_Wind_Onshore_inf') = yes;

set Offshore(t);
Offshore(t) = no;
Offshore('Res_Wind_Offshore_Deep') = yes;
Offshore('Res_Wind_Offshore_Shallow') = yes;
Offshore('Res_Wind_Offshore_Transitional') = yes;

set Oil(t);
Oil(t) = no;
Oil('P_Oil') = yes;
Oil('HMI_Oil') = yes;
Oil('HLI_Oil_Boiler') = yes;
Oil('HLR_Oil_Boiler') = yes;
Oil('CHP_Oil') = yes;


Set Biomass(t);
Biomass(t) = no;
Biomass('RES_Grass') = yes;
Biomass('RES_Wood') = yes;
Biomass('RES_Residues') = yes;
Biomass('RES_Paper_Cardboard') = yes;
Biomass('RES_Roundwood') = yes;
Biomass('RES_Biogas') = yes;


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
