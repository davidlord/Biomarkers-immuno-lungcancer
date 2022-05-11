#=================================================================================
# LOAD LIBRARIES & READ FILES
#=================================================================================
library(ggplot2)
library(plyr)
library(dplyr)
library(tidyverse)

# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

# Read data file
total_df <- read.delim("combined_data.tsv", stringsAsFactors = TRUE)


#=================================================================================
# CALCULATE SUMMARY STATISTICS ACROSS COHORTS
#=================================================================================

# Overview structure of dataset
str(total_df)

# Samples in each cohort
table(total_df$Study_ID)

# Calculate summary statistics
  # TMB:
    # TMB for each cohort:
    total_df %>% group_by(Study_ID) %>% summarize(
      average_TMB = mean(TMB), standard_deviation_TMB = sd(TMB)
    )
    # TMB for entire dataset: 
      total_df %>% summarize(average_TMB = mean(TMB), standard_deviation_TMB = sd(TMB))

  # Age:
      # Age for each cohort:
      total_df %>% filter(!is.na(Diagnosis_Age)) %>% group_by(Study_ID) %>% summarize(
        average_age = mean(Diagnosis_Age), standard_deviation_age = sd(Diagnosis_Age)
      )
      # Age for entire set:
      total_df %>% filter(!is.na(Diagnosis_Age)) %>% summarize(average_age = mean(Diagnosis_Age), standard_deviation_age = sd(Diagnosis_Age))
  
  # Durable clinical benefit: 
      # Fraction durable clinical benefit for each cohort:
      total_df %>% group_by(Study_ID) %>% summarize(
        fraction_DCB = (sum(Durable_clinical_benefit == 'YES') / length(Durable_clinical_benefit)),
        fraction_NDB = 1 - fraction_DCB
      )
      # Fraction durable clinical benefit for entire dataset: 
      total_df %>% summarize(
        fraction_DCB = (sum(Durable_clinical_benefit == 'YES') / length(Durable_clinical_benefit)),
        fraction_NDB = 1 - fraction_DCB
      )
  
  # PD-L1 expression
      # For each cohort: 
      # Fraction negative
      total_df %>% group_by(Study_ID) %>% filter(!is.na(PD.L1_Expression)) %>% summarize(
        fraction_negative = (sum(PD.L1_Expression == 'Negative') / length(PD.L1_Expression)),
      )
      # Fraction weak
      total_df %>% group_by(Study_ID) %>% filter(!is.na(PD.L1_Expression)) %>% summarize(
        fraction_weak = (sum(PD.L1_Expression == 'Weak') / length(PD.L1_Expression)),
      )
      # Fraction strong
      total_df %>% group_by(Study_ID) %>% filter(!is.na(PD.L1_Expression)) %>% summarize(
        fraction_strong = (sum(PD.L1_Expression == 'Strong') / length(PD.L1_Expression)),
      )
      # For entire dataset: 
      table(total_df$PD.L1_Expression)
  
  
  # Progression free survival:
      # Progression free survival for each cohort:
      total_df %>% group_by(Study_ID) %>% filter(!is.na(PFS_months)) %>% summarize(
        average_PFS = mean(PFS_months),
        standard_deviation_PFS = sd(PFS_months)
      )
      # Progression free survial for entire dataset:
      total_df %>% filter(!is.na(PFS_months)) %>% summarize(
        average_PFS = mean(PFS_months),
        standard_deviation_PFS = sd(PFS_months)
      )

  # Sex ratio:
      # Sex ratio for each cohort:
      total_df %>% group_by(Study_ID) %>% filter(!is.na(Sex)) %>% summarize(
        fraction_male = sum(Sex == "Male") / length(Sex),
        fraction_female = sum(Sex == "Female") / length(Sex)
      )
      # Sex ratio for entire dataset: 
      total_df %>% filter(!is.na(Sex)) %>% summarize(
        fraction_male = sum(Sex == "Male") / length(Sex),
        fraction_female = sum(Sex == "Female") / length(Sex)
      )
      
  
#============================================================================
# AVERAGE MUTATIONAL INSTANCES (FOR ALL INCLUDED MUTATIONS) PER PATIENT
#============================================================================
str(total_df)
# Gene-mutation columns:

colnames(total_df)
# Get column names
  cols <- colnames(total_df)
  print(cols)
# Select mutation columns
  mutation_cols <- cols[13:71]
  print(mutation_cols)

# Subset df to include only mutation columns & study ID
  mutations_df <- total_df %>% select(Study_ID, mutation_cols)
# Create StudyID "Total" consisting of all entries
  total_muts_df <- mutations_df %>% mutate(Study_ID = "Total")
# Combine mutations df with total mutations df
  mutations_df <- rbind(mutations_df, total_muts_df)
  
# Split to dfs based on factors in StudyID, read to list
  mut_dfs_list <- split(mutations_df, f = mutations_df$Study_ID)

str(mut_dfs_list)

# Define a function that takes df as input and returns mean number of mutations / patient
calc_mut_freq <- function(df){
  sum(df[mutation_cols]/nrow(df))
}
calc_mut_freq(mutations_df)
 
# Calculate average mutational instance per patient (for included muations) for each cohort
lapply(mut_dfs_list, calc_mut_freq)


#============================================================================
# FRACTION PATIENTS WITH SPECIFIC GENE-MUTATION
#============================================================================

str(mut_dfs_list)

# Define genes of interest
genes_of_interest <- c("EGFR", "KRAS", "TP53", "POLE", "POLD1", "KEAP1", "STK11", "MSH2", "PTEN")

# Create 
calc_gene_mut_freq <- function(df){
  # Convert to dataframe
  df <- as.data.frame(df)
  for (gene in genes_of_interest) {
    print(gene)
    print(sum(df[gene]) / nrow(df))
    #sum(genecol) / nrow(df)
  }
}
calc_gene_mut_freq(mutations_df)




