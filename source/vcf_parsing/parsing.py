
from cyvcf2 import VCF
import click
import json

@click.command()
@click.option('--vcffile', required=True,
	help='Path to input vcf file')
def main(vcffile):
	#Parse VCF file
	dict = {}
	gene_list = ['EGFR', 'BRAF']

	for variant in VCF(vcffile):
		filter_res = variant.FILTER
		#if filter_res != 'PASS':
		#	continue
		chrom = str(variant.CHROM)
		genotype = variant.ploidy
		start_pos = str(variant.start)
		info = variant.INFO.get('FUNCOTATION')
		gene_name = info.split('|')[0][1:]
		# Change: Read as list, get first element as gene_name
		
		#if gene_name in gene_list:
		print(chrom, end=" ")
		print(start_pos, end=" ")
		print(genotype, end=" ")
		print(filter_res)
		print(gene_name)

if __name__ == '__main__':
	main()



