library(dplyr)
library(tidyverse)

# Set working directory (also place data to read in working directory).
  WORK_DIR <- "/Users/davidlord/Documents/External_data"
  setwd(WORK_DIR)

# Read all .tsv files in the folder into a list
  MYFILES <- list.files(path = WORK_DIR, 
                     pattern = "\\.tsv$")

# Read all files in the list
  MYDATA <- lapply(MYFILES, read.delim)

# Convert the read files from lists to data frames

# SOLVE THIS :)

# Print the column names of all dataframes and store in object. 


# Keep duplicates in one object and uniques in separate object (?SKIP?)


# Create empty dataframe including duplicated columns (?SKIP?)


# Create an empty dataframe including all column names. 


# Merge all dataframes into empty dataframe.


# Modify data. 






