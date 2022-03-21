#====================================================================================
# Load libraries
#====================================================================================
library(dplyr)
library(readxl)


#====================================================================================
# Read data
#====================================================================================
setwd("/Users/davidlord/Documents/Results/variant_validation")

# Read manually validated variants: 
manually_validated <- read_excel("Variants_classified_by_Louise.xlsx", col_names = TRUE)

# Read variants deduced from variant-calling pipeline:
variants <- read.csv("BioLung-variants-table.tsv", sep = '\t')


#====================================================================================
# Data filtering and wrangling
#====================================================================================

# Rename gene name column
colnames(manually_validated)[which(names(manually_validated) == "COSMIC CGC Gene (cgcGene)")] <- "Gene_name"
colnames(manually_validated)[which(names(manually_validated) == "Sample+A:FI")] <- "Sample_name"

table(manually_validated$Sample_name)

# Filter for true variants
validated_as_true <- c("sann", "Sann", "sann?")
manually_validated <- manually_validated %>% filter(Utvärdering %in% validated_as_true)

# Select genes of interest
genes_of_interest <- c("EGFR", "KRAS", "TP53", "STK11", "PTEN", "ARID1A", "ARID1B")
manually_validated <- manually_validated %>% filter(Gene_name %in% genes_of_interest)

# Subset columns of interest
manually_validated <- manually_validated %>% select(Sample_name, Gene_name)

