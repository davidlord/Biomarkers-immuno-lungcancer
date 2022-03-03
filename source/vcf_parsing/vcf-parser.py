from cyvcf2 import VCF
import click
import json


# Genes of interest (will be moved to config file):
gene_list = ['EGFR', 'BRAF', 'TP53', 'PAK3', 'ATRX']

# For each variant in VCF file, print FUNCOTATION[0] in info field if filter is PASS. 
@click.command()
@click.option('--vcffile', required=True,
        help='Path to input vcf file')
def main(vcffile):
	for variant in VCF(vcffile):
		filter_res = variant.FILTER
		if filter_res != None:
			continue
		else:
			info = variant.INFO.get('FUNCOTATION')
			gene_name = info.split('|')[0][1:]
			if gene_name in gene_list:
				print(gene_name)			

# Change: Read as list, get first element as gene_name


if __name__ == '__main__':
	main()
