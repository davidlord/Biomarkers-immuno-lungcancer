library(dplyr)
library(tidyverse)
library(stringr)

# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

# Read all .tsv files in the folder into a list
MYFILES <- list.files(path = WORK_DIR, 
                      pattern = "\\.tsv$")

# Read all files in the list
MYDATA <- lapply(MYFILES, read.delim)

length(MYDATA)

# Create a df for each data frame in MYDATA
### Fix this later... 
for(i in 1:length(MYDATA)){
  istr <- as.character(i)
  print(istr)
  x = (paste("df", istr, sep = "_"))
  x <- as.data.frame(MYDATA[[i]])
}

# Read each data sets as data frames
df1 <- as.data.frame(MYDATA[[1]])
df2 <- as.data.frame(MYDATA[[2]])
df3 <- as.data.frame(MYDATA[[3]])
df4 <- as.data.frame(MYDATA[[4]])
df5 <- as.data.frame(MYDATA[[5]])

# Select relevant columns and filter for immunotherapy when necessary. 
Col_in_all_datasets <- c("Study.ID", "Patient.ID", "Sample.ID", "Cancer.Type.Detailed", "Durable.Clinical.Benefit", "Sex", "TMB..nonsynonymous.")
# Add: Age, smoking status

df1_trimmed <- df1 %>% select("Study.ID", "Age..yrs.", "Smoking.Status", "Patient.ID", "Sample.ID", "Cancer.Type.Detailed", "Durable.Clinical.Benefit", "Sex", "TMB..nonsynonymous.")

df2_trimmed <- df2 %>% select("Study.ID", "Smoking.History", "Gene.Panel", "Diagnosis.Age", "Immunotherapy", "Patient.ID", "Sample.ID", "Cancer.Type.Detailed", "Durable.Clinical.Benefit", "Sex", "TMB..nonsynonymous.") %>% filter(Immunotherapy == 'YES' & !is.na(Durable.Clinical.Benefit))

df3_trimmed <- df3 %>% select("Study.ID", "Diagnosis.Age", "Smoking.History", "Patient.ID", "Sample.ID", "Cancer.Type.Detailed", "Durable.Clinical.Benefit", "Sex", "TMB..nonsynonymous.")

df4_trimmed <- df4 %>% select("Study.ID", "Smoking.History", "Patient.Current.Age", "Patient.ID", "Sample.ID", "Cancer.Type.Detailed", "Durable.Clinical.Benefit", "Sex", "TMB..nonsynonymous.")

df5_trimmed <- df5 %>% select("Study.ID", "Age..yrs.", "Smoking.Status", "Patient.ID", "Sample.ID", "Cancer.Type.Detailed", "Durable.Clinical.Benefit", "Sex", "TMB..nonsynonymous.")



