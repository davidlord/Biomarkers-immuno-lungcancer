library(plyr)
library(dplyr)
library(tidyverse)
library(stringr)
library(writexl)


# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

# Read all tsv files or read manually: 
  
  # Read all .tsv files: 

    # Read all .tsv files in the folder into a list
    MYFILES <- list.files(path = WORK_DIR, 
                      pattern = "\\.tsv$")
    # Read all files in the list
    MYDATA <- lapply(MYFILES, read.delim)

    # Read each data sets as data frames
    df1 <- as.data.frame(MYDATA[[1]])
    df2 <- as.data.frame(MYDATA[[2]])
    df3 <- as.data.frame(MYDATA[[3]])
    df4 <- as.data.frame(MYDATA[[4]])
    df5 <- as.data.frame(MYDATA[[5]])
    df6 <- as.data.frame(MYDATA[[6]])
    
  # Read manually
    Rivzi_2015 <- read.delim("Rivzi_2015_clinical_data.tsv")
    LUAD_Rivzi_2015 <- read.delim("LUAD_Rivzi_2015_clinical_data.tsv")
    Jordan_2017 <- read.delim("Jordan_2017_clinical_data.tsv")
    Hellmann_2018 <- read.delim("Hellmann_2018_clinical_data.tsv")
    Rivzi_2018 <- read.delim("Rivzi_2018_clinical_data.tsv")
    Chen_2020 <- read.delim("LUAD_Chen_2020_clinical_data.tsv")
    
  

# Select relevant columns and filter for immunotherapy when necessary. 
Col_in_all_datasets <- c("Study.ID", "Patient.ID", "Sample.ID", "Cancer.Type.Detailed", "Durable.Clinical.Benefit", "Sex", "TMB..nonsynonymous.")
# Add: Age, smoking status

Hellmann_2018_trimmed <- Hellmann_2018 %>% select("Study.ID", "Age..yrs.", "Smoking.Status", "Patient.ID", "Sample.ID", "Cancer.Type.Detailed", "Durable.Clinical.Benefit", "Sex", "TMB..nonsynonymous.", "Progress.Free.Survival..Months.", "PD.L1.expression..Percentage.")

Jordan_2017_trimmed <- Jordan_2017 %>% filter(Immunotherapy == 'YES' & !is.na(Durable.Clinical.Benefit)) %>% select("Study.ID", "Smoking.History", "Diagnosis.Age", "Patient.ID", "Sample.ID", "Cancer.Type.Detailed", "Durable.Clinical.Benefit", "Sex", "TMB..nonsynonymous.", "Stage.At.Diagnosis", "Gene.Panel")
                              
LUAD_Rivzi_2015_trimmed <- LUAD_Rivzi_2015 %>% select("Study.ID", "Diagnosis.Age", "Smoking.History", "Patient.ID", "Sample.ID", "Cancer.Type.Detailed", "Durable.Clinical.Benefit", "Sex", "TMB..nonsynonymous.", "PDL1.Expression", "Progress.Free.Survival..Months.")

Rivzi_2015_trimmed <- Rivzi_2015 %>% select("Study.ID", "Smoking.History", "Patient.Current.Age", "Patient.ID", "Sample.ID", "Cancer.Type.Detailed", "Durable.Clinical.Benefit", "Sex", "TMB..nonsynonymous.", "PDL1.Expression", "Progress.Free.Survival..Months.")

Rivzi_2018_trimmed <- Rivzi_2018 %>% select("Study.ID", "Patient.ID", "Sample.ID", "Diagnosis.Age", "Cancer.Type.Detailed", "Durable.Clinical.Benefit", "Gene.Panel", "PD.L1.Score....", "Progress.Free.Survival..Months.", "Sex", "Smoker", "TMB..nonsynonymous.")

# Exclude for now since does not contain progression free survival status
Chen_2020_trimmed <- LUAD_Chen_2020 %>% filter(TKI.Treatment == 'Yes'& Sequencing.Type != 'RNA-Seq') %>% select("Cancer.Study", "Patient.ID", "Sample.ID", "Cancer.Type.Detailed", "Age", "Sex", "Stage", "Smoking.status", "TMB..nonsynonymous.")


### Set same name for columns to enable merge

## Study ID = 'Study.ID'
## Patient ID = 'Patient.ID'
## Sample ID = 'Sample.ID'
## Cancer type = 'Cancer.Type.Detailed'
## Age = 'Diagnosis.Age'
## Sex = 'Sex'
## TMB = 'TMB..nonsynonymous.'
## Smoking status = 'Smoking.History'
## Clinical benefit = 'Durable.Clinical.Benefit'
## Gene panel = 'Sequencing.Type'
## PD.L1 = 'PD.L1.Expression'
## Progression free survival = 'Progress.Free.Survival..Months.'

# Change column names using: 
colnames(df)[which(names(df) == "colname")] <- "newcolname"

# Hellmann_2018
colnames(Hellmann_2018_trimmed)[which(names(Hellmann_2018_trimmed) == "Age..yrs.")] <- "Diagnosis.Age"
colnames(Hellmann_2018_trimmed)[which(names(Hellmann_2018_trimmed) == "Smoking.Status")] <- "Smoking.History"
colnames(Hellmann_2018_trimmed)[which(names(Hellmann_2018_trimmed) == "PD.L1.expression..Percentage.")] <- "PDL1.Expression"

# Jordan_2017
colnames(Jordan_2017_trimmed)[which(names(Jordan_2017_trimmed) == "Gene.Panel")] <- "Sequencing.Type"

# LUAD_Rivzi_2015

# Rivzi_2015
colnames(Rivzi_2015_trimmed)[which(names(Rivzi_2015_trimmed) == "Patient.Current.Age")] <- "Diagnosis.Age"

# Rivzi_2018
colnames(Rivzi_2018_trimmed)[which(names(Rivzi_2018_trimmed) == "Smoker")] <- "Smoking.History"
colnames(Rivzi_2018_trimmed)[which(names(Rivzi_2018_trimmed) == "PD.L1.Score....")] <- "PDL1.Expression"
colnames(Rivzi_2018_trimmed)[which(names(Rivzi_2018_trimmed) == "Gene.Panel")] <- "Sequencing.Type"




# Merge data sets by columns, missing columns will be NA

clinical_df <- rbind.fill(Hellmann_2018_trimmed, Jordan_2017_trimmed, LUAD_Rivzi_2015_trimmed, Rivzi_2015_trimmed, Rivzi_2018_trimmed)
clinical_df <- as.data.frame(merged_df, StringAsFactors = F)


# Add sequencing type to Hellmann_2018, LUAD_Rivzi_2015, and Rivzi_2018 (All WES)

clinical_df <- clinical_df %>% mutate(Sequencing.Type = ifelse(Study.ID %in% c("luad_mskcc_2015", "nsclc_mskcc_2018", "nsclc_mskcc_2015"), "WES", Sequencing.Type))


# Replace entries in columns so they match

# Smoking history, this may later be converted to ordinal data. 
table(clinical_df$Smoking.History)
# Current <- Current heavy
# Ever <- Current-Former
# Former <- 'Former heavy', 'Former light'
# Never <- Never
clinical_df$Smoking.History[clinical_df$Smoking.History == "Former heavy" | clinical_df$Smoking.History == "Former light"] <- "Former"
clinical_df$Smoking.History[clinical_df$Smoking.History == "Current heavy"] <- "Current"
clinical_df$Smoking.History[clinical_df$Smoking.History == "Ever"] <- "Current/Former"
table(clinical_df$Smoking.History)

# Durable clinical benefit, two categories
table(clinical_df$Durable.Clinical.Benefit)
# NA <- 'await', 'Not reached 6 months follow-up', 'NE'
# YES <- 'Durable Clinical Benefit', 'Durable clinical benefit beyond 6 months', 'DCB'
# NO <- 'No durable benefit', 'No Durable Benefit', 'NDB', 

clinical_df$Durable.Clinical.Benefit[clinical_df$Durable.Clinical.Benefit == "await" | clinical_df$Durable.Clinical.Benefit == "Not reached 6 months follow-up" | clinical_df$Durable.Clinical.Benefit == "NE"] <- NA
clinical_df$Durable.Clinical.Benefit[clinical_df$Durable.Clinical.Benefit == "Durable Clinical Benefit" | clinical_df$Durable.Clinical.Benefit == "Durable clinical benefit beyond 6 months" | clinical_df$Durable.Clinical.Benefit == "DCB"] <- "YES"
clinical_df$Durable.Clinical.Benefit[clinical_df$Durable.Clinical.Benefit == "No durable benefit" | clinical_df$Durable.Clinical.Benefit == "No Durable Benefit" | clinical_df$Durable.Clinical.Benefit == "NDB"] <- "NO"

# PD-L1 expression: 
table(clinical_df$PDL1.Expression)
# May want to include but skip for now... Only roughly 200 samples include PDL1 expr. 
sum(is.na(clinical_df$PDL1.Expression))


# Remove NAs: 
clinical_df <- clinical_df %>% filter(!is.na(Durable.Clinical.Benefit))

# Remove duplicate patient IDs:
clinical_df <- clinical_df %>% distinct(Patient.ID, .keep_all = TRUE)

# Rename column names in data set



# Visualize missing data (NAs) with heatmap
library(naniar)
vis_miss(clinical_df)


# Create one data frame for regression model (including progression free survival, excluding Durable clinical benefit)

# Create one data frame for classification model (including durable clinical benefit, excluding progression free survival)


# Export clinical data frame in excel format to work dir
write_xlsx(df_cbioportal_clinical, paste(WORK_DIR, "cbioportal_clinical_data.xlsx", sep = "/"))

# Export dataframe as 
write.table(df_cbioportal_clinical, file = "cbioportal_clinical_data.tsv", dec = ".", col.names = TRUE, sep = "\t")
