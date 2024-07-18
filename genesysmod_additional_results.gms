parameters
SelfSufficiencyRate
ElectrificationRate
additional_capacity
additional_production
additional_emissions
additional_costs
additional_other
;

Set FinalEnergy(f);
FinalEnergy(f) = no;
FinalEnergy('Power') = yes;
FinalEnergy('Biomass') = yes;
FinalEnergy('Hardcoal') = yes;
FinalEnergy('Lignite') = yes;
FinalEnergy('H2') = yes;
FinalEnergy('Gas_Natural') = yes;
FinalEnergy('Oil') = yes;
FinalEnergy('Nuclear') = yes;

$if not set test $setglobal test 0
$ifthen %test% == 1
$include data_upload_europe.gms
$endif

$ifthen %short_results% == 1
Set
Category / Power, Residential, Industry, Transformation, Transport, Storage, Resource /
map_techToCategory(t,Category)
;
alias(Category, c);

map_techToCategory(t,c) = NO;

map_techToCategory('X_Electrolysis','Transformation') = Yes;
map_techToCategory('X_Fuel_Cell','Transformation') = Yes;
map_techToCategory('X_Methanation','Transformation') = Yes;
map_techToCategory('X_Biofuel','Transformation') = Yes;
map_techToCategory('X_SMR','Transformation') = Yes;
map_techToCategory('X_Powerfuel','Transformation') = Yes;

map_techToCategory('HB_Gas_Boiler','Residential') = Yes;
map_techToCategory('HB_Gas_CHP','Power') = Yes;
map_techToCategory('HB_Biomass','Residential') = Yes;
map_techToCategory('HB_Biomass_CHP','Power') = Yes;
map_techToCategory('HB_Hardcoal','Residential') = Yes;
map_techToCategory('HB_Lignite','Residential') = Yes;
map_techToCategory('HB_Hardcoal_CHP','Power') = Yes;
map_techToCategory('HB_Lignite_CHP','Power') = Yes;
map_techToCategory('HB_Direct_Electric','Residential') = Yes;
map_techToCategory('HB_Solar_Thermal','Residential') = Yes;
map_techToCategory('HB_Heatpump_Aerial','Residential') = Yes;
map_techToCategory('HB_Heatpump_Ground','Residential') = Yes;
map_techToCategory('HB_Geothermal','Residential') = Yes;
map_techToCategory('HB_Oil_Boiler','Residential') = Yes;
map_techToCategory('HB_H2_Boiler','Residential') = Yes;
map_techToCategory('HLI_Gas_Boiler','Industry') = Yes;
map_techToCategory('HLI_Gas_CHP','Power') = Yes;
map_techToCategory('HLI_Biomass','Industry') = Yes;
map_techToCategory('HLI_Biomass_CHP','Power') = Yes;
map_techToCategory('HLI_Hardcoal','Industry') = Yes;
map_techToCategory('HLI_Lignite','Industry') = Yes;
map_techToCategory('HLI_Hardcoal_CHP','Power') = Yes;
map_techToCategory('HLI_Lignite_CHP','Power') = Yes;
map_techToCategory('HLI_Direct_Electric','Industry') = Yes;
map_techToCategory('HLI_Solar_Thermal','Industry') = Yes;
map_techToCategory('HLI_Fuelcell','Industry') = Yes;
map_techToCategory('HLI_Geothermal','Industry') = Yes;
map_techToCategory('HLI_Oil_Boiler','Industry') = Yes;
map_techToCategory('HLI_Oil_CHP','Power') = Yes;
map_techToCategory('HMI_Gas','Industry') = Yes;
map_techToCategory('HMI_Biomass','Industry') = Yes;
map_techToCategory('HMI_HardCoal','Industry') = Yes;
map_techToCategory('HMI_Steam_Electric','Industry') = Yes;
map_techToCategory('HMI_Oil','Industry') = Yes;
map_techToCategory('HHI_BF_BOF','Industry') = Yes;
map_techToCategory('HHI_DRI_EAF','Industry') = Yes;
map_techToCategory('HHI_Scrap_EAF','Industry') = Yes;
map_techToCategory('HHI_H2DRI_EAF','Industry') = Yes;
map_techToCategory('HHI_Molten_Electrolysis','Industry') = Yes;
map_techToCategory('HHI_Bio_BF_BOF','Industry') = Yes;
map_techToCategory('HLI_H2_Boiler','Industry') = Yes;
map_techToCategory('HMI_H2','Industry') = Yes;

map_techToCategory('D_Battery_Li-Ion','Storage') = Yes;
map_techToCategory('D_Battery_Redox','Storage') = Yes;
map_techToCategory('D_Gas_H2','Storage') = Yes;
map_techToCategory('D_Gas_Methane','Storage') = Yes;
map_techToCategory('D_Heat_HLI','Storage') = Yes;
map_techToCategory('D_Heat_HB','Storage') = Yes;
map_techToCategory('D_PHS','Storage') = Yes;
map_techToCategory('D_PHS_Residual','Storage') = Yes;
map_techToCategory('D_CAES','Storage') = Yes;


$ontext
map_techToCategory('Area_Wind_offshore','Landuse') = Yes;
map_techToCategory('Area_Wind_onshore','Landuse') = Yes;
map_techToCategory('Area_Solar_roof','Landuse') = Yes;
map_techToCategory('Area_PV_Commercial','Landuse') = Yes;
map_techToCategory('Area_PV_Utility_opt','Landuse') = Yes;
map_techToCategory('Area_PV_Utility_avg','Landuse') = Yes;
map_techToCategory('Area_PV_Utility_inf','Landuse') = Yes;
map_techToCategory('Area_CSP_Storage','Landuse') = Yes;
map_techToCategory('Area_CSP','Landuse') = Yes;
map_techToCategory('Area_Thermal_GEO','Landuse') = Yes;
map_techToCategory('Area_Hydro_small','Landuse') = Yes;
map_techToCategory('Area_Hydro_large','Landuse') = Yes;
map_techToCategory('Area_wave','Landuse') = Yes;
map_techToCategory('Area_tidal','Landuse') = Yes;
map_techToCategory('Area_biofuels','Landuse') = Yes;
map_techToCategory('Area_DistrictHeating_avg','Landuse') = Yes;
map_techToCategory('Area_DistrictHeating_inf','Landuse') = Yes;
map_techToCategory('Area_DistrictHeating_opt','Landuse') = Yes;
$offtext

*-----------2015er Technologien-------------
map_techToCategory('R_Coal_Hardcoal','Resource') = Yes;
map_techToCategory('R_Coal_Lignite','Resource') = Yes;
map_techToCategory('R_Gas','Resource') = Yes;
map_techToCategory('R_Nuclear','Resource') = Yes;
map_techToCategory('R_Oil','Resource') = Yes;
map_techToCategory(ImportTechnology,'Resource') = Yes;

map_techToCategory('R_Grass','Resource') = Yes;
map_techToCategory('R_Wood','Resource') = Yes;
map_techToCategory('R_Residues','Resource') = Yes;
map_techToCategory('R_Paper_Cardboard','Resource') = Yes;
map_techToCategory('R_Roundwood','Resource') = Yes;
map_techToCategory('R_Biogas','Resource') = Yes;

map_techToCategory('P_Biomass','Power') = Yes;
map_techToCategory('P_Biomass_CCS','Power') = Yes;
map_techToCategory('P_Coal_Hardcoal','Power') = Yes;
map_techToCategory('P_Coal_Lignite','Power') = Yes;
map_techToCategory('P_Gas_OCGT','Power') = Yes;
map_techToCategory('P_Gas_CCGT','Power') = Yes;
map_techToCategory('P_H2_OCGT','Power') = Yes;
map_techToCategory('P_Gas_Engines','Power') = Yes;
map_techToCategory('P_Oil','Power') = Yes;
map_techToCategory('P_Nuclear','Power') = Yes;
;
map_techToCategory('P_CSP','Power') = Yes;
map_techToCategory('P_Geothermal','Power') = Yes;
map_techToCategory('P_Hydro_Dispatchable','Power') = Yes;
map_techToCategory('P_Hydro_RoR','Power') = Yes;
map_techToCategory('P_Ocean','Power') = Yes;
map_techToCategory('P_PV_Rooftop_Commercial','Power') = Yes;
map_techToCategory('P_PV_Rooftop_Residential','Power') = Yes;
map_techToCategory('P_PV_Utility_Avg','Power') = Yes;
map_techToCategory('P_PV_Utility_Inf','Power') = Yes;
map_techToCategory('P_PV_Utility_Opt','Power') = Yes;
map_techToCategory('P_Wind_Offshore_Transitional','Power') = Yes;
map_techToCategory('P_Wind_Offshore_Shallow','Power') = Yes;
map_techToCategory('P_Wind_Offshore_Deep','Power') = Yes;
map_techToCategory('P_Wind_Onshore_Avg','Power') = Yes;
map_techToCategory('P_Wind_Onshore_Inf','Power') = Yes;
map_techToCategory('P_Wind_Onshore_Opt','Power') = Yes;
map_techToCategory('P_Wind_Onshore_Opt_H2','Power') = Yes;
map_techToCategory('P_Wind_Offshore_Shallow_H2','Power') = Yes;
map_techToCategory('P_PV_Utility_Opt_H2','Power') = Yes;
map_techToCategory('A_CCS_Capacity','Resource') = Yes;

map_techToCategory('PSNG_Air_Bio','Transport') = Yes;
map_techToCategory('PSNG_Air_Conv','Transport') = Yes;
map_techToCategory('PSNG_Air_H2','Transport') = Yes;
map_techToCategory('PSNG_Rail_Conv','Transport') = Yes;
map_techToCategory('PSNG_Rail_Electric','Transport') = Yes;
map_techToCategory('PSNG_Road_BEV','Transport') = Yes;
map_techToCategory('PSNG_Road_H2','Transport') = Yes;
map_techToCategory('PSNG_Road_ICE','Transport') = Yes;
map_techToCategory('PSNG_Road_PHEV','Transport') = Yes;
map_techToCategory('FRT_Rail_Conv','Transport') = Yes;
map_techToCategory('FRT_Rail_Electric','Transport') = Yes;
map_techToCategory('FRT_Road_BEV','Transport') = Yes;
map_techToCategory('FRT_Road_H2','Transport') = Yes;
map_techToCategory('FRT_Road_ICE','Transport') = Yes;
map_techToCategory('FRT_Road_PHEV','Transport') = Yes;
map_techToCategory('FRT_Road_OH','Transport') = Yes;
map_techToCategory('FRT_Ship_Bio','Transport') = Yes;
map_techToCategory('FRT_Ship_Conv','Transport') = Yes;
map_techToCategory('FRT_Ship_H2','Transport') = Yes;
map_techToCategory('FRT_Ship_EL','Transport') = Yes;

set powerSubsector /res,com,ind/;
table powerSubsectorShares(REGION_FULL, powerSubsector)
                 res                com                ind
Europe_AT        0.302660018        0.208698688        0.488641294
Europe_Balt      0.273035073        0.395523507        0.33144142
Europe_BeLux     0.232689177        0.273172858        0.494137965
Europe_CH        0.336213163        0.31459413         0.349192707
Europe_CZ        0.272363028        0.278901086        0.448735886
Europe_DE        0.258558354        0.285028479        0.456413166
Europe_DK        0.335179713        0.333027318        0.331792969
Europe_FR        0.360505861        0.353856746        0.285637393
Europe_GB        0.359654042        0.309566169        0.330779789
Europe_Iberia    0.308727529        0.343607234        0.347665237
Europe_IT        0.237072804        0.326485907        0.436441289
Europe_NL        0.229602188        0.357020588        0.413377224
Europe_PL        0.229548038        0.369234995        0.401216967
Europe_Scand     0.324732631        0.224507331        0.450760038
Europe_East      0.278040904        0.224629772        0.497329325
Europe_Balkan    0.445861383        0.235053879        0.319084739
Europe_GR        0.348902067        0.342863023        0.30823491
;

parameter  z_UseByTechnologyByMode, z_ProductionByTechnologyByMode;

z_ProductionByTechnologyByMode(r,l,t,m,f,y) = RateOfProductionByTechnologyByMode.l(y,l,t,m,f,r) * YearSplit(l,y);
z_UseByTechnologyByMode(r,l,t,m,f,y) = RateOfUseByTechnologyByMode.l(y,l,t,m,f,r) * YearSplit(l,y);

$endif


$ifthen %test%==0
*additional_production(r,c,t,m,f,y,l,'Production','PJ','%EmissionPathway%_%sensitivity%')$(map_techToCategory(t,c)) = z_ProductionByTechnologyByMode(r,l,t,m,f,y) ;
additional_production(r,c,t,m,f,y,l,'Production','TWh','%EmissionPathway%_%sensitivity%')$(map_techToCategory(t,c)) = z_ProductionByTechnologyByMode(r,l,t,m,f,y) * 0.2778;
additional_production(r,c,Transport,m,f,y,l,'Production','TWh','%EmissionPathway%_%sensitivity%')$(map_techToCategory(Transport,c)) = 0 ;
additional_production(r,c,Passenger,m,f,y,l,'Production','gpkm','%EmissionPathway%_%sensitivity%')$(map_techToCategory(Passenger,c)) = z_ProductionByTechnologyByMode(r,l,Passenger,m,f,y) ;
additional_production(r,c,Freight,m,f,y,l,'Production','gtkm','%EmissionPathway%_%sensitivity%')$(map_techToCategory(Freight,c)) = z_ProductionByTechnologyByMode(r,l,Freight,m,f,y) ;

*additional_production(r,c,t,m,f,y,l,'Use','PJ','%EmissionPathway%_%sensitivity%')$(map_techToCategory(t,c)) = - z_UseByTechnologyByMode(r,l,t,m,f,y) ;
additional_production(r,c,t,m,f,y,l,'Use','TWh','%EmissionPathway%_%sensitivity%')$(map_techToCategory(t,c)) = - z_UseByTechnologyByMode(r,l,t,m,f,y) * 0.2778;

*additional_production(r,'InputDemand','Power_Demand','1','Power',y,l,'Use','PJ','%EmissionPathway%_%sensitivity%') = - Demand.l(y,l,'Power',r) ;
*additional_production(r,'InputDemand','Power_Demand_IHS_Residential','1','Power',y,l,'Use','PJ','%EmissionPathway%_%sensitivity%') = - Demand.l(y,l,'Power',r)*powerSubsectorShares(r,'res');
*additional_production(r,'InputDemand','Power_Demand_IHS_Industrial','1','Power',y,l,'Use','PJ','%EmissionPathway%_%sensitivity%') = - Demand.l(y,l,'Power',r)*powerSubsectorShares(r,'ind');
*additional_production(r,'InputDemand','Power_Demand_IHS_Commercial','1','Power',y,l,'Use','PJ','%EmissionPathway%_%sensitivity%') = - Demand.l(y,l,'Power',r)*powerSubsectorShares(r,'com');

additional_production(r,'InputDemand','Power_Demand','1','Power',y,l,'Use','TWh','%EmissionPathway%_%sensitivity%') = - Demand(y,l,'Power',r) * 0.2778;
additional_production(r,'InputDemand','Power_Demand_IHS_Residential','1','Power',y,l,'Use','TWh','%EmissionPathway%_%sensitivity%') = - Demand(y,l,'Power',r) * 0.2778*powerSubsectorShares(r,'res');
additional_production(r,'InputDemand','Power_Demand_IHS_Industrial','1','Power',y,l,'Use','TWh','%EmissionPathway%_%sensitivity%') = - Demand(y,l,'Power',r) * 0.2778*powerSubsectorShares(r,'ind');
additional_production(r,'InputDemand','Power_Demand_IHS_Commercial','1','Power',y,l,'Use','TWh','%EmissionPathway%_%sensitivity%') = - Demand(y,l,'Power',r) * 0.2778*powerSubsectorShares(r,'com');

*additional_production(r,'InputDemand','Heat_Buildings_Demand','1','Heat_Buildings',y,l,'Use','PJ','%EmissionPathway%_%sensitivity%') = - Demand.l(y,l,'Heat_Buildings',r) ;
*additional_production(r,'InputDemand','Heat_Low_Industrial_Demand','1','Heat_Low_Industrial',y,l,'Use','PJ','%EmissionPathway%_%sensitivity%') = - Demand.l(y,l,'Heat_Low_Industrial',r) ;
*additional_production(r,'InputDemand','Heat_Medium_Industrial_Demand','1','Heat_Medium_Industrial',y,l,'Use','PJ','%EmissionPathway%_%sensitivity%') = - Demand.l(y,l,'Heat_Medium_Industrial',r) ;
*additional_production(r,'InputDemand','Heat_High_Industrial_Demand','1','Heat_High_Industrial',y,l,'Use','PJ','%EmissionPathway%_%sensitivity%') = - Demand.l(y,l,'Heat_High_Industrial',r) ;

additional_production(r,'InputDemand','Heat_Buildings_Demand','1','Heat_Buildings',y,l,'Use','TWh','%EmissionPathway%_%sensitivity%') = - Demand(y,l,'Heat_Buildings',r) * 0.2778 ;
additional_production(r,'InputDemand','Heat_Low_Industrial_Demand','1','Heat_Low_Industrial',y,l,'Use','TWh','%EmissionPathway%_%sensitivity%') = - Demand(y,l,'Heat_Low_Industrial',r) * 0.2778 ;
additional_production(r,'InputDemand','Heat_Medium_Industrial_Demand','1','Heat_Medium_Industrial',y,l,'Use','TWh','%EmissionPathway%_%sensitivity%') = - Demand(y,l,'Heat_Medium_Industrial',r) * 0.2778 ;
additional_production(r,'InputDemand','Heat_High_Industrial_Demand','1','Heat_High_Industrial',y,l,'Use','TWh','%EmissionPathway%_%sensitivity%') = - Demand(y,l,'Heat_High_Industrial',r) * 0.2778 ;

*additional_production(r,'Trade','Trade','1',f,y,l,'NetTrade','PJ','%EmissionPathway%_%sensitivity%') = - NetTrade.l(y,l,f,r) ;
additional_production(r,'Trade','Trade','1',f,y,l,'NetTrade','TWh','%EmissionPathway%_%sensitivity%') = - NetTrade.l(y,l,f,r)* 0.2778 ;

additional_production(r,'Storage Losses',StorageDummies,m,f,y,l,'Use','TWh','%EmissionPathway%_%EmissionScenario%')$(OutputActivityRatio(r,StorageDummies,f,m,y)) = -(ProductionByTechnology.l(y,l,StorageDummies,f,r)*(1-OutputActivityRatio(r,StorageDummies,f,m,y)))/3.6;


additional_capacity(r,c,t,y,'NewCapacity','%EmissionPathway%_%sensitivity%')$(map_techToCategory(t,c)) = AccumulatedNewCapacity.l(y,t,r) ;
additional_capacity(r,c,t,y,'ResidualCapacity','%EmissionPathway%_%sensitivity%')$(map_techToCategory(t,c)) = ResidualCapacity(r,t,y) ;
additional_capacity(r,c,t,y,'TotalCapacity','%EmissionPathway%_%sensitivity%')$(map_techToCategory(t,c)) = TotalCapacityAnnual.l(y,t,r) ;
additional_capacity(r,c,t,y,'PotentialUsed','%EmissionPathway%_%sensitivity%')$(map_techToCategory(t,c) and (TotalAnnualMaxCapacity(r,t,y) > 0)) =  TotalCapacityAnnual.l(y,t,r)/TotalAnnualMaxCapacity(r,t,y);

additional_emissions(r,'TechnologyEmission',c,e,t,y,'%EmissionPathway%_%sensitivity%')$(map_techToCategory(t,c))  = AnnualTechnologyEmission.l(y,t,e,r);
additional_emissions(r,'ExogenousEmissions','X',e,'X',y,'%EmissionPathway%_%sensitivity%')  = AnnualExogenousEmission(r,e,y);
additional_emissions(r,'SectorEmissions',Sector,e,'Total',y,'%EmissionPathway%_%sensitivity%') = sum(f,TagFuelToSector(Sector,f)*SectorEmissions(y,r,f,e));
additional_emissions(r,'SectorEmissions',Sector,e,f,y,'%EmissionPathway%_%sensitivity%')$(TagFuelToSector(Sector,f)) = SectorEmissions(y,r,f,e);
additional_emissions(r,'EmissionIntensity',Sector,e,f,y,'%EmissionPathway%_%sensitivity%')$(TagFuelToSector(Sector,f)) = EmissionIntensity(y,r,f,e);
additional_emissions('X','EmissionLimit','X',e,'X',y,'%EmissionPathway%_%sensitivity%') = AnnualEmissionLimit(e,y);

additional_costs('GeneratingCosts',r,'Resource',f,'1',y) = additional_resourcecosts('ResourceCosts',r,f,y);
additional_costs('TotalSystemCosts','X','X','X','X','X') = z.l;

SelfSufficiencyRate(r,y) = ProductionAnnual.l(y,'Power',r)/(SpecifiedAnnualDemand(r,'Power',y)+UseAnnual.l(y,'Power',r));
ElectrificationRate(Sector,y)$(sum((f,r)$(TagFuelToSector(Sector,f)>0),TagFuelToSector(Sector,f)*ProductionAnnual.l(y,f,r)) > 0) = sum((f,t,r)$(ProductionByTechnologyAnnual.l(y,t,f,r) > 0), TagFuelToSector(Sector,f)*TagElectricTechnology(t)*ProductionByTechnologyAnnual.l(y,t,f,r))/sum((f,r)$(TagFuelToSector(Sector,f)>0),TagFuelToSector(Sector,f)*ProductionAnnual.l(y,f,r));

additional_other('SelfSufficiencyRate',r,'X','X',y) = SelfSufficiencyRate(r,y) ;
additional_other('ElectrificationRate','X',Sector,'X',y)  = ElectrificationRate(Sector,y) ;
additional_other('FinalEnergyConsumption',r,t,f,y) =  UseByTechnologyAnnual.l(y,t,f,r)/3.6;
additional_other('FinalEnergyConsumption',r,'InputDemand',f,y) = (SpecifiedAnnualDemand(r,f,y))/3.6;
additional_other('FinalEnergyConsumption',r,'InputDemand',Transport,y) = additional_other('FinalEnergyConsumption',r,'InputDemand',Transport,y)*3.6;
additional_other('ElectricityShareOfFinalEnergy',r,'X','X',y) = (UseAnnual.l(y,'Power',r)+SpecifiedAnnualDemand(r,'Power',y)) /  (sum(FinalEnergy,UseAnnual.l(y,FinalEnergy,r))+SpecifiedAnnualDemand(r,'Power',y));
additional_other('ElectricityShareOfFinalEnergy','Total','X','X',y) = sum(r,(UseAnnual.l(y,'Power',r)+SpecifiedAnnualDemand(r,'Power',y))) /  sum(r,(sum(FinalEnergy,UseAnnual.l(y,FinalEnergy,r))+SpecifiedAnnualDemand(r,'Power',y)));



* Write gdxxrw option file
$onecho >%tempdir%temp_additionaloutput.tmp
se=0

text="Region"                            Rng=Production!A1
text="Category"                          Rng=Production!B1
text="Technology"                        Rng=Production!C1
text="Mode"                              Rng=Production!D1
text="Fuel"                              Rng=Production!E1
text="Year"                              Rng=Production!F1
text="Timeslice"                         Rng=Production!G1
text="Type"                              Rng=Production!H1
text="Unit"                              Rng=Production!I1
text="Scenario"                          Rng=Production!J1
text="Value"                             Rng=Production!K1
        par=additional_production             Rng=Production!A2                     rdim=10        cdim=0

text="Region"                            Rng=Capacity!A1
text="Category"                          Rng=Capacity!B1
text="Technology"                        Rng=Capacity!C1
text="Year"                              Rng=Capacity!D1
text="Type"                              Rng=Capacity!E1
text="Scenario"                          Rng=Capacity!F1
text="Value"                             Rng=Capacity!G1
        par=additional_capacity               Rng=Capacity!A2                        rdim=6        cdim=0

text="Region"                            Rng=Emissions!A1
text="Type"                              Rng=Emissions!B1
text="Category"                          Rng=Emissions!C1
text="Emission"                          Rng=Emissions!D1
text="Technology"                        Rng=Emissions!E1
text="Year"                              Rng=Emissions!F1
text="Scenario"                          Rng=Emissions!G1
text="Value"                             Rng=Emissions!H1
        par=additional_emissions               Rng=Emissions!A2                      rdim=7        cdim=0

text="Type"                              Rng=Costs!A1
text="Region"                            Rng=Costs!B1
text="Technology"                        Rng=Costs!C1
text="Fuel"                              Rng=Costs!D1
text="Mode of Operation"                 Rng=Costs!E1
text="Year"                              Rng=Costs!F1
text="Value"                             Rng=Costs!G1
        par=additional_costs                  Rng=Costs!A2                            rdim=6        cdim=0

text="Type"                              Rng=Other!A1
text="Region"                            Rng=Other!B1
text="Sector"                            Rng=Other!C1
text="Technology"                        Rng=Other!D1
text="Year"                              Rng=Other!E1
text="Value"                             Rng=Other!F1
        par=additional_other                  Rng=Other!A2                            rdim=5        cdim=0

$offecho
$endif

$ifthen %scenario% == all
$call gdxmerge %gdxdir%additional\*.gdx output= %gdxdir%additional\Merged\Output_%region%_%EmissionPathway%_%EmissionScenario%.gdx
$onecho >%tempdir%temp_exceloutput.tmp
se=0
text="Merge"                             Rng=Production!A1
text="Region"                            Rng=Production!B1
text="Category"                          Rng=Production!C1
text="Technology"                        Rng=Production!D1
text="Mode"                              Rng=Production!E1
text="Fuel"                              Rng=Production!F1
text="Year"                              Rng=Production!G1
text="Timeslice"                         Rng=Production!H1
text="Type"                              Rng=Production!I1
text="Unit"                              Rng=Production!J1
text="Scenario"                          Rng=Production!K1
text="Value"                             Rng=Production!L1
        par=additional_production             Rng=Production!A2                     rdim=11        cdim=0

text="Merge"                             Rng=Capacity!A1
text="Region"                            Rng=Capacity!B1
text="Category"                          Rng=Capacity!C1
text="Technology"                        Rng=Capacity!D1
text="Year"                              Rng=Capacity!E1
text="Type"                              Rng=Capacity!F1
text="Scenario"                          Rng=Capacity!G1
text="Value"                             Rng=Capacity!H1
        par=additional_capacity               Rng=Capacity!A2                        rdim=7        cdim=0

text="Merge"                             Rng=Emissions!A1
text="Region"                            Rng=Emissions!B1
text="Type"                              Rng=Emissions!C1
text="Category"                          Rng=Emissions!D1
text="Emission"                          Rng=Emissions!E1
text="Technology"                        Rng=Emissions!F1
text="Year"                              Rng=Emissions!G1
text="Scenario"                          Rng=Emissions!H1
text="Value"                             Rng=Emissions!I1
        par=additional_emissions               Rng=Emissions!A2                      rdim=8        cdim=0


text="Merge"                             Rng=Costs!A1
text="Type"                              Rng=Costs!B1
text="Region"                            Rng=Costs!C1
text="Technology"                        Rng=Costs!D1
text="Fuel"                              Rng=Costs!E1
text="Mode of Operation"                 Rng=Costs!F1
text="Year"                              Rng=Costs!G1
text="Value"                             Rng=Costs!H1
        par=additional_costs                  Rng=Costs!A2                            rdim=7        cdim=0

text="Merge"                             Rng=Other!A1
text="Type"                              Rng=Other!B1
text="Region"                            Rng=Other!C1
text="Sector"                            Rng=Other!D1
text="Technology"                        Rng=Other!E1
text="Year"                              Rng=Other!F1
text="Value"                             Rng=Other!G1
        par=additional_other                  Rng=Other!A2                            rdim=6        cdim=0

$offecho

$endif


$ifthen %test% == 0
$ifthen set Info
execute_unload "%gdxdir%additional\Output_additional_%region%_%EmissionPathway%_%sensitivity%_%Info%.gdx"
$else
execute_unload "%gdxdir%additional\Output_additional_%region%_%EmissionPathway%_%sensitivity%.gdx"
$endif

additional_production
additional_emissions
additional_capacity
additional_costs
additional_other
;
$endif

$if not set WriteExcel $setglobal WriteExcel 1
$ifthen %WriteExcel% == 1
$ifthen %scenario% == all
execute 'gdxxrw.exe i=%gdxdir%additional\Merged\Output_%region%_%EmissionPathway%_%EmissionScenario%.gdx UpdLinks=3 o=%resultdir%Data_Output_%EmissionPathway%_Merged.xlsx @%tempdir%temp_exceloutput.tmp';
$else
$ifthen set Info
execute 'gdxxrw.exe i=%gdxdir%additional\Output_additional_%region%_%EmissionPathway%_%sensitivity%_%Info%.gdx UpdLinks=3 o=%resultdir%Data_Output_additional_%EmissionPathway%_%sensitivity%_%Info%.xlsx @%tempdir%temp_additionaloutput.tmp';
$else
execute 'gdxxrw.exe i=%gdxdir%additional\Output_additional_%region%_%EmissionPathway%_%sensitivity%.gdx UpdLinks=3 o=%resultdir%Data_Output_additional_%EmissionPathway%_%sensitivity%.xlsx @%tempdir%temp_additionaloutput.tmp';
$endif
$endif
$endif



