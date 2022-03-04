from cyvcf2 import VCF
import click
import pandas as pd

# Add later so that input is path to dir in which vcf files are located. Read all *.vcf files in list (import re), get filename (import os andimport glob)

# Define gene list (will be moved to config file):
gene_list = ['EGFR', 'BRAF', 'TP53', 'PAK3', 'ATRX']

@click.command()
@click.option('--vcf_list', required=True,
        help='Path to list file, containing names of input vcf files')
def main(vcf_list):
	# Create dict to store gene info for each sample. 
	gene_dict = {}	

	vcf_handle = open(vcf_list)
	for vcffileL in vcf_handle:
		gene_name_list = []
		# Remove newline when read in file from list: 
		vcffile = vcffileL.rstrip("\n")
		# Get sample name (refine with regex later, hardcode for now) 
		samplename = vcffile[:8]
		for variant in VCF(vcffile):
			if variant.FILTER != None:
				continue
			else:
				info = variant.INFO.get('FUNCOTATION')
				gene_name = info.split('|')[0][1:]
				if gene_name in gene_list:
					# Samples and mutated genes for each sample in dict: 
					gene_name_list.append(gene_name)
				gene_dict[samplename] = gene_name_list
				#df = pd.DataFrame.from_dict(gene_dict)
	print("dict: ")
	print(gene_dict)
	print("df: ")
	#print(df)




if __name__ == '__main__':
        main()
