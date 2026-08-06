* ============================================================
* GENeSYS-MOD Acceptance Sensitivity Analysis
* ============================================================
* Controls which AcceptanceFactor values are overridden
* before the first solve in the AUGMECON driver.
*
* Usage (command line):
*   gams genesysmod --switch_sensitivity=wind_plus10 --switch_guard_mode=1
*   gams genesysmod --switch_sensitivity=h2boiler_low --switch_guard_mode=1
*   gams genesysmod --switch_sensitivity=h2boiler_mean --switch_guard_mode=1
*
* Without --switch_sensitivity: baseline (no override, normal run).
*
* IMPORTANT — SCALE: this file is included from the AUGMECON driver,
* i.e. AFTER genesysmod_acceptance_factor.gms has inverted
* AcceptanceFactor to RESISTANCE (= 100 - acceptance). All overrides
* below are therefore written on the RESISTANCE scale:
*   acceptance +10pp  ==  resistance -10
*   acceptance = 45   ==  resistance = 55
*   acceptance = 63.2 ==  resistance = 36.8
* (Fixed 2026-07-07: overrides were previously written on the
* acceptance scale and thus acted in the OPPOSITE direction; the
* wind_plus10 run of 2026-06-20 measured wind MINUS 10pp acceptance.)
* Override is applied BEFORE Anchor 1 → all results (zAccAtCost,
* zAccMin, Pareto frontier) reflect the modified values consistently.
* ============================================================

$ifthen.sens "%switch_sensitivity%" == "wind_plus10"
* ----------------------------------------------------------------
* Sensitivity 1: Wind Onshore +10 percentage points
*
* Motivation: simulates effect of successful community engagement
* (e.g. Bürgerwindparks, improved Abstandsregelungen, participation
* processes). Tests how much cheaper the Pareto frontier becomes
* when Wind Onshore acceptance improves by 10pp in all regions.
*
* Technologies: RES_Wind_Onshore_Opt, _Avg, _Inf
* Change: acceptance +10pp = RESISTANCE - 10, floored at 0
* ----------------------------------------------------------------
    AcceptanceFactor(r,'RES_Wind_Onshore_Opt',y)
        = max(0, AcceptanceFactor(r,'RES_Wind_Onshore_Opt',y) - 10);
    AcceptanceFactor(r,'RES_Wind_Onshore_Avg',y)
        = max(0, AcceptanceFactor(r,'RES_Wind_Onshore_Avg',y) - 10);
    AcceptanceFactor(r,'RES_Wind_Onshore_Inf',y)
        = max(0, AcceptanceFactor(r,'RES_Wind_Onshore_Inf',y) - 10);

    display "SENSITIVITY: Wind Onshore +10pp acceptance (resistance -10) applied.";
    display AcceptanceFactor;

$elseif.sens "%switch_sensitivity%" == "h2boiler_low"
* ----------------------------------------------------------------
* Sensitivity 2: HLR_H2_Boiler acceptance reduced to 45%
*
* Motivation: baseline survey assigns ~80% acceptance to H2 boilers
* (general-local gap: respondents support H2 technology in general
* but may resist local installations). 45% is a pessimistic scenario
* reflecting strong local opposition.
* Tests whether the Frontier shape and technology shifts are robust
* to this single assumption, given HLR_H2_Boiler is the largest
* capacity driver in the baseline results (+830 GW toward k1).
* ----------------------------------------------------------------
*   acceptance 45 -> resistance 100-45 = 55
    AcceptanceFactor(r,'HLR_H2_Boiler',y) = 55;

    display "SENSITIVITY: HLR_H2_Boiler acceptance set to 45% (resistance 55).";
    display AcceptanceFactor;

$elseif.sens "%switch_sensitivity%" == "h2boiler_mean"
* ----------------------------------------------------------------
* Sensitivity 3: HLR_H2_Boiler acceptance set to mean fallback (63.2%)
*
* Motivation: the survey-based value of ~80% may overstate acceptance
* for H2 boilers because no direct survey question exists for this
* technology in the SNB — the value is inferred from related items.
* Setting it to the mean fallback (63.2%) tests whether results
* change qualitatively when the technology receives a neutral weight.
* ----------------------------------------------------------------
*   acceptance 63.2 (mean) -> resistance 100-63.2 = 36.8 (cf. acceptance_factor.gms mean-fill)
    AcceptanceFactor(r,'HLR_H2_Boiler',y) = 36.8;

    display "SENSITIVITY: HLR_H2_Boiler acceptance set to 63.2% (resistance 36.8, mean fallback).";
    display AcceptanceFactor;

$elseif.sens "%switch_sensitivity%" == "wind_plus10_h2boiler_low"
* ----------------------------------------------------------------
* Sensitivity 4: Combined — Wind +10pp AND H2 Boiler at 45%
*
* Motivation: joint policy scenario. Better wind acceptance
* (participation policy) + lower H2 boiler acceptance (realistic
* local resistance to new fuel infrastructure). Tests whether
* the frontier shifts more toward PV when H2 boiler is less attractive
* AND wind is more attractive simultaneously.
* ----------------------------------------------------------------
    AcceptanceFactor(r,'RES_Wind_Onshore_Opt',y)
        = max(0, AcceptanceFactor(r,'RES_Wind_Onshore_Opt',y) - 10);
    AcceptanceFactor(r,'RES_Wind_Onshore_Avg',y)
        = max(0, AcceptanceFactor(r,'RES_Wind_Onshore_Avg',y) - 10);
    AcceptanceFactor(r,'RES_Wind_Onshore_Inf',y)
        = max(0, AcceptanceFactor(r,'RES_Wind_Onshore_Inf',y) - 10);
*   acceptance 45 -> resistance 55
    AcceptanceFactor(r,'HLR_H2_Boiler',y) = 55;

    display "SENSITIVITY: Wind +10pp acceptance AND HLR_H2_Boiler = 45% acceptance applied (resistance scale).";
    display AcceptanceFactor;

$elseif.sens "%switch_sensitivity%" == "cable"
* ----------------------------------------------------------------
* Sensitivity 5: Underground-cabling regime (Erdkabel statt Freileitung)
*
* Motivation: >2/3 of residents reject new overhead lines while cables
* are broadly accepted (Stiftung Energie & Klimaschutz); cable capex is
* a factor ~2-3 above overhead lines over lifetime (Frontier Economics,
* SuedWestLink). Tests whether buying grid acceptance is cheaper than
* re-siting generation.
* NB semantics of AcceptanceFactorPowerLines are unresolved (147.79>100
* outlier); scaling the factor toward 0 shrinks the zAcc powerline term
* regardless of orientation, so the scenario is semantics-robust.
* ----------------------------------------------------------------
    AcceptanceFactorPowerLines(r,rr,'Power',y) = 0.2 * AcceptanceFactorPowerLines(r,rr,'Power',y);
    TradeCapacityGrowthCosts(r,'Power',rr) = 2.5 * TradeCapacityGrowthCosts(r,'Power',rr);

    display "SENSITIVITY: cable regime - powerline resistance x0.2, Power grid growth costs x2.5.";

$elseif.sens "%switch_sensitivity%" == "familiarity"
* ----------------------------------------------------------------
* Sensitivity 6: Exposure/familiarity effect (Gewoehnungseffekt)
*
* Motivation: SNB/AEE surveys consistently find ~+10pp acceptance where
* installations are already known (RE in neighbourhood 60->70%, heat
* pumps 49->68%). Approximated exogenously: RES wind/PV resistance
* falls by 10 points from 2040 (post-buildout familiarisation).
* ----------------------------------------------------------------
    AcceptanceFactor(r,'RES_Wind_Onshore_Opt',y)$(YearVal(y) >= 2040)  = max(0, AcceptanceFactor(r,'RES_Wind_Onshore_Opt',y) - 10);
    AcceptanceFactor(r,'RES_Wind_Onshore_Avg',y)$(YearVal(y) >= 2040)  = max(0, AcceptanceFactor(r,'RES_Wind_Onshore_Avg',y) - 10);
    AcceptanceFactor(r,'RES_Wind_Onshore_Inf',y)$(YearVal(y) >= 2040)  = max(0, AcceptanceFactor(r,'RES_Wind_Onshore_Inf',y) - 10);
    AcceptanceFactor(r,'RES_Wind_Offshore_Deep',y)$(YearVal(y) >= 2040) = max(0, AcceptanceFactor(r,'RES_Wind_Offshore_Deep',y) - 10);
    AcceptanceFactor(r,'RES_Wind_Offshore_Shallow',y)$(YearVal(y) >= 2040) = max(0, AcceptanceFactor(r,'RES_Wind_Offshore_Shallow',y) - 10);
    AcceptanceFactor(r,'RES_Wind_Offshore_Transitional',y)$(YearVal(y) >= 2040) = max(0, AcceptanceFactor(r,'RES_Wind_Offshore_Transitional',y) - 10);
    AcceptanceFactor(r,'RES_PV_Utility_Opt',y)$(YearVal(y) >= 2040)    = max(0, AcceptanceFactor(r,'RES_PV_Utility_Opt',y) - 10);
    AcceptanceFactor(r,'RES_PV_Utility_Avg',y)$(YearVal(y) >= 2040)    = max(0, AcceptanceFactor(r,'RES_PV_Utility_Avg',y) - 10);
    AcceptanceFactor(r,'RES_PV_Utility_Inf',y)$(YearVal(y) >= 2040)    = max(0, AcceptanceFactor(r,'RES_PV_Utility_Inf',y) - 10);
    AcceptanceFactor(r,'RES_PV_Utility_Tracking',y)$(YearVal(y) >= 2040) = max(0, AcceptanceFactor(r,'RES_PV_Utility_Tracking',y) - 10);
    AcceptanceFactor(r,'RES_PV_Rooftop_Commercial',y)$(YearVal(y) >= 2040) = max(0, AcceptanceFactor(r,'RES_PV_Rooftop_Commercial',y) - 10);
    AcceptanceFactor(r,'RES_PV_Rooftop_Residential',y)$(YearVal(y) >= 2040) = max(0, AcceptanceFactor(r,'RES_PV_Rooftop_Residential',y) - 10);

    display "SENSITIVITY: familiarity - RES wind/PV resistance -10 from 2040.";

$elseif.sens "%switch_sensitivity%" == "meanfill_50"
* ----------------------------------------------------------------
* Sensitivity 7a: mean-fill robustness — neutral 50
* Techs without survey rows sit at resistance exactly 36.8 (=100-63.2
* mean-fill in genesysmod_acceptance_factor.gms). Set them to 50
* (indifferent) to test how much the fill constant drives the frontier.
* ----------------------------------------------------------------
    AcceptanceFactor(r,t,y)$(abs(AcceptanceFactor(r,t,y) - 36.8) < 0.011) = 50;

    display "SENSITIVITY: mean-fill robustness - filled techs resistance 36.8 -> 50.";

$elseif.sens "%switch_sensitivity%" == "meanfill_low"
* ----------------------------------------------------------------
* Sensitivity 7b: mean-fill robustness — empirical mean
* The v07 sheet's own empirical mean acceptance (excluding its 63.2
* hard-coded fill rows) is 61.5 -> resistance 38.5.
* ----------------------------------------------------------------
    AcceptanceFactor(r,t,y)$(abs(AcceptanceFactor(r,t,y) - 36.8) < 0.011) = 38.5;

    display "SENSITIVITY: mean-fill robustness - filled techs resistance 36.8 -> 38.5.";

$elseif.sens "%switch_sensitivity%" == "accounting_zero"
* ----------------------------------------------------------------
* Sensitivity 8: accounting techs carry no local resistance
* A_* (area supply) and Z_Import_* (import accounting) are not
* physically sited installations; mean-fill gives them resistance 36.8
* which e.g. shadows rooftop PV (via A_Rooftop_*) and penalises
* imports. Set their resistance to 0.
* ----------------------------------------------------------------
    AcceptanceFactor(r,'A_Air',y) = 0;
    AcceptanceFactor(r,'A_Rooftop_Commercial',y) = 0;
    AcceptanceFactor(r,'A_Rooftop_Residential',y) = 0;
    AcceptanceFactor(r,'Z_Import_Gas',y) = 0;
    AcceptanceFactor(r,'Z_Import_H2',y) = 0;
    AcceptanceFactor(r,'Z_Import_Hardcoal',y) = 0;
    AcceptanceFactor(r,'Z_Import_LNG',y) = 0;
    AcceptanceFactor(r,'Z_Import_Oil',y) = 0;

    display "SENSITIVITY: accounting techs (A_*, Z_Import_*) resistance = 0.";

$elseif.sens "%switch_sensitivity%" == "acc_up"
* ----------------------------------------------------------------
* Sensitivity 9a: acceptance POLICY SUCCESS (2026-07-16)
* Acceptance of the key transition technologies (onshore wind,
* utility PV, BEV, heat pumps) rises by cfg_acc_delta points from
* cfg_acc_start (default 2030; participation schemes,
* familiarisation, better siting). cfg_acc_start parameterises the
* ONSET YEAR for the timing experiment (early vs late acceptance
* shift, e.g. --cfg_acc_start=2035).
* NB: runs AFTER the capacity-unit normalisation, so the delta is
* scaled by CtA/31.536 per tech (wind/PV are GW-native, BEV and
* heat pumps are PJ/a-native).
* ----------------------------------------------------------------
$if not set cfg_acc_delta $setglobal cfg_acc_delta 1
$if not set cfg_acc_start $setglobal cfg_acc_start 2030
set acc_sens_tech(t) /
    RES_Wind_Onshore_Opt, RES_Wind_Onshore_Avg, RES_Wind_Onshore_Inf,
    RES_PV_Utility_Opt, RES_PV_Utility_Avg, RES_PV_Utility_Inf,
    RES_PV_Utility_Tracking,
    PSNG_Road_BEV,
    HLR_Heatpump_Aerial, HLR_Heatpump_Ground,
    HLR_Heatpump_Geo_Surface, HLR_Heatpump_Geo_Deep /;
    AcceptanceFactor(r,acc_sens_tech,y)$(YearVal(y) >= %cfg_acc_start%)
        = max(0, AcceptanceFactor(r,acc_sens_tech,y)
                 - %cfg_acc_delta% * CapacityToActivityUnit(acc_sens_tech) / 31.536);

    display "SENSITIVITY: acc_up - key-tech resistance -%cfg_acc_delta% pts (unit-scaled) from %cfg_acc_start%.";

$elseif.sens "%switch_sensitivity%" == "acc_down"
* ----------------------------------------------------------------
* Sensitivity 9b: acceptance POLICY FAILURE (2026-07-16)
* Mirror of acc_up: acceptance of the key transition technologies
* falls by cfg_acc_delta points from cfg_acc_start (default 2030;
* backlash, failed participation). Same unit scaling; resistance
* capped at the unit-scaled equivalent of 100.
* ----------------------------------------------------------------
$if not set cfg_acc_delta $setglobal cfg_acc_delta 1
$if not set cfg_acc_start $setglobal cfg_acc_start 2030
set acc_sens_tech(t) /
    RES_Wind_Onshore_Opt, RES_Wind_Onshore_Avg, RES_Wind_Onshore_Inf,
    RES_PV_Utility_Opt, RES_PV_Utility_Avg, RES_PV_Utility_Inf,
    RES_PV_Utility_Tracking,
    PSNG_Road_BEV,
    HLR_Heatpump_Aerial, HLR_Heatpump_Ground,
    HLR_Heatpump_Geo_Surface, HLR_Heatpump_Geo_Deep /;
    AcceptanceFactor(r,acc_sens_tech,y)$(YearVal(y) >= %cfg_acc_start%)
        = min(100 * CapacityToActivityUnit(acc_sens_tech) / 31.536,
              AcceptanceFactor(r,acc_sens_tech,y)
              + %cfg_acc_delta% * CapacityToActivityUnit(acc_sens_tech) / 31.536);

    display "SENSITIVITY: acc_down - key-tech resistance +%cfg_acc_delta% pts (unit-scaled) from %cfg_acc_start%.";

$else.sens
    abort "Unknown switch_sensitivity value: %switch_sensitivity%. "
          "Valid options: wind_plus10, h2boiler_low, h2boiler_mean, wind_plus10_h2boiler_low, cable, familiarity, meanfill_50, meanfill_low, accounting_zero, acc_up, acc_down";
$endif.sens
