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
biolung_2022 <- read_excel("BioLung_data/BioLung_clinical_data.xlsx")

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
  # OUTDATED!!!
#================================================================================

# Read BioLung variant file
  biolung_variants_df <- read.delim("BioLung_data/BioLung_Pan_variants_table.tsv")

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
# PROCESS BIOLUNG VARIANTS FILE
#================================================================================

#================================================================================
# READ VARIANTS FILE & SELECT COLUMNS
#================================================================================
variants_df <- read_excel("BioLung_data/BioLung_variants_manually_classified.xlsx", 
                          sheet = "merged_6filter_211229", 
                          col_names = TRUE, 
                          skip = 4)

# Filter artifacts and select relevant columns
variants_df <- variants_df %>% filter(Utvärdering != 'artefakt') %>%
  select(`Sample+A:FI`, `Gene (gene)`)

# Rename columns
variants_df <- variants_df %>% rename(Patient_ID = `Sample+A:FI`, Gene = `Gene (gene)`)


#================================================================================
# HARMONIZE PATIENT ID ENTRIES TO CLINICAL BIOLUNG DF
#================================================================================

# Harmonize patient IDs to BioLung clinical dataset
table(variants_df$Patient_ID)
variants_df$Patient_ID <- str_sub(variants_df$Patient_ID, -3, -1)
variants_df$Patient_ID <- paste('BL', variants_df$Patient_ID, sep = '_')
table(variants_df$Patient_ID)


#================================================================================
# CREATE DATAFRAME TO STORE BINARY GENE-MUTATION DATA IN
#================================================================================

# Count number of samples included in BioLung dataset
patient_ids <- unique(variants_df$Patient_ID)
length(patient_ids)

# Store genes of interest in a character vector
genes <- c('EGFR', 'KRAS', 'TP53', 'STK11', 'KEAP1', 'PTEN', 'POLE', 'POLD1', 'MSH2', 'ABL1', 'ATM', 'BRCA2', 'CARD11', 'CDC73', 'EPHA3', 'EPHA7', 'ASXL1', 'BCOR', 'BRIP1', 'CD79B', 'CIC', 'EPHA5', 'EPHB1', 'ERCC4', 'FLT3', 'HGF', 'JAK3', 'MDC1', 'MET', 'ERBB4', 'FGFR4', 'FOXL2', 'INHBA', 'MAX', 'MED12', 'MGA', 'NFKBIA', 'NOTCH2', 'NUF2', 'PAX5', 'PIK3C2G', 'MRE11', 'NF2', 'NOTCH1', 'NTRK3', 'PARP1', 'PGR', 'PIK3C3', 'PIM1', 'PPM1D', 'PTPRD', 'STAT3', 'TET1', 'ZFHX3', 'PIK3CG', 'PPP2R1A', 'RET', 'TENT5C', 'TSC2')

# Create an empty dataframe: nrow = number of samples, ncol = number of genes + 1.
df <- data.frame(matrix(ncol = length(genes) + 1, nrow = length(patient_ids)))
# Add column names
colnames <- append("Patient_ID", genes)
colnames(df) <- colnames
# Replace NAs with 0s
df[is.na(df)] = 0
# Sort patient IDs vector by patient ID
patient_ids <- sort(patient_ids)
# Insert as Patient IDs column in dataframe
df$Patient_ID <- patient_ids


#================================================================================
# STORE MUTATION DATA IN DATAFRAME
#================================================================================

for (row in 1:nrow(variants_df)) {
  if (variants_df$Gene[row] %in% genes) {
    # Get Patient ID
    pid <- variants_df$Patient_ID[row]
    # Get gene-mutation name
    gene_mut <- variants_df$Gene[row]
    # Change value in newly binary gene-mutation data df
    # Get indices of x and y coordinates in df
    yind <- which(colnames == gene_mut)
    xind <- which(df$Patient_ID == pid)
    df[xind, yind] <- 1
  }
}



#================================================================================
# MERGE DFs & EXPORT
#================================================================================

# Export variants table as tsv
write.table(df, file = "BioLung_variants_data.tsv", dec = ".", col.names = TRUE, sep = "\t")

# Merge BioLung clinical- and mutations dataframes
merged_BioLung_df <- merge(biolung_2022, df, by = "Patient_ID")

# Export merged df to tsv
write.table(merged_BioLung_df, file = "merged_BioLung_data.tsv", dec = ".", col.names = TRUE, sep = "\t")

