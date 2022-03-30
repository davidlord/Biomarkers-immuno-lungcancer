#!/bin/bash -l


# Source config file
source ../config

INPUT=$1

mkdir ${WORK_DIR}/fastqc_output
echo Running FastQC.
while read F; do
	qsub fastqc -t 1 ${WORK_DIR}/${F} -o ${WORK_DIR}/fastqc_output
done < $INPUT


