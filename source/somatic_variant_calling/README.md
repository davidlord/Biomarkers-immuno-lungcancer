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
 * String manipulation (of importance in the "FilterMutectCalls.sge" & "Mutect2.sge" scripts) is optimized for the samples included in this project and may not hold 
 true for other projects. Thus, string manipulation in the FilterMutectCalls & Mutect2 scripts may need to be tinkered in order to fit the customs of naming samples to the corresponding project. 

## Sub-scripts:

#### Mutect2.sge
Runs somatic variant caller Mutect2 (GATK) on paired normal-tumor processed .bam file input. Mutect2 identifies short somatic variants through de-novo assembly of active regions.
Mutect2.sge parameters: $1 = normal.bam, $2 = tumor.bam, $3 = Sample name, $4 = Panel of Normals, $5 = Germline resource file, $6 = intervals list file, $7 = output.f1r2, $8 = output.unfiltered.vcf, $9 = output.bamout

#### GetPileUpSummaries.sge
Runs GetPileUpSummaries (GATK), summarizing read support for reference- vs. alternate alleles at any given read in table format. 
GetPileupSummaries.sge parameters: $1 = .bam file (processed), $2 = Germline resource, $3 = Germline resource, $4 = output.pileups.table

#### CalculateContamination.sge



#### LearnReadOrientationModel.sge



#### FilterMutectCalls.sge









