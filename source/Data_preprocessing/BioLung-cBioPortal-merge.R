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
#------------------
# Read cBioPortal df
cbioportal_df <- read.delim("merged_cBioPortal_clinical_mutation_data.tsv")
# Read BioLung df
control_df <- read.delim("merged_control_clinical_mutation_data.tsv")
# Read modelling control df
biolung_df <- read.delim("merged_BioLung_clinical_mutation_data.tsv")


#=================================================================================
# PREPROCESS & MERGE
#=================================================================================

# Remove 'Sample_ID' column from cBioPortal and Control dfs. 
cbioportal_df <- cbioportal_df %>% select(-Sample_ID)
control_df <- control_df %>% select(-Sample_ID)

# Add empty columns to harmonize
# Add 'Stage_at_diagnosis' to BioLung df
biolung_df <- biolung_df %>% add_column(Stage_at_diagnosis = NA)
# Add 'MSI_MSISensorPro' to cbioportal df
cbioportal_df <- cbioportal_df %>% add_column(MSI_MSISensorPro = NA)

# Merge cBioPortal & BioLung data
total_df <- rbind(cbioportal_df, biolung_df)


# Overview structure of dataset
str(total_df)


# EXPORT FILE
write.table(total_df, file = "total_df.tsv", dec = ".", col.names = TRUE, sep = "\t")

