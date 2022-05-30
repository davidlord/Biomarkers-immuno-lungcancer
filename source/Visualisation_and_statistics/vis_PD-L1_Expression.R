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
# PD-L1 Expression
#=======================================================================




