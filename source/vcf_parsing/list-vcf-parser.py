from cyvcf2 import VCF
import click


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
					#Store in dict
					gene_name_list.append(gene_name)
				gene_dict[samplename] = gene_name_list
	print(gene_dict)
					##print(samplename + " " + gene_name)



if __name__ == '__main__':
        main()
