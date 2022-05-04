#=================================================================================
# LOAD LIBRARIES & READ FILES
#=================================================================================
library(ggplot2)
library(dplyr)
library(tidyverse)
library(hash)

# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

# Read data file
total_df <- read.delim("total_df.tsv", stringsAsFactors = TRUE)


#=======================================================================
# DIFFERENCE IN TMB BETWEEN COHORTS?
#=======================================================================

# Two-way ANOVA, test TMB as function of cohort and sequencing type
two_way_anova <- aov(TMB ~ Study_ID + Sequencing_type, data = total_df)
summary(two_way_anova)
# Sequencing type p-value = 0.68
# Study_ID p-value = 0.0056
# Will need to normalize TMB by study ID, not by sequencing type. 

# Two-way ANOVA on log2-transformed TMB values as function of cohort and sequencing type
# Create df with TMB log2 transformed
log2_total_df <- total_df %>% mutate(TMB = log2(TMB)) %>% filter(!is.infinite(TMB))
# Perform ANOVA
log2_two_way_anova <- aov(TMB ~ Study_ID + Sequencing_type, data = log2_total_df)
summary(log2_two_way_anova)

#=======================================================================
# ATTEMPT TO NORMALIZE
#=======================================================================

# Create a dictionary to store mean values for each cohort in
mean_TMB_dict <- hash()
# Get Study_IDs in df
study_ids <- levels(total_df$Study_ID)

ind <- total_df$Study_ID == "BioLung_2022"
# Count entries of this cohort
sum(total_df$Study_ID == "BioLung_2022")
# Calculate

#=======================================================================
# DO MANUALLY...
#=======================================================================


table(total_df$Study_ID)


length(test_df$Study_ID)
test_df <- total_df %>% filter(!is.na(TMB)) %>% mutate(TMB_normalized = )

grouped_df <- total_df %>% group_by(Study_ID)



