#=================================================================================
# LOAD LIBRARIES & READ FILES
# DEV: Read total_df from summary statistics instead...
#=================================================================================
library(ggplot2)
library(dplyr)
library(tidyverse)
library(naniar)
library(visdat)
library(readxl)
library(FactoMineR)
library(factoextra)

# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

# Read data file
total_df <- read.delim("combined_data.tsv", stringsAsFactors = TRUE)



#=======================================================================  
# PAN ET AL 2020 MUTATIONS
#=======================================================================

# Read model-ready dataset
model_df <- read.delim("model-ready_combinded_data.tsv", stringsAsFactors = TRUE)
unique(model_df$Study_ID)
model_df <- model_df %>% filter(Study_ID != "Model_Control")

model_df %>% ggplot(aes(x = Pan_2020_muts, fill = Treatment_Outcome)) +
  geom_histogram(binwidth = 1, alpha = 0.7) +
  scale_fill_brewer(palette = "Paired", direction = -1)

model_df %>% ggplot(aes(fill = Treatment_Outcome, y = Pan_2020_muts)) +
  geom_boxplot() +
  scale_y_continuous(trans = "log10")