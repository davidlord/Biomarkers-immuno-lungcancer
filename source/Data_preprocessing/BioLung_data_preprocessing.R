#================================================================================
# LOAD LIBRARIES & READ FILES
#================================================================================
# Load libraries
library(plyr)
library(dplyr)
library(tidyverse)
library(stringr)
library(writexl)
library(readxl)

# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

# Read clinical data
biolung_2022 <- read_excel("BioLung_clinical_data.xlsx")

#================================================================================
# DATA CLEANING
#================================================================================

# Filter unpaired samples
biolung_2022 <- biolung_2022 %>% filter(Somatic_Status == TRUE)

# Filter NAs in response variable entries
biolung_2022 <- biolung_2022 %>% filter(Durable_clinical_benefit == 'Responder' | Durable_clinical_benefit == 'Non responder')


#================================================================================
# HARMONIZE COLUMN ENTRIES TO cBioPortal DATA
#================================================================================

# Durable clinical benefit
  # 'YES' <- 'Responder'
  # 'NO' <- 'Non-responder'
  biolung_2022$Durable_clinical_benefit[biolung_2022$Durable_clinical_benefit == "Responder"] <- "YES"
  biolung_2022$Durable_clinical_benefit[biolung_2022$Durable_clinical_benefit == "Non responder"] <- "NO"

# Histology
  # 'Lung adenocarcinoma' <- 'LUAD'
  # 'Lung Squamous Cell Carcinoma' <- 'SCC'
  # 'Non-Small Cell Lung Cancer'
  biolung_2022$Histology[biolung_2022$Histology == "LUAD"] <- "Lung Adenocarcinoma"
  biolung_2022$Histology[biolung_2022$Histology == "SCC"] <- "Lung Squamous Cell Carcinoma"
  biolung_2022$Histology[biolung_2022$Histology == "NSCLC"] <- "Non-Small Cell Lung Cancer"
  
# Smoking history
  # 'Former' <- 'Previous'
  # 'Never' <- 'Non-smoker'
  biolung_2022$Smoking_History[biolung_2022$Smoking_History == "Previous"] <- "Former"
  biolung_2022$Smoking_History[biolung_2022$Smoking_History == "Non-smoker"] <- "Never"
  
# PD-L1 Expression
  table(biolung_2022$`PD-L1_Expression`)
  # '<1' <- 0
  biolung_2022$`PD-L1_Expression`[biolung_2022$`PD-L1_Expression` == '<1'] <- 0
  # Convert to numeric factor
  biolung_2022$`PD-L1_Expression` <- as.numeric(biolung_2022$`PD-L1_Expression`)
  # Bin to factors
  biolung_2022$`PD-L1_Expression`[biolung_2022$`PD-L1_Expression` > 50 | biolung_2022$`PD-L1_Expression` == 50] <- "Strong"
  biolung_2022$`PD-L1_Expression`[biolung_2022$`PD-L1_Expression` >= 1 & biolung_2022$`PD-L1_Expression` < 50] <- "Weak"
  # '7' got stuck for some reason...
  biolung_2022$`PD-L1_Expression`[biolung_2022$`PD-L1_Expression` == 7] <- "Weak"
  biolung_2022$`PD-L1_Expression`[biolung_2022$`PD-L1_Expression` < 1] <- "Negative"
  table(biolung_2022$`PD-L1_Expression`)
  
  # Study ID: BioLung <- BioLung_2022
  biolung_2022$Study_ID[biolung_2022$Study_ID == "BioLung"] <- "BioLung_2022"

  
#================================================================================
# SELECT & RENAME COLUMNS
#================================================================================

# Select columns
### Frist try out w TMB_lower
biolung_2022 <- biolung_2022 %>% select(Study_ID, Patient_ID, Sequencing_type, Durable_clinical_benefit, PFS_months, Histology, Smoking_History, Diagnosis_Age, Sex, `PD-L1_Expression`, TMB_lower, MSI_MSISensorPro)

# Harmonize column names
  # Smoking_history <- Smoking_History
  colnames(biolung_2022)[which(names(biolung_2022) == "Smoking_history")] <- "Smoking_History"
  # TMB_lower <- TMB
  colnames(biolung_2022)[which(names(biolung_2022) == "TMB_lower")] <- "TMB"


#================================================================================
# PROCESS BIOLUNG VARIANTS FILE
#================================================================================

# Read BioLung variant file
  biolung_variants_df <- read.delim("BioLung_variants_table.tsv")

# Reformat Patient ID so it matches the clinical df
  # Extract patient number
  PID1 <- gsub("[a-zA-Z]", "", biolung_variants_df$Patient.ID)
  # Remove special characters
  PID2 <- gsub("[[:punct:]]", "", PID1)
  # Add 'BL_' prefix
  PID3 <- paste('BL', PID2, sep = '_')
  # Replace entries in variants df patient ID column
  biolung_variants_df$Patient.ID <- PID3

# Filter entries not present in clinical df from variant df
  biolung_variants_df <- biolung_variants_df %>% filter(biolung_variants_df$Patient.ID %in% biolung_2022$Patient_ID)
  
# Rename 'Patient.ID' column
colnames(biolung_variants_df)[which(names(biolung_variants_df) == "Patient.ID")] <- "Patient_ID"


#================================================================================
# MERGE DFs & EXPORT
#================================================================================
  
# Merge dataframes
merged_BioLung_df <- merge(biolung_2022, biolung_variants_df, by = "Patient_ID")

# Export to tsv
write.table(merged_BioLung_df, file = "merged_BioLung_clinical_mutation_data.tsv", dec = ".", col.names = TRUE, sep = "\t")

