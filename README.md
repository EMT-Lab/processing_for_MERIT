## Previous procedure:
1) SNP_CSV.m would select two .snp files convert to a .csv then subtract
2) SNP_CSV.m would save subtracted .csv to a folder along with frequencies, and channels (array with i,j)
3) CompleteAnalysis.m would pull .csv from said folder

## New procedure:
1) processing_for_MERIT.m converts .snp files to sparameter object https://www.mathworks.com/help/rf/ref/sparameters.html
2) Subtracts the two objects data from each other and uses that to make a new sparameter object
3) Frequencies, channels are taken from the sparameters objects instead .csv

## Benefits
1) More robust
2) Less scripts floating around
3) rfplot command makes it easy to display reflection coefficients, transmission coefficients https://www.mathworks.com/help/rf/ref/rfplot.html
