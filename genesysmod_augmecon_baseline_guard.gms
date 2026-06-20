* ============================================================
* Baseline-guard constraints for AUGMECON  — v2
* ============================================================
*
* switch_guard_mode = 0  :  Capacity-Guard (original behaviour)
*   • FIX_TotalCapacityAnnual_Sector  — equality per sector & year
*   • FIX_NewCapacity_NonOpt          — equality per tech/region
*   • Import fixes                    — always active
*
* switch_guard_mode = 1  :  Dispatch-Guard (new)
*   • RateOfActivity pinned to Anchor-1 values for all non-opt-sector
*     technologies: literal .fx = 0 where Anchor-1 value is exactly zero
*     (no roundoff risk, fully eliminated in presolve); a tight .lo/.up
*     band (+/- epsDispatchGuard, 1e-6) around the Anchor-1 value where it
*     is nonzero (only there does the .l -> parameter -> .fx roundtrip
*     risk floating-point noise)
*     → applied PROCEDURALLY in genesysmod_augmecon_driver.gms
*     → effectively fixed for solver purposes; avoids both the literal-
*       equality EB2 floating-point infeasibility AND the numerical-
*       conditioning blowup a uniform near-zero band caused at 364h/484h/724h
*   • FIX_NewCapacity_NonOpt still active as capacity safety net
*   • FIX_TotalCapacityAnnual_Sector INACTIVE for opt sectors
*     Rationale: the energy balance (EB2_EnergyBalanceEachTS) already
*     implicitly fixes total opt-sector production per timeslice once
*     demand, non-opt consumption, and imports are all frozen.
*     The opt sector is free to reallocate across technologies and
*     regions — including adjusting installed capacity — as long as
*     it satisfies the unchanged energy balance.
*   • Import fixes                    — always active
*
* Sector selection (which sectors enter zAcc) is controlled by
* accOptSector(se) in the driver — independent of this switch.
* ============================================================

scalar switch_guard_mode /0/;
* 0 = Capacity-Guard  (FIX_TotalCapacityAnnual_Sector, original)
* 1 = Dispatch-Guard  (RateOfActivity .fx=0 / .lo-.up band via driver, no capacity eq.)

scalar capDrop /0.00/;
* (not used; kept for easy switching if needed)

scalar runGuard /0/;
* 0 = guard off, 1 = guard active (used for Anchor 2)

scalar capTol /0.01/;
* Reference only — NOT applied in equality form.
* Positive tolerance forces more capacity than baseline, which can
* conflict with TotalAnnualMaxCapacity and cause infeasibility.

* ------------------------------------------------------------------
* Import baseline scalars
* ------------------------------------------------------------------
scalar RefTotalH2Import        /0/;
scalar RefTotalGasImport       /0/;
scalar RefTotalHardcoalImport  /0/;
scalar RefTotalLNGImport       /0/;
scalar RefTotalOilImport       /0/;

* ------------------------------------------------------------------
* Capacity baseline per sector/year (Capacity-Guard mode)
* ------------------------------------------------------------------
parameter RefTotalCapYearSector(SECTOR,y_full);
RefTotalCapYearSector(SECTOR,y_full) = 0;

* ------------------------------------------------------------------
* NewCapacity baseline per technology/region/year (both modes)
* Prevents cascading demand effects from non-opt sector tech swaps.
* ------------------------------------------------------------------
parameter RefNewCap(y_full,TECHNOLOGY,REGION_FULL);
RefNewCap(y_full,TECHNOLOGY,REGION_FULL) = 0;

* ------------------------------------------------------------------
* Dispatch baseline per technology/timeslice/mode/region (Dispatch-Guard)
* Populated from Anchor1 .l values in the driver; used for .fx assignment.
* Dimensions match RateOfActivity exactly so GDX load/save is trivial.
* This is the original, validated parameter (exact 595.6 GW Power-sector
* capacity constancy confirmed at 244h/364h resolution).
* ------------------------------------------------------------------
parameter RefRateOfActivity(y_full,TIMESLICE_FULL,TECHNOLOGY,MODE_OF_OPERATION,REGION_FULL);
RefRateOfActivity(y_full,l_full,TECHNOLOGY,MODE_OF_OPERATION,REGION_FULL) = 0;

* ------------------------------------------------------------------
* Equation declarations
* ------------------------------------------------------------------
equations
    FIX_H2Import
    FIX_GasImport
    FIX_HardcoalImport
    FIX_LNGImport
    FIX_OilImport
    FIX_TotalCapacityAnnual_Sector
    FIX_NewCapacity_NonOpt
;

* ------------------------------------------------------------------
* Import fixes — active in BOTH guard modes
* Prevents acceptance-driven substitution of domestic generation by imports.
* ------------------------------------------------------------------
FIX_H2Import$((runAug=1) or (runGuard=1))..
    sum((y,r), ProductionByTechnologyAnnual(y,"Z_Import_H2","H2",r))
    =e= RefTotalH2Import;

FIX_GasImport$((runAug=1) or (runGuard=1))..
    sum((y,r), ProductionByTechnologyAnnual(y,"Z_Import_Gas","Gas_Natural",r))
    =e= RefTotalGasImport;

FIX_HardcoalImport$((runAug=1) or (runGuard=1))..
    sum((y,r), ProductionByTechnologyAnnual(y,"Z_Import_Hardcoal","Hardcoal",r))
    =e= RefTotalHardcoalImport;

FIX_LNGImport$((runAug=1) or (runGuard=1))..
    sum((y,r), ProductionByTechnologyAnnual(y,"Z_Import_LNG","LNG",r))
    =e= RefTotalLNGImport;

FIX_OilImport$((runAug=1) or (runGuard=1))..
    sum((y,r), ProductionByTechnologyAnnual(y,"Z_Import_Oil","Oil",r))
    =e= RefTotalOilImport;

* ------------------------------------------------------------------
* Capacity-Guard: total installed capacity per sector and year.
* ACTIVE ONLY in switch_guard_mode = 0 (Capacity-Guard).
* In Dispatch-Guard mode (switch_guard_mode = 1) this equation
* generates ZERO rows — opt-sector capacity is free and implicitly
* bounded by the energy balance.
* ------------------------------------------------------------------
FIX_TotalCapacityAnnual_Sector(se,y)$(
    ((runAug=1) or (runGuard=1))
    and switch_guard_mode = 0
    and RefTotalCapYearSector(se,y) > 0
)..
    sum((r,t)$(TagTechnologyToSector(t,se) = 1), TotalCapacityAnnual(y,t,r))
    =e= RefTotalCapYearSector(se,y);
* Exact equality — always feasible because RefTotalCapYearSector was
* achieved in Anchor 1. A positive tolerance is NOT applied: it would
* force MORE capacity than the baseline, conflicting with
* TotalAnnualMaxCapacity and causing infeasibility in Anchor 2.

* ------------------------------------------------------------------
* NewCapacity fix for non-opt-sector technologies — BOTH guard modes.
* Prevents cascading effects: e.g. fewer EVs (Transportation) reduces
* electricity demand, indirectly reshaping the Power sector in a way
* that looks acceptance-driven but is not.
* In Dispatch-Guard mode, RateOfActivity .lo/.up pinning (applied in driver)
* is the primary constraint; this equation is a redundant safety net that
* prevents the accumulation equations from building excess capacity.
* ------------------------------------------------------------------
FIX_NewCapacity_NonOpt(y,t,r)$(
    ((runAug=1) or (runGuard=1))
    and sum(se$(TagTechnologyToSector(t,se) = 1 and accOptSector(se) = 0), 1) > 0
    and TotalAnnualMaxCapacity(r,t,y) > 0
)..
    NewCapacity(y,t,r) =e= RefNewCap(y,t,r);
* TotalAnnualMaxCapacity > 0 limits to buildable technologies.
* RefNewCap = 0 is valid: prevents building techs the cost-optimal
* solution did not invest in.

* ------------------------------------------------------------------
* Dispatch-Guard: RateOfActivity .lo/.up band for non-opt-sector technologies
*
* NOT implemented as an equation here — applied as .lo/.up variable bounds
* (+/- epsDispatchGuard around the Anchor-1 value, NOT a literal .fx) in
* genesysmod_augmecon_driver.gms immediately after Anchor 1 is saved.
* A literal .fx was used originally but over-determined
* EB2_EnergyBalanceEachTS for fuels served exclusively by non-opt-sector
* technologies via floating-point roundoff in the .l -> parameter -> .fx
* roundtrip (confirmed at 364h/484h/724h); the tiny band absorbs that
* noise while remaining numerically indistinguishable from a true fix.
*
* Why .lo/.up (not .fx) and not an equation?
*   An equation FIX_RateOfActivity_NonOpt(y,l,t,m,r) over all non-opt
*   technologies would add several million rows to the LP (y × 244l × t × m × r).
*   Variable bounding via .lo/.up is handled in presolve much like .fx:
*   Gurobi can still substitute these effectively-fixed variables out
*   before factorisation, keeping the LP small and Barrier convergence fast.
*
* See genesysmod_augmecon_driver.gms, section "DISPATCH-GUARD ANCHOR1 CAPTURE"
* for the exact implementation.
* ------------------------------------------------------------------
