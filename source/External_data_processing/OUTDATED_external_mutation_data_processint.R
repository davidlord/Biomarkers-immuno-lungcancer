library(dplyr)
library(tidyverse)
library(stringr)
library(writexl)


# Genes to include in analysis: EGFR, KRAS, TP53, STK11, KEAP1, PTEN


# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

# See categories for different 
table(Mutations$MS)
table(Mutations$Allele.Freq..T.)
sum(is.na(Mutations$Allele.Freq..T.))

# Can not afford to exclude Allele freq = NA for now since almost all data would be lost. 
# Try first without filter for allele freq. 
# Filter on: "MS" == SOMATIC

df <- Mutations %>% filter(MS == "SOMATIC") %>% select(Sample.ID, Variant.Type, Mutation.Type, Copy.., MS, Allele.Freq..T., ClinVar)

# Later decide on what to do with ClinVar data...




