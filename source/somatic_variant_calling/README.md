# Somatic variant calling pipeline

This directory contains the scripts used for somatic variant calling, generating .vcf files from processed .bam files. 
The "somatic-variant-calling-wrapper.sh" script is designed for automation & parallelization of this process. This wrapper calls the sub-scripts, each conducting a step in the processing of the input files.

**INPUT**: Processed .bam files.

**OUTPUT**: Filtered .vcf files. 

## Notes:
* The wrapper was specifically designed to run in a Sun Grid Engine grid computing system. Users running on different systems may attain the same results by running the scripts step-by-step. 
 A description on how to run this pipeline without using the wrapper script follows below.
 * Before running the scripts, various script variables - corresponding to paths to various directories and reference files - need to be changed in the 
 "config.txt" file in the parental "source" directory. For information on how to access the required reference files, see the wiki pages.
 * String manipulation (of importance in the "FilterMutectCalls.sge" script) is optimized for the samples included in this project and may not hold 
 true for other projects. Thus, string manipulation in the FilterMutectCalls script may need to be tinkered in order to fit the customs of naming samples to the corresponding project. 


