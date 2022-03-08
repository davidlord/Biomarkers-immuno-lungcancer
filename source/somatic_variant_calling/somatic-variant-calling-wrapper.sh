#!/bin/bash

# Wrapper script for somatic variant calling and variant filtering, script calls: X, Y, Z, I, N. 
# INPUT: List (text file) of normal-tumor (N-T) paired processed BAM files; N T.
#
# 1. Run Mutect2 on NT paired processed bam files. Outputting unfiltered vcf files and f1r2 files. 
# 2. LearnReadOrientationModel: Inputs f1r2, outputs read-orientation-model. 
# 3. GetPileupSummaries: Input: .bam, outout: Getpileupsummaries.table
# 4. CalculateContamination, input: Getpileupsummaries.table
# 5. Filtermutectcalls. 

# 





INPUT=$1

# Create two lists, one containing each N entry of the input file and one containing each T entry of the input file. 



IN_FILES=""
while read N T; do
	N_LIST+=`echo $N`
	T_LIST+=`echo $T`
done < $INPUT


## echo N_LIST: $N_LIST
## echo T_LIST: $T_LIST

while read N; do
	FIRST=`echo $N | tr '\n' ' '`
	N2_LIST=+=($FIRST)
done < $N_LIST


# echo N2_LIST: $N2_LIST


