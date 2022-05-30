#=================================================================================
# LOAD LIBRARIES & READ FILES
# DEV: Read total_df from summary statistics instead...
#=================================================================================
library(ggplot2)
library(dplyr)
library(tidyverse)
library(readxl)
library(FactoMineR)
library(factoextra)
library(ggpubr)

# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

# Read data file
total_df <- read.delim("combined_data.tsv", stringsAsFactors = FALSE)

# Replace 'Responder' for 'Responders' & 'Non-responder' for 'Non-responders'
total_df$Treatment_Outcome <- ifelse(total_df$Treatment_Outcome == "Responder", "Responders", "Non-responders")


#=======================================================================
# PATIENT DEMOGRAPHY & TREATMENT OUTCOME
#=======================================================================

# PATIENT AGE
#=============

# PLOT AGE DISTRIBUTION
#------------------------
age_hist <- total_df %>% ggplot(aes(x = Diagnosis_Age)) +
  geom_histogram(aes(y = ..density..), binwidth = 3.5, color = "dodgerblue3", fill = "dodgerblue4") +
  geom_density(alpha = 0.2, fill = "dodgerblue2") +
  labs(x = "Patient Age at Diagnosis", y = "Density") +
  theme(text = element_text(size = 14))
age_hist

# PATIENT AGE QQ-PLOT
age_qq <- ggqqplot(total_df$Diagnosis_Age, ylab = "")

# COMBINE
ggarrange(age_hist, age_qq, labels = c("A", "B"))


# BOXPLOT, PATIENT AGE, RESPONDERS VS NON-RESPONDERS
#--------------------------------------------------------
temp_df <- total_df %>% filter(!is.na(Diagnosis_Age))
table(temp_df$Treatment_Outcome)
temp_df$Treatment_Outcome <- ifelse(temp_df$Treatment_Outcome == "Responders", "Responders\n(N = 159)", "Non-responders\n(N = 223)")

boxp_age <- temp_df %>% ggplot(aes(x = Treatment_Outcome, y = Diagnosis_Age, fill = Treatment_Outcome)) +
  geom_boxplot() +
  scale_fill_brewer(palette = "Paired", direction = -1) + 
  labs(x = "", y = "\nDiagnosis Age") +
  theme(legend.position = "none", text = element_text(size = 14))
boxp_age


# PATIENT SEX
#==============

# BARPLOT, PATIENT SEX, RESPONDERS VS NON-RESPONDERS
#-----------------------------------------------------
# Calculate sums, store as df
sex_df <- total_df %>% group_by(Sex) %>% summarize(
  "Responders" = sum(Treatment_Outcome == "Responders"), 
  "Non-responders" = sum(Treatment_Outcome == "Non-responders")
)

# Transform to managable format
sexcol <- c("Female\n(N = 190)", "Female\n(N = 190)", "Male\n(N = 185)", "Male\n(N = 185)")
respcol <- c("Responders", "Non-responders", "Responders", "Non-responders")
countcol <- c(83, 107, 70, 115)
fraccols <- c(0.437, 0.563, 0.378, 0.622)
sex_df2 <- data.frame(sexcol, respcol, countcol, fraccols)

sex_barp <- sex_df2 %>% ggplot(aes(x = sexcol, y = fraccols, fill = respcol)) +
  geom_bar(stat = "identity", position = position_dodge(), color = "dodgerblue4") +
  scale_fill_brewer(palette = "Paired", direction = -1) +
  labs(fill = "Treatment Outcome", x ="Patient Sex\n", y ="") +
  theme(text = element_text(size = 14)) +
  scale_y_continuous(labels = scales::percent)
sex_barp


# TUMOR HISTOLOGY
#===================

# BARPLOT, HISTOLOGY, RESPONDERS VS NON-RESPONDERS
#----------------------------------------------------

# Remove NAs in a temporary df
temp_df <- total_df %>% filter(!is.na(Histology))

# Replace entries with abbreviations
unique(temp_df$Histology)
temp_df$Histology[temp_df$Histology == "Large Cell Neuroendocrine Carcinoma"] <- "LCNEC\n(N = 6)"
temp_df$Histology[temp_df$Histology == "Lung Adenocarcinoma"] <- "LUAD\n(N = 322)"
temp_df$Histology[temp_df$Histology == "Lung Squamous Cell Carcinoma"] <- "LSCC\n(N = 40)"
temp_df$Histology[temp_df$Histology == "Non-Small Cell Lung Cancer"] <- "NSCLC\n(N = 14)"

# Calculate numbers of each
table(temp_df$Histology)
counts <- c(6, 40, 322, 14)
nrow(temp_df)

# BARPLOT HISTOLOGY RESPONDERS VS NON-RESPONDERS
histology_barp <- temp_df %>% ggplot(aes(x = Histology, fill = Treatment_Outcome)) +
  geom_bar(position = position_dodge(), color = "dodgerblue4") +
  scale_y_continuous(trans = "log10") +
  scale_fill_brewer(palette = "Paired", direction = -1) +
  labs(x = "Histology\n", y = "Count\n(log10 scale)", fill = "Treatment Outcome") +
  theme(text = element_text(size = 14))
histology_barp



# SMOKING HISTORY VERSION 1: BINNED
#======================================

# Remove NAs 
temp_df <- total_df %>% filter(!is.na(Smoking_History))
table(temp_df$Smoking_History)

# Combine Current and former to Current/Former
temp_df$Smoking_History[temp_df$Smoking_History == "Current"] <- "Current/Former"
temp_df$Smoking_History[temp_df$Smoking_History == "Former"] <- "Current/Former"

# Calculate sums, store as df
temp_df %>% group_by(Smoking_History) %>% summarize(
  "Responders" = sum(Treatment_Outcome == "Responders"), 
  "Non-responders" = sum(Treatment_Outcome == "Non-responders")
)

# Transform to managable format
smokcol <- c("Current / Former\n(N = 299)", "Current / Former\n(N = 299)", "Never\n(N = 76)", "Never\n(N = 76)")
respcol <- c("Responders", "Non-responders", "Responders", "Non-responders")
countcol <- c(123, 176, 30, 46)
fraccols <- c(0.411, 0.588, 0.3947, 0.605)
smoke_df <- data.frame(smokcol, respcol, countcol, fraccols)

# Plot proportions as barplot
smokinghistory_barp <- smoke_df %>% ggplot(aes(x = smokcol, y = fraccols, fill = respcol)) +
  geom_bar(stat = "identity", position = position_dodge(), color = "dodgerblue4") +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_brewer(palette = "Paired", direction = -1) +
  labs(x = "Smoking History\n", y = "", fill = "Treatment Outcome") +
  theme(text = element_text(size = 14))
smokinghistory_barp


# SMOKING HISTORY VERSION 2: UNBINNED
#======================================

# Remove NAs 
temp_df <- total_df %>% filter(!is.na(Smoking_History))
table(temp_df$Smoking_History)

# Transform to managable format
smokcol <- c("Current\n(N = 21)", "Current\n(N = 21)", "Current/Former\n(N = 169)", "Current/Former\n(N = 169)", "Former\n(N = 109)", "Former\n(N = 109)", "Never\n(N = 76)", "Never\n(N = 76)")
respcol <- c("Responders", "Non-responders", "Responders", "Non-responders", "Responders", "Non-responders", "Responders", "Non-responders")
countcol <- c(7, 14, 57, 112, 59, 50, 30, 46)
fraccols <- c(0.33333, 0.6666, 0.33727, 0.6627, 0.54128, 0.458715, 0.39473, 0.60526)
smoke_df <- data.frame(smokcol, respcol, countcol)

# Plot proportions as barplot
smokinghistory_barp <- smoke_df %>% ggplot(aes(x = smokcol, y = fraccols, fill = respcol)) +
  geom_bar(stat = "identity", position = position_dodge(), color = "dodgerblue4") +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_brewer(palette = "Paired", direction = -1) +
  labs(x = "Smoking History\n", y = "", fill = "Treatment Outcome") +
  theme(text = element_text(size = 14))
smokinghistory_barp


# COMBINE PLOTS
#=================
# Remove ligands from plots
sex_barp2 <- sex_barp + theme(legend.position="none")
histology_barp2 <- histology_barp + theme(legend.position="none")
smokinghistory_barp2 <- smokinghistory_barp + theme(legend.position="none")

# Combine plotw w ggArrange
ggarrange(histology_barp, ggarrange(sex_barp2, boxp_age, ncol = 2, labels = c("B", "C")), 
          ggarrange(smokinghistory_barp2, labels = "D"), nrow = 3, labels = "A")


