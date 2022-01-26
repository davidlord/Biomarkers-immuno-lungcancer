# Wrapper script for BAM-file processing

Wrapper script calls sub-scripts located in the same directory, each conducting a step in the processing of the input BAM-files. 
INPUT: 
OUTPUT: 

## Notes
* Before running the script, script variables containing paths to directories and required files need no be changed. 
* Required files can be downloaded from the GATK best-practices resources bundle. See the "Methods" section in wiki for links to each respective resource file. 
* Intermediate files will not be deleted, ona may delete them manually after the process is finished running. 
* The script is designed to run on an HPC (SGE more specifically), the different sub-scripts require different amount of threads. 
* **WARNING**: The MarkDuplicates process is bugged and will DEVOUR threads. 
* String manipulation in script may need to be modified depending on sample names. 

## Sub-scripts: 
