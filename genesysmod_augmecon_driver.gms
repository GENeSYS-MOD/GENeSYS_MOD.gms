* ============================================================
* GENeSYS-MOD: AUGMECON driver
* - payoff anchors
* - epsilon sweep
* - per-point GDX + per-point CSV dumps
* ============================================================

$if not set augmecon_points $setglobal augmecon_points 3

$eval NPOINTS %augmecon_points%
set k /k1*k%NPOINTS%/;

parameter epsGrid(k);

scalar zStar, zAccAtCost, zAccMin;
scalar zAccLo, zAccHi;

file pareto /%resultdir%pareto_augmecon.csv/;
put pareto;
put "k,epsAcc,z,zAcc,sAcc,modelstat,solvestat" /;

* -------------------------------------------------
* Anchors
* -------------------------------------------------
runAug = 0;

solve genesys minimizing z using lp;
zStar      = z.l;
zAccAtCost = zAcc.l;

solve genesys minimizing zAcc using lp;
zAccMin = zAcc.l;

* numeric settings for augmented objective
zAccLo  = min(zAccMin, zAccAtCost);
zAccHi  = max(zAccMin, zAccAtCost);

rangeAcc = max(1e-6, zAccHi - zAccLo);
rho      = 1e-6 * max(1, abs(zStar));

* epsilon grid (guard for NPOINTS=1)
epsGrid(k) = zAccLo;
epsGrid(k)$(card(k) > 1) = zAccLo + (ord(k)-1)/(card(k)-1) * (zAccHi - zAccLo);

* -------------------------------------------------
* AUGMECON LOOP
* -------------------------------------------------
runAug = 1;

loop(k,

    epsAcc = epsGrid(k);

    solve genesys minimizing zAug using lp;

* update runtime scalar (used in genesysmod_results.gms)
    elapsed = (jnow - starttime)*24*3600;

    put ord(k):0:0, ",",
        epsAcc:16:6, ",",
        z.l:20:6, ",",
        zAcc.l:20:6, ",",
        sAcc.l:20:6, ",",
        genesys.modelstat:0:0, ",",
        genesys.solvestat:0:0 /;

* --- compute derived params first, then results
$include genesysmod_variable_parameter.gms
$include genesysmod_results.gms

* --- write GDX for this point
    put_utility 'gdxout' /
        "%gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%_k"
        ord(k):0:0
        ".gdx";
    execute_unload;

* --- write CSV dumps per point (only if requested)
$ifthen %switch_write_output% == csv

* Production (timeslice)
    put_utility 'shell' /
        'cmd /c echo Region,Sector,Technology,Mode,Fuel,Timeslice,Type,Unit,Scenario,Year,Value> "%resultdir%Output_Production_%model_region%_%emissionPathway%_%emissionScenario%_k'
        ord(k):0:0
        '.csv"';
    put_utility 'shell' /
        'gdxdump "%gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%_k'
        ord(k):0:0
        '.gdx" symb=output_energy_balance format=csv noHeader >> "%resultdir%Output_Production_%model_region%_%emissionPathway%_%emissionScenario%_k'
        ord(k):0:0
        '.csv"';

* Annual Production
    put_utility 'shell' /
        'cmd /c echo Region,Sector,Technology,Fuel,Type,Unit,Scenario,Year,Value> "%resultdir%Output_AnnualProduction_%model_region%_%emissionPathway%_%emissionScenario%_k'
        ord(k):0:0
        '.csv"';
    put_utility 'shell' /
        'gdxdump "%gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%_k'
        ord(k):0:0
        '.gdx" symb=output_energy_balance_annual format=csv noHeader >> "%resultdir%Output_AnnualProduction_%model_region%_%emissionPathway%_%emissionScenario%_k'
        ord(k):0:0
        '.csv"';

* Capacity
    put_utility 'shell' /
        'cmd /c echo Region,Sector,Technology,Type,Scenario,Year,Value> "%resultdir%Output_Capacity_%model_region%_%emissionPathway%_%emissionScenario%_k'
        ord(k):0:0
        '.csv"';
    put_utility 'shell' /
        'gdxdump "%gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%_k'
        ord(k):0:0
        '.gdx" symb=output_capacity format=csv noHeader >> "%resultdir%Output_Capacity_%model_region%_%emissionPathway%_%emissionScenario%_k'
        ord(k):0:0
        '.csv"';

* Emissions
    put_utility 'shell' /
        'cmd /c echo Region,Sector,Emission,Technology,Type,Scenario,Year,Value> "%resultdir%Output_Emissions_%model_region%_%emissionPathway%_%emissionScenario%_k'
        ord(k):0:0
        '.csv"';
    put_utility 'shell' /
        'gdxdump "%gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%_k'
        ord(k):0:0
        '.gdx" symb=output_emissions format=csv noHeader >> "%resultdir%Output_Emissions_%model_region%_%emissionPathway%_%emissionScenario%_k'
        ord(k):0:0
        '.csv"';

* Objective / meta (optional but usually helpful)
    put_utility 'shell' /
        'cmd /c echo Name,Scenario,Value> "%resultdir%Output_Objectives_%model_region%_%emissionPathway%_%emissionScenario%_k'
        ord(k):0:0
        '.csv"';
    put_utility 'shell' /
        'gdxdump "%gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%_k'
        ord(k):0:0
        '.gdx" symb=output_z format=csv noHeader >> "%resultdir%Output_Objectives_%model_region%_%emissionPathway%_%emissionScenario%_k'
        ord(k):0:0
        '.csv"';

    put_utility 'shell' /
        'cmd /c echo Name,Scenario,x,x,Value> "%resultdir%Output_ModelMeta_%model_region%_%emissionPathway%_%emissionScenario%_k'
        ord(k):0:0
        '.csv"';
    put_utility 'shell' /
        'gdxdump "%gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%_k'
        ord(k):0:0
        '.gdx" symb=output_model format=csv noHeader >> "%resultdir%Output_ModelMeta_%model_region%_%emissionPathway%_%emissionScenario%_k'
        ord(k):0:0
        '.csv"';

$endif

);

putclose pareto;
