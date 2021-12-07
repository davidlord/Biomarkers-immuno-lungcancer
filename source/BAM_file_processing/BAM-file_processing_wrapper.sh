#!/bin/bash

# Wrapper script for processing BAM files, script calls BAM_file_processing_1_MarkDuplicates.sge, BAM_file_processing_2_AddOrReplaceReadGroups.sge, X, and Y, each running a step in BAM-file processing
# INPUT: List (text file) of unprocessed BAM files. 
# OUTPUT: Processed BAM files, ready for variant calling. 
# NOTE: 

# Samtools index parameters: $1 = Input (BAM).
# MarkDuplicates parameters: $1 = Input (BAM), $2 = Output (BAM), $3 = Metrics_file (txt).
# AddOrReplaceReadGroups parameters: $1 = Input (BAM), $2 = Output (BAM). 
# BaseRecalibrator parameters: $1 = Input (BAM), $2 = Output (base recalibration model, table file), $3 = Reference genome (HG38), $4 = Known SNPs file, $5 = Known Indels file.
# ApplyBQSR parameters: 


# Set script variables 
### Remove unused script variables

	WORK_DIR=/home/xlorda/anna_tmp/test_rerun

	HG38=/home/xlorda/anna_tmp/reference_and_misc_files/GRCh38.primary_assembly.genome.fa

	INTERVALS_LIST=/home/xlorda/anna_tmp/reference_and_misc_files/wgs_calling_regions.hg38.list

	GERMLINE_RESOURCE=/home/xlorda/anna_tmp//reference_and_misc_files/af-only-gnomad.hg38.vcf.gz

	KNOWN_SNPS=/home/xlorda/anna_tmp/reference_and_misc_files/Homo_sapiens_assembly38.dbsnp138.vcf

	KNOWN_INDELS=/home/xlorda/anna_tmp/reference_and_misc_files/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
	


	# Calling scripts

		SCRIPT_PATH=/home/xlorda/Biomarkers-immuno-lungcancer/source/BAM_file_processing

		SamtoolsIndex=${SCRIPT_PATH}/BAM_file_processing_0_Samtools_index.sge

		MarkDuplicates=${SCRIPT_PATH}/BAM_file_processing_1_MarkDuplicates.sge

		AddOrReplaceReadGroups=${SCRIPT_PATH}/BAM_file_processing_2_AddOrReplaceReadGroups.sge

		BaseRecalibrator=${SCRIPT_PATH}/BAM_file_processing_3_BaseRecalibrator.sge




INPUT=$1

# Create a list, consisting of each entry (line) in the input file.
# Note: Instances in input file are separated by newlines, convert to spaces before appending to a list.

IN_FILES=""
while read LINE; do
        FIRST=`echo $LINE | tr '\n' ' '`
        IN_FILES+=($FIRST)
done < $INPUT


# Create a comma separated string (JOBLIST) used for parallelisation in qsub.
# Run samtools index for each entry in list.
# Samtools index parameters: $1 = Input (BAM).


JOBLIST=""
for i in ${IN_FILES[@]}; do
        JOBNAME=samtools_index_${i}
        JOBLIST+=`echo ${JOBNAME},`
	qsub -N ${JOBNAME} -cwd $SamtoolsIndex ${WORK_DIR}/${i}
done

# Remove comma from last item in list
JOBLIST=${JOBLIST%,}


# Run MarkDuplicates (GATK) for each entry in the list.
# MarkDuplicates parameters: $1 = Input (BAM), $2 = Output (BAM), $3 = Metrics_file (txt).

	# Set prefix for MarkDuplicates output
	PREFIX1=RMDUP_

JOBLIST2=""
for i in ${IN_FILES[@]}; do
	JOBNAME=MarkDuplicates_${i}
	JOBLIST2+=`echo $JOBNAME,`
	qsub -hold_jid $JOBLIST -N $JOBNAME -cwd $MarkDuplicates ${WORK_DIR}/${i} ${WORK_DIR}/${PREFIX1}${i} ${WORK_DIR}/${PREFIX1}${i%.bam}_metrics.txt
done

# Remove comma from last item in list
JOBLIST2=${JOBLIST2%,}



# Run samtools index for each entry in list.
# Samtools index parameters: $1 = Input (BAM).

JOBLIST3=""
for i in ${IN_FILES[@]}; do
	JOBNAME=samtools_index_${PREFIX1}${i}
	JOBLIST3+=`echo $JOBNAME,`
	qsub -hold_jid $JOBLIST2 -N $JOBNAME -cwd $SamtoolsIndex ${WORK_DIR}/${PREFIX1}${i}
done

# Remove comma from last item in list
JOBLIST3=${JOBLIST3%,}


# Run AddOrReplaceReadGroups (GATK) for each entry in list.
# AddOrReplaceReadGroups parameters: $1 = Input (BAM), $2 = Output (BAM).


	#Set prefix for AddOrReplaceReadGroups output.
	PREFIX2=RG_RMDUP_

JOBLIST4=""
for i in ${IN_FILES[@]}; do
	JOBNAME=AddOrReplaceReadGroups_${PREFIX1}${i}
	JOBLIST4+=`echo $JOBNAME,`
	qsub -hold_jid $JOBLIST3 -N $JOBNAME -cwd $AddOrReplaceReadGroups ${WORK_DIR}/${PREFIX1}${i} ${WORK_DIR}/${PREFIX2}${i}
done
 






# Run Index output? 

# Run AddOrReplaceReadGroups

# Index output? 

# Run BaseRecalibrator (BQSR step 1)

# Run ApplyBQSR (BQSR step 2)

	




