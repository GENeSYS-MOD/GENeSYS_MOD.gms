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



$onuelxref
scalar starttime;
starttime = jnow;

$if not set data_file                    $setglobal data_file RegularParameters_None
$if not set hourly_data_file             $setglobal hourly_data_file Timeseries_None
$if not set switch_read_data_long        $setglobal switch_read_data_long 1
$if not set elmod_nthhour                $setglobal elmod_nthhour 484
$if not set elmod_starthour              $setglobal elmod_starthour 8
$if not set year                         $setglobal year 2018
$if not set data_base_region             $setglobal data_base_region Gondor
$if not set timeseries                   $setglobal timeseries elmod
$if not set solver                       $setglobal solver cplex


$if not set switch_test_data_load        $setglobal switch_test_data_load 0
$if not set switch_investLimit           $setglobal switch_investLimit 1
$if not set switch_infeasibility_tech    $setglobal switch_infeasibility_tech 0
$if not set switch_base_year_bounds      $setglobal switch_base_year_bounds 1
$if not set switch_base_year_bounds_debugging      $setglobal switch_base_year_bounds_debugging 1


$if not set switch_unixPath              $setglobal switch_unixPath 0
$if not set switch_ccs                   $setglobal switch_ccs 1
$if not set switch_ramping               $setglobal switch_ramping 0
$if not set switch_short_term_storage    $setglobal switch_short_term_storage 1
$if not set switch_all_regions           $setglobal switch_all_regions 1
$if not set switch_only_load_gdx         $setglobal switch_only_load_gdx 0
$if not set switch_write_output          $setglobal switch_write_output gdx
$if not set switch_aggregate_region      $setglobal switch_aggregate_region 0
$if not set switch_intertemporal         $setglobal switch_intertemporal 0
$if not set switch_weighted_emissions    $setglobal switch_weighted_emissions 1
$if not set switch_employment_calculation $setglobal switch_employment_calculation 0
$if not set switch_only_write_results    $setglobal switch_only_write_results 0


$if not set set_symmetric_transmission   $setglobal set_symmetric_transmission 0
$if not set switch_hydrogen_blending_share      $setglobal switch_hydrogen_blending_share 1
$if not set set_storagelevelstart_up     $setglobal set_storagelevelstart_up 0.75
$if not set set_storagelevelstart_low    $setglobal set_storagelevelstart_low 0.25

$if not set switch_peaking_capacity      $setglobal switch_peaking_capacity 1
$if not set switch_peaking_with_trade    $setglobal switch_peaking_with_trade 1
$if not set switch_peaking_with_storages $setglobal switch_peaking_with_storages 1
$if not set switch_peaking_minrun        $setglobal switch_peaking_minrun 0
$if not set set_peaking_slack            $setglobal set_peaking_slack 1.0
*consider vRES only partially (1.0 consider vRES fully, 0.0 ignore vRES in peaking equation)
$if not set set_peaking_res_cf           $setglobal set_peaking_res_cf 0.5
$if not set set_peaking_min_thermal      $setglobal set_peaking_min_thermal 0.5
$if not set set_peaking_startyear        $setglobal set_peaking_startyear 2030
$if not set set_peaking_minrun_share     $setglobal set_peaking_minrun_share 0.15

$if not set model_region                 $setglobal model_region middleearth
$if not set eployment_data_file          $setglobal employment_data_file Employment_v01_06_11_2019
$if not set threads                      $setglobal threads 6
$if not set elmod_dunkelflaute           $setglobal elmod_dunkelflaute 0
$if not set hydrogen_growthcost_multiplier $setglobal hydrogen_growthcost_multiplier 1


$if not set emissionPathway              $setglobal emissionPathway middleearth
$if not set emissionScenario             $setglobal emissionScenario globalLimit

$ifthen %switch_unixPath% == 1
$if not set inputdir                     $setglobal inputdir Inputdata/
$if not set gdxdir                       $setglobal gdxdir GdxFiles/
$if not set tempdir                      $setglobal tempdir TempFiles/
$if not set resultdir                    $setglobal resultdir Results/
$else
$if not set inputdir                     $setglobal inputdir Inputdata\
$if not set gdxdir                       $setglobal gdxdir GdxFiles\
$if not set tempdir                      $setglobal tempdir TempFiles\
$if not set resultdir                    $setglobal resultdir Results\
$endif

option dnlp = ipopt;

$ifthen %emissionPathway% == REPowerEU
$setglobal data_file RegularParameters_Europe_EnVis_REPowerEU++
$setglobal hourly_data_file Timeseries_Europe_EnVis_REPowerEU++
$elseif %emissionPathway% == NECPEssentials
$setglobal data_file RegularParameters_Europe_EnVis_NECPEssentials
$setglobal hourly_data_file Timeseries_Europe_EnVis_NECPEssentials
$elseif %emissionPathway% == Green
$setglobal data_file RegularParameters_Europe_EnVis_Green
$setglobal hourly_data_file Timeseries_Europe_EnVis_Green
$elseif %emissionPathway% == Trinity
$setglobal data_file RegularParameters_Europe_EnVis_Trinity
$setglobal hourly_data_file Timeseries_Europe_EnVis_Trinity
$endif

$ifthen %model_region% == middleearth
$setglobal data_file RegularParameters_MiddleEarth
$setglobal hourly_data_file Timeseries_MiddleEarth
$setglobal data_base_region Gondor
$setglobal emissionPathway middleearth
$endif

*
* ####### Declarations #############
*

$offlisting
$include genesysmod_dec.gms

*
* ####### Load data from provided excel files #############
*

$offlisting
$ifthen %switch_read_data_long% == 1
$include genesysmod_dataload_long.gms
$else
$include genesysmod_dataload.gms
$endif

*
* ####### Settings for model run (Years, Regions, etc) #############
*
$offlisting
$include genesysmod_settings.gms

$offlisting
*$include genesysmod_interpolation.gms

$ifthen %switch_aggregate_region% == 1
$include genesysmod_aggregate_region.gms
$endif
*
* ####### apply general model bounds #############
*
$offlisting
$include genesysmod_bounds.gms

*
* ####### load additional bounds and data for certain scenarios #############
*
$ifthen exist genesysmod_scenariodata_%model_region%.gms
$include genesysmod_scenariodata_%model_region%.gms
$else
display "HINT: No scenario data for region %model_region% found!";
$endif

$offlisting
$include genesysmod_errorcheck.gms

$ifthen %switch_test_data_load% == 0
$ifthen %switch_only_write_results% == 0
*
* ####### Including Equations #############
*



$offlisting
$include genesysmod_equ.gms



*
* ####### CPLEX Options #############
*
option
lp = %solver%
limrow = 0
limcol = 0
solprint = off
sysout = off
profile=2
;



$onecho > cplex.opt
threads %threads%
parallelmode -1
lpmethod 4
names yes
*writemps mpsfile
*solutiontype 2
quality yes
*barobjrng 1e+075
tilim 1000000
$offecho

$onecho > gurobi.opt
threads %threads%
method 2
names yes
barhomogeneous 1
timelimit 1000000
*writeprob mps_GAMS.mps
*crossover 0
$offecho


$onecho > osigurobi.opt
threads %threads%
method 2
names no
barhomogeneous 1
timelimit 1000000
$offecho

display "switch_investLimit   = %switch_investLimit%";
display "switch_ccs           = %switch_ccs%";
display "switch_ramping       = %switch_ramping%";
display "switch_short_term_storage = %switch_short_term_storage%";
display "switch_all_regions = %switch_all_regions%";
display "switch_infeasibility_tech = %switch_infeasibility_tech%";
display "switch_base_year_bounds = %switch_base_year_bounds%";
display "switch_only_load_gdx = %switch_only_load_gdx%";

display "model_region = %model_region%";
display "data_base_region = %data_base_region%";
display "data_file = %data_file%";
display "hourly_data_file = %hourly_data_file%";
display "solver = %solver%";
display "timeseries = %timeseries%";

display "emissionScenario = %emissionScenario%";
display "emissionPathway = %emissionPathway%";

display "info = %info%";

*
* ####### Model and Solve statements #############
*
model genesys /all
$ifthen %switch_dispatch% == 1
$elseIf %timeseries% == elmod
-def_scaling_objective
-def_scaling_flh
-def_scaling_min
-def_scaling_max
$else
$endif
/;

genesys.holdfixed = 1;
genesys.optfile = 1;

scalar heapSizeBeforSolve;
heapSizeBeforSolve = heapSize;

solve genesys minimizing z using lp;

$include genesysmod_variable_parameter.gms

scalar heapSizeAfterSolve;
heapSizeAfterSolve = heapSize;

scalar elapsed;
elapsed = (jnow - starttime)*24*3600;

display elapsed,  heapSizeBeforSolve, heapSizeAfterSolve;
$endif

*
* ####### Creating Result Files #############
*
$include genesysmod_results.gms



$ifthen not %switch_write_output% == xls
$ifthen not %switch_write_output% == csv
$ifthen not %switch_write_output% == gdx
display "HINT: No output file format (csv, xls, gdx) specified, will reset to default and only output gdx file!";
$endif
$endif
$endif

$if %switch_employment_calculation% == 1 $include genesysmod_employment.gms

$endif
