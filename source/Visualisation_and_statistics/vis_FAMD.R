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
# VISUALIZE MISSING DATA (CLINICAL FEATURES)
#=======================================================================

# Select relevant columns for visualization of missing data:
colnames(total_df)
# Rename PD-L1 Expression column
total_df <- total_df %>% rename("PD-L1_Expression" = "PD.L1_Expression")
# Subset into separate df
md_df <- total_df %>% select(Histology, 'PD-L1_Expression', Smoking_History, TMB, Diagnosis_Age, Stage_at_diagnosis, Sex, MSI, Study_ID)
# Replace empty string entries with NAs
md_df[md_df == ''] <- NA
# Create heatmap of missing data
gg_miss_fct(x = md_df, fct = Study_ID) + 
  labs(title = "Missing data in Combined Dataset", y = "Feature", x = "Cohort of Origin") +
  theme(axis.text.y = element_text(angle = 45))


#=======================================================================  
# PLOT RAWDATA, FAMD
#=======================================================================

# Read model-ready dataset
model_df <- read.delim("model-ready_combinded_data.tsv", stringsAsFactors = TRUE)

# Remove features
model_df <- model_df %>% select(-c(Treatment_Outcome, TMB, TMB_norm))

# Get FAMD
res_famd <- FAMD (base = model_df, ncp = 5, sup.var = NULL, ind.sup = NULL)

# Get & plot proportion of variances retained by dimensions (eigenvalues)
eig_vals <- get_eigenvalue(res_famd)
head(eig_vals)
fviz_screeplot(res_famd)

fviz_famd_ind(res_famd, habillage = "Study_ID", addEllipses = TRUE, 
              col.ind = "cos2", repel = TRUE, 
              )

