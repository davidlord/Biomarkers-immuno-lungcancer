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


### Select name conventions for columns: 

## Study ID = 'Study.ID'
## Patient ID = 'Patient.ID'
## Sample ID = 'Sample.ID'
## Cancer type = 'Cancer.Type'
## Age = 'Age'
## Sex = 'Sex'
## TMB = 'TMB..nonsynonymous.'
## Smoking status = 'Smoking.Status'
## Clinical benefit = 'Durable.Clinical.Benefit'
## Gene panel = Gene.Panel
## PD.L1 score = PD-L1_score
## Progression free survival = 'Progression.Free.Survival'

# Change column names using: 
colnames(df)[which(names(df) == "colname")] <- "newcolname"

# Rename columns prior to data merge

# Hellmann_2018
colnames(Hellmann_2018_trimmed)[which(names(Hellmann_2018_trimmed) == "Age..yrs.")] <- "Diagnosis.Age"

# Jordan_2017
colnames(Jordan_2017_trimmed)[which(names(Jordan_2017_trimmed) == "Diagnosis.Age")] <- "Age"



# LUAD_Rivzi_2015


# Rivzi_2015
colnames(Hellmann_2018_trimmed)[which(names(Hellmann_2018_trimmed) == "Patient.Current.Age")] <- "Diagnosis.Age"

# Rivzi_2018



# Merge data sets by columns

df_cbioportal_clinical <- rbind(df1_trimmed, df2_trimmed, df3_trimmed, df4_trimmed, df5_trimmed)


length(df_cbioportal_clinical)

str(df_cbioportal_clinical)

# Replace entries in columns

  # Smoking status
  table(df_cbioportal_clinical$Smoking.Status)
    # Former heavy -> Former
    # Former light -> Former
    # Current heavy -> Current
    df_cbioportal_clinical$Smoking.Status[df_cbioportal_clinical$Smoking.Status == "Former heavy" | df_cbioportal_clinical$Smoking.Status == "Former light"] <- "Former"
    df_cbioportal_clinical$Smoking.Status[df_cbioportal_clinical$Smoking.Status == "Current heavy"] <- "Current"
  
  # Durable clinical benefit
  table(df_cbioportal_clinical$Durable.Clinical.Benefit)
    # DCB | Durable clinical benefit beyond 6 months | YES -> Durable Clinical Benefit
    df_cbioportal_clinical$Durable.Clinical.Benefit[df_cbioportal_clinical$Durable.Clinical.Benefit == "DCB" | df_cbioportal_clinical$Durable.Clinical.Benefit == "Durable clinical benefit beyond 6 months" | df_cbioportal_clinical$Durable.Clinical.Benefit == "YES"] <- "Durable Clinical Benefit"
    # No durable benefit | NDB | NO -> No Durable Benefit
    df_cbioportal_clinical$Durable.Clinical.Benefit[df_cbioportal_clinical$Durable.Clinical.Benefit == "NDB" | df_cbioportal_clinical$Durable.Clinical.Benefit == "No durable benefit" | df_cbioportal_clinical$Durable.Clinical.Benefit == "NO"] <- "No Durable Benefit"
    # await | Not reached 6 months follow-up -> NA
    df_cbioportal_clinical$Durable.Clinical.Benefit[df_cbioportal_clinical$Durable.Clinical.Benefit == "await" | df_cbioportal_clinical$Durable.Clinical.Benefit == "Not reached 6 months follow-up"] <- NA
    # Filter away NAs 
    df_cbioportal_clinical <- df_cbioportal_clinical %>% filter(!is.na(Durable.Clinical.Benefit))
    # Remove duplicates
    df_cbioportal_clinical <- df_cbioportal_clinical %>% distinct()
    
# Check so that no NAs left:
sum(is.na(df_cbioportal_clinical))

# Remove duplicated entries (same Patient ID)




# Export clinical data frame in excel format to work dir
write_xlsx(df_cbioportal_clinical, paste(WORK_DIR, "cbioportal_clinical_data.xlsx", sep = "/"))

# Export dataframe as 
write.table(df_cbioportal_clinical, file = "cbioportal_clinical_data.tsv", dec = ".", col.names = TRUE, sep = "\t")
