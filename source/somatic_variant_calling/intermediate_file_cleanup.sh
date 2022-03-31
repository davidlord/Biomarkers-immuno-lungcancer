#!/bin/bash -l

# Remove intermediate files from BAM file processing pipeline. 

# queue in batch or test
#$ -cwd
#$ -S /bin/bash
#$ -pe mpi 1
#$ -q test.q
#$ -o logs/stdout_intermediate_file_cleanup.txt
#$ -e logs/stderr_intermediate_file_cleanup.txt

source ../config.txt

rm ${WORK_DIR}/*.pileups.*.table
rm ${WORK_DIR}/*.segments.table
rm ${WORK_DIR}/*normal-tumor.bam
rm ${WORK_DIR}/*normal-tumor.bai
rm ${WORK_DIR}/*f1r2.tar.gz
rm ${WORK_DIR}/*.read-orientation-model.tar.gz
rm ${WORK_DIR}/*.filteringStats.tsv

mkdir ${WORK_DIR}/contamination_tables
mv ${WORK_DIR}/*contamination.table ${WORK_DIR}/contamination_tables


