* GENeSYS-MOD v3.1 [Global Energy System Model]  ~ March 2022
*
* #############################################################
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*
* #############################################################



* ################### CHOOSE CALCULATED YEARS ###################
***  TO LEAVE OUT A CERTAIN YEAR, REMOVE COMMENT OF RESPECTIVE LINE ***

*y('2018') = no;
y('2020') = no;
*y('2022') = no;
*y('2025') = no;
*y('2030') = no;
*y('2035') = no;
*y('2040') = no;
*y('2045') = no;
*y('2050') = no;

* ################### OTHER GENERAL INPUTS ###################

DepreciationMethod = 1;
GeneralDiscountRate(r) = 0.05;
TechnologyDiscountRate(r,t)$(TagTechnologyToSubsets(t,'Households')) = 0.05;
TechnologyDiscountRate(r,t)$(not TagTechnologyToSubsets(t,'Households')) = 0.05;
SocialDiscountRate(r) = 0.05;


scalar InvestmentLimit  Freedom for investment choices to spread across periods. A value of 1 would mean equal share for each period.
                      /1.9/;
scalar NewRESCapacity /0.1/;

scalar StorageLimitOffset /0.015/;

BaseYearSlack(f) = 0.035;
BaseYearSlack('Power') = 0.035;

