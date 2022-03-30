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
echo Running Samtools index.
JOBLIST=""
for i in ${IN_FILES[@]}; do
        JOBNAME=samtools_index_${i}
        JOBLIST+=`echo ${JOBNAME},`
	qsub -N ${JOBNAME} -cwd ./Samtools-index.sge ${i}
done

# Remove comma from last item in joblist
JOBLIST=${JOBLIST%,}


# Run MarkDuplicates (GATK) on BAM files. 
# MarkDuplicates parameters: $1 = Input (BAM), $2 = Output (BAM), $3 = Metrics_file (txt).
echo Running MarkDuplicates GATK4.
JOBLIST2=""
for i in ${IN_FILES[@]}; do
	JOBNAME=MarkDuplicates_${i}
	JOBLIST2+=`echo $JOBNAME,`
	qsub -hold_jid $JOBLIST -N $JOBNAME -cwd ./MarkDuplicates.sge ${i} RMDUP_${i} ${i%.bam}_MarkDuplicates.metrics.txt
done

# Remove comma from last item in joblist2
JOBLIST2=${JOBLIST2%,}



# Run samtools index for each output from MarkDuplicates
# Samtools index parameters: $1 = Input (BAM).
echo Running Samtools index.
JOBLIST3=""
for i in ${IN_FILES[@]}; do
	JOBNAME=samtools_index_RMDUP_${i}
	JOBLIST3+=`echo $JOBNAME,`
	qsub -hold_jid $JOBLIST2 -N $JOBNAME -cwd ./Samtools-index.sge RMDUP_${i}
done

# Remove comma from last item in list
JOBLIST3=${JOBLIST3%,}


# Run AddOrReplaceReadGroups (GATK) for each output BAM from last step. 
# AddOrReplaceReadGroups parameters: $1 = Input (BAM), $2 = Output (BAM).
echo Running AddOrReplaceReadGroups GATK4.
JOBLIST4=""
for i in ${IN_FILES[@]}; do
	JOBNAME=AddOrReplaceReadGroups_${i}
	JOBLIST4+=`echo $JOBNAME,`
	qsub -hold_jid $JOBLIST3 -N $JOBNAME -cwd ./AddOrReplaceReadGroups.sge RMDUP_${i} RG_RMDUP_${i}
done

# Remove comma from last item in joblist4
JOBLIST4=${JOBLIST4%,}

# Run Samtools index on output. 
echo Running Samtools index. 
JOBLIST5=""
for i in ${IN_FILES[@]}; do
	JOBNAME=samtools_index_RG_RMDUP_${i}
	JOBLIST5+=`echo $JOBNAME,`
	qsub -hold_jid $JOBLIST4 -N $JOBNAME -cwd ./Samtools-index.sge RG_RMDUP_${i}
done

# Remove comma from last item in joblist5
JOBLIST5=${JOBLIST5%,}


# Run BaseRecalibrator (GATK) for each entry in list
# BaseRecalibrator parameters: $1 = Input (BAM), $2 = Output (base recalibration model, table file), $3 = Reference genome (HG38), $4 = Known SNPs file, $5 = Known Indels file
echo Running BaseRecalibrator GATK4.
JOBLIST6=""
for i in ${IN_FILES[@]}; do
	JOBNAME=BaseRecalibrator_${i}
	JOBLIST6+=`echo $JOBNAME,`
	qsub -hold_jid $JOBLIST5 -N $JOBNAME -cwd ./BaseRecalibrator.sge RG_RMDUP_${i} ${i%.bam}.BQSR.table
done

# Remove comma from last item in joblist6
JOBLIST6=${JOBLIST6%,}


# Run ApplyBQSR (GATK) for each entry in the list
# ApplyBQSR parameters: $1 = Input (BAM), $2 = Output (BAM), $3 = Reference genome (HG38), $4 = Base recalibration table file.
echo Running ApplyBQSR GATK4.
JOBLIST7=""
for i in ${IN_FILES[@]}; do
	JOBNAME=ApplyBQSR_${i}
	JOBLIST7+=`echo $JOBNAME,`
	qsub -hold_jid $JOBLIST6 -N $JOBNAME -cwd ./ApplyBQSR.sge RG_RMDUP_${i} BQSR_RG_RMDUP_${i} ${i%.bam}.BQSR.table
done
	
# Remove comma from last item in joblist7
JOBLIST7=${JOBLIST7%,}

echo Cleaning up intermediate files.
# Run intermediate_file_cleanup, removing intermediate files.
qsub -hold_jid $JOBLIST7 -cwd ./intermediate_file_cleanup.sh




