* ###################### genesysmod_acceptance_results.gms #######################
*
* GENeSYS-MOD v3.1 [Global Energy System Model]  ~ March 2022
*
* #############################################################
* Licensed under the Apache License, Version 2.0
* #############################################################

* =====================================================================
* FIXES:
*  - NO $onecho inside runtime if(...)
*  - Tagged $onecho/$offecho (prevents nesting errors)
*  - Removed stray extra $endif (only close the two tagged ifthens)
*  - Optional per-point suffix via %ktag% (set by AUGMECON driver)
* =====================================================================

* ---------------------------------------------------------------------------
* Compile-time switches only
* ---------------------------------------------------------------------------
$ifthen.accRes "%switch_acceptance_factor%" == "1"
$ifthen.accRes2 "%switch_augmecon%" == "1"

* ---------------------------------------------------------------------------
* Optional AUGMECON point suffix (driver can set: $setglobal ktag _k1 etc.)
* ---------------------------------------------------------------------------
$if not set ktag $setglobal ktag

* ---------------------------------------------------------------------------
* Declarations MUST be outside runtime if(...)
* ---------------------------------------------------------------------------
Parameter AverageYearlyAcceptancePerRegion(r_full,y_full);
Parameter AverageYearlyAcceptance(y_full);
Parameter ShareofTotalAcceptanceperRegion(r_full,y_full);
Parameter ShareofNCapacity(r_full,y_full);

* ---------------------------------------------------------------------------
* Excel export mapping (compile-time echo, ALWAYS balanced)
* ---------------------------------------------------------------------------
$onecho.accX >%tempdir%temp_%Acceptance_data_file%%ktag%.tmp
se=0
        var=Acceptance                            Rng=Acceptance!A1                       rdim=3    cdim=0
text="Region"                                     Rng=Acceptance!A1
text="Technology"                                 Rng=Acceptance!B1
text="Year"                                       Rng=Acceptance!C1
text="Acceptance"                                 Rng=Acceptance!D1

        var=Acceptance_Powerlines                 Rng=Acceptance_Powerlines!A1            rdim=4    cdim=0
text="Region"                                     Rng=Acceptance_Powerlines!B1
text="Region_2"                                   Rng=Acceptance_Powerlines!C1
text="Fuel"                                       Rng=Acceptance_Powerlines!D1
text="Year"                                       Rng=Acceptance_Powerlines!E1
text="Acceptance"                                 Rng=Acceptance_Powerlines!F1

        var=TotalAcceptanceperRegion              Rng=TotalAcceptanceperRegion!A1         rdim=2    cdim=0
text="Region"                                     Rng=TotalAcceptanceperRegion!A1
text="Year"                                       Rng=TotalAcceptanceperRegion!B1
text="TotalAcceptanceperRegion"                   Rng=TotalAcceptanceperRegion!C1

        var=TotalAcceptanceperRegion_Powerlines   Rng=TotalAcceptanceperRegion_P!A1       rdim=2    cdim=0
text="Region"                                     Rng=TotalAcceptanceperRegion_P!B1
text="Year"                                       Rng=TotalAcceptanceperRegion_P!C1
text="TotalAcceptanceperRegion"                   Rng=TotalAcceptanceperRegion_P!D1

        var=TotalAcceptance                       Rng=TotalAcceptance!A1                  rdim=1    cdim=0
text="Year"                                       Rng=TotalAcceptance!A1
text="TotalAcceptance"                            Rng=TotalAcceptance!B1

        var=TotalAcceptance_Powerlines            Rng=TotalAcceptance_Powerlines!A1       rdim=1    cdim=0
text="Year"                                       Rng=TotalAcceptance_Powerlines!A1
text="TotalAcceptance"                            Rng=TotalAcceptance_Powerlines!B1

        var=TotalNCapacityperRegion               Rng=TotalNCapacityperRegion!A1          rdim=2    cdim=0
text="Region"                                     Rng=TotalNCapacityperRegion!A1
text="Year"                                       Rng=TotalNCapacityperRegion!B1
text="TotalNCapacityperRegion"                    Rng=TotalNCapacityperRegion!C1

        var=TotalNCapacityperRegion_Powerlines    Rng=TotalNCapacityperRegion_P!A1        rdim=2    cdim=0
text="Region"                                     Rng=TotalNCapacityperRegion_P!A1
text="Year"                                       Rng=TotalNCapacityperRegion_P!B1
text="TotalNCapacityperRegion"                    Rng=TotalNCapacityperRegion_P!C1

        var=TotalNCapacity                        Rng=TotalNCapacity!A1                   rdim=1    cdim=0
text="Year"                                       Rng=TotalNCapacity!A1
text="TotalNCapacity"                             Rng=TotalNCapacity!B1

        var=TotalNCapacity_Powerlines             Rng=TotalNCapacity_Powerlines!A1        rdim=1    cdim=0
text="Year"                                       Rng=TotalNCapacity_Powerlines!A1
text="TotalNCapacity"                             Rng=TotalNCapacity_Powerlines!B1

        par=AverageYearlyAcceptance               Rng=AverageYearlyAcceptance!A1          rdim=1    cdim=0
text="Year"                                       Rng=AverageYearlyAcceptance!A1
text="AverageYearlyAcceptance"                    Rng=AverageYearlyAcceptance!B1

        par=AverageYearlyAcceptancePerRegion      Rng=AvgYearlyAcceptancePerRegion!A1     rdim=2    cdim=0
text="Region"                                     Rng=AvgYearlyAcceptancePerRegion!A1
text="Year"                                       Rng=AvgYearlyAcceptancePerRegion!B1
text="AverageYearlyAcceptancePerRegion"           Rng=AvgYearlyAcceptancePerRegion!C1

        par=ShareofTotalAcceptanceperRegion       Rng=ShareofTotalAcceptanceperRegion!A1  rdim=2    cdim=0
text="Region"                                     Rng=ShareofTotalAcceptanceperRegion!A1
text="Year"                                       Rng=ShareofTotalAcceptanceperRegion!B1
text="ShareofTotalAcceptanceperRegion"            Rng=ShareofTotalAcceptanceperRegion!C1

        par=ShareofNCapacity                      Rng=ShareofNCapacity!A1                 rdim=2    cdim=0
text="Region"                                     Rng=ShareofNCapacity!A1
text="Year"                                       Rng=ShareofNCapacity!B1
text="ShareofNCapacity"                           Rng=ShareofNCapacity!C1
$offecho.accX

* ---------------------------------------------------------------------------
* Runtime execution only when runAug=1
* ---------------------------------------------------------------------------
if(runAug = 1,

    AverageYearlyAcceptancePerRegion(r,y)$(TotalNCapacityperRegion.l(r,y) > 0) =
        (TotalAcceptanceperRegion.l(r,y) + TotalAcceptanceperRegion_PowerLines.l(r,y))
      / (TotalNCapacityperRegion.l(r,y) + TotalNCapacityperRegion_PowerLines.l(r,y));

    AverageYearlyAcceptance(y)$(TotalNCapacity.l(y) > 0) =
        (TotalAcceptance.l(y) + TotalAcceptance_PowerLines.l(y))
      / (TotalNCapacity.l(y) + TotalNCapacity_PowerLines.l(y));

    ShareofTotalAcceptanceperRegion(r,y)$(TotalAcceptance.l(y) > 0) =
        (TotalAcceptanceperRegion.l(r,y) + TotalAcceptanceperRegion_PowerLines.l(r,y))
      / (TotalAcceptance.l(y) + TotalAcceptance_PowerLines.l(y));

    ShareofNCapacity(r,y)$(TotalNCapacity.l(y) > 0) =
        (TotalNCapacityperRegion.l(r,y) + TotalNCapacityperRegion_PowerLines.l(r,y))
      / (TotalNCapacity.l(y) + TotalNCapacity_PowerLines.l(y));

    execute_unload "%gdxdir%Acceptance_%model_region%_%emissionPathway%_%emissionScenario%%ktag%.gdx"
        Acceptance
        Acceptance_Powerlines
        TotalAcceptanceperRegion
        TotalAcceptanceperRegion_Powerlines
        TotalAcceptance
        TotalAcceptance_Powerlines
        TotalNCapacityperRegion
        TotalNCapacityperRegion_Powerlines
        TotalNCapacity
        TotalNCapacity_Powerlines
        AverageYearlyAcceptance
        AverageYearlyAcceptancePerRegion
        ShareofTotalAcceptanceperRegion
        ShareofNCapacity
        Z
    ;

    execute 'gdxxrw.exe i=%gdxdir%Acceptance_%model_region%_%emissionPathway%_%emissionScenario%%ktag%.gdx UpdLinks=3 o=%resultdir%Acceptance_Results_%model_region%_%emissionPathway%_%emissionScenario%%ktag%.xlsx @%tempdir%temp_%Acceptance_data_file%%ktag%.tmp';

);

$endif.accRes2
$endif.accRes
