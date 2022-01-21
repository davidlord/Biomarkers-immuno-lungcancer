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

    # Write better later, do manually for now... 
      # Count number of columns in total in all dataframes in MYDATA
###      COL_COUNT = 0
###      for (i in 1:LEN) {
###      N <- (length(MYDATA[[i]]))
###      COL_COUNT = COL_COUNT + N
###      }

    # 
    COLNAMES = 0
    for (i in 1:LEN) {
      Z <- colnames(MYDATA[[i]])
      COLNAMES <- append(COLNAMES, Z)
    }
length(COLNAMES)    
print(COLNAMES)



