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
# VISUALIZE MISSING DATA (CLINICAL FEATURES)
#=======================================================================

# Select relevant columns for visualization of missing data:
colnames(total_df)
# Rename PD-L1 Expression column
total_df <- total_df %>% rename("PD-L1_Expression" = "PD.L1_Expression")
# Subset into separate df
md_df <- total_df %>% select(Stage_at_diagnosis, `PD-L1_Expression`, Smoking_History, Sex, Histology, Diagnosis_Age, TMB)
# Replace empty string entries with NAs
md_df[md_df == ''] <- NA

# Rename columns
colnames(md_df)
md_df <- md_df %>% rename("Stage at Diagnosis" = Stage_at_diagnosis, "PD-L1 Expression" = `PD-L1_Expression`,
                          "Smoking History" = Smoking_History, "Tumor Histology" = Histology,
                          "Diagnosis Age" = Diagnosis_Age)

# Create barplots of missing data
md_barp <- md_df %>%
  summarise_all(list(~is.na(.))) %>%
  pivot_longer(everything(),
               names_to = "Features", values_to = "Missing") %>%
  count(Features, Missing) %>%
  ggplot(aes(y = Features, x = n, fill = Missing)) + 
  geom_col(position = "fill") +
  scale_fill_brewer(palette = "Paired") +
  theme(axis.title.y = element_blank()) +
  labs(x = "\nProportion")
md_barp

sum(is.na(md_df$`PD-L1 Expression`))/nrow(md_df)
