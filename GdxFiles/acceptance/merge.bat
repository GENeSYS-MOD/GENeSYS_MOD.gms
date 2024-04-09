echo Step 1: merge gdx files
gdxmerge *.gdx id=AverageYearlyAcceptance,z

echo Step 2: create energy balance csv
echo Model Version,Year,Value > output_averageyearlyacceptance.csv
gdxdump merged.gdx symb=AverageYearlyAcceptance format=csv noHeader >> output_averageyearlyacceptance.csv

echo Step 3: create emissions csv
echo Model Version,Value > output_objvalue.csv
gdxdump merged.gdx symb=z format=csv noHeader >> output_objvalue.csv


pause