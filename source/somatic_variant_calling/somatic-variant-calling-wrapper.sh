#!/bin/bash

# Wrapper script for somatic variant calling and variant filtering, script calls: X, Y, Z, I, N. 
# INPUT: List (text file) of normal-tumor (N-T) paired processed BAM files; N T.
#
# 1. Run Mutect2 on NT paired processed bam files. Outputting unfiltered vcf files and f1r2 files. 
# 2. LearnReadOrientationModel: Inputs f1r2, outputs read-orientation-model. 
# 3. GetPileupSummaries: Input: .bam, outout: Getpileupsummaries.table
# 4. CalculateContamination, input: Getpileupsummaries.table
# 5. Filtermutectcalls. 

# Source config file
source ../config.txt

# Read input file
INPUT=$1


# Reat input from paired list file, store N and T in separate lists.
INPUT_LISTN=""
INPUT_LISTT=""

# Read paired input into separate lists
while read N T; do
	#echo $N | tr '\n' ' '
	INPUT_LISTN+=`echo $N | tr '\n' ' '`
	#echo $T | tr '\n' ' '
	INPUT_LISTT+=`echo $T | tr '\n' ' '`
done < $INPUT


#Get length of paired inputs
len=`wc -l $INPUT | cut -f 1 -d " "`

echo $INPUT_LISTN
echo $INPUT_LISTT
echo $len

for (( i=0; i<$len; i++)); do
	echo $INPUT_LISTN[$i]
done









# Create a comma separated string (JOBLIST) used for parallelisation in qsub.
# Run Samtools index for each entry in list.
# Samtools index parameters: $1 = Input (BAM).

#JOBLIST=""
#for i in ${IN_FILES[@]}; do
#        JOBNAME=samtools_index_${i}
#        JOBLIST+=`echo ${JOBNAME},`
#        qsub -N ${JOBNAME} -cwd ./Samtools-index.sge ${WORK_DIR}/${i}
#done



### ISSUE: Can not iterate over two lists at the same time, can thus not pass in items from both lists as parameters to mutect2. 
### Possible solution: Pass in each line both to Mutect2 and GetPileUpSummaries instead?  





