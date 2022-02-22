library(dplyr)
library(tidyverse)
library(stringr)
library(writexl)

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

df2_trimmed <- df2 %>% filter(Immunotherapy == 'YES' & !is.na(Durable.Clinical.Benefit)) %>% select("Study.ID", "Smoking.History", "Diagnosis.Age", "Patient.ID", "Sample.ID", "Cancer.Type.Detailed", "Durable.Clinical.Benefit", "Sex", "TMB..nonsynonymous.")
                              
df3_trimmed <- df3 %>% select("Study.ID", "Diagnosis.Age", "Smoking.History", "Patient.ID", "Sample.ID", "Cancer.Type.Detailed", "Durable.Clinical.Benefit", "Sex", "TMB..nonsynonymous.",)

df4_trimmed <- df4 %>% select("Study.ID", "Smoking.History", "Patient.Current.Age", "Patient.ID", "Sample.ID", "Cancer.Type.Detailed", "Durable.Clinical.Benefit", "Sex", "TMB..nonsynonymous.")

df5_trimmed <- df5 %>% select("Study.ID", "Age..yrs.", "Smoking.Status", "Patient.ID", "Sample.ID", "Cancer.Type.Detailed", "Durable.Clinical.Benefit", "Sex", "TMB..nonsynonymous.")

### NOTE: May add gene panels (info from publications) as column later, comparison of different properties between gene panels / WES

### Select name conventions for columns: 

## Study ID = 'Study.ID'
## Patient ID = 'Patient.ID'
## Sample ID = 'Sample.ID'
## Cancer type = 'Cancer.Type.Detailed'
## Age = 'Age'
## Sex = 'Sex'
## TMB = 'TMB..nonsynonymous.'
## Smoking status = 'Smoking.Status'
## Clinical benefit = 'Durable.Clinical.Benefit'


# Rename necessary columns

# df1:
colnames(df1_trimmed) [2] <- "Age"

# df2:
colnames(df2_trimmed) [2] <- "Smoking.Status"
colnames(df2_trimmed) [3] <- "Age"

# df3: 
colnames(df3_trimmed) [2] <- "Age"
colnames(df3_trimmed) [3] <- "Smoking.Status"

# df4:
colnames(df4_trimmed) [2] <- "Smoking.Status"
colnames(df4_trimmed) [3] <- "Age"

# df5:
colnames(df5_trimmed) [2] <- "Age"


# Merge data sets by columns

df_cbioportal_clinical <- rbind(df1_trimmed, df2_trimmed, df3_trimmed, df4_trimmed, df5_trimmed)

# Export clinical data frame in excel format to work dir
write_xlsx(df_cbioportal_clinical, paste(WORK_DIR, "cbioportal_clinical_data.xlsx", sep = "/"))


df_cbioportal_clinical %>% ggplot(aes(TMB..nonsynonymous.)) + geom_histogram(binwidth = 1) + facet_wrap(~Study.ID)




