#!/bin/bash

# Wrapper script for processing BAM files, script calls: BAM_file_processing_0_Samtools_index.sge, BAM_file_processing_1_MarkDuplicates.sge, BAM_file_processing_2_AddOrReplaceReadGroups.sge, BAM_file_processing_3_BaseRecalibrator.sge, and BAM_file_processing_4_ApplyBQSR.sge. 
# INPUT: List (text file) of unprocessed BAM files. 
# OUTPUT: Processed BAM files, ready for variant calling. 
# NOTE: 

# Samtools index parameters: $1 = Input (BAM).
# MarkDuplicates parameters: $1 = Input (BAM), $2 = Output (BAM), $3 = Metrics_file (txt).
# AddOrReplaceReadGroups parameters: $1 = Input (BAM), $2 = Output (BAM). 
# BaseRecalibrator parameters: $1 = Input (BAM), $2 = Output (base recalibration model, table file), $3 = Reference genome (HG38), $4 = Known SNPs file, $5 = Known Indels file.
# ApplyBQSR parameters: $1 = Input (BAM), $2 = Output (BAM), $3 = Reference genome (HG38), $4 = Base recalibration table file.


# Set script variables 

	WORK_DIR=/home/xlorda/anna_tmp/test_rerun

	REF_DIR=/home/xlorda/anna_tmp/reference_and_misc_files

	HG38=${REF_DIR}/GRCh38.primary_assembly.genome.fa

	KNOWN_SNPS=${REF_DIR}/Homo_sapiens_assembly38.dbsnp138.vcf

	KNOWN_INDELS=${REF_DIR}/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
	


	# Calling scripts

		SCRIPT_PATH=/home/xlorda/Biomarkers-immuno-lungcancer/source/BAM_file_processing

		SamtoolsIndex=${SCRIPT_PATH}/BAM_file_processing_0_Samtools_index.sge

		MarkDuplicates=${SCRIPT_PATH}/BAM_file_processing_1_MarkDuplicates.sge

		AddOrReplaceReadGroups=${SCRIPT_PATH}/BAM_file_processing_2_AddOrReplaceReadGroups.sge

		BaseRecalibrator=${SCRIPT_PATH}/BAM_file_processing_3_BaseRecalibrator.sge

		ApplyBQSR=${SCRIPT_PATH}/BAM_file_processing_4_ApplyBQSR.sge




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



# Run samtools index for each output from MarkDuplicates
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
	# Set prefix for AddOrReplaceReadGroups output.
	PREFIX2=RG_${PREFIX1}

JOBLIST4=""
for i in ${IN_FILES[@]}; do
	JOBNAME=AddOrReplaceReadGroups_${PREFIX1}${i}
	JOBLIST4+=`echo $JOBNAME,`
	qsub -hold_jid $JOBLIST3 -N $JOBNAME -cwd $AddOrReplaceReadGroups ${WORK_DIR}/${PREFIX1}${i} ${WORK_DIR}/${PREFIX2}${i}
done

# Remove comma from last item in list
JOBLIST4=${JOBLIST4%,}


JOBLIST5=""
for i in ${IN_FILES[@]}; do
	JOBNAME=samtools_index_${PREFIX2}${i}
	JOBLIST5+=`echo $JOBNAME,`
	qsub -hold_jid $JOBLIST4 -N $JOBNAME -cwd $SamtoolsIndex ${WORK_DIR}/${PREFIX2}${i}
done

# Remove comma from last item in list
JOBLIST5=${JOBLIST5%,}


# Run BaseRecalibrator (GATK) for each entry in list
# BaseRecalibrator parameters: $1 = Input (BAM), $2 = Output (base recalibration model, table file), $3 = Reference genome (HG38), $4 = Known SNPs file, $5 = Known Indels file
	# Set prefix for BaseRecalibrator output (table file)
	PREFIX3=TABLE_BQSR_${PREFIX2}

JOBLIST6=""
for i in ${IN_FILES[@]}; do
	JOBNAME=BaseRecalibrator_${PREFIX2}${i}
	JOBLIST6+=`echo $JOBNAME,`
	qsub -hold_jid $JOBLIST5 -N $JOBNAME -cwd $BaseRecalibrator ${WORK_DIR}/${PREFIX2}${i} ${WORK_DIR}/${PREFIX3}${i} $HG38 $KNOWN_SNPS $KNOWN_INDELS
done

# Remove comma from last item in list
JOBLIST6=${JOBLIST6%,}


# Run ApplyBQSR (GATK) for each entry in the list
# ApplyBQSR parameters: $1 = Input (BAM), $2 = Output (BAM), $3 = Reference genome (HG38), $4 = Base recalibration table file.
	# Set prefix for ApplyBQSR output (processed BAM file)
	PREFIX4=BQSR_${PREFIX2}

JOBLIST7=""
for i in ${IN_FILES[@]}; do
	JOBNAME=ApplyBQSR_${PREFIX2}${i}
	JOBLIST7+=`echo $JOBNAME,`
	qsub -hold_jid $JOBLIST6 -N $JOBNAME -cwd $ApplyBQSR ${WORK_DIR}/${PREFIX2}${i} ${WORK_DIR}/${PREFIX4}${i} $HG38 ${WORK_DIR}/${PREFIX3}${i}
done
	


