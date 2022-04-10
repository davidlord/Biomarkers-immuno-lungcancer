#!/bin/bash

# Text description


# Source config file
source ../config.txt


INPUT=$1

# Run Samtools index on .bam files: $1 = Bam file

JOBLIST1=""
JOBLIST2=""
echo Running Samtools index.
while read N T; do
	# Run Samtools index on normal samples
	JOBNAME_N=Samtools-index-${N}
	JOBLIST1+=`echo $JOBNAME_N,`
	qsub -N $JOBNAME_N -cwd ./Samtools-index.sge $N
	# Run Samtools index on tumor samples
	JOBNAME_T=Samtools-index-${T}
	JOBLIST2+=`echo $JOBNAME_T,`
	qsub -N $JOBNAME_T -cwd ./Samtools-index.sge $T
done < $INPUT
# Remove last commas from joblists
JOBLIST1=${JOBLIST1%,}
JOBLIST2=${JOBLIST2%,}


# Run RealignerTargetCreator (GATK3) on normal and tumor samples separately.
# RealignerTargetCreator parameters: $1 = Input (BAM), $2 = output.target.intervals
JOBLIST3=""
JOBLIST4=""
echo Running RealignerTargetCreator GATK3.
while read N T; do
	# Run on normal samples
	JOBNAME_N=RealignerTargetCreator-${N}
	JOBLIST3+=`echo $JOBNAME_N,`
	qsub -hold_jid $JOBLIST1 -N $JOBNAME_N -cwd ./RealignerTargetCreator-gatk3.sge ${N} ${N%.bam}.target.intervals
	# Run on tumor samples
	JOBNAME_T=RealignerTargetCreator-${T}
	JOBLIST4+=`echo $JOBNAME_T,`
	qsub -hold_jid $JOBLIST2 -N $JOBNAME_T -cwd ./RealignerTargetCreator-gatk3.sge ${T} ${T%.bam}.target.intervals
done < $INPUT
# Remove last commas from joblists
JOBLIST3=${JOBLIST3%,}
JOBLIST4=${JOBLIST4%,}


# IndelRealigner: $1 = target.intervals, $2 = Input.bam, $3 Output.indels.realigned.bam




# Run IndelRealigner (GATK3) on normal and tumor samples (separately)
# IndelRealigner: $1 = target.intervals, $2 = Input.bam, $3 Output.indels.realigned.bam
JOBLIST5=""
JOBLIST6=""
echo Running IndelRealigner GATK3.
while read N T; do
        # Run on normal samples
        JOBNAME_N=IndelRealigner-${N}
        JOBLIST5+=`echo $JOBNAME_N,`
        qsub -hold_jid $JOBLIST3 -N $JOBNAME_N -cwd ./IndelRealigner-gatk3.sge ${N%.bam}.target.intervals ${N} ${N%.bam}.indels-realigned.bam
        # Run on tumor samples
        JOBNAME_T=IndelRealigner-${T}
        JOBLIST6+=`echo $JOBNAME_T,`
        qsub -hold_jid $JOBLIST4 -N $JOBNAME_T -cwd ./IndelRealigner-gatk3.sge ${T%.bam}.target.intervals ${T} ${T%.bam}.indels-realigned.bam
done < $INPUT
# Remove last commas from joblists
JOBLIST5=${JOBLIST5%,}
JOBLIST6=${JOBLIST6%,}


# Run MSIsensor-pro in scan mode on the reference genome
# MSIsensor-pro scan parameters: $1 = output.site
echo MSIsensor-pro: Scanning reference genome for MSI sites.
REF_MSI=${WORK_DIR}/Reference_MSI.site
qsub -hold_jid $JOBLIST5 -hold_jid $JOBLIST6 -N MSIsensor-pro_scan_reference -cwd ./MSIsensor-pro-scan-reference.sge $REF_MSI


# Run MSIsensor-pro on paired normal-tumor bam files
# MSIsensor-pro parameters: $1 = reference.site, $2 = normal.bam, $3 = tumor.bam, output.msi
JOBLIST7=""
echo Running MSIsensor-pro on paired normal-tumor input.
while read N T; do
	# Get sample name
	FIRST=${T#*[0-9]_}
	SECOND=${FIRST%%lib*}
	SAMPLENAME=${SECOND%_}
	JOBNAME=MSIsensor-pro-${T}
	JOBLIST7+=`echo $JOBNAME,`
	# Run MSIsensor-pro
	qsub -hold_jid MSIsensor-pro_scan_reference -N MSIsensor-pro-${T} -cwd ./MSIsensor-pro_normal-tumor.sge $REF_MSI ${N%.bam}.indels-realigned.bam ${T%.bam}.indels-realigned.bam ${SAMPLENAME}.msi
done <$INPUT 
# Remove last comma from joblist
JOBLIST7=${JOBLIST7%,}


# Clean up intermediate files
qsub -hold_jid $JOBLIST7 -cwd ./intermediate_file_cleanup.sh







