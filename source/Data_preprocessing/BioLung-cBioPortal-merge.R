#================================================================================
# LOAD LIBRARIES & READ FILES
#================================================================================
# Load libraries
library(plyr)
library(dplyr)
library(tidyverse)

# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

# READ DATA FILES
#--------------------
# Read cBioPortal df
cbioportal_df <- read.delim("merged_cBioPortal_data.tsv")
# Read BioLung data
biolung_df <- read.delim("merged_BioLung_data.tsv")


#=================================================================================
# PREPROCESS & MERGE
#=================================================================================

# Remove 'Sample_ID' column from cBioPortal df
cbioportal_df <- cbioportal_df %>% select(-Sample_ID)

# Harmonize columns between datasets
  # Add 'Stage_at_diagnosis' to BioLung df
  biolung_df <- biolung_df %>% add_column(Stage_at_diagnosis = NA)
  # Add 'MSI_MSISensorPro' to cbioportal df
  cbioportal_df <- cbioportal_df %>% add_column(MSI_MSISensorPro = NA)


#================================================================================
# SEPARATE CONTROL COHORT
#================================================================================
# Separate the control cohort
control_df <- cbioportal_df %>% filter(Immunotherapy == 'NO')
cbioportal_df <- cbioportal_df %>% filter(Immunotherapy != 'NO')

# Remove 'Immunotherapy' column from both datasets
control_df <- control_df %>% select(-Immunotherapy)
cbioportal_df <- cbioportal_df %>% select(-Immunotherapy)


#================================================================================
# MERGE & EXPORT DATASETS
#================================================================================

# Merge cBioPortal & BioLung data
combined_df <- rbind(cbioportal_df, biolung_df)

# Export combined dataframe as tsv
write.table(combined_df, file = "combined_data.tsv", dec = ".", col.names = TRUE, sep = "\t")

# Export control df as tsv
write.table(control_df, file="control_data.tsv", dec = ".", col.names = TRUE, sep = "\t")

