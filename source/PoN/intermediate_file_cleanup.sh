#!/bin/bash -l

# Removes intermediate files from PoN generation pipeline. 

# queue in batch or test
#$ -cwd
#$ -S /bin/bash
#$ -pe mpi 5
#$ -q test.q
#$ -o logs/stdout_PoN_intermediate_file_cleanup.txt
#$ -e logs/stderr_PoN_intermediate_file_cleanup.txt

source ../config.txt

rm ${WORK_DIR}/BQSR*.vcf.gz*
rm -R ${WORK_DIR}/PON_DB

