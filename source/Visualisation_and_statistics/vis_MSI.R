#=================================================================================
# LOAD LIBRARIES & READ FILES
# DEV: Read total_df from summary statistics instead...
#=================================================================================
library(ggplot2)
library(dplyr)
library(tidyverse)
library(readxl)

# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

# Read data file
total_df <- read.delim("combined_data.tsv", stringsAsFactors = FALSE)

# Replace 'Responder' for 'Responders' & 'Non-responder' for 'Non-responders'
total_df$Treatment_Outcome <- ifelse(total_df$Treatment_Outcome == "Responder", "Responders", "Non-responders")


#=======================================================================
# MSI
#=======================================================================
biolung_df <- total_df %>% filter(Study_ID == "BioLung_2022")

# MSI HISTOGRAMS
#-----------------
MSI_hist <- biolung_df %>% ggplot(aes(x = MSI)) + geom_histogram(binwidth = 5)
MSI_hist


# MSI BOXPLOTS
#--------------
biolung_df$Treatment_Outcome <- ifelse(biolung_df$Treatment_Outcome == "Responder", "Responders \n (N = 20)", "Non-responders \n (N = 14)")

MSI_boxplot <- biolung_df %>% ggplot(aes(
  x = Treatment_Outcome, y = MSI, fill = Treatment_Outcome)) +
  geom_boxplot() +
  scale_fill_brewer(palette = "Paired", direction = -1) + 
  labs(x = "\n Treatment Outcome", y = "% Microsatellite Instability \n", subtitle = "N = 34", size = 10) +
  theme(legend.position = "none", text = element_text(size = 14))
MSI_boxplot


# MSI CORRELATIONS
#-------------------

# MSI vs TMB
biolung_df %>% ggplot(aes(x = MSI, y = TMB)) + 
  geom_point(color = "dodgerblue4") + 
  scale_x_continuous(trans = "log2") + 
  scale_y_continuous(trans = "log2") + 
  geom_smooth(method = lm, se=FALSE, linetype = "dashed", color = "dodgerblue3") + 
  labs(x = "\n % Microsatellite instability (log2)", y = "Tumor Mutation Burden (log2) \n", subtitle = "N = 34") +
  theme(text = element_text(size = 14))

biolung_df$PD.L1_Expression <- as.numeric(biolung_df$PD.L1_Expression)
biolung_df %>% ggplot(aes(MSI, y = PD.L1_Expression)) + 
  geom_point() +
  scale_x_continuous(trans = "log2")

