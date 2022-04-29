# Variants to table

Script reads .vcf files in the working directory (specified in config file) and generates a table of binary gene mutation data in the genes of interest (specified in the config file) in .tsv format. 1 = Mutation present in gene, 0 = No mutation present in gene. 

### Note:

* Before running script, configurate the working directory and genes of interest in the 'config.py' file. 
* Script assumes that .vcf files to be processed hold the '.vcf' suffix.
* Script is specifically designed for .vcf files annotated through Funcotator (GATK4) using the following data sources: Clinvar, Cosmic, Gencode. 





