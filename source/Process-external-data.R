library(dplyr)
library(tidyverse)
library(stringr)

# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data"
setwd(WORK_DIR)

# Read all .tsv files in the folder into a list
MYFILES <- list.files(path = WORK_DIR, 
                     pattern = "\\.tsv$")

# Read all files in the list
MYDATA <- lapply(MYFILES, read.delim)

# Convert the read files from lists to data frames

# Get column names of all data frames in list, store in object

  # Count number of lists in MYDATA
  LEN <- (length(MYDATA))

  # Count number of columns in total in all dataframes in MYDATA
  COL_COUNT = 0
  for (i in 1:LEN) {
      N <- (length(MYDATA[[i]]))
      COL_COUNT = COL_COUNT + N
      }

    # Create an empty list with the length of COL_COUNT  
    COL_LIST <- vector(length = COL_COUNT)
    
for(i in 1:LEN){
  test_colnames_list <- (colnames(MYDATA[[i]]))
}


# Print the column names of all dataframes and store in object. 


# Keep duplicates in one object and uniques in separate object (?SKIP?)


# Create empty dataframe including duplicated columns (?SKIP?)


# Create an empty dataframe including all column names. 


# Merge all dataframes into empty dataframe.


# Modify data. 






