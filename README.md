[![Documentation Status](https://app.readthedocs.org/projects/genesysmod/badge/?version=latest&style=flat-square)](https://genesysmod.readthedocs.io/en/latest/?badge=latest)
[![CI](https://github.com/GENeSYS-MOD/GENeSYSMOD.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/GENeSYS-MOD/GENeSYS_MOD.gms/actions/workflows/gams-compile.yml)
[![status](https://joss.theoj.org/papers/c5ecbff41e8464c9d43f5c76879befb4/status.svg)](https://joss.theoj.org/papers/c5ecbff41e8464c9d43f5c76879befb4)

# GENeSYS-MOD Readme

You can find a full documentation on our [readthedocs](https://genesysmod.readthedocs.io/en/latest/index.html) page. :)

## Introduction
![alt text](Docs/logo_simplified_2.png "GENeSYS-MOD Logo")

**GENeSYS-MOD v3.0 [Global Energy System Model]** with additional equations for ramping, ramping costs, and minimal runtime requirements. Test dataset for [Middle-earth] included.

GENeSYS-MOD is a linear program, minimizing total system costs. Energy demands are exogenously predefined and the model needs to provide the necessary capacities to meet them. To achieve a cost-optimal energy mix, the model considers a plethora of different technology options, including generation, sector coupling, and storages.

### Quick-Start Guide
#### Starting a default model run
Default and fallback values for the command line parameters are found in the file **genesysmod.gms**:
```
[...]
$if not set switch_unixPath              $setglobal switch_unixPath 0
$if not set switch_investLimit           $setglobal switch_investLimit 1
$if not set switch_ccs                   $setglobal switch_ccs 1
$if not set switch_ramping               $setglobal switch_ramping 0
$if not set switch_short_term_storage    $setglobal switch_short_term_storage 1
$if not set switch_all_regions           $setglobal switch_all_regions 1
$if not set switch_infeasibility_tech    $setglobal switch_infeasibility_tech 1
$if not set switch_base_year_bounds      $setglobal switch_base_year_bounds 1
$if not set switch_only_load_gdx         $setglobal switch_only_load_gdx 0
$if not set switch_write_output          $setglobal switch_write_output csv
$if not set switch_aggregate_region      $setglobal switch_aggregate_region 0
$if not set switch_intertemporal         $setglobal switch_intertemporal 0
$if not set switch_weighted_emissions    $setglobal switch_weighted_emissions 1
$if not set switch_employment_calculation $setglobal switch_employment_calculation 0
$if not set switch_test_data_load        $setglobal switch_test_data_load 0
$if not set switch_only_write_results    $setglobal switch_only_write_results 0


$if not set solver                       $setglobal solver gurobi
$if not set model_region                 $setglobal model_region middleearth
$if not set data_base_region             $setglobal data_base_region Gondor
$if not set global_data_file             $setglobal global_data_file Global_Data_v05_oE
$if not set data_file                    $setglobal data_file Data_MiddleEarth_v01
$if not set eployment_data_file          $setglobal employment_data_file Employment_v01_06_11_2019
$if not set hourly_data_file             $setglobal hourly_data_file Hourly_Data_MiddleEarth_v01
$if not set threads                      $setglobal threads -2
$if not set timeseries                   $setglobal timeseries elmod
$if not set elmod_nthhour                $setglobal elmod_nthhour 244
$if not set elmod_starthour              $setglobal elmod_starthour 8
$if not set elmod_dunkelflaute           $setglobal elmod_dunkelflaute 0
$if not set elmod_hour_steps             $setglobal elmod_hour_steps 4


$if not set emissionPathway              $setglobal emissionPathway MiddleEarth
$if not set emissionScenario             $setglobal emissionScenario globalLimit
[...]
```

The default model run can be started by just executing the genesysmod.gms file. No further command-line parameters are required. Command line parameters can be provided via the GAMS IDE or when executing gams directly from the command line. E.g.:
```
gams.exe genesysmod.gms --switch_ccs=1 --switch_ramping --timeseries=elmod --nth=337
```


#### Command-Line parameters

| Parameter                 | Values        | Description                              |
|---------------------------|---------------|------------------------------------------|
| switch\_unixPath	       | 0,1           | Activates/Deactivates the usage of Unix (compared to Windows) file paths. |
| switch\_investLimit	       | 0,1           | Activates/Deactivates the investment-limits and capacity addition limits. |
| switch\_ccs                | 0,1           | Activates/Deactivates the investment into CCS technologies. |
| switch\_ramping            | 0,1           | Activates/Deactivates ramping and costs. **Note:** should only be used with a **timeseries=elmod**. |
| switch\_short\_term\_storage | 0,1           | Activates/Deactivates a more simple and easier to solve storage formulation that works with consecitive time-slices. **Note:** should only be used with a **timeseries=elmod** |
| switch\_all\_regions        | 0,1           | When activated all regions that are found in the input excel are computed. Else, only the first three regions are calculated. Used for debugging and testing. |
| switch\_infeasibility\_tech | 0,1           | Activates/Deactivates *infesability technologies*. These are very expensive arbitrary technologies that can fulfill every demand without other limitations. This parameter should be used to check if the available potential and existing capacities are sufficient to fulfill the inputted demand. |
| switch\_base\_year\_bounds   | 0,1           | Activates/Deactivates base year production limits. |
| switch\_only\_load\_gdx      | 0,1           | When set to 1, only gdx files will be loaded and no new gdx files will be generated from excel input files. |
| switch\_write\_output\_excel      | 0,1           | When set to 1, excel files from result gdx will be created. Otherwise, results are only written to .gdx files. |
|                           |               |                                          |
| solver                    | cplex,gurobi  | Sets the solver, currently only option files for *cplex* and *gurobi* are provided. Other solver can nonetheless be used and eneterd here. |
| model\_region              | user defined  | Sets the model region. Used for defining additional bounds and scenario parameters |
| data\_base\_region          | user defined  | Sets the base-region of the model run. When a technology parameter is not defined for a region, this here set region will be used as fallback.  <br>E.g., technology costs data is only definied for region 'CN-AH' in the input file. While loading the data, the cost data for all other regions will be also set to the costs for 'CN-AH'. |
| data_file                 | user defined  | Sets the input-file for obtaining general data. |
| hourly\_data\_file          | user defined  | Sets the input-file for obtaining hourly data. |
| timeseries                | classic,elmod | Switches between reduced hourly time-series and the classic OSeMOSY/GENeSYS-MOD timeslice approach. |
| elmod_nthhour                | (24\*n)+1; E.g., 337,169,121,73,49 | Defines the level of aggregation when using **timeseries=elmod**. |
| elmod_starthour                | (1-24) | Sets the starting hour of the time-series reduction algorithm when using **timeseries=elmod**. |
|                           |               |                                          |
| emissionPathway           | user defined  | User defined scenario pathway.           |
| emissionScenario          | user defined  | User defined scenario.           |



### Adding a new region to GENeSYS-MOD
#### 1. Set up data files
Set up and provide data files for general (data\_file) and hourly (hourly\_data\_file) data. Use existing files as template. Suggestion: copy and rename the existing files and try to run them as your new region.

#### 2. Add region-specific bounds file
Add new file **genesysmod\_scenariodata\_\[YOUR REGION\].gms**. This file is used to add scenarios for your case-study. Also, because this file is loaded after setting general bounds and limitiations, you can use is to overwrite predefinied bounds. Restrain from changing the general bounds as much as possible.

#### 3. Test your region and input files
Provide the new data-files via command-line parameter or change the default values in the **genesysmod.gms** file.

#### Further hints and tipps
* Start slow and change as little as much possible between the model runs
* Start with **timeseries=classic** and without ramping. The model size is greatly reduced and you can calibrate the base-year and general pathway transition of your model much easier.

___
## Version History
* Version 1.0:
  - Initial **GENeSYS-MOD**-Version, based on **OSeMOSYS** 2016.08
* [Version 2.0]:
  - More timeslices (16 yearly timeslices)
  - Revamped trade equations, added equations for power trade (losses, grid expansion, costs)
  - Renewable integration and reserve margin redefinition
  - Performance optimization
* Version 2.1:
  - Curtailment and different handling of dispatchable and non-dispatchable technologies added
* Version 2.2:
  - Revamped heating sector with four different temperature ranges and corresponding technologies
* Version 2.3:
  - Additional equations for ramping, ramping costs, and minimal runtime requirements
  - Timeseries reduction algorithm from **[dynElmod]** implemented
  - Matrix-size optimizations
* Version 3.0:
  - An option of running the model with reduced foresight has been added
  - Additional feature to obtain the cost-optimal renewable energy sources share has been adde
  - Results handling optimized
  - Enhanced features for setting emission limits

___
## Disclaimer
**GENeSYS-MOD v3.0 [Global Energy System Model]**  ~ December 2020  
Based on OSEMOSYS 2011.07.07 conversion to GAMS by Ken Noble, Noble-Soft Systems - August 2012

Updated to newest OSeMOSYS-Version (2016.08) and further improved with additional equations 2016 - 2020 by Konstantin Löffler, Thorsten Burandt, Karlo Hainsch

**Copyright 2020 Technische Universität Berlin and DIW Berlin**

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[dynElmod]: https://www.diw.de/documents/publikationen/73/diw_01.c.558112.de/diw_datadoc_2017-088.pdf
[Version 2.0]: https://www.diw.de/documents/publikationen/73/diw_01.c.594273.de/diw_datadoc_2018-094.pdf
[Middle-earth]: https://en.wikipedia.org/wiki/Middle-earth
