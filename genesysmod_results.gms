* ============================================================
* GENeSYS-MOD — RESULTS COMPUTATION ONLY
* (NO file output, NO execute_unload)
* ============================================================

* -------------------------------
* Trade & capacity diagnostics
* -------------------------------
check_tradecapacityusage(y,l,f,r,rr)$(Import.l(y,l,f,rr,r) and TagFuelToSubsets(f,'GasFuels')) =
    (TotalTradeCapacity.l(y,f,r,rr)*YearSplit(l,y)) - Import.l(y,l,f,rr,r);

check_tradecapacityfull(y,l,r,rr)$(
    sum(f$(TagFuelToSubsets(f,'GasFuels')), Import.l(y,l,f,rr,r))
      = (TotalTradeCapacity.l(y,'Gas_Natural',r,rr)*YearSplit(l,y))
    and TotalTradeCapacity.l(y,'Gas_Natural',r,rr)
) = 1;

* -------------------------------
* Energy balances
* -------------------------------
output_energy_balance(r,se,t,m,f,l,'Production','PJ','%emissionPathway%_%emissionScenario%',y)$(TagTechnologyToSector(t,se) and not TagTechnologyToSector(t,'Transportation')) =
    RateOfProductionByTechnologyByMode(y,l,t,m,f,r) * YearSplit(l,y);

output_energy_balance(r,'Transportation',t,m,f,l,'Production','billion km','%emissionPathway%_%emissionScenario%',y)$(TagTechnologyToSector(t,'Transportation')) =
    RateOfProductionByTechnologyByMode(y,l,t,m,f,r) * YearSplit(l,y);

output_energy_balance(r,se,t,m,f,l,'Use','PJ','%emissionPathway%_%emissionScenario%',y)$(TagTechnologyToSector(t,se)) =
    -RateOfUseByTechnologyByMode(y,l,t,m,f,r) * YearSplit(l,y);

* -------------------------------
* Annual aggregation
* -------------------------------
output_energy_balance_annual(r,se,t,f,'Production','PJ','%emissionPathway%_%emissionScenario%',y) =
    sum((l,m), output_energy_balance(r,se,t,m,f,l,'Production','PJ','%emissionPathway%_%emissionScenario%',y));

output_energy_balance_annual(r,se,t,f,'Use','PJ','%emissionPathway%_%emissionScenario%',y) =
    sum((l,m), output_energy_balance(r,se,t,m,f,l,'Use','PJ','%emissionPathway%_%emissionScenario%',y));

* -------------------------------
* Capacity
* -------------------------------
output_capacity(r,se,t,'TotalCapacity','%emissionPathway%_%emissionScenario%',y)$(TagTechnologyToSector(t,se)) = TotalCapacityAnnual.l(y,t,r);

* -------------------------------
* Emissions
* -------------------------------
output_emissions(r,se,e,t,'Emissions','%emissionPathway%_%emissionScenario%',y)$(TagTechnologyToSector(t,se)) = AnnualTechnologyEmission.l(y,t,e,r);

* -------------------------------
* Objective values
* -------------------------------
output_z('z_system_costs','%emissionPathway%_%emissionScenario%') = z.l;
output_z('zAcc','%emissionPathway%_%emissionScenario%') = zAcc.l;

* -------------------------------
* Meta
* -------------------------------
output_model('Objective','%emissionPathway%_%emissionScenario%','x','x') = z.l;
output_model('Runtime','%emissionPathway%_%emissionScenario%','x','x') = elapsed;
