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

$offorder

Scalar switch_dunkelflaute /%elmod_dunkelflaute%/;

set OLD_TIMESLICE /Q1M,Q1P,Q1A,Q1N,Q2M,Q2P,Q2A,Q2N,Q3M,Q3P,Q3A,Q3N,Q4M,Q4P,Q4A,Q4N/;
alias (ol,OLD_TIMESLICE);

set COUNTRY_DATA_ENTRIES
/load,
pv_avg, pv_inf, pv_opt,
wind_onshore_avg, wind_onshore_inf, wind_onshore_opt,
wind_offshore,wind_offshore_shallow,wind_offshore_deep,
mobility_psng,
heat_low, heat_high,
heat_pump_air, heat_pump_ground,hydro_ror,pv_tracking/;
alias (cde,COUNTRY_DATA_ENTRIES);

parameter CountryData(REGION_FULL,TIMESLICE_FULL,COUNTRY_DATA_ENTRIES);

parameter CountryData_Load(TIMESLICE_FULL,REGION_FULL);
parameter CountryData_PV_avg(TIMESLICE_FULL,REGION_FULL);
parameter CountryData_PV_inf(TIMESLICE_FULL,REGION_FULL);
parameter CountryData_PV_opt(TIMESLICE_FULL,REGION_FULL);
parameter CountryData_PV_tracking(TIMESLICE_FULL,REGION_FULL);
parameter CountryData_Wind_Onshore_avg(TIMESLICE_FULL,REGION_FULL);
parameter CountryData_Wind_Onshore_inf(TIMESLICE_FULL,REGION_FULL);
parameter CountryData_Wind_Onshore_opt(TIMESLICE_FULL,REGION_FULL);
parameter CountryData_Wind_Offshore(TIMESLICE_FULL,REGION_FULL);
parameter CountryData_Wind_Offshore_Shallow(TIMESLICE_FULL,REGION_FULL);
parameter CountryData_Wind_Offshore_Deep(TIMESLICE_FULL,REGION_FULL);
parameter CountryData_Mobility_Psng(TIMESLICE_FULL,REGION_FULL);
parameter CountryData_Heat_Low(TIMESLICE_FULL,REGION_FULL);
parameter CountryData_Heat_High(TIMESLICE_FULL,REGION_FULL);
parameter CountryData_HeatPump_AirSource(TIMESLICE_FULL,REGION_FULL);
parameter CountryData_HeatPump_GroundSource(TIMESLICE_FULL,REGION_FULL);
parameter CountryData_Hydro_RoR(TIMESLICE_FULL,REGION_FULL);

parameter Dunkelflaute(REGION_FULL,TIMESLICE_FULL,COUNTRY_DATA_ENTRIES);

parameter SmoothedCountryData(REGION_FULL,TIMESLICE_FULL,COUNTRY_DATA_ENTRIES);
parameter ScaledCountryData(REGION_FULL,TIMESLICE_FULL,COUNTRY_DATA_ENTRIES);
parameter AverageCapacityFactor(REGION_FULL,COUNTRY_DATA_ENTRIES);


$onecho >%tempdir%temp_%hourly_data_file%_elmod.tmp
se=0
         par=CountryData_PV_inf            Rng=TS_PV_INF!A1              rdim=1    cdim=1
         par=CountryData_PV_avg            Rng=TS_PV_AVG!A1              rdim=1    cdim=1
         par=CountryData_PV_opt            Rng=TS_PV_OPT!A1              rdim=1    cdim=1
         par=CountryData_PV_tracking       Rng=TS_PV_TRA!A1              rdim=1    cdim=1
         par=CountryData_Wind_Onshore_inf  Rng=TS_WIND_ONSHORE_INF!A1    rdim=1    cdim=1
         par=CountryData_Wind_Onshore_avg  Rng=TS_WIND_ONSHORE_AVG!A1    rdim=1    cdim=1
         par=CountryData_Wind_Onshore_opt  Rng=TS_WIND_ONSHORE_OPT!A1    rdim=1    cdim=1
         par=CountryData_Wind_Offshore Rng=TS_WIND_OFFSHORE!A1   rdim=1    cdim=1
         par=CountryData_Wind_Offshore_Shallow Rng=TS_WIND_OFFSHORE_SHALLOW!A1   rdim=1    cdim=1
         par=CountryData_Wind_Offshore_Deep Rng=TS_WIND_OFFSHORE_DEEP!A1   rdim=1    cdim=1
         par=CountryData_Heat_High     Rng=TS_HEAT_HIGH!A1       rdim=1    cdim=1
         par=CountryData_Heat_Low      Rng=TS_HEAT_LOW!A1        rdim=1    cdim=1
         par=CountryData_Mobility_Psng Rng=TS_MOBILITY_PSNG!A1   rdim=1    cdim=1
         par=CountryData_Load          Rng=TS_LOAD!A1            rdim=1    cdim=1
         par=CountryData_HeatPump_GroundSource Rng=TS_HP_GROUNDSOURCE!A1      rdim=1    cdim=1
         par=CountryData_HeatPump_AirSource    Rng=TS_HP_AIRSOURCE!A1   rdim=1    cdim=1
         par=CountryData_Hydro_RoR                       Rng=TS_HYDRO_ROR!A1            rdim=1    cdim=1
$offecho
$ifi %switch_only_load_gdx%==0 $call "gdxxrw %inputdir%%hourly_data_file%.xlsx @%tempdir%temp_%hourly_data_file%_elmod.tmp o=%gdxdir%%hourly_data_file%_elmod.gdx MaxDupeErrors=99 CheckDate";
$GDXin %gdxdir%%hourly_data_file%_elmod.gdx
$onUNDF
$load CountryData_PV_inf, CountryData_PV_avg, CountryData_PV_opt, CountryData_PV_tracking, CountryData_Wind_Onshore_inf, CountryData_Wind_Onshore_avg, CountryData_Wind_Onshore_opt, CountryData_HeatPump_GroundSource, CountryData_HeatPump_AirSource, CountryData_Load, CountryData_Wind_Offshore, CountryData_Heat_High, CountryData_Heat_Low, CountryData_Mobility_Psng, CountryData_Hydro_RoR, CountryData_Wind_Offshore_Deep, CountryData_Wind_Offshore_Shallow
$offUNDF

CountryData(r_full, l_full, 'load') = CountryData_Load(l_full, r_full);
CountryData(r_full, l_full, 'pv_avg') = CountryData_PV_avg(l_full,  r_full);
CountryData(r_full, l_full, 'pv_inf') = CountryData_PV_inf(l_full,  r_full);
CountryData(r_full, l_full, 'pv_opt') = CountryData_PV_opt(l_full,  r_full);
CountryData(r_full, l_full, 'pv_tracking') = CountryData_PV_tracking(l_full,  r_full);
CountryData(r_full, l_full, 'wind_onshore_avg') = CountryData_Wind_Onshore_avg(l_full, r_full);
CountryData(r_full, l_full, 'wind_onshore_inf') = CountryData_Wind_Onshore_inf(l_full, r_full);
CountryData(r_full, l_full, 'wind_onshore_opt') = CountryData_Wind_Onshore_opt(l_full, r_full);
CountryData(r_full, l_full, 'wind_offshore') = CountryData_Wind_Offshore(l_full, r_full);
CountryData(r_full, l_full, 'wind_offshore_deep') = CountryData_Wind_Offshore_Deep(l_full, r_full);
CountryData(r_full, l_full, 'wind_offshore_shallow') = CountryData_Wind_Offshore_Shallow(l_full, r_full);
CountryData(r_full, l_full, 'heat_low') = CountryData_Heat_Low(l_full, r_full);
CountryData(r_full, l_full, 'heat_high') = CountryData_Heat_High(l_full, r_full);
CountryData(r_full, l_full, 'heat_pump_air') = CountryData_HeatPump_AirSource(l_full, r_full);
CountryData(r_full, l_full, 'heat_pump_ground') = CountryData_HeatPump_GroundSource(l_full, r_full);
CountryData(r_full, l_full, 'mobility_psng') = CountryData_Mobility_Psng(l_full, r_full);
CountryData(r_full, l_full, 'hydro_ror') = CountryData_Hydro_RoR(l_full, r_full);

parameter x_averageTimeSeriesValue(r_full, cde);
x_averageTimeSeriesValue(r,cde)${sum(l_full, CountryData(r,l_full,cde))} = (sum(l_full,CountryData(r,l_full,cde))/8760);

parameter x_peakingDemand(r_full, se);
x_peakingDemand(r,'industry') = smax((l_full),CountryData(r,l_full,'heat_high')/x_averageTimeSeriesValue(r, 'heat_high'));
x_peakingDemand(r,'buildings') = smax((l_full),CountryData(r,l_full,'heat_low')/x_averageTimeSeriesValue(r, 'heat_low'));
x_peakingDemand(r,'transportation') = smax((l_full),CountryData(r,l_full,'mobility_psng')/x_averageTimeSeriesValue(r, 'mobility_psng'));
x_peakingDemand(r,'power') = smax((l_full),CountryData(r,l_full,'load')/x_averageTimeSeriesValue(r, 'load'));

parameter negativeCDE(r_full, l_full, cde);
negativeCDE(r_full, l_full, cde)$(CountryData(r_full, l_full, cde) < 0) = CountryData(r_full, l_full, cde);

* choose every %elmod_nthhour% hour starting with the %elmod_starthour%
l(l_full)$(mod((ord(l_full) - %elmod_starthour%), %elmod_nthhour%) = 0) = yes;

set LAST_TIMESLICE(l_full);
set FIRST_TIMESLICE(l_full);

LAST_TIMESLICE(l_full) = NO;
FIRST_TIMESLICE(l_full) = NO;
LAST_TIMESLICE(l)$(ord(l) = card(l)) = YES;
FIRST_TIMESLICE(l)$(ord(l) = 1) = YES;

scalar
iterator /1/
;

*insert the Dunkelflaute
while(iterator lt 24 and card(l_full) lt 500,
l(l_full)$(ord(l_full) = (((24 - %elmod_starthour%) * %elmod_nthhour% + %elmod_starthour%) + iterator)) = yes;

Dunkelflaute(r_full,l_full,'pv_inf')$(ord(l_full) = (((24 - %elmod_starthour%) * %elmod_nthhour% + %elmod_starthour%) + iterator)) = 0.5;
Dunkelflaute(r_full,l_full,'wind_onshore_inf')$(ord(l_full) = (((24 - %elmod_starthour%) * %elmod_nthhour% + %elmod_starthour%) + iterator)) = 0.1;
Dunkelflaute(r_full,l_full,'wind_offshore')$(ord(l_full) = (((24 - %elmod_starthour%) * %elmod_nthhour% + %elmod_starthour%) + iterator)) = 0.1;

Dunkelflaute(r_full,l_full,'pv_avg')$(ord(l_full) = (((24 - %elmod_starthour%) * %elmod_nthhour% + %elmod_starthour%) + iterator)) = 0.5;
Dunkelflaute(r_full,l_full,'wind_onshore_avg')$(ord(l_full) = (((24 - %elmod_starthour%) * %elmod_nthhour% + %elmod_starthour%) + iterator)) = 0.1;
Dunkelflaute(r_full,l_full,'wind_offshore_shallow')$(ord(l_full) = (((24 - %elmod_starthour%) * %elmod_nthhour% + %elmod_starthour%) + iterator)) = 0.1;

Dunkelflaute(r_full,l_full,'pv_opt')$(ord(l_full) = (((24 - %elmod_starthour%) * %elmod_nthhour% + %elmod_starthour%) + iterator)) = 0.5;
Dunkelflaute(r_full,l_full,'wind_onshore_opt')$(ord(l_full) = (((24 - %elmod_starthour%) * %elmod_nthhour% + %elmod_starthour%) + iterator)) = 0.1;
Dunkelflaute(r_full,l_full,'wind_offshore_deep')$(ord(l_full) = (((24 - %elmod_starthour%) * %elmod_nthhour% + %elmod_starthour%) + iterator)) = 0.1;

*Depending on the length of the total time set the length of the dunkelflaute are included
iterator${%elmod_nthhour% gt 97 } = iterator + 8 ;
iterator${%elmod_nthhour% gt 49 and %elmod_nthhour% le 97} = iterator + 4 ;
iterator${%elmod_nthhour% gt 25 and %elmod_nthhour% le 49} = iterator + 2 ;
iterator${%elmod_nthhour% le 25 } = iterator +1 ;
);

* SCALING

set       set_SmoothedCountryDataMin(r_full,cde,l_full);
set       set_SmoothedCountryDataMax(r_full,cde,l_full);

parameter CountryDataMin(r_full,cde);
parameter CountryDataMax(r_full,cde);
parameter SmoothedCountryDataMin(r_full,cde);
parameter SmoothedCountryDataMax(r_full,cde);


AverageCapacityFactor(r,'load')${sum(l, CountryData(r,l,'load'))} = sum(l_full,CountryData(r,l_full,'load'))/8760;
CountryData(r,l_full,'load') = CountryData(r,l_full,'load')/AverageCapacityFactor(r,'load');
AverageCapacityFactor(r,'load')${sum(l, CountryData(r,l,'load'))} = sum(l_full,CountryData(r,l_full,'load'))/8760;

AverageCapacityFactor(r,'heat_low')${sum(l, CountryData(r,l,'heat_low'))} = sum(l_full,CountryData(r,l_full,'heat_low'))/8760;
CountryData(r,l_full,'heat_low') = CountryData(r,l_full,'heat_low')/AverageCapacityFactor(r,'heat_low');
AverageCapacityFactor(r,'heat_low')${sum(l, CountryData(r,l,'heat_low'))} = sum(l_full,CountryData(r,l_full,'heat_low'))/8760;

AverageCapacityFactor(r,cde)${sum(l, CountryData(r,l,cde))} = sum(l_full,CountryData(r,l_full,cde))/8760;

parameter smoothing_range(cde);
smoothing_range('load') = 3;
smoothing_range('pv_inf') = 1;
smoothing_range('wind_onshore_inf') = 2;
smoothing_range('pv_avg') = 1;
smoothing_range('wind_onshore_avg') = 2;
smoothing_range('pv_opt') = 1;
smoothing_range('pv_tracking') = 1;
smoothing_range('wind_onshore_opt') = 2;
smoothing_range('wind_offshore') = 2;
smoothing_range('wind_offshore_shallow') = 2;
smoothing_range('wind_offshore_deep') = 2;
smoothing_range('mobility_psng') = 3;
smoothing_range('heat_low') = 3;
smoothing_range('heat_high') = 3;
smoothing_range('heat_pump_air') = 3;
smoothing_range('heat_pump_ground') = 3;
smoothing_range('hydro_ror') = 3;

smoothing_range(cde)=1;


* Full calculation
if(card(l) = 8760,
smoothing_range('load') = 0;
smoothing_range('pv_inf') = 0;
smoothing_range('wind_onshore_inf') = 0;
smoothing_range('pv_avg') = 0;
smoothing_range('wind_onshore_avg') = 0;
smoothing_range('pv_opt') = 0;
smoothing_range('pv_tracking') = 0;
smoothing_range('wind_onshore_opt') = 0;
smoothing_range('wind_offshore') = 0;
smoothing_range('wind_offshore_shallow') = 0;
smoothing_range('wind_offshore_deep') = 0;
smoothing_range('mobility_psng') = 0;
smoothing_range('heat_low') = 0;
smoothing_range('heat_high') = 0;
smoothing_range('heat_pump_air') = 0;
smoothing_range('heat_pump_ground') = 0;
smoothing_range('hydro_ror') = 0;
);

* Every 25th hour
if(card(l) = 374,
smoothing_range('load') = 3;
smoothing_range('pv_inf') = 1;
smoothing_range('wind_onshore_inf') = 4;
smoothing_range('pv_avg') = 1;
smoothing_range('wind_onshore_avg') = 4;
smoothing_range('pv_opt') = 1;
smoothing_range('pv_tracking') = 1;
smoothing_range('wind_onshore_opt') = 4;
smoothing_range('wind_offshore') = 4;
smoothing_range('wind_offshore_shallow') = 4;
smoothing_range('wind_offshore_deep') = 4;
smoothing_range('mobility_psng') = 3;
smoothing_range('heat_low') = 3;
smoothing_range('heat_high') = 3;
smoothing_range('heat_pump_air') = 3;
smoothing_range('heat_pump_ground') = 3;
smoothing_range('hydro_ror') = 3;
);

* Every 49th hour
if(card(l) = 191,
smoothing_range('load') = 3;
smoothing_range('pv_inf') = 1;
smoothing_range('wind_onshore_inf') = 3;
smoothing_range('pv_avg') = 1;
smoothing_range('wind_onshore_avg') = 3;
smoothing_range('pv_opt') = 1;
smoothing_range('pv_tracking') = 1;
smoothing_range('wind_onshore_opt') = 3;
smoothing_range('wind_offshore') = 3;
smoothing_range('wind_offshore_shallow') = 3;
smoothing_range('wind_offshore_deep') = 3;
smoothing_range('mobility_psng') = 3;
smoothing_range('heat_low') = 3;
smoothing_range('heat_high') = 3;
smoothing_range('heat_pump_air') = 3;
smoothing_range('heat_pump_ground') = 3;
smoothing_range('hydro_ror') = 3;
);

* If very short time-spans are used (e.g. for testing) decrease smoothing range
smoothing_range(cde)${smoothing_range(cde)*2+1 gt card(l)} = max(0, round(card(l)/2-2));

loop((r,cde)${SUM[ll,CountryData(r,ll,cde)]},

         SmoothedCountryData(r,l,cde)${smoothing_range(cde) = 0} = CountryData(r,l,cde);

         SmoothedCountryData(r,l,cde)${smoothing_range(cde) ge 0} =
                  sum(ll${ord(ll) ge ord(l) - smoothing_range(cde)
                      and ord(ll) le ord(l) + smoothing_range(cde)}, CountryData(r,ll,cde)*(1 + (-1 + Dunkelflaute(r,ll,cde))$(switch_dunkelflaute = 1 and Dunkelflaute(r,ll,cde) gt 0)))
                  /
                  sum(ll${ord(ll) ge ord(l) - smoothing_range(cde)
                      and ord(ll) le ord(l) + smoothing_range(cde)}, 1)
         ;
);

* Determine minimum and maximum values in timeup and timeup_smoothed
CountryDataMin(r,cde)           = smin(l_full, CountryData(r,l_full,cde));
CountryDataMax(r,cde)           = smax(l_full, CountryData(r,l_full,cde));
SmoothedCountryDataMin(r,cde) = smin(l, SmoothedCountryData(r,l,cde));
SmoothedCountryDataMax(r,cde) = smax(l, SmoothedCountryData(r,l,cde));

*Find the t with the highest /lovest value
set_SmoothedCountryDataMin(r,cde,l) = 0;
set_SmoothedCountryDataMax(r,cde,l) = 0;

loop(l,
set_SmoothedCountryDataMin(r,cde,l)${sum((ll)$set_SmoothedCountryDataMin(r,cde,ll),1) = 0 and SmoothedCountryDataMin(r,cde) = SmoothedCountryData(r,l,cde)} = 1;
set_SmoothedCountryDataMax(r,cde,l)${sum((ll)$set_SmoothedCountryDataMax(r,cde,ll),1) = 0 and SmoothedCountryDataMax(r,cde) = SmoothedCountryData(r,l,cde)} = 1;
);

*$ontext

variables
scaling_objective
scaling_exponent(r_full,cde)
scaling_multiplicator(r_full,cde)
scaling_addition(r_full,cde)
;

equations
def_scaling_objective
def_scaling_flh(r_full,cde)
def_scaling_min(r_full,cde)
def_scaling_max(r_full,cde)
;


def_scaling_objective.. scaling_objective =e=
sum((r,cde)${AverageCapacityFactor(r,cde) and (SmoothedCountryDataMax(r,cde) - SmoothedCountryDataMin(r,cde)) NE 0},
    Sqr(AverageCapacityFactor(r,cde)*card(l) -
        sum(l${SmoothedCountryData(r,l,cde) - SmoothedCountryDataMin(r,cde) NE 0},
            max(0,
                (
                 (
                  (
                   (SmoothedCountryData(r,l,cde) - SmoothedCountryDataMin(r,cde)) / (SmoothedCountryDataMax(r,cde) - SmoothedCountryDataMin(r,cde))
                  )**scaling_exponent(r,cde)
                 ) * (CountryDataMax(r,cde) - CountryDataMin(r,cde))
                ) + CountryDataMin(r,cde)
               )
            ) - sum(l$(SmoothedCountryData(r,l,cde) - SmoothedCountryDataMin(r,cde) = 0),
                    max(0, CountryDataMin(r,cde))
                   )
       )
    )
;


def_scaling_max(r,cde)${AverageCapacityFactor(r,cde) and (SmoothedCountryDataMax(r,cde)-SmoothedCountryDataMin(r,cde)) NE 0}..
         CountryDataMax(r,cde) - CountryDataMin(r,cde)  =e= scaling_multiplicator(r,cde);


def_scaling_min(r,cde)${AverageCapacityFactor(r,cde) and (SmoothedCountryDataMax(r,cde)-SmoothedCountryDataMin(r,cde)) NE 0}..
         CountryDataMin(r,cde) =e= scaling_addition(r,cde);




model scaling1 /
def_scaling_min
def_scaling_max
def_scaling_objective
/
;



scaling1.holdfixed=1;

scaling_exponent.lo(r,cde)${AverageCapacityFactor(r,cde)}      = 0;
scaling_exponent.up(r,cde)${AverageCapacityFactor(r,cde)}      = 10;
scaling_exponent.l(r,cde)${AverageCapacityFactor(r,cde)}      = 1;


solve scaling1 min scaling_objective using DNLP;

abort$(scaling1.solvestat <> %solvestat.NormalCompletion%)  'Solvestat is wrong';
abort$(scaling1.modelstat <> 1 and scaling1.modelstat <> 2 and scaling1.modelstat <> 8)  'Modelstat is wrong';


ScaledCountryData(r,l,cde)${(SmoothedCountryDataMax(r,cde) - SmoothedCountryDataMin(r,cde)) NE 0} =
        max(0,
            (
             (
              (
               (SmoothedCountryData(r,l,cde) - SmoothedCountryDataMin(r,cde)) / (SmoothedCountryDataMax(r,cde) - SmoothedCountryDataMin(r,cde))
              )**max(0,scaling_exponent.l(r,cde))
             ) * scaling_multiplicator.l(r,cde)
            ) + scaling_addition.l(r,cde)
           );


YearSplit(l,y) = 1/card(l);

SpecifiedDemandProfile(r,f,l,y)$(SpecifiedAnnualDemand(r,f,y)) = ScaledCountryData(r,l,'load')/sum(ll,ScaledCountryData(r,ll,'load'));
SpecifiedDemandProfile(r,'Mobility_Passenger',l,y) = ScaledCountryData(r,l,'mobility_psng')/sum(ll,ScaledCountryData(r,ll,'mobility_psng'));
SpecifiedDemandProfile(r,'Mobility_Freight',l,y) = ScaledCountryData(r,l,'mobility_psng')/sum(ll,ScaledCountryData(r,ll,'mobility_psng'));
SpecifiedDemandProfile(r,'Heat_Buildings',l,y) = ScaledCountryData(r,l,'heat_low')/sum(ll,ScaledCountryData(r,ll,'heat_low'));
SpecifiedDemandProfile(r,'Heat_Low_Industrial',l,y) = ScaledCountryData(r,l,'heat_high')/sum(ll,ScaledCountryData(r,ll,'heat_high'));
SpecifiedDemandProfile(r,'Heat_MediumLow_Industrial',l,y) = ScaledCountryData(r,l,'heat_high')/sum(ll,ScaledCountryData(r,ll,'heat_high'));
SpecifiedDemandProfile(r,'Heat_MediumHigh_Industrial',l,y) = ScaledCountryData(r,l,'heat_high')/sum(ll,ScaledCountryData(r,ll,'heat_high'));
SpecifiedDemandProfile(r,'Heat_High_Industrial',l,y) = ScaledCountryData(r,l,'heat_high')/sum(ll,ScaledCountryData(r,ll,'heat_high'));

CapacityFactor(r,t,l,y) = 1;
CapacityFactor(r,t,l,y)$(TagTechnologyToSubsets(t,'Solar')) = 0;
CapacityFactor(r,t,l,y)$(TagTechnologyToSubsets(t,'Wind')) = 0;

TimeDepEfficiency(r,t,l,y) = 1;

CapacityFactor(r,'HB_Heatpump_Aerial',l,y) = 1;
CapacityFactor(r,'HB_Heatpump_Ground',l,y) = 1;
TimeDepEfficiency(r,'HB_Heatpump_Aerial',l,y) = ScaledCountryData(r,l,'heat_pump_air');
TimeDepEfficiency(r,'HB_Heatpump_Ground',l,y) = ScaledCountryData(r,l,'heat_pump_ground');

CapacityFactor(r,'P_pv_utility_opt',l,y) = ScaledCountryData(r,l,'pv_opt');
CapacityFactor(r,'P_Wind_Onshore_opt',l,y) = ScaledCountryData(r,l,'wind_onshore_opt');
CapacityFactor(r,'P_Wind_Offshore_Transitional',l,y) = ScaledCountryData(r,l,'wind_offshore');

CapacityFactor(r,'P_pv_utility_avg',l,y) = ScaledCountryData(r,l,'pv_avg');
CapacityFactor(r,'P_Wind_Onshore_avg',l,y) = ScaledCountryData(r,l,'wind_onshore_avg');
CapacityFactor(r,'P_Wind_Offshore_Shallow',l,y) = ScaledCountryData(r,l,'wind_offshore_shallow');

CapacityFactor(r,'P_pv_utility_inf',l,y) = ScaledCountryData(r,l,'pv_inf');
CapacityFactor(r,'P_Wind_Onshore_inf',l,y) = ScaledCountryData(r,l,'wind_onshore_inf');
CapacityFactor(r,'P_Wind_Offshore_Deep',l,y) = ScaledCountryData(r,l,'wind_offshore_deep');

CapacityFactor(r,'P_pv_utility_tracking',l,y) = ScaledCountryData(r,l,'pv_tracking');

CapacityFactor(r,'P_Hydro_RoR',l,y) = ScaledCountryData(r,l,'hydro_ror');


if(card(l) = 8760,
CapacityFactor(r,'HB_Heatpump_Aerial',l,y) = CountryData(r,l,'heat_pump_air');
CapacityFactor(r,'HB_Heatpump_Ground',l,y) = CountryData(r,l,'heat_pump_ground');

CapacityFactor(r,'P_pv_utility_opt',l,y) = CountryData(r,l,'pv_opt');
CapacityFactor(r,'P_Wind_Onshore_opt',l,y) = CountryData(r,l,'wind_onshore_opt');
CapacityFactor(r,'P_Wind_Offshore_Transitional',l,y) = CountryData(r,l,'wind_offshore');

CapacityFactor(r,'P_pv_utility_avg',l,y) = CountryData(r,l,'pv_avg');
CapacityFactor(r,'P_Wind_Onshore_avg',l,y) = CountryData(r,l,'wind_onshore_avg');
CapacityFactor(r,'P_Wind_Offshore_Shallow',l,y) = CountryData(r,l,'wind_offshore_shallow');

CapacityFactor(r,'P_pv_utility_inf',l,y) = CountryData(r,l,'pv_inf');
CapacityFactor(r,'P_Wind_Onshore_inf',l,y) = CountryData(r,l,'wind_onshore_inf');
CapacityFactor(r,'P_Wind_Offshore_Deep',l,y) = CountryData(r,l,'wind_offshore_deep');

CapacityFactor(r,'P_pv_utility_tracking',l,y) = CountryData(r,l,'pv_tracking');
CapacityFactor(r,'P_Hydro_RoR',l,y) = CountryData(r,l,'hydro_ror');
);
