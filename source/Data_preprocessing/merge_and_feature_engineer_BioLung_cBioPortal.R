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
# HARMONIZE COLUMN NAMES & ENTRIES
#=================================================================================

# Harmonize columns between datasets
# Remove 'Sample_ID' column from cBioPortal df
  cbioportal_df <- cbioportal_df %>% select(-Sample_ID)

# Add 'Stage_at_diagnosis' to BioLung df
  biolung_df <- biolung_df %>% add_column(Stage_at_diagnosis = NA)
  
# Add 'MSI_MSISensorPro' to cbioportal df
  cbioportal_df <- cbioportal_df %>% add_column(MSI = NA)
  
# Rename MSI column in BioLung dataset
  biolung_df <- biolung_df %>% rename(MSI = MSI_MSISensorPro)
  
# Add empty 'Immunotherapy column to BioLung df'
  biolung_df$Immunotherapy <- NA
  
# Change name of PD-L1 expression column
  cbioportal_df <- cbioportal_df %>% rename("PD-L1_Expression" = "PD.L1_Expression")
  biolung_df <- biolung_df %>% rename("PD-L1_Expression" = "PD.L1_Expression")
  
# Replace no info entries with NA in PD-L1 expression
  table(cbioportal_df$`PD-L1_Expression`)
  cbioportal_df$`PD-L1_Expression`[cbioportal_df$`PD-L1_Expression` == "Unassessable"] <- NA


# Change "Durable clinical benefit" to "Treatment outcome"
  cbioportal_df <- cbioportal_df %>% rename(Treatment_Outcome = Durable_clinical_benefit)
  biolung_df <- biolung_df %>% rename(Treatment_Outcome = Durable_clinical_benefit)

# Replace entries in response variable
  # YES <- Responder
  # NO <- Non-Responder
  cbioportal_df$Treatment_Outcome[cbioportal_df$Treatment_Outcome == "YES"] <- "Responder"
  cbioportal_df$Treatment_Outcome[cbioportal_df$Treatment_Outcome == "NO"] <- "Non-Responder"
  biolung_df$Treatment_Outcome[biolung_df$Treatment_Outcome == "YES"] <- "Responder"
  biolung_df$Treatment_Outcome[biolung_df$Treatment_Outcome == "NO"] <- "Non-Responder"

# Check that column names match
  biolung_cols <- colnames(biolung_df)
  cbio_cols <- colnames(cbioportal_df)
  setdiff(biolung_cols, cbio_cols)

#================================================================================
# SEPARATE CONTROL COHORT
#================================================================================

# Separate the control cohort
  control_df <- cbioportal_df %>% filter(Immunotherapy == 'NO')
  cbioportal_df <- cbioportal_df %>% filter(Immunotherapy != 'NO')

# Edit Study ID entry for control cohort
  control_df$Study_ID <- "Model_Control"

#================================================================================
# MERGE & EXPORT DATASETS (FEATURES UNALTERED)
#================================================================================

# NOTE: The files exported below serve as input for the primary data visualization and the summary statistics steps.

# Merge cBioPortal & BioLung data
  combined_df <- rbind(cbioportal_df, biolung_df)

# Export combined dataframe as tsv
  write.table(combined_df, file = "combined_data.tsv", dec = ".", col.names = TRUE, sep = "\t")

# Export control df as tsv
  write.table(control_df, file="control_data.tsv", dec = ".", col.names = TRUE, sep = "\t")


#===========================================================================
# FEATURE ENGINEERING
#===========================================================================

# COMBINE DATA FILES
#----------------------
total_df <- rbind(combined_df, control_df)


#===========================================================================
# SUM PAN 2020 MUTATIONS IN NEW COLUMN
#===========================================================================

# Create a vector of all mutations column names
colnames(total_df)
mutations_cols <- colnames(total_df)[14:72]

# Define Pan et al 2020 genes
pan_2020_genes <- mutations_cols[! mutations_cols %in% c("EGFR", "PTEN", "TP53", "STK11", "POLD1", "KRAS", "KEAP1")]
# Sum Pan 2020 gene-mutations
temp <- total_df %>% select(pan_2020_genes) %>% mutate(Pan_2020_muts = rowSums(.))
total_df$Pan_2020_muts <- temp$Pan_2020_muts

# Add column holding binary data of whether or not Pan_2020_muts >= 2
# 1 = Holds >= 2 of gene mutations of list defined by 
total_df$Pan_2020_compound_muts <- ifelse(total_df$Pan_2020_muts >=2, 1, 0)


#===========================================================================
# COMBINE SPECIFIC GENE-MUTATIONS TO SINGLE SCORES
#===========================================================================
### Enriched in non-responders: EGFR, STK11
### Enriched in responders: PTEN, KRAS, POLE, POLD1, MSH2

# Define vectors for durable clinical benefit (DCB) & no durable benefit (NDB) associated genes
NDB_genes <- c("EGFR", "STK11")
DCB_genes <- c("PTEN", "KRAS", "POLE", "POLD1", "MSH2", "TP53")
# Add KEAP1 to DCB genes? 

# Combine sums to columns
temp <- total_df %>% select(DCB_genes) %>% mutate(DCB_genes = rowSums(.))
total_df$DCB_genes <- temp$DCB_genes
temp <- total_df %>% select(NDB_genes) %>% mutate(NDB_genes = rowSums(.))
total_df$NDB_genes <- temp$NDB_genes


#===========================================================================
# FURTHER PREPROCESSING
#===========================================================================


#===========================================================================
# PD-L1 EXPRESSION
#===========================================================================

# To be added...


#===========================================================================
# NORMALIZE TMB
#===========================================================================

# Normalize TMB across cohorts
total_df <- total_df %>% group_by(Study_ID) %>% mutate(TMB_norm = TMB / mean(TMB))

# Log2 transform TMB
total_df$TMB_norm_log2 <- log2(total_df$TMB_norm)

# Replace -Inf values for log2 transformed normalized TMB with minimum value
temp <- total_df %>% filter(!is.infinite(TMB_norm_log2))
min(temp$TMB_norm_log2)
# Minimum is -5(ish)
total_df$TMB_norm_log2 <- ifelse(is.infinite(total_df$TMB_norm_log2), -5, total_df$TMB_norm_log2)


#===========================================================================
# EXCLUDE FEATURES ?
#===========================================================================

# Convert relevant columns to factors? Remove? 
colz <- c('Durable_clinical_benefit', 'Histology', 'Smoking_history', 'Sex')
data[colz] <- lapply(data[colz], factor)


#===========================================================================
# EXPORT FILE
#===========================================================================

write.table(total_df, "Features_engineered_control_included.tsv", dec = ".", col.names = TRUE, sep = "\t")





