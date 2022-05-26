#=================================================================================
# LOAD LIBRARIES & READ FILES
# DEV: Read total_df from summary statistics instead...
#=================================================================================
library(ggplot2)
library(dplyr)
library(tidyverse)
library(naniar)
library(visdat)
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
# VISUALIZE MISSING DATA (CLINICAL FEATURES)
#=======================================================================

# Select relevant columns for visualization of missing data:
colnames(total_df)
# Rename PD-L1 Expression column
total_df <- total_df %>% rename("PD-L1_Expression" = "PD.L1_Expression")
# Subset into separate df
md_df <- total_df %>% select(Histology, 'PD-L1_Expression', Smoking_History, TMB, Diagnosis_Age, Stage_at_diagnosis, Sex, MSI, Study_ID)
# Replace empty string entries with NAs
md_df[md_df == ''] <- NA
# Create heatmap of missing data
gg_miss_fct(x = md_df, fct = Study_ID) + 
  labs(title = "Missing data in Combined Dataset", y = "Feature", x = "Cohort of Origin") +
  theme(axis.text.y = element_text(angle = 45))


#=======================================================================  
# PLOT RAWDATA, FAMD
#=======================================================================

# Read model-ready dataset
model_df <- read.delim("model-ready_combinded_data.tsv", stringsAsFactors = TRUE)

# Remove features
model_df <- model_df %>% select(-c(Treatment_Outcome, TMB, TMB_norm))

# Get FAMD
res_famd <- FAMD (base = model_df, ncp = 5, sup.var = NULL, ind.sup = NULL)

# Get & plot proportion of variances retained by dimensions (eigenvalues)
eig_vals <- get_eigenvalue(res_famd)
head(eig_vals)
fviz_screeplot(res_famd)

fviz_famd_ind(res_famd, habillage = "Study_ID", addEllipses = TRUE, 
              col.ind = "cos2", repel = TRUE, 
              )


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
  labs(x = "", y = "Diagnosis Age", subtitle = "N = 382") +
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
  labs(fill = "Treatment Outcome", x ="Patient Sex\n", y ="", subtitle = "N = 375") +
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
  labs(x = "Histology\n", y = "Count\n(log10 scale)", fill = "Treatment Outcome", subtitle = "N = 382") +
  theme(text = element_text(size = 14))
histology_barp



# SMOKING HISTORY
#===================

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

# COMBINE CURRENT + FORMER
smokinghistory_barp <- smoke_df %>% ggplot(aes(x = smokcol, y = fraccols, fill = respcol)) +
  geom_bar(stat = "identity", position = position_dodge(), color = "dodgerblue4") +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_brewer(palette = "Paired", direction = -1) +
  labs(x = "Smoking History\n", y = "", fill = "Treatment Outcome", subtitle = "N = 375") +
  theme(text = element_text(size = 14))
smokinghistory_barp


# COMBINE PLOTS
#=================
# Remove ligands from plots
sex_barp2 <- sex_barp + theme(legend.position="none")
histology_barp2 <- histology_barp + theme(legend.position="none")
smokinghistory_barp2 <- smokinghistory_barp + theme(legend.position="none")



ggarrange(histology_barp, ggarrange(sex_barp2, smokinghistory_barp2, ncol = 2, labels = c("B", "C")), 
          ggarrange(boxp_age, age_hist, ncol = 2, labels = c("D", "E")), nrow = 3, labels = c("A"))




#=======================================================================
# MUTATION FREQUENCIES
#=======================================================================

# Read gene frequencies file (excel file)
gene_freq_df <- read_excel("Gene_frequencies_2.xlsx")
gene_freq_df$Gene_freq <- as.numeric(gene_freq_df$Gene_freq)

# Barplots facet by column
barplot <- gene_freq_df %>% ggplot(aes(x = Study_ID, y = Gene_freq, fill = Study_ID, color = Study_ID)) +
  geom_bar(stat = "identity", color = "black") + 
  facet_wrap(~ Gene_mut) +
  scale_fill_brewer(palette = "Blues") +
  scale_y_continuous(limits = c(0, 0.7)) +
  theme(axis.text.x = element_blank()) +
  labs(x = "", y = "Gene mutation frequency")
barplot

test <- gene_freq_df %>% ggplot(aes(x =))
class(gene_freq_df$Gene_freq)

ylim = c(0, 0.5)


#=======================================================================
# MSI
#=======================================================================
biolung_df <- total_df %>% filter(Study_ID == "BioLung_2022")

# MSI HISTOGRAMS
#-----------------
MSI_hist <- biolung_df %>% ggplot(aes(x = MSI)) + geom_histogram(binwidth = 5)
MSI_hist


# MSI BOXPLOTS
#--------------
biolung_df$Treatment_Outcome <- ifelse(biolung_df$Treatment_Outcome == "Responder", "Responders \n (N = 20)", "Non-responders \n (N = 14)")

MSI_boxplot <- biolung_df %>% ggplot(aes(
  x = Treatment_Outcome, y = MSI, fill = Treatment_Outcome)) +
  geom_boxplot() +
  scale_fill_brewer(palette = "Paired", direction = -1) + 
  labs(x = "\n Treatment Outcome", y = "% Microsatellite Instability \n", subtitle = "N = 34", size = 10) +
  theme(legend.position = "none", text = element_text(size = 14))
MSI_boxplot


# MSI CORRELATIONS
#-------------------

# MSI vs TMB
biolung_df %>% ggplot(aes(x = MSI, y = TMB)) + 
  geom_point(color = "dodgerblue4") + 
  scale_x_continuous(trans = "log2") + 
  scale_y_continuous(trans = "log2") + 
  geom_smooth(method = lm, se=FALSE, linetype = "dashed", color = "dodgerblue3") + 
  labs(x = "\n % Microsatellite instability (log2)", y = "Tumor Mutation Burden (log2) \n", subtitle = "N = 34") +
  theme(text = element_text(size = 14))

biolung_df$PD.L1_Expression <- as.numeric(biolung_df$PD.L1_Expression)
biolung_df %>% ggplot(aes(MSI, y = PD.L1_Expression)) + 
  geom_point() +
  scale_x_continuous(trans = "log2")




#============================================================================
# ENGINEERED FEATURES:
# NDB RELATED GENES (STK11, EGFR)
# DCB RELATED GENES ()
# PAN ET AL (2020) COMPOUND MUTATIONS
#============================================================================






# Grid of histograms displaying TMB from clinical data set (from cBioPortal), later also include Biolung data. 
# Also include sequencing platform and N (sample size) as subtitle. 
# Select cool colour. 
df_cbioportal_clinical %>% ggplot(aes(TMB..nonsynonymous.)) + geom_histogram(binwidth = 1) + facet_wrap(~Study.ID)

# Generate boxplots of TMB across different studies. Add gene panel and sample size as sub-title. Facet grid. 

# Generate boxplots of TMB comparison between responders and non-responders in each study, facet grid. 


# Generate barplots of comparison between sexes. 

# Boxplot: Group by age. Facet by study. 