# Bam file processing

This directory contains the script used for processing .bam files prior to variant calling. The "BAM-file-processing-wrapper.sh" wrapper script is designed for parallelization of this process. This wrapper calls the sub-scripts, each conducting a step in the processing of the input files. 

**INPUT**: Unprocessed .bam file.

**OUTPUT**: Processed .bam file, ready for variant calling.

## Notes:
* This wrapper was specifically designed to run in a Sun Grid Engine grid computing system. Users running on different systems may attain the same results by running the scripts step-by-step. A description on how to run this pipeline without using the wrapper script follows below. 
* Before running the scripts, various script variables - corresponding to paths to various directories and reference files - need to be changed in the "config.txt" file in the parental "source" directory. For information on how to access the required reference files, see the wiki pages. 
* String manipulation (of importance in the "AddOrReplaceReadGroups.sge" script) is optimized for the samples included in this project and may not hold true for other projects. Thus, string manipulation in the AddOrReplaceReadGroups script may need to be tinkered in order to fit the customs of naming samples to the corresponding project. 

## Sub-scripts: 

#### Samtools_index.sge
Runs Samtools Index, enabling fast random access of the input bam file.\
Samtools-index.sge parameters: $1 = input (bam)

#### BAM_file_processing_1_MarkDuplicates.sge
Runs MarkDuplicates (GATK), locating and tagging duplicate reads.\
MarkDuplicates.sge parameters: $1 = input (bam), $2 = output (bam), $3 = metrics file (txt).

#### BAM_file_processing_2_AddOrReplaceReadGroups.sge
Runs AddOrReplaceReadGroups (GATK), assigning new read groups to the reads.\
AddOrReplaceReagGroups.sge parameters: $1 = input (bam), $2 = output (bam).

#### BAM_file_processing_3_BaseRecalibrator.sge
Runs BaseRecalibrator (GATK), generating a recalibration table used for the downstream ApplyBQSR process.\
BaseRecalibrator parameters: $1 = input (bam), $2 = output (base recalibration table), $3 = reference genome, $4 = known SNPs resource file, $5 = known indels resource file. 

#### BAM_file_processing_4_ApplyBQSR.sge
Runs ApplyBQSR (GATK), recalibrating the base quality scores in the inputed bam file based on the recalibration table.\
ApplyBQSR parameters: $1 = input (bam), $2 = output (bam), $3 = reference genome, $4 = base recalibration table.


## Running scripts manually

Each script can be run manually, for single input simply run E.g: './<script> <parameter_1> <parameter_2>'\
For multiple file input the scripts can instead be run through a loop, E.g: 'cat <input_file_list> | while read FILE; do ./<script> <parameter_1> <Parameter2>; done'


The following order applies when running the scripts manually: Samtools index -> MarkDuplicates -> Samtools index -> AddOrReplaceReadGroups -> Samtools index -> BaseRecalibrator -> ApplyBQSR


