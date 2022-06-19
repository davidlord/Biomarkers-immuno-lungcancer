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

# Read Combined dataset
total_df <- read.delim("combined_data.tsv", stringsAsFactors = TRUE)
# Read model-ready dataset
model_df <- read.delim("model-ready_combinded_data.tsv", stringsAsFactors = TRUE)
model_df <- model_df %>% filter(Study_ID != "Model_Control")
model_df <- model_df %>% filter(Study_ID != "Jordan_2017")
unique(model_df$Study_ID)


#=======================================================================  
# PLOT RAWDATA, FAMD
#=======================================================================





# Get FAMD
res_famd <- FAMD (base = model_df, ncp = 5, sup.var = NULL, ind.sup = NULL)

# Get & plot proportion of variances retained by dimensions (eigenvalues)
eig_vals <- get_eigenvalue(res_famd)
head(eig_vals)
fviz_screeplot(res_famd)

fviz_famd_ind(res_famd, habillage = "Study_ID", addEllipses = TRUE, 
              col.ind = "cos2", repel = TRUE, 
              )



fviz_famd_ind(res_famd, habillage = "Treatment_Outcome", addEllipses = TRUE, 
              col.ind = "cos2", repel = TRUE, 
)






