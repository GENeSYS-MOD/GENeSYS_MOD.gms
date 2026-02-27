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

* Minimizing zAug => minimize cost, and secondarily drive sAcc -> 0 (tight epsilon)
augObj$(runAug = 1)..
    zAug =e= z + rho * (sAcc / rangeAcc);

