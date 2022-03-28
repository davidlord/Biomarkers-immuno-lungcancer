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


#Get length of paired inputs
#len=`wc -l $INPUT | cut -f 1 -d " "`

# Create a comma separated string (JOBLIST) used for parallelisation in qsub.
echo Running Mutect2 on paired normal-tumor bam files.
JOBLIST1=""
while read N T; do
	# Convert newlines to spaces
	#N_FIRST=`echo ${N} | tr '\n' ' '`
	#T_FIRST=`echo ${T} | tr '\n' ' '`
	# String manipulation: Get samplename (MOVE TO LAST STEP INSTEAD)
		#M2_OUT_1=${T_FIRST#*[0-9]_}
		#M2_OUT_2=${M2_OUT_1%lib*}
		#M2_OUT=${M2_OUT_2%_}
	# Run Mutect2 for each normal-tumor .bam file pair
	JOBNAME1=Mutect2_${N}
	JOBLIST1+=`echo ${JOBNAME1},`
	echo qsub -N $JOBNAME1 -cwd ./Mutect2.sge $N $T ${T%.bam}_f1r2.tar.gz ${T%.bam}.unfiltered.vcf.gz ${T%.bam}_normal-tumor.bam
	# Run GetPileupSummaries
	#JOBNAME2=GetPileupSummaries_${T_FIRST}
	#JOBLIST2+=`echo ${JOBNAME2},`
	#echo qsub -N $JOBNAME2 -cwd ./GetPileUpSummaries $N $T param3 param4
	#echo qsub -N $JOBNAME2 -cwd ./GetPileUpSummaries $N $T param3 param4
done < $INPUT
JOBLIST1=${JOBLIST1%,}


# Run GetPileupSummaries on normal samples when Mutect2 is done running
echo Running GetPileupSummaries on normal samples.
JOBLIST2=""
while read N T; do
	JOBNAME2=GetPileupSummaries-normal-${N}
	JOBLIST2+=`echo ${JOBNAME2},`
	echo qsub -hold_jid $JOBLIST1 -N $JOBNAME2 -cwd ./GetPileupSummaries.sge ${N} ${N%.bam}.pileups.normal.table
done < $INPUT
# Remove last comma from JOBLIST2
JOBLIST2=${JOBLIST2%,}

# Run GetPileupSummaries on tumor samples when previous GetPilupSummaries processes are done running.
echo Running GetPileupSummaries on tumor samples.
JOBLIST3=""
while read N T; do
	JOBNAME3=GetPileupSummaries-tumor-${T}
	JOBLIST3+=`echo ${JOBNAME3},`
	echo qsub -hold_jid $JOBLIST2 -N $JOBNAME3 -cwd ./GetPileupSummaries.sge ${T} ${T%.bam}.pileups.tumor.table
done < $INPUT
# Remove last comma from JOBLIST3
JOBLIST3=${JOBLIST3%,}


# Run CalculateContamination on pileups.table files when previous GetPileupSummaries processes are done running
echo Running CalculateContamination.
JOBLIST4=""
while read N T; do
	JOBNAME4=CalculateContamination_${T}
	JOBLIST4+=`echo ${JOBNAME4},`
	echo qsub -hold_jid $JOBLIST3 -N $JOBNAME4 -cwd ./CalculateContamination.sge ${T}.pileups.tumor.table ${N}.pileups.normal.table ${T%.bam}.segments.table ${T%.bam}.contamination.table
done < $INPUT
# Remove last comma from JOBLIST4
JOBLIST4=${JOBLIST4%,}

# Run LearnReadOrientationModel when CalculateContamination is done running
echo Running LearnReadOrientationModel.
JOBLIST5=""
while read N T; do
	JOBNAME5=LearnReadOrientationModel_${T}
	JOBLIST5+=`echo ${JOBNAME5},`
	echo qsub -hold_jid $JOBLIST4 -N $JOBNAME5 -cwd ./LearnReadOrientationModel.sge ${T%.bam}_f1r2.tar.gz ${T%.bam}.read-orientation-model.tar.gz
done < $INPUT
# Remove last comma from JOBLIST5
JOBLIST5=${JOBLIST5%,}


# Run FilterMutectCalls when CalculateContamination is done running
echo Running FilterMutectCalls on unfiltered .vcf files. 
while read N T; do
	JOBNAME6=FilterMutectCalls_${T}
	JOBLIST6+=`echo ${JOBNAME6},`
		# Get sample name
		OUT_FIRST=${T#*[0-9]_}
		OUT_SECOND=${OUT_FIRST%lib*}
		OUTNAME=${OUT_SECOND%_}
	echo qsub -hold_jid $JOBLIST5 -N $JOBNAME6 -cwd ./FilterMutectCalls.sge ${T%.bam}.unfiltered.vcf.gz ${T%.bam}.segments.table ${T%.bam}.contamination.table ${T%.bam}.read-orientation-model.tar.gz ${OUTNAME}.filtered.vcf.gz
done < $INPUT


                #M2_OUT_1=${T_FIRST#*[0-9]_}
                #M2_OUT_2=${M2_OUT_1%lib*}
                #M2_OUT=${M2_OUT_2%_}




