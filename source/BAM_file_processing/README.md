# Wrapper script for BAM-file processing

Wrapper script calls sub-scripts located in the same directory, each conducting a step in the processing of the input bam-files. 
INPUT: 
OUTPUT: 

## Notes
* Before running the script, script variables containing paths to directories and required files need no be changed. 
* Required files can be downloaded from the GATK best-practices resources bundle. See the "Methods" section in wiki for links to each respective resource file. 
* Intermediate files will not be deleted, ona may delete them manually after the process is finished running. 
* The script is designed to run on an HPC (SGE more specifically), the different sub-scripts require different amount of threads. 
* String manipulation in script may need to be modified depending on sample names. 
* **WARNING**: The MarkDuplicates process is bugged and will DEVOUR threads. 


## Sub-scripts: 

### BAM_file_processing_0_Samtools_index.sge
Runs Samtools Index. 
**INPUT**: .bam file
**OUTPUT**: .bai file

### BAM_file_processing_1_MarkDuplicates.sge
Runs MarkDuplicates (GATK).
**INPUT**: Duplicated .bam file
**OUTPUT**: .bam file with duplicates marked. 

### BAM_file_processing_2_AddOrReplaceReadGroups.sge
Runs AddOrReplaceReadGroups (GATK)
**INPUT**: .bam file. 
**OUTPUT**: .bam file.

### BAM_file_processing_3_BaseRecalibrator.sge
Runs BaseRecalibrator (GATK)
**INPUT**: .bam file. 
**OUTPUT**: table file, base recalibration model. 

### BAM_file_processing_4_ApplyBQSR.sge
Runs ApplyBQSR (GATK)
**INPUT**: .bam file, base recalibration table. 
**OUTPUT**: .bam file. 
