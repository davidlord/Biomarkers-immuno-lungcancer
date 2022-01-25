library(dplyr)
library(tidyverse)
library(stringr)
library(writexl)

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


# Store data frame in object, manual for now, update later... 
df1 <- as.data.frame(MYDATA[[1]])
df2 <- as.data.frame(MYDATA[[2]])
df3 <- as.data.frame(MYDATA[[3]])
df4 <- as.data.frame(MYDATA[[4]])

# Create an excel table from the data frame
write_xlsx(df1, "/Users/davidlord/Documents/External_data/Test_data_frames/test_table.xlsx")


