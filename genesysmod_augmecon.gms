* #############################################################
* #  GENeSYS-MOD: AUGMECON (Augmented epsilon-constraint) add-on
* #
* #  Include this file AFTER:  $include genesysmod_equ.gms
* #  and BEFORE the model statement:  model genesys /all/ ... /;
* #
* #  It adds:
* #    - zAug : augmented objective variable
* #    - sAcc : slack for epsilon constraint on zAcc
* #    - accEps / augObj equations (activated via runAug=1)
* #
* #############################################################

* --- augmented objective variable (free) ---
free variable zAug "AUGMECON augmented objective (cost + tiny penalty on epsilon slack)";

* --- slack for epsilon constraint ---
positive variable sAcc "slack for epsilon constraint on zAcc (forces zAcc <= epsAcc)";

* --- AUGMECON controls (set by driver) ---
scalar epsAcc   /0/
*"epsilon bound for zAcc";
scalar rho      /0/
*"augmentation weight (small)";
scalar rangeAcc /1/
*"normalization range for zAcc";
scalar runAug   /0/
*"0=off, 1=activate AUGMECON equations";

equations
    accEps  "AUGMECON epsilon constraint: zAcc + sAcc = epsAcc"
    augObj  "AUGMECON augmented objective definition";

* Activate only when runAug = 1 (so payoff-table solves are unaffected)
accEps$(runAug = 1)..
    zAcc + sAcc =e= epsAcc;

* Minimizing zAug => minimize cost, and secondarily REWARD slack so that among
* all cost-equivalent solutions the one with the LOWEST zAcc (best acceptance)
* is selected. This is the standard AUGMECON augmentation and guarantees the
* reported points are strictly Pareto-efficient, not weakly-dominated.
*
* NOTE: the sign was previously '+', which PENALISED slack and therefore drove
* zAcc UP to epsAcc at every point (sAcc = 0 everywhere in the output). Near the
* cost-optimal end that produced a spurious "free-lunch" frontier segment
* (k7-k10): identical generation capacity, near-flat cost, yet zAcc smeared from
* 56.7 up to 63.4 purely because the augmentation forced zAcc onto the epsilon
* bound. With the corrected '-' sign, those dominated points collapse onto the
* true minimum-resistance cost-optimal solution, and the remaining frontier is
* genuinely efficient.
augObj$(runAug = 1)..
    zAug =e= z - rho * (sAcc / rangeAcc);

