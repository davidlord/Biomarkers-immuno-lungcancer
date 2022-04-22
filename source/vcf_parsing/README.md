# Variants to table

Script reads .vcf files in the working directory (specified in config file) and generates a table of binary gene mutation data in the genes of interest (specified in the config file) in .tsv format. 

### Note:

* Before running script, configurate the working directory and genes of interest in the 'config.py' file. 

**Note:** The string manipulation regarding 


Script reads all '*.vcf' files in the specified working directory, parses through each .vcf file and searches for specific mutations. Then constructs a table based on if the specified mutations are present or not in each sample (.vcf file). Outputs this table in .tsv format. 

**INPUT:** Filtered .vcf files, annotated with Funcotator (GATK4). 

**OUTPUT:** A .tsv file consisting of sample IDs as rows and gene names as columns. 1 = Mutation present in sample, 0 = Mutation not present in sample.





