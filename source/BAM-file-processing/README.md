# Wrapper script for BAM-file processing

Wrapper script calls sub-scripts located in the same directory, each conducting a step in the processing of the input bam-files. 
INPUT: Unprocessed .bam file.
OUTPUT: Processed .bam file, ready for variant calling.

## Notes:
* This wrapper was specifically designed to run in a Sun Grid Engine grid computing system. Users running on different systems may attain the same results by running the scripts step-by-step. A description on how to run the scripts manually follows below. 
* Before running the script, script variables containing paths to directories and reference files needs no be changed. For further information on how to access the required reference files .... wiki? ....
* **WARNING**: The "MarkDuplicates" step will DEVOUR CPU. 
* Double check string manipulation...


## Sub-scripts: 

##### Samtools_index.sge
Runs Samtools Index. 
**INPUT**: .bam file
**OUTPUT**: .bai file

#### BAM_file_processing_1_MarkDuplicates.sge
Runs MarkDuplicates (GATK).
**INPUT**: Duplicated .bam file
**OUTPUT**: .bam file with duplicates marked. 

#### BAM_file_processing_2_AddOrReplaceReadGroups.sge
Runs AddOrReplaceReadGroups (GATK)
**INPUT**: .bam file. 
**OUTPUT**: .bam file.

#### BAM_file_processing_3_BaseRecalibrator.sge
Runs BaseRecalibrator (GATK)
**INPUT**: .bam file. 
**OUTPUT**: table file, base recalibration model. 

#### BAM_file_processing_4_ApplyBQSR.sge
Runs ApplyBQSR (GATK)
**INPUT**: .bam file, base recalibration table. 
**OUTPUT**: .bam file. 
