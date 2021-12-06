#!/bin/bash

# Wrapper script for processing BAM files, script calls X, Y, and Z, each running a step in BAM-file processing
# INPUT: Unprocessed BAM files. 
# OUTPUT: Processed BAM files, ready for variant calling. 
# NOTE: 

# MarkDuplicates parameters: 
# AddOrReplaceReadGroups parameters: 
# BaseRecalibrator parameters: 
# ApplyBQSR parameters: 


# Set script variables 

	IN_PATH=

	WORK_DIR=

	SCRIPT_PATH=/home/xlorda/Biomarkers-immuno-lungcancer/source

	HG38=/home/xlorda/anna_tmp/reference_and_misc_files/GRCh38.primary_assembly.genome.fa

	INTERVALS_LIST=/home/xlorda/anna_tmp/reference_and_misc_files/wgs_calling_regions.hg38.list

	GERMLINE_RESOURCE=/home/xlorda/anna_tmp//reference_and_misc_files/af-only-gnomad.hg38.vcf.gz

	PON=


INPUT=$1






# Run MarkDuplicates

# Run Index output? 

# Run AddOrReplaceReadGroups

# Index output? 

# Run BaseRecalibrator (BQSR step 1)

# Run ApplyBQSR (BQSR step 2)

	




