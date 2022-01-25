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

# Get column names of all data frames in list, store in object

    # Count number of lists in MYDATA
    LEN <- (length(MYDATA))

    # Create an empty list COLNAMES
    COLNAMES <- list()
    # Store column names for each dataset in object COLNAMES
    for (i in 1:LEN) {
      Z <- colnames(MYDATA[[i]])
      COLNAMES <- append(COLNAMES, Z)
      }

      # Identify unique column names, only present in one dataset
      ### unique_ind <- !duplicated(COLNAMES)
      
      # Store unique column names in object
      ### UNIQUE_COLNAMES <- COLNAMES[unique_ind]

      ### length(UNIQUE_COLNAMES)


