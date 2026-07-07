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
* AcceptanceFactor(r,t,y) is on a 0-100 scale.
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
* Change: AcceptanceFactor + 10, capped at 100
* ----------------------------------------------------------------
    AcceptanceFactor(r,'RES_Wind_Onshore_Opt',y)
        = min(100, AcceptanceFactor(r,'RES_Wind_Onshore_Opt',y) + 10);
    AcceptanceFactor(r,'RES_Wind_Onshore_Avg',y)
        = min(100, AcceptanceFactor(r,'RES_Wind_Onshore_Avg',y) + 10);
    AcceptanceFactor(r,'RES_Wind_Onshore_Inf',y)
        = min(100, AcceptanceFactor(r,'RES_Wind_Onshore_Inf',y) + 10);

    display "SENSITIVITY: Wind Onshore +10pp applied.";
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
    AcceptanceFactor(r,'HLR_H2_Boiler',y) = 45;

    display "SENSITIVITY: HLR_H2_Boiler acceptance set to 45%.";
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
    AcceptanceFactor(r,'HLR_H2_Boiler',y) = 63.2;

    display "SENSITIVITY: HLR_H2_Boiler acceptance set to 63.2% (mean fallback).";
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
        = min(100, AcceptanceFactor(r,'RES_Wind_Onshore_Opt',y) + 10);
    AcceptanceFactor(r,'RES_Wind_Onshore_Avg',y)
        = min(100, AcceptanceFactor(r,'RES_Wind_Onshore_Avg',y) + 10);
    AcceptanceFactor(r,'RES_Wind_Onshore_Inf',y)
        = min(100, AcceptanceFactor(r,'RES_Wind_Onshore_Inf',y) + 10);
    AcceptanceFactor(r,'HLR_H2_Boiler',y) = 45;

    display "SENSITIVITY: Wind +10pp AND HLR_H2_Boiler = 45% applied.";
    display AcceptanceFactor;

$else.sens
    abort "Unknown switch_sensitivity value: %switch_sensitivity%. "
          "Valid options: wind_plus10, h2boiler_low, h2boiler_mean, wind_plus10_h2boiler_low";
$endif.sens
