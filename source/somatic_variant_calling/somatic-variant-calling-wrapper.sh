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


# Create a comma separated string (JOBLIST) used for parallelisation in qsub
# Run Mutect2 on paired normal-tumor bam files. 
# Mutect2 parameters: $1 = Normal.bam, $2 = Tumor.bam, $3 = f1r2.tar.gz output, $4 = Output.unfiltered.vcf.gz, $5 = bam-out output.
echo Running Mutect2 on paired normal-tumor bam files.
JOBLIST1=""
while read N T; do
	JOBNAME=Mutect2_${N}
	JOBLIST1+=`echo ${JOBNAME},`
	qsub -N $JOBNAME -cwd ./Mutect2.sge $N $T ${T%.bam}_f1r2.tar.gz ${T%.bam}.unfiltered.vcf.gz ${T%.bam}_normal-tumor.bam
done < $INPUT
# Remove comma from last item in JOBLIST1
JOBLIST1=${JOBLIST1%,}


# Run GetPileupSummaries on normal samples when Mutect2 is done running
# GetPileupSummaries parameters: $1 = input.bam, $2 = output.table
echo Running GetPileupSummaries on normal samples.
JOBLIST2=""
while read N T; do
	JOBNAME=GetPileupSummaries-normal-${N}
	JOBLIST2+=`echo ${JOBNAME},`
	qsub -hold_jid $JOBLIST1 -N $JOBNAME -cwd ./GetPileupSummaries.sge ${N} ${N%.bam}.pileups.normal.table
done < $INPUT
# Remove last comma from JOBLIST2
JOBLIST2=${JOBLIST2%,}


# Run GetPileupSummaries on tumor samples when previous GetPilupSummaries processes are done running.
# GetPileupSummaries parameters: $1 = input.bam, $2 = output.table
echo Running GetPileupSummaries on tumor samples.
JOBLIST3=""
while read N T; do
	JOBNAME=GetPileupSummaries-tumor-${T}
	JOBLIST3+=`echo ${JOBNAME},`
	qsub -hold_jid $JOBLIST2 -N $JOBNAME -cwd ./GetPileupSummaries.sge ${T} ${T%.bam}.pileups.tumor.table
done < $INPUT
# Remove last comma from JOBLIST3
JOBLIST3=${JOBLIST3%,}


# Run CalculateContamination on pileups.table files when previous GetPileupSummaries processes are done running
# CalculateContamination parameters: $1 = pileups.tumor.table, $2 = pileups.normal.table, $3 = tumor.segments.table (output), $4 = contamination.table (output)
echo Running CalculateContamination.
JOBLIST4=""
while read N T; do
	JOBNAME=CalculateContamination_${T}
	JOBLIST4+=`echo ${JOBNAME},`
	qsub -hold_jid $JOBLIST3 -N $JOBNAME -cwd ./CalculateContamination.sge ${T%.bam}.pileups.tumor.table ${N%.bam}.pileups.normal.table ${T%.bam}.segments.table ${T%.bam}.contamination.table
done < $INPUT
# Remove last comma from JOBLIST4
JOBLIST4=${JOBLIST4%,}


# Run LearnReadOrientationModel when CalculateContamination is done running
# LearnReadOrientationModel parameters: $1 = f1r2.tar.gz (input), $2 = orientation.model.tar.gz (output)
echo Running LearnReadOrientationModel.
JOBLIST5=""
while read N T; do
	JOBNAME=LearnReadOrientationModel_${T}
	JOBLIST5+=`echo ${JOBNAME},`
	qsub -hold_jid $JOBLIST4 -N $JOBNAME -cwd ./LearnReadOrientationModel.sge ${T%.bam}_f1r2.tar.gz ${T%.bam}.read-orientation-model.tar.gz
done < $INPUT
# Remove last comma from JOBLIST5
JOBLIST5=${JOBLIST5%,}


# Run FilterMutectCalls when CalculateContamination is done running
# FilterMutectCalls parameters: $1 = unfiltered.vcf.gz (input), $2 = segments.table
echo Running FilterMutectCalls on unfiltered .vcf files. 
JOBLIST6=""
VCF_FILES_LIST=""
while read N T; do
	JOBNAME=FilterMutectCalls_${T}
	JOBLIST6+=`echo ${JOBNAME},`
		# Get sample name
		OUT_FIRST=${T#*[0-9]_}
		OUT_SECOND=${OUT_FIRST%lib*}
		OUTNAME=${OUT_SECOND%_}
	qsub -hold_jid $JOBLIST5 -N $JOBNAME -cwd ./FilterMutectCalls.sge ${T%.bam}.unfiltered.vcf.gz ${T%.bam}.segments.table ${T%.bam}.contamination.table ${T%.bam}.read-orientation-model.tar.gz ${OUTNAME}.filtered.vcf.gz
done < $INPUT





