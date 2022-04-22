library(dplyr)
library(tidyverse)
library(stringr)
library(writexl)

# Read mutation table files
# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

# Read all .tsv files in the folder into a list
MYFILES <- list.files(path = WORK_DIR, 
                      pattern = "\\.mutation.tsv$")
# Read all files in the list
MYDATA <- lapply(MYFILES, read.delim)

df <- as.data.frame(MYDATA[[1]])


help("names")
# Load clinical data tables as data frames. 

  # Rename columns to be included so they match. 

  # Select columns, then merge clinical data tables to one data set. 

  # Rename entries i n columns using 'ifelse'. 


# For each mutation tables: 

  # Load mutation tables as data frames.

  # Filter for allele frequency > 0.1, filter for variant reads > 10 select columns. 

  # Decide on a way to deal with duplicates... 

  # If overall.survival.months and response.free.survival. 

  # Merge to clinical data frame (matched by sample ID), set column name as gene. 







