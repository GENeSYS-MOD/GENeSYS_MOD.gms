* ============================================================
* GENeSYS-MOD: AUGMECON driver
* ============================================================
*
* ============================================================
* *** CENTRAL CONFIGURATION — only edit this block ***
* ============================================================

* Number of Pareto points (10 for final runs, 5 for screening)
* All three settings are command-line overridable since 2026-07-08,
* e.g.  gams genesysmod.gms --augmecon_points=5 --cfg_sensitivity=cable
$if not set augmecon_points $setglobal augmecon_points 10

* Guard mode:
*   0 = Capacity-Guard (original, fixes total sector capacity)
*   1 = Dispatch-Guard (new, fixes RateOfActivity for non-opt sectors)
$if not set cfg_guard_mode $setglobal cfg_guard_mode 1

* Sensitivity run (leave empty for baseline; see genesysmod_sensitivity.gms):
*   ''              = baseline (no override)
*   'wind_plus10'   = Wind Onshore +10pp acceptance (§6 EEG participation)
*   'h2boiler_low' / 'h2boiler_mean' / 'wind_plus10_h2boiler_low'
*   'cable'         = underground-cabling regime (powerline resistance x0.2,
*                     Power trade capacity growth costs x2.5)
*   'familiarity'   = exposure effect: RES wind/PV resistance -10 from 2040
*   'meanfill_50' / 'meanfill_low' = mean-fill robustness (36.8 -> 50 / 38.5)
*   'accounting_zero' = A_*/Z_Import_* accounting techs resistance = 0
$if not set cfg_sensitivity $setglobal cfg_sensitivity ''

* ============================================================
* *** END OF CONFIGURATION — do not edit below this line ***
* ============================================================

* Apply sensitivity override (only if cfg_sensitivity is not empty)
$if not '%cfg_sensitivity%'=='' $setglobal switch_sensitivity %cfg_sensitivity%
$if set switch_sensitivity $include genesysmod_sensitivity.gms

$if not set augmecon_points $setglobal augmecon_points 3
* Derive base GDX name from the -gdx= command line argument.
* $setNames splits %gams.gdx% into path (fp), filename (fn), extension (fe).
* Result: run_gdx = same name as -gdx= argument, without extension.
* anchor1 and k-outputs are then named: <gdx>_anchor1.gdx, <gdx>_k1.gdx etc.
$setNames "%gams.gdx%" gdx_fp gdx_fn gdx_fe
$if not set run_gdx $setglobal run_gdx "%gdxdir%%gdx_fn%"
$if not set anchor1_gdx $setglobal anchor1_gdx "%run_gdx%_anchor1"
* Example: -gdx=myrun_netzero produces myrun_netzero_anchor1.gdx, myrun_netzero_k1.gdx

* Tag for result-file names (pareto CSV) so parallel runs / sensitivity
* scenarios do not overwrite each other. Taken from the -gdx= run name;
* falls back to 'baseline' if no -gdx= was given on the command line.
$if not set run_tag $setglobal run_tag %gdx_fn%
$if '%run_tag%'=='' $setglobal run_tag baseline
$if not set switch_acc_sector_select $setglobal switch_acc_sector_select 1

$eval NPOINTS %augmecon_points%
set k /k1*k%NPOINTS%/;

parameter epsGrid(k);

scalar zStar, zAccAtCost, zAccMin;
scalar zAccLo, zAccHi;
scalar nEB2Skip;

* -------------------------------------------------
* Base-year capacity lock (switch_fix_baseyear)
* The acceptance objective (genesysmod_acceptance_factor.gms) counts
* NewCapacity only for YearVal > 2020, exempting the base year (2018).
* Because zAcc is built from NewCapacity (a flow) rather than the capacity
* stock, the optimiser can retime cheap Resources-sector builds (roundwood,
* grass, rooftop PV) across the 2018/2025 boundary to move zAcc up or down at
* near-zero cost, while the physical stock (TotalCapacity) stays identical.
* This produced the spurious flat "free-lunch" tail of the Pareto frontier.
* Locking base-year NewCapacity to the cost-optimal Anchor 1 values removes
* that accounting lever: the base year (a calibration year) can no longer be
* used as an acceptance-free buffer, so zAcc can only change through genuine
* in-window (2025+) capacity decisions that carry real cost.
* -------------------------------------------------
scalar switch_fix_baseyear /1/;
parameter RefNewCapacityBase(YEAR_FULL,TECHNOLOGY,REGION_FULL);

* Dispatch-Guard floating-point tolerance (see Block 2 below).
* Diagnosed from genesysmod.lst EB2_EnergyBalanceEachTS infeasibility reports
* at 364h/484h/724h: residuals from the RateOfActivity.l -> RefRateOfActivity
* -> .fx roundtrip cluster at 1e-15 to 3.75e-13 (IEEE double epsilon scale).
* Smallest real RHS magnitude observed in the same runs is 5e-6.
* 1e-6 sits comfortably above the worst observed residual (3.75e-13) and
* far below any economically meaningful activity level (RefRateOfActivity
* values observed up to ~1e3), while staying away from extreme near-zero
* bound widths. Only applied to instances with Anchor1 value != 0 (see
* Block 2 Step 2): exact-zero instances use a literal .fx = 0 instead,
* since summing exact zeros carries no roundoff risk and keeps those
* (numerous) variables fully eliminated in presolve rather than leaving
* them as near-zero-but-nonzero boxes, which is what broke Gurobi's
* Barrier/Crossover numerics in the first attempt (Bound range collapsed
* to [1e-09, 1e+03] alongside RHS up to 7e6 when the band was applied
* uniformly, including to exact-zero instances).
scalar epsDispatchGuard /1e-6/;

file pareto /%resultdir%pareto_augmecon_%run_tag%.csv/;
put pareto;
put "k,epsAcc,z,zAcc,sAcc,modelstat,solvestat" /;

* -------------------------------------------------
* IMPORTANT: initialize symbols used in accObj BEFORE first solve
* -------------------------------------------------
$ifthen.initAcc %switch_acceptance_factor% == 1
    wAccSector(se,y) = 1;
    accOptSector(se) = 1;
* Transportation excluded from zAcc: Modal-split constraints conflict with
* the capacity guard, making sector totals inconsistent across Pareto points.
* The guard still fixes Transportation capacity — only the zAcc contribution
* is disabled. FRT/PSNG technology swaps are cost-driven, not acceptance-driven.
    accOptSector('Transportation') = 0;
$endif.initAcc

* -------------------------------------------------
* OPTIONAL: If sector-selection mode is ON, you can overwrite here.
* E.g., optimize only Power, freeze everything else:
* -------------------------------------------------
$ifthen.sel %switch_acc_sector_select% == 1
*accOptSector(se) = 0;
    accOptSector('Power') = 1;
    accOptSector('Industry') = 0;
    accOptSector('Buildings') = 0;
    accOptSector('Transportation') = 0;
    accOptSector('Resources') = 1;
    accOptSector('Storages') = 0;
    accOptSector('Transformation') = 0;
    accOptSector('CHP') = 0;
$endif.sel
* 2 = heat-scope scenario: Buildings additionally in zAcc (heat-pump
*     resistance 43 counts; GEG/Waermewende research question, 2026-07-08)
$ifthen.sel2 %switch_acc_sector_select% == 2
    accOptSector('Power') = 1;
    accOptSector('Industry') = 0;
    accOptSector('Buildings') = 1;
    accOptSector('Transportation') = 0;
    accOptSector('Resources') = 1;
    accOptSector('Storages') = 0;
    accOptSector('Transformation') = 0;
    accOptSector('CHP') = 0;
$endif.sel2

* -------------------------------------------------
* [BLOCK 1] Guard mode selection
* 0 = Capacity-Guard (default, original behaviour):
*       FIX_TotalCapacityAnnual_Sector keeps total installed capacity
*       per sector equal to the cost-optimal baseline.
* 1 = Dispatch-Guard (new):
*       RateOfActivity is fixed for all non-opt-sector technologies
*       via .fx bounds (applied below after Anchor 1).
*       Opt-sector (e.g. Power) capacity is FREE to adjust between
*       technologies and regions; total output per timeslice is
*       implicitly fixed by the energy balance because all non-opt
*       sector consumption and all imports are frozen.
* -------------------------------------------------
* Read from central configuration block above
switch_guard_mode = %cfg_guard_mode%;

* -------------------------------------------------
* Secondary Gurobi option file (optfile=2): identical to gurobi.opt
* (set up by genesysmod.gms) except crossover=0. Used ONLY for the
* Anchor-2 (zAcc minimisation) solve below, where the LP is highly
* degenerate in the dispatch dimension and crossover can take hours
* to find a basic solution we do not actually need (see Anchor 2 note).
* -------------------------------------------------
$onecho > gurobi.op2
threads %threads%
method 2
names yes
barhomogeneous 1
timelimit 1000000
crossover 0
$offecho

* -------------------------------------------------
* Anchors
* -------------------------------------------------
runAug   = 0;
runGuard = 0;

solve genesys minimizing z using lp;
zStar = z.l;

***** Set Baseline (from cost-min run) — must happen before any $include
***** that might overwrite .l values
RefTotalH2Import =
    sum((y,r), ProductionByTechnologyAnnual.l(y,"Z_Import_H2","H2",r));
RefTotalGasImport =
    sum((y,r), ProductionByTechnologyAnnual.l(y,"Z_Import_Gas","Gas_Natural",r));
RefTotalHardcoalImport =
    sum((y,r), ProductionByTechnologyAnnual.l(y,"Z_Import_Hardcoal","Hardcoal",r));
RefTotalLNGImport =
    sum((y,r), ProductionByTechnologyAnnual.l(y,"Z_Import_LNG","LNG",r));
RefTotalOilImport =
    sum((y,r), ProductionByTechnologyAnnual.l(y,"Z_Import_Oil","Oil",r));

RefTotalCapYearSector(se,y) =
    sum((r,t)$(TagTechnologyToSector(t,se) = 1), TotalCapacityAnnual.l(y,t,r));

* Save NewCapacity for non-acceptance-optimized sectors (technology-level fix).
* This prevents cascading demand effects (e.g. EV->electricity) from
* indirectly reshaping sectors that ARE in the acceptance objective.
RefNewCap(y,t,r)$(
    sum(se$(TagTechnologyToSector(t,se)=1 and accOptSector(se)=0), 1) > 0
) = NewCapacity.l(y,t,r);

* Capture base-year (YearVal <= 2020) NewCapacity from the cost-optimal Anchor 1.
* Reference is Anchor 1 because it has no acceptance objective and therefore no
* incentive to game the base year — a clean, cost-driven calibration value.
* Applied (fixed) below, just before Anchor 2, when switch_fix_baseyear = 1.
RefNewCapacityBase(y,t,r)$(YearVal(y) <= 2020) = NewCapacity.l(y,t,r);

* -------------------------------------------------
* [BLOCK 2] DISPATCH-GUARD ANCHOR1 CAPTURE
* Only executed when switch_guard_mode = 1.
* Must happen BEFORE wAccSector normalisation so that .l values
* from Anchor 1 are still in memory.
* -------------------------------------------------
if(switch_guard_mode = 1,

*   DISPATCH-GUARD: Fix RateOfActivity per timeslice for all non-opt-sector,
*   non-Storage technologies. This is the original, validated formulation
*   (confirmed exact 595.6 GW Power-sector capacity constancy across all
*   k-points at 244h/364h resolution).
*
*   Storages sector is EXCLUDED: S2_StorageLevelTSStart is a time-sequential
*   balance (StorageLevel(t+1) = StorageLevel(t) + charge.fx - discharge.fx).
*   Fixing both charge and discharge per timeslice fully determines the storage
*   level trajectory; even tiny floating-point differences from Anchor1 .l values
*   can push StorageLevel outside its bounds, causing GAMS to flag
*   "Equation infeasible due to rhs value" at equation-generation time.
*   Storage capacity is still constrained via FIX_NewCapacity_NonOpt.
*
*   FIXED (root cause confirmed via genesysmod.lst at 364h/484h/724h):
*   strict .fx over-determines EB2_EnergyBalanceEachTS for fuels served
*   EXCLUSIVELY by non-opt-sector technologies (Mobility_Passenger,
*   Mobility_Freight, Heat_District, Heat_High_Industrial,
*   Heat_Medium_Industrial — confirmed across all violated instances,
*   never Power-sector fuels). After .fx removes every free variable from
*   such an EB2 instance, GAMS's pre-solve equality check requires
*   sum(fixed terms) = 0 EXACTLY; the RateOfActivity.l -> RefRateOfActivity
*   -> .fx roundtrip leaves residuals of 1e-15 to 3.75e-13 (IEEE double
*   epsilon scale), which GAMS then flags as "Equation infeasible due to
*   rhs value" before the solver is ever invoked. This reproduced
*   identically and deterministically at 364h, 484h, and 724h baseline
*   (no sensitivity), so it is NOT resolution- or sensitivity-specific —
*   only the data path (which fuels happen to be non-opt-exclusive) decides
*   whether a given run trips it.
*   Fix: see the zero/nonzero split implemented in Step 2 below.

*   Step 1: save RateOfActivity from Anchor 1 for non-opt-sector technologies.
    RefRateOfActivity(y,l,t,m,r)$(
        sum(se$(TagTechnologyToSector(t,se)=1
                and accOptSector(se)=0
                and not sameas(se,'Storages')), 1) > 0
        and not sum(se$(TagTechnologyToSector(t,se)=1
                        and sameas(se,'Storages')), 1) > 0
    ) = RateOfActivity.l(y,l,t,m,r);

*   Step 2: pin RateOfActivity to Anchor1 values for non-opt, non-Storage
*   sectors via EXACT .fx (single statement, zero- and nonzero-valued alike).
*   Exact fixing eliminates these variables in Gurobi presolve, so the LP
*   keeps a clean Bound range (no tiny near-zero boxes) and the Barrier
*   converges fast as in Anchor 1 -> Crossover is safe again. This restores
*   bit-exact Power-sector capacity constancy (595.6 GW across all k-points).
*   The EB2 over-determination that exact .fx would otherwise trigger is
*   handled NOT by widening bounds (the superseded +/- epsDispatchGuard band,
*   which left tens of thousands of [val-1e-6, val+1e-6] boxes next to RHS up
*   to 7e6, wrecked Barrier/Crossover numerics) but by SKIPPING the affected
*   EB2 rows at generation time (TagEB2Skip below + gated condition in
*   genesysmod_equ.gms). A skipped row has no free variable, so dropping it
*   adds no information and introduces no dispatch freedom.
*   Storage dispatch remains free — determined by energy balance + storage
*   constraints (S2, S3, S5, S6) with fixed capacity from FIX_NewCapacity_NonOpt.
    RateOfActivity.fx(y,l,t,m,r)$(
        sum(se$(TagTechnologyToSector(t,se)=1
                and accOptSector(se)=0
                and not sameas(se,'Storages')), 1) > 0
        and not sum(se$(TagTechnologyToSector(t,se)=1
                        and sameas(se,'Storages')), 1) > 0
    ) = RefRateOfActivity(y,l,t,m,r);

*   Step 3: build the EB2 skip tag. A row (y,f,r) is skippable iff its whole
*   EB2 balance is frozen by the guard, i.e.:
*     - it is a per-timeslice fuel (TagTimeIndependentFuel = 0, so EB2 applies)
*     - NetTrade is fixed (no trade route -> NetTrade.fx = 0 upstream)
*     - it has at least one contributing technology term, AND
*     - NONE of its contributing technologies is free, where "free" means in
*       an opt sector (accOptSector = 1) or in Storages. Equivalently: every
*       producer/consumer of that fuel is a non-opt, non-Storage (now-fixed)
*       technology. These are exactly the rows that error with
*       "Equation infeasible due to rhs value" under a strict .fx.
*   The tag is purely topological (technology-fuel ratios + accOptSector +
*   Storage membership). The acceptance sensitivities only override
*   AcceptanceFactor (a zAcc input), so this set is identical across baseline
*   and every sensitivity scenario, and it auto-adapts if accOptSector changes.
    TagEB2Skip(y,f,r) = 0;
    TagEB2Skip(y,f,r)$(
        TagTimeIndependentFuel(y,f,r) = 0
        and sum(rr, TradeRoute(r,f,y,rr)) = 0
        and sum((t,m)$(OutputActivityRatio(r,t,f,m,y) <> 0
                       or InputActivityRatio(r,t,f,m,y) <> 0), 1) > 0
        and sum((t,m)$(
                (OutputActivityRatio(r,t,f,m,y) <> 0
                 or InputActivityRatio(r,t,f,m,y) <> 0)
                and ( sum(se$(TagTechnologyToSector(t,se)=1
                              and accOptSector(se)=1), 1) > 0
                      or sum(se$(TagTechnologyToSector(t,se)=1
                                 and sameas(se,'Storages')), 1) > 0 )
            ), 1) = 0
    ) = 1;

*   Activate the gated EB2 skip for Anchor 2 and the whole AUGMECON loop.
*   (guardActive was 0 during Anchor 1, so that solve was untouched.)
    guardActive = 1;

*   Sanity guard: report how many (y,f,r) rows are skipped and abort if the
*   count is implausibly large. Expected: a handful of non-opt-exclusive fuels
*   (Mobility_Passenger, Mobility_Freight, Heat_District, Heat_High_Industrial,
*   Heat_Medium_Industrial) x affected regions x years. A large number would
*   mean an opt-sector (e.g. Power/electricity) fuel was wrongly captured —
*   stop before producing misleading results.
    nEB2Skip = sum((y,f,r)$(TagEB2Skip(y,f,r) = 1), 1);
    display nEB2Skip;
    abort$(nEB2Skip > 2000)
        "Dispatch-Guard EB2 skip captured an unexpectedly large number of "
        "(y,f,r) rows. Check accOptSector and the technology-fuel topology "
        "before trusting results.";

*   Note on opt-sector behaviour in Dispatch-Guard mode:
*   After fixing non-opt (excl. Storages) RateOfActivity, the electricity
*   balance EB2_EnergyBalanceEachTS has:
*     Power_production(free) + Storage_dispatch(free) - fixed_loads = Demand(exog.)
*   The opt sector (Power, Resources) and storage dispatch are FREE to choose
*   any technology/region combination. Storage provides timeslice flexibility
*   for the Power sector reallocation. Total opt-sector capacity per timeslice
*   is therefore implicitly pinned by the now fully-determined residual
*   demand — confirmed empirically (exact 595.6 GW Power capacity constancy
*   across all k-points at 244h/364h resolution).
);
* -------------------------------------------------
* END BLOCK 2
* -------------------------------------------------

$ifthen.accW %switch_acceptance_factor% == 1
    wAccSector(se,y) = 0;
    wAccSector(se,y)$(RefTotalCapYearSector(se,y) > 0) =
        SectorAcceptanceWeight(se) / RefTotalCapYearSector(se,y);
$endif.accW

* Re-evaluate zAccAtCost AFTER wAccSector normalization so both anchor points
* use the same normalized units. Using .l values from Anchor 1 still in memory.
$ifthen.accW3 %switch_acceptance_factor% == 1
zAccAtCost =
    sum((r,y,se,t)$(
            YearVal(y) > 2020
        and TagTechnologyToSector(t,se) = 1
        and wAccSector(se,y) > 0
        and accOptSector(se) = 1
    ), Acceptance.l(r,t,y) * wAccSector(se,y))
  + sum((r,y)$(
            YearVal(y) > 2020
        and wAccSector('Power',y) > 0
        and accOptSector('Power') = 1
    ), TotalAcceptanceperRegion_Powerlines.l(r,y) * wAccSector('Power',y));
$else.accW3
zAccAtCost = zAcc.l;
$endif.accW3

* Save Anchor 1 GDX (raw variable values - no includes to avoid warm-start issues)
put_utility 'gdxout' / "%anchor1_gdx%.gdx";
execute_unload;

* IMPORTANT: compute zAccMin under SAME guard constraints (runGuard=1 activates your guard)
*
* CROSSOVER DISABLED FOR THIS SOLVE ONLY:
* zAcc (acceptance objective) depends only on capacity-related variables
* (NewCapacity / TotalCapacityAnnual), NOT on the intra-year dispatch profile.
* With the annual-total dispatch guard, intra-year timeslice distribution is
* completely free for both opt- and non-opt-sector technologies — meaning
* there are vast numbers of dispatch profiles that achieve the exact same
* zAcc value (primal degeneracy). Crossover must pivot through this
* degenerate space to find a basic (vertex) solution, which can take many
* hours or never terminate at high time resolutions (e.g. 484+ timeslices).
* We only need the scalar zAccMin (objective value) here — no .l values from
* this solve are used downstream (no GDX is saved, see note below) — so a
* basic solution is unnecessary. gurobi.op2 is identical to gurobi.opt except
* crossover=0, letting Gurobi report the barrier objective directly.
* -------------------------------------------------
* Lock the base year before any acceptance-constrained solve.
* From here on (Anchor 2 + entire AUGMECON loop) base-year capacity is frozen
* to the cost-optimal Anchor 1 values; the 2018 acceptance-free buffer is shut.
* .fx persists across all following solves until released. Fixing ALL techs
* (not just Resources) is intentional: 2018 is a calibration year and should
* not flex with acceptance preferences. For non-opt techs this coincides with
* the Dispatch-Guard's own NewCapacity fix (same Anchor 1 value -> consistent).
* -------------------------------------------------
if(switch_fix_baseyear = 1,
    NewCapacity.fx(y,t,r)$(YearVal(y) <= 2020) = RefNewCapacityBase(y,t,r);
);

genesys.optfile = 2;
runGuard = 1;
solve genesys minimizing zAcc using lp;
* Robustness (added 2026-07-09 after a 5.5h degenerate heat run): the
* crossover-0 barrier can die with 'Numerical trouble' (LP status 12,
* modelstat 6+). Without this check the garbage zAccMin collapsed the
* epsilon grid and every k-point silently reproduced the cost anchor.
* Retry once with optfile 1 (default barrier + crossover), then abort
* rather than burn hours on a degenerate frontier.
* modelstat 7 (sub-optimal termination, solution AVAILABLE) is acceptable
* for an anchor: zAccMin only sets the epsilon-grid end and the grid
* starts 5% above it anyway. Observed 2026-07-09 (noimp run): attempt 1
* delivered zAccMin=31.97 with modelstat 7 after 7h; the crossover retry
* then died with LP status 12 and the strict abort wasted the run.
if((genesys.modelstat > 2) and (genesys.modelstat <> 7),
    put_utility 'log' / 'AUGMECON WARNING: Anchor 2 modelstat ' genesys.modelstat:0:0 ' - retrying with optfile 1 (crossover)';
    genesys.optfile = 1;
    solve genesys minimizing zAcc using lp;
);
if((genesys.modelstat = 7),
    put_utility 'log' / 'AUGMECON WARNING: Anchor 2 sub-optimal (modelstat 7) - accepting available zAccMin for the epsilon grid';
);
abort$((genesys.modelstat > 2) and (genesys.modelstat <> 7)) "Anchor 2 (min zAcc) has no usable solution after retry - aborting instead of producing a degenerate frontier.";
zAccMin = zAcc.l;
runGuard = 0;
genesys.optfile = 1;
* Restored to default (crossover=1) for Anchor 1 already done, and required
* for all AUGMECON loop solves below (GDX export needs a basic solution).

* Anchor 2 GDX intentionally NOT saved here.
* Saving it would pass the guard-constrained solution as warm start
* to the AUGMECON loop, causing modelstat=7 (sub-optimal termination).
* To inspect anchor 2, comment the loop back in temporarily.

* numeric settings for augmented objective
zAccLo  = min(zAccMin, zAccAtCost);
zAccHi  = max(zAccMin, zAccAtCost);

rangeAcc = max(1e-6, zAccHi - zAccLo);
rho      = 1e-6 * max(1, abs(zStar));

* Start grid 5% above zAccMin to avoid numerically difficult extreme point.
* k=1 at exactly zAccMin is often sub-optimal due to tight feasibility region.
* The 5% offset skips this while preserving a meaningful Pareto frontier.
epsGrid(k) = zAccLo + 0.05 * rangeAcc;
epsGrid(k)$(card(k) > 1) = zAccLo + 0.05 * rangeAcc
    + (ord(k)-1)/(card(k)-1) * rangeAcc * 0.95;

* -------------------------------------------------
* AUGMECON LOOP
* -------------------------------------------------
runAug = 1;

* Reset warm start: the anchor 2 solution (with guard) would be passed
* as starting point to the loop solves, making them infeasible with the
* eps constraint active. BRatio=1 tells GAMS to use the solver's own
* starting point instead.
genesys.BRatio = 1;

loop(k,
    epsAcc = epsGrid(k);

    solve genesys minimizing zAug using lp;

    elapsed = (jnow - starttime)*24*3600;

    put ord(k):0:0, ",",
        epsAcc:16:6, ",",
        z.l:20:6, ",",
        zAcc.l:20:6, ",",
        sAcc.l:20:6, ",",
        genesys.modelstat:0:0, ",",
        genesys.solvestat:0:0 /;

$include genesysmod_variable_parameter.gms
$include genesysmod_results.gms

    put_utility 'gdxout' / "%run_gdx%_k" ord(k):0:0 ".gdx";
    execute_unload;

$ifthen.outcsv %switch_write_output% == csv
    * ... your CSV dump block unchanged ...
$endif.outcsv
);

putclose pareto;
