#!/bin/bash

# Wrapper script for generating PoN. Script calls PoN1, PoN2, and PoN3, each running a step in the process of generating PoN. 
# INPUT: File containing list of processed normal sample BAM files (used to generate the PoN).
# OUTPUT: Panel of normals, used for downstream processing in Mutect2 somatic variant calling (normal-tumor mode).  
# NOTE: Make sure to be located in work_dir when executing the script. 

# PoN1 parameters: $1 = Ref, $2 = Input (BAM), $3 = Output (VCF)
# PoN2 parameters: $1 = Ref, $2 = Intervals list, $3 = Work dir, $4 = Input (VCF)
# Script3 parameters: 



# Source config file
source ../config.txt

#### POTENTIAL SOURCE OF ERROR, first step to debug if script error. 
PON_DB=${WORK_DIR}/PON_DB


INPUT=$1

# Create a list, consisting of each entry (line) in the input file.
# Convert newlines to spaces. 

IN_FILES=""
while read LINE; do
	FIRST=`echo $LINE | tr '\n' ' '`
	IN_FILES+=($FIRST)
done < $INPUT


# Run PoN1.sge for each item in input list
# PoN1 parameters: $1 = Ref, $2 = Input (BAM), $3 = Output (VCF)
# Create a comma separated string, jobnames, used for parallelisation in qsub. 

for i in ${IN_FILES[@]}; do
	JOBNAME=Mutect2_${i}
	JOBLIST+=`echo ${JOBNAME},`
	qsub -N ${JOBNAME} -cwd ./PoN1.sge $HG38 ${WORK_DIR}/${i} ${WORK_DIR}/${i%.bam}.vcf.gz
done

# Remove comma from last item in JOBLIST
JOBLIST=${JOBLIST%,}


# Create a string holding all outputs of PoN1, string will be passed as input parameter for PoN2. 

V_STR=""
for i in ${IN_FILES[@]}; do
	V_STR+="${WORK_DIR}/${i%.bam}.vcf.gz,"
done


# Start PoN2 when all PoN1 jobs are finished running.
# PoN2 parameters: $1 = Ref. genome, $2 = Intervals list, $3 = Work dir, $4 = Input
### PON_DB step potential source of error: Script only worked when run in bam file dir earlier. Debug. 

qsub -hold_jid $JOBLIST -N "PoN2.sge" -cwd ./PoN2.sge ${WORK_DIR}/PON_DB $V_STR


# Start PoN3 when PoN2 is finished running
# PoN3 parameters: $1 = Ref, $2 = germline resource (VCF from populational resource, containing allele frequencies only), $3 = Input, PoN_DB (generated in previous step), $4 = Output, PoN (VCF).

qsub -hold_jid "PoN2.sge" -N "PoN3.sge" -cwd ./PoN3.sge $PON_DB ${WORK_DIR}/PoN.vcf.gz



# Remove intermediate files when PoN3 is finished running
qsub -hold_jid "PoN3.sge" -cwd ./intermediate_file_cleanup.sh



