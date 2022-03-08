#!/bin/bash -l

# Remove intermediate files from BAM file processing pipeline. 

# queue in batch or test
#$ -cwd
#$ -S /bin/bash
#$ -pe mpi 1
#$ -q test.q
#$ -o logs/stdout_BAM_processing_intermediate_file_cleanup.txt
#$ -e logs/stderr_BAM_processing_intermediate_file_cleanup.txt

source ../config.txt

rm ${WORK_DIR}/RMDUP*
rm ${WORK_DIR}/RG_RMDUP*
rm ${WORK_DIR}/TABLE_BQSR*


