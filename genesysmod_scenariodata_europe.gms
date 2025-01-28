AvailabilityFactor(r,'X_DAC_HT',y) = 0;
AvailabilityFactor(r,'X_DAC_LT',y) = 0;



parameter warning_TotalAnnualMinCapacityTooHigh;
warning_TotalAnnualMinCapacityTooHigh(r,t,y)$(TotalAnnualMaxCapacity(r,t,y)<TotalAnnualMinCapacity(r,t,'2025')) = 1;

TotalAnnualMaxCapacity(r,t,y)$(TotalAnnualMaxCapacity(r,t,y)<TotalAnnualMinCapacity(r,t,'2025')) = TotalAnnualMinCapacity(r,t,'2025');

NewCapacity.up('2025',t,r)$(TagTechnologyToSubsets(t,'PowerSupply') and not TotalAnnualMinCapacity(r,t,'2025')) = TotalAnnualMinCapacity(r,t,'2025');


equation Add_FlatH2Imports(y_full,l_full,r_full);
Add_FlatH2Imports(y,l,r)..   RateOfActivity(y,l,'Z_Import_H2','1',r)  =l= sum(ll,RateOfActivity(y,ll,'Z_Import_H2','1',r))*YearSplit(l,y)*1.05;

equation Add_FlatGasImports(y_full,l_full,r_full);
Add_FlatGasImports(y,l,r)..   RateOfActivity(y,l,'Z_Import_Gas','1',r)  =l= sum(ll,RateOfActivity(y,ll,'Z_Import_Gas','1',r))*YearSplit(l,y)*1.05;