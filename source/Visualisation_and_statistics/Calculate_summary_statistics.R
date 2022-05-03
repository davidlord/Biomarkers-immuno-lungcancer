#=================================================================================
# LOAD LIBRARIES & READ FILES
#=================================================================================
library(ggplot2)
library(dplyr)
library(tidyverse)

# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

# Read data file
total_df <- read.delim("total_df.tsv", stringsAsFactors = TRUE)


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
      
  
#=======================================================================
# MUTATION FREQUENCIES
#=======================================================================
str(total_df)
# Gene-mutation columns:

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
# Combine 
  mutations_df <- rbind(mutations_df, total_muts_df)
  
  
# Split to dfs based on factors in StudyID
  mut_dfs_list <- split(mutations_df, f = mutations_df$Study_ID)

  
  


  
  
  
  
  
  
  
  
  
  
  
  
  
  
# Perform calculation for each gene, on each df 
func <- function(df) {
  sum(df$POLE) / nrow(df)
}
lapply(mut_dfs_list, func)

# DEV: Integrate in a loop that iterates over each column name in mutation_columns
func <- function(df) {
  for (i in mutation_cols) {
    print(i)
    print(sum(df %>% select(i)) / nrow(df))
  }
}




# DEV: Store info in dictionary
test <- list()
test <- deparse(substitute(mutations_df))

paste("helo", test, sep='_')

func <- function(df) {
  # get df name
  df_name <- deparse(substitute(df))
  # Create a list named as df
  dict_name <- paste(df_name, "dict", sep = '_')
  # Initiate a list named after df
  dict_name <- list()
  # For mutation in mutation_cols, calculate mutation frequency, store in dict
  for (i in mutation_cols) {
    freq <- sum(df %>% select(i)) / nrow(df)
    dict_name <- append(dict_name, (i = freq))
  }
}
func(mutations_df)

func <- function(df) {
  df_name <- deparse(substitute(df))
   print(df_name)
   dict_name <- paste(df_name, "dict", sep = '_')
   print(dict_name)
   dict_name <- list("helo")
}





