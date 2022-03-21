from cyvcf2 import VCF
import pandas as pd
import os
import glob
import config


# Read genes of interest from config file
genes_of_interest = config.genes_of_interest

# Set working directory
WORK_DIR = config.WORK_DIR
os.chdir(WORK_DIR)

# Read all vcf files in cwd: 
	# Development: Move WD to config file. 
vcf_files_list = glob.glob("*.vcf")


# Get sample names, store in list
sample_names_list = []
for vcf_file in vcf_files_list:
	samplename = vcf_file[:8]
	sample_names_list.append(samplename)


# Create dataframe to place mutations in: 
column_1_name = ["Patient.ID"]
column_names = column_1_name + genes_of_interest
df = pd.DataFrame(columns = column_names)

# append sample name + genes dict as rows to df. 

# Parse through vcf files (cyvcf2): 
for vcf_file in vcf_files_list:
	# get sample name: 
		# Development: Use split instead of hardcoding, update later. 
	samplename = vcf_file[:8]
	# Create dict to store mutated genes:
	genes_sample_dict = {"Patient.ID": samplename}
	for variant in VCF(vcf_file):
		if variant.FILTER != None:
			continue
		else:
			infoF = variant.INFO.get('FUNCOTATION')
			gene_name = infoF.split('|')[0][1:]
			if gene_name in genes_of_interest:
				genes_sample_dict[gene_name] = 1
	# Fill missing genes to dict
	for gene in genes_of_interest:
		if gene in genes_sample_dict:
			continue
		else:
			genes_sample_dict[gene] = 0

	# Append dict to dataframe: 
	df = df.append(genes_sample_dict, ignore_index = True)


print("final df: ")
print(df)

df.to_csv('variants_table.tsv', sep = '\t', index = False)





