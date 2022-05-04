#================================================================================
# LOAD LIBRARIES & READ FILES
#================================================================================
# Load libraries
library(plyr)
library(dplyr)
library(tidyverse)
library(stringr)
library(writexl)
library(readxl)

# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

# Read clinical data
biolung_2022 <- read_excel("x")

# Read BioLung clinical data table
#
# Get BioLung clinical data sample IDs as vector

#================================================================================
# 
#================================================================================

# Select relevant columns in variants table

# Check format of sample IDs in variants table. 


# Check entries in Sample ID with levels function


# Check so that patients in clinical df are included in variants table. 


# Select patients included in


# Check so that mutations of interest are present in variants table




# Check so that Pan 2020 mutations are present in variants table



# Pseudocode: 
# Create an empty dataframe with columns: Patient_ID + mutation names

# Select 








