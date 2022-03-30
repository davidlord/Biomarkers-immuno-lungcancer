#!/bin/bash -l

# Script runs quality control on fastq files. 


# Queue in batch or test
#$ -cwd
#$ -S /bin/bash
#$ -o logs/stdout_LearnReadOrientationModel
#$ -e logs/stderr_LearnReadOrientationModel
#$ -pe mpi 1
#$ -q test.q


# Source config file
source ../config





