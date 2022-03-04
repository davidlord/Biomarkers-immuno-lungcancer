from cyvcf2 import VCF
import click
import pandas as pd
import os
import glob

# Define gene list (will be moved to config file):
genes_of_interest = ['EGFR', 'BRAF', 'TP53', 'PAK3', 'ATRX']

# Read all vcf files in cwd: 
vcf_files_list = glob.glob("*.vcf")

# TO DEBUG: 
print("vcf files list: ")
print(vcf_files_list)

# Get sample names, store in list
sample_names_list = []
for vcf_file in vcf_files_list:
	samplename = vcf_file[:8]
	sample_names_list.append(samplename)

# TO DEBUG:
print("sample names list: ")
print(sample_names_list)


# Create dataframe to place mutations in: 
column_1_name = ["Patient.ID"]
column_names = column_1_name + genes_of_interest

# TO DEBUG: 
print("Column names in df")
print(column_names)

df = pd.DataFrame(columns = column_names)
print("df:")
print(df)


# Get genes and shiii as dict

# append sample name + genes dict as rows to df. 

# Parse through vcf files (cyvcf2): 
for vcf_file in vcf_files_list:
	# get sample name
	samplename = vcf_file[:8]
	# Create dict to store mutated genes:
	genes_sample_dict = {"Patient.ID": samplename}
	print("dict:")
	print(genes_sample_dict)
	for variant in VCF(vcf_file):
		if variant.FILTER != None:
			continue
		else:
			info = variant.INFO.get('FUNCOTATION')
			gene_name = info.split('|')[0][1:]
			if gene_name in genes_of_interest:
				print(samplename, end = " ")
				print(gene_name)
				genes_sample_dict[gene_name] = 1
	# Fill missing genes to dict
	for gene in genes_of_interest:
		if gene in genes_sample_dict:
			continue
		else:
			genes_sample_dict[gene] = 0

	print("dict2")
	print(genes_sample_dict)


	# Append dict to dataframe: 
	df = df.append(genes_sample_dict, ignore_index = True)




print("final df")
print(df)

