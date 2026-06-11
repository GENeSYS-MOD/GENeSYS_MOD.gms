* ============================================================
* GENeSYS-MOD: AUGMECON driver
* ============================================================

$if not set augmecon_points $setglobal augmecon_points 3
* Derive base GDX name from the -gdx= command line argument.
* $setNames splits %gams.gdx% into path (fp), filename (fn), extension (fe).
* Result: run_gdx = same name as -gdx= argument, without extension.
* anchor1 and k-outputs are then named: <gdx>_anchor1.gdx, <gdx>_k1.gdx etc.
$setNames "%gams.gdx%" gdx_fp gdx_fn gdx_fe
$if not set run_gdx $setglobal run_gdx "%gdx_fp%%gdx_fn%"
$if not set anchor1_gdx $setglobal anchor1_gdx "%run_gdx%_anchor1"
* Example: -gdx=myrun_netzero produces myrun_netzero_anchor1.gdx, myrun_netzero_k1.gdx
$if not set switch_acc_sector_select $setglobal switch_acc_sector_select 0

$eval NPOINTS %augmecon_points%
set k /k1*k%NPOINTS%/;

parameter epsGrid(k);

scalar zStar, zAccAtCost, zAccMin;
scalar zAccLo, zAccHi;

file pareto /%resultdir%pareto_augmecon.csv/;
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
    accOptSector('Resources') = 0;
    accOptSector('Storages') = 0;
    accOptSector('Transformation') = 0;
    accOptSector('CHP') = 0;
$endif.sel

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
* This prevents cascading demand effects (e.g. EV→electricity) from
* indirectly reshaping sectors that ARE in the acceptance objective.
RefNewCap(y,t,r)$(
    sum(se$(TagTechnologyToSector(t,se)=1 and accOptSector(se)=0), 1) > 0
) = NewCapacity.l(y,t,r);

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
runGuard = 1;
solve genesys minimizing zAcc using lp;
zAccMin = zAcc.l;
runGuard = 0;

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