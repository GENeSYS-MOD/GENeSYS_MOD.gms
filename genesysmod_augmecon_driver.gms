* #############################################################
* #  GENeSYS-MOD: AUGMECON driver (payoff table + epsilon sweep)
* #  - epsilon sweep over zAcc
* #  - ONLY ONE GDX OUTPUT (last epsilon point)
* #############################################################

$if not set switch_augmecon              $setglobal switch_augmecon 1
$if not set augmecon_points              $setglobal augmecon_points 2

$ifthen %switch_augmecon% == 1

* ------------------------------------------------------------
* Declarations MUST be outside loop/if
* ------------------------------------------------------------
scalar doWrite;
scalar zStar, zAccAtCost, zAtAccMin, zAccMin;
scalar zAccLo, zAccHi, rangeAcc;

* These are referenced by genesysmod_results.gms in YOUR file set
* If your model already declares them, remove these two lines.
scalar heapSizeAfterSolve;
scalar elapsed;

* GDX output file handle (MUST be declared with filename here)
$ifthen set Info
file gdxout / "%gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%_%info%.gdx" /;
$else
file gdxout / "%gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%.gdx" /;
$endif

* Ensure AUGMECON equations are OFF for payoff table
runAug = 0;

* (A) Cost-optimal anchor
solve genesys minimizing z using lp;
zStar      = z.l;
zAccAtCost = zAcc.l;

* (B) Acceptance-optimal anchor
solve genesys minimizing zAcc using lp;
zAtAccMin = z.l;
zAccMin   = zAcc.l;

zAccLo = min(zAccMin, zAccAtCost);
zAccHi = max(zAccMin, zAccAtCost);

* (C) Scaling for augmented term (if used inside augmecon.gms)
rangeAcc = max(1e-6, zAccHi - zAccLo);
rho      = 1e-6 * max(1, abs(zStar));

display zStar, zAccAtCost, zAtAccMin, zAccMin, zAccLo, zAccHi, rangeAcc, rho;

* (D) Build epsilon grid
$eval NPOINTS %augmecon_points%
Set k /k1*k%NPOINTS%/;

Parameter epsGrid(k), zP(k), zAccP(k), sAccP(k);
Parameter ms(k), ss(k);

epsGrid(k) = zAccLo + (ord(k)-1)/(card(k)-1) * (zAccHi - zAccLo);

file pareto /%resultdir%pareto_augmecon.csv/;
put pareto;
put "k,epsAcc,z,zAcc,sAcc,modelstat,solvestat" /;

* Activate AUGMECON equations for ε-sweep
runAug = 1;

loop(k,
    epsAcc = epsGrid(k);

    solve genesys minimizing zAug using lp;

    zP(k)    = z.l;
    zAccP(k) = zAcc.l;
    sAccP(k) = sAcc.l;
    ms(k)    = genesys.modelstat;
    ss(k)    = genesys.solvestat;

    put ord(k):0:0, ",",
        epsAcc:16:6, ",",
        z.l:20:6, ",",
        zAcc.l:20:6, ",",
        sAcc.l:20:6, ",",
        genesys.modelstat:0:0, ",",
        genesys.solvestat:0:0 /;
);

putclose pareto;

* ------------------------------------------------------------
* ONLY ONE GDX: use LAST solve status
* ------------------------------------------------------------
doWrite = (genesys.modelstat = 1 and genesys.solvestat = 1);

* If these exist in your core model, set them here; otherwise keep 0
heapSizeAfterSolve = 0;
elapsed            = 0;

* IMPORTANT:
* These includes MUST be outside any loop/if,
* because genesysmod_variable_parameter.gms declares parameters.
$include genesysmod_variable_parameter.gms
$include genesysmod_results.gms


$else

* ------------------------------------------------------------
* Original weighted-sum solve
* ------------------------------------------------------------
scalar doWrite;
scalar heapSizeAfterSolve;
scalar elapsed;

$ifthen set Info
file gdxout / "%gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%_%info%.gdx" /;
$else
file gdxout / "%gdxdir%Output_%model_region%_%emissionPathway%_%emissionScenario%.gdx" /;
$endif

runAug = 0;
solve genesys minimizing zBi using lp;

doWrite = (genesys.modelstat = 1 and genesys.solvestat = 1);

heapSizeAfterSolve = 0;
elapsed            = 0;

$include genesysmod_variable_parameter.gms
$include genesysmod_results.gms

$endif
