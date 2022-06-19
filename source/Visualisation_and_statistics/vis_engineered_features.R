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
dcb_bar <- dcb_df %>% ggplot(aes(x = DCB_genes, fill = Treatment_Outcome)) +
  geom_bar(color = "dodgerblue4", position = position_dodge()) +
  scale_fill_brewer(palette = "Paired", direction = -1) +
  scale_y_continuous(trans = "log2") +
  labs(y = "Count (log2 scale)", x = "Number of Gene Mutations", 
       fill = "Treatment Outcome", title = "DCB Gene Mutations")
dcb_bar

# HISTOGRAM 
#------------
dcb_hist <- dcb_df %>% ggplot(aes(x = DCB_genes)) +
  geom_histogram(binwidth = 1, color = "dodgerblue4", fill = "steelblue") +
  scale_y_continuous(trans = "log2") +
  labs(y = "Count (log2 scale)", x = "Number of DCB Gene Mutations")
dcb_hist





#=======================================================================  
# GENES ASSOCIATED WITH UNBENEFICIAL TREATMENT OUTCOME
#=======================================================================

# Create temporary df
ndb_df <- temp_df %>% select(Study_ID, Treatment_Outcome, NDB_genes)

# BARPLOTS RESPONDERS VS NON-RESPONDERS
#----------------------------------------
ndb_bar <- ndb_df %>% ggplot(aes(x = NDB_genes, fill = Treatment_Outcome)) +
  geom_bar(color = "dodgerblue4", position = position_dodge()) +
  scale_fill_brewer(palette = "Paired", direction = -1) +
  scale_y_continuous(trans = "log2") +
  labs(y = "Count (log2 scale)", x = "Number of Gene Mutations", 
       fill = "Treatment Outcome", title = "NDB Gene Mutations")
ndb_bar

# HISTOGRAM
#-----------
ndb_hist <- ndb_df %>% ggplot(aes(x = NDB_genes)) +
  geom_histogram(binwidth = 1, color = "dodgerblue4", fill = "steelblue") +
  scale_y_continuous(trans = "log2") +
  labs(y = "Count (log2 scale)", x = "Number of DCB Gene Mutations")
ndb_hist




#=======================================================================  
# PAN ET AL 2020 MUTATIONS
#=======================================================================

temp_df %>% ggplot(aes(x = Pan_2020_muts)) +
  geom_histogram(binwidth = 1, fill = "steelblue", color = "dodgerblue4") +
  labs(x = "Number of Signature Mutations", y = "Count", title = "Pan et al 2020 Signature Mutations")

sig_genes_hist <- temp_df %>% ggplot(aes(x = Pan_2020_muts, fill = Treatment_Outcome)) +
  geom_histogram(binwidth = 1, alpha = 1, color = "dodgerblue4") +
  scale_fill_brewer(palette = "Paired", direction = -1) +
  labs(x = "Number of Signature Mutations\n", y = "Count", 
       fill = "Treatment Outcome", title = "Signature Gene Mutations")
sig_genes_hist


#=======================================================================  
# COMBINE PLOTS
#=======================================================================
# Remove legends
sig_genes_hist
dcb_bar <- dcb_bar + theme(legend.position="none")
ndb_bar <- ndb_bar + theme(legend.position="none")

# Combine barplots and Signature genes histogram
ggarrange(sig_genes_hist, ggarrange(dcb_bar, ndb_bar, ncol = 2, labels = c("B", "C")), nrow = 2, labels = "A")

# Combine NDB gene mutations and DCB gene mutations hist
ggarrange(dcb_hist, ndb_hist)


