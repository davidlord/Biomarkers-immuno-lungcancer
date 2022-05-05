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
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running/BioLung_data"
setwd(WORK_DIR)

#================================================================================
# READ FILE & SELECT COLUMNS
#================================================================================
variants_df <- read_excel("BioLung_variants_manually_classified.xlsx", 
                           sheet = "merged_6filter_211229", 
                           col_names = TRUE, 
                           skip = 4)


# Filter artifacts and select relevant columns
variants_df <- variants_df %>% filter(Utvärdering != 'artefakt') %>%
  select(`Sample+A:FI`, `Gene (gene)`)

# Rename columns
variants_df <- variants_df %>% rename(Sample_ID = `Sample+A:FI`, Gene = `Gene (gene)`)

table(variants_df$Sample_ID)

# Experimental df
variants_df2 <- variants_df

# String manipulation of patient IDs, use regex. 


lapply(variants$Sample_ID, nchar())
nchar(variants_df$Sample_ID)

# Read BioLung clinical data table
#
# Get BioLung clinical data sample IDs as vector

#================================================================================
# 
#================================================================================

# Select relevant columns in variants table

# Check format of sample IDs in variants table. 


# Check entries in Sample ID with levels function


# Check so that patients in clinical df are included in variants table. 


# Select patients included in


# Check so that mutations of interest are present in variants table




# Check so that Pan 2020 mutations are present in variants table



# Pseudocode: 
# Create an empty dataframe with columns: Patient_ID + mutation names

# Select 








