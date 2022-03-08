#!/bin/bash

# Wrapper script for processing BAM files, script calls: Samtools-index.sge, MarkDuplicates.sge, AddOrReplaceReadGroups.sge, BaseRecalibrator.sge, and ApplyBQSR.sge. 
# INPUT: List (text file) of unprocessed BAM files. 
# OUTPUT: Processed BAM files, ready for variant calling. 
# NOTE: 


# Read config file
source ../config.txt

INPUT=$1

# Create a list consisting of each entry (line) in the input file.
# Set separator as spaces instead of newlines.

IN_FILES=""
while read LINE; do
        FIRST=`echo $LINE | tr '\n' ' '`
        IN_FILES+=($FIRST)
done < $INPUT


# Create a comma separated string (JOBLIST) used for parallelisation in qsub.
# Run Samtools index for each entry in list.
# Samtools index parameters: $1 = Input (BAM).

JOBLIST=""
for i in ${IN_FILES[@]}; do
        JOBNAME=samtools_index_${i}
        JOBLIST+=`echo ${JOBNAME},`
	qsub -N ${JOBNAME} -cwd ./Samtools-index.sge ${WORK_DIR}/${i}
done

# Remove comma from last item in joblist
JOBLIST=${JOBLIST%,}


# Run MarkDuplicates (GATK) on BAM files. 
# MarkDuplicates parameters: $1 = Input (BAM), $2 = Output (BAM), $3 = Metrics_file (txt).

	# Set prefix for MarkDuplicates output
	PREFIX1=RMDUP_

JOBLIST2=""
for i in ${IN_FILES[@]}; do
	JOBNAME=MarkDuplicates_${i}
	JOBLIST2+=`echo $JOBNAME,`
	qsub -hold_jid $JOBLIST -N $JOBNAME -cwd ./MarkDuplicates.sge ${WORK_DIR}/${i} ${WORK_DIR}/${PREFIX1}${i} ${WORK_DIR}/${PREFIX1}${i%.bam}_metrics.txt
done

# Remove comma from last item in joblist2
JOBLIST2=${JOBLIST2%,}



# Run samtools index for each output from MarkDuplicates
# Samtools index parameters: $1 = Input (BAM).

JOBLIST3=""
for i in ${IN_FILES[@]}; do
	JOBNAME=samtools_index_${PREFIX1}${i}
	JOBLIST3+=`echo $JOBNAME,`
	qsub -hold_jid $JOBLIST2 -N $JOBNAME -cwd ./Samtools-index.sge ${WORK_DIR}/${PREFIX1}${i}
done

# Remove comma from last item in list
JOBLIST3=${JOBLIST3%,}


# Run AddOrReplaceReadGroups (GATK) for each output BAM from last step. 
# AddOrReplaceReadGroups parameters: $1 = Input (BAM), $2 = Output (BAM).
	# Set prefix for AddOrReplaceReadGroups output.
	PREFIX2=RG_${PREFIX1}

JOBLIST4=""
for i in ${IN_FILES[@]}; do
	JOBNAME=AddOrReplaceReadGroups_${PREFIX1}${i}
	JOBLIST4+=`echo $JOBNAME,`
	qsub -hold_jid $JOBLIST3 -N $JOBNAME -cwd ./AddOrReplaceReadGroups.sge ${WORK_DIR}/${PREFIX1}${i} ${WORK_DIR}/${PREFIX2}${i}
done

# Remove comma from last item in joblist4
JOBLIST4=${JOBLIST4%,}


JOBLIST5=""
for i in ${IN_FILES[@]}; do
	JOBNAME=samtools_index_${PREFIX2}${i}
	JOBLIST5+=`echo $JOBNAME,`
	qsub -hold_jid $JOBLIST4 -N $JOBNAME -cwd ./Samtools-index.sge ${WORK_DIR}/${PREFIX2}${i}
done

# Remove comma from last item in joblist5
JOBLIST5=${JOBLIST5%,}


# Run BaseRecalibrator (GATK) for each entry in list
# BaseRecalibrator parameters: $1 = Input (BAM), $2 = Output (base recalibration model, table file), $3 = Reference genome (HG38), $4 = Known SNPs file, $5 = Known Indels file
	# Set prefix for BaseRecalibrator output (table file)
	PREFIX3=TABLE_BQSR_${PREFIX2}

JOBLIST6=""
for i in ${IN_FILES[@]}; do
	JOBNAME=BaseRecalibrator_${PREFIX2}${i}
	JOBLIST6+=`echo $JOBNAME,`
	qsub -hold_jid $JOBLIST5 -N $JOBNAME -cwd ./BaseRecalibrator.sge ${WORK_DIR}/${PREFIX2}${i} ${WORK_DIR}/${PREFIX3}${i} $HG38 $KNOWN_SNPS $KNOWN_INDELS
done

# Remove comma from last item in joblist6
JOBLIST6=${JOBLIST6%,}


# Run ApplyBQSR (GATK) for each entry in the list
# ApplyBQSR parameters: $1 = Input (BAM), $2 = Output (BAM), $3 = Reference genome (HG38), $4 = Base recalibration table file.
	# Set prefix for ApplyBQSR output (processed BAM file)
	PREFIX4=BQSR_${PREFIX2}

JOBLIST7=""
for i in ${IN_FILES[@]}; do
	JOBNAME=ApplyBQSR_${PREFIX2}${i}
	JOBLIST7+=`echo $JOBNAME,`
	qsub -hold_jid $JOBLIST6 -N $JOBNAME -cwd ./ApplyBQSR.sge ${WORK_DIR}/${PREFIX2}${i} ${WORK_DIR}/${PREFIX4}${i} $HG38 ${WORK_DIR}/${PREFIX3}${i}
done
	
# Remove comma from last item in joblist7
JOBLIST7=${JOBLIST7%,}

# Run intermediate_file_cleanup, removing intermediate files.
qsub -hold_jid $JOBLIST7 -cwd ./intermediate_file_cleanup.sh




