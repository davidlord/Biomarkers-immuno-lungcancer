### NOTE: Create wrapper for this...

# The scripts in this directory are used for microsatellite instability (MSI) analysis of processed .bam files. 
# The scripts are intended to be run sequentially.

# 1. RealignerTargetCreator (GATK) identifies target intervals in the .bam file. 
# 2. IndelRealigner (GATK) performs local realignment on the target identified in the upstream process. 
# 3. MSIsensor-pr...


