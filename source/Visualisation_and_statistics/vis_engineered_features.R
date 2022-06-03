#=================================================================================
# LOAD LIBRARIES & READ FILES
# DEV: Read total_df from summary statistics instead...
#=================================================================================
library(ggplot2)
library(ggpubr)
library(dplyr)
library(tidyverse)


# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

# Read data file
total_df <- read.delim("Features_engineered_control_included.tsv", stringsAsFactors = FALSE)

# Remove control cohort
unique(total_df$Study_ID)
temp_df <- total_df %>% filter(Study_ID != "Model_Control")
unique(temp_df$Study_ID)



#=======================================================================  
# GENES ASSOCIATED WITH BENEFICIAL TREATMENT OUTCOME
#=======================================================================

# Create temporary df
dcb_df <- temp_df %>% select(Study_ID, Treatment_Outcome, DCB_genes)

# BARPLOTS RESPONDERS VS NON-RESPONDERS
#----------------------------------------
dcb_df %>% ggplot(aes(x = DCB_genes, fill = Treatment_Outcome)) +
  geom_bar(color = "dodgerblue4", position = position_dodge()) +
  scale_fill_brewer(palette = "Paired", direction = -1) +
  scale_y_continuous(trans = "log2") +
  labs(y = "Count (log2 scale)", x = "Number of Gene Mutations", fill = "Treatment Outcome")



#=======================================================================  
# GENES ASSOCIATED WITH UNBENEFICIAL TREATMENT OUTCOME
#=======================================================================

# Create temporary df
ndb_df <- temp_df %>% select(Study_ID, Treatment_Outcome, NDB_genes)

# BARPLOTS RESPONDERS VS NON-RESPONDERS
#----------------------------------------
ndb_df %>% ggplot(aes(x = NDB_genes, fill = Treatment_Outcome)) +
  geom_bar(color = "dodgerblue4", position = position_dodge()) +
  scale_fill_brewer(palette = "Paired", direction = -1) +
  scale_y_continuous(trans = "log2") +
  labs(y = "Count (log2 scale)", x = "Number of Gene Mutations", fill = "Treatment Outcome")



#=======================================================================  
# PAN ET AL 2020 MUTATIONS
#=======================================================================

temp_df %>% ggplot(aes(x = Pan_2020_muts)) +
  geom_histogram(binwidth = 1, fill = "steelblue", color = "dodgerblue4") +
  labs(x = "Number of Signature Mutations", y = "Count", title = "Pan et al 2020 Signature Mutations")

temp_df %>% ggplot(aes(x = Pan_2020_muts, fill = Treatment_Outcome)) +
  geom_histogram(binwidth = 1, alpha = 0.7, color = "dodgerblue4") +
  scale_fill_brewer(palette = "Paired", direction = -1)

temp_df %>% filter(Pan_2020_muts < 10) %>%
  ggplot(aes(x = Treatment_Outcome, y = Pan_2020_muts)) +
  geom_boxplot()


