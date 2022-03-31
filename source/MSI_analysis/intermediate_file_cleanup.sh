#!/bin/bash -l

# Remove intermediate files from BAM file processing pipeline. 

# queue in batch or test
#$ -cwd
#$ -S /bin/bash
#$ -pe mpi 1
#$ -q batch.q
#$ -o logs/stdout_BAM_processing_intermediate_file_cleanup.txt
#$ -e logs/stderr_BAM_processing_intermediate_file_cleanup.txt

source ../config.txt

rm ${WORK_DIR}/*.target.intervals
rm ${WORK_DIR}/*.indels-realigned.bam
rm ${WORK_DIR}/Reference_MSI.site

mkdir${WORK_DIR}/MSI_output
mv ${WORK_DIR}/*.msi_dis ${WORK_DIR}/MSI_output
mv ${WORK_DIR}/*.msi ${WORK_DIR}/MSI_output
