#=================================================================================
# LOAD LIBRARIES & READ FILES
#=================================================================================
library(ggplot2)
library(dplyr)
library(tidyverse)
library(ggpubr)

# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

# Read data file
total_df <- read.delim("combined_data.tsv", stringsAsFactors = FALSE)



#=======================================================================
# MSI STATISTICAL ANALYSIS
#=======================================================================

# COMPARE MSI: RESPONDERS VS NON-RESPONDERS
#---------------------------------------------

# Subset BioLung DF
biolung_df <- total_df %>% filter(Study_ID == "BioLung_2022")
# Check for NAs in MSI data
sum(is.na(biolung_df$MSI))
# Compare MSI responders vs non-responders using Mann-Whitney-Wilcoxon test
wilcox.test(MSI ~ Treatment_Outcome, data = biolung_df)

# Get median for each group
biolung_df %>% group_by(Treatment_Outcome) %>% summarize(
  median(MSI)
)
temp <- biolung_df %>% select(Treatment_Outcome, MSI)


# CORRELATION BETWEEN MSI AND OTHER BIOMARKERS?
#------------------------------------------------
# Note: Use Spearman correlation as we can not assume a normal distribution in MSI.
temp <- biolung_df %>% select(Treatment_Outcome, MSI, TMB, PD.L1_Expression)

# MSI vs TMB
#-------------
cor.test(biolung_df$MSI, biolung_df$TMB, method = "spearman")

# MSI vs PD-L1 expression
#--------------------------
# View vector
biolung_df$PD.L1_Expression
# Convert "<1" to 0
biolung_df$PD.L1_Expression <- ifelse(biolung_df$PD.L1_Expression == "<1", 0, biolung_df$PD.L1_Expression)
# convert to numeric
biolung_df$PD.L1_Expression <- as.numeric(biolung_df$PD.L1_Expression)
# Calculate, exclude incomplete entries (NAs)
cor.test(biolung_df$MSI, biolung_df$PD.L1_Expression, method = "spearman", use = "complete.obs")



#=======================================================================
# PATIENT DEMOGRAPHY & TREATMENT OUTCOME
#=======================================================================

colnames(total_df)
# PATIENT AGE
#=============
res <- t.test(Diagnosis_Age ~ Treatment_Outcome, data = total_df)
res

# PATIENT SEX
#==============
# View Histology vs Treatment outcome in table format
table(total_df$Sex, total_df$Treatment_Outcome)

# Run Chi-Square test
chisq <- chisq.test(total_df$Sex, total_df$Treatment_Outcome)
chisq

# TUMOR HISTOLOGY
#==================
# View Histology vs Treatment outcome in table format
table(total_df$Histology, total_df$Treatment_Outcome)

# Run Chi-Square test
chisq <- chisq.test(total_df$Histology, total_df$Treatment_Outcome, simulate.p.value = TRUE)
chisq
  
# SMOKING HISTORY
#=================
# View Histology vs Treatment outcome in table format
table(total_df$Smoking_History, total_df$Treatment_Outcome)

# Run Chi-Square test
chisq <- chisq.test(total_df$Smoking_History, total_df$Treatment_Outcome)
chisq



#=======================================================================
# PD-L1 EXPRESSION
#=======================================================================

# PREPROCESS
temp_df <- total_df
# Investigate vector
class(temp_df$PD.L1_Expression)
# Change to character class
temp_df$PD.L1_Expression <- as.character(temp_df$PD.L1_Expression)
# Investigate vector
table(temp_df$PD.L1_Expression)
# Change to numeric
temp_df$PD.L1_Expression <- as.numeric(temp_df$PD.L1_Expression)

# Difference in PD-L1 Expression between responders & non-responders? 
wilcox.test(PD.L1_Expression ~ Treatment_Outcome, data = temp_df, exact = FALSE)

# Difference in PD-L1 Expression across cohorts of origin? 
# Kruskal-Wallis test by rank is a non-parametric alternative to one-way ANOVA test, 
# which extends the two-samples Wilcoxon test in the situation where there are more 4than 
# two groups.
kruskal.test(PD.L1_Expression ~ Study_ID, data = temp_df)

# Correlation between PD-L1 Expression and TMB? 
# Use Spearman test since can not assume a normal distribution for PD-L1
res2 <-cor.test(my_data$wt, my_data$mpg,  method = "spearman")




#=======================================================================
# GENES OF INTEREST
#=======================================================================

# Calculate again after excluding Jordan 2017
temp_df <- total_df %>% select(Treatment_Outcome, Study_ID, genes_of_interest) %>%
  filter(Study_ID != "Jordan_2017")

# Count responders & non-responders
table(temp_df$Treatment_Outcome)

# Define genes of interest
genes_of_interest <- c("PTEN", "POLD1", "STK11", "TP53", "POLE", "KEAP1", "MSH2", "EGFR", "KRAS")

temp_df <- total_df %>% select(Treatment_Outcome, genes_of_interest)

table(temp_df$Treatment_Outcome, temp_df$KRAS)


EGFR <- table(temp_df$Treatment_Outcome, temp_df$EGFR)
chisq.test(EGFR)$expected
chisq.test(EGFR)

STK11 <- table(temp_df$Treatment_Outcome, temp_df$STK11)
chisq.test(STK11)$expected
chisq.test(STK11)

KRAS <- table(temp_df$Treatment_Outcome, temp_df$KRAS)
chisq.test(KRAS)$expected
chisq.test(KRAS)

POLD1 <- table(temp_df$Treatment_Outcome, temp_df$POLD1)
chisq.test(POLD1)$expected
chisq.test(POLD1)

TP53 <- table(temp_df$Treatment_Outcome, temp_df$TP53)
chisq.test(TP53)$expected
chisq.test(TP53)

POLE <- table(temp_df$Treatment_Outcome, temp_df$POLE)
chisq.test(POLE)$expected
chisq.test(POLE)

KEAP1 <- table(temp_df$Treatment_Outcome, temp_df$KEAP1)
chisq.test(KEAP1)$expected
chisq.test(KEAP1)

MSH2 <- table(temp_df$Treatment_Outcome, temp_df$MSH2)
chisq.test(MSH2)$expected
chisq.test(MSH2)

PTEN <- table(temp_df$Treatment_Outcome, temp_df$PTEN)
chisq.test(PTEN)$expected
chisq.test(PTEN)




#=======================================================================
# ENGINEERED FEATURES
#=======================================================================

# PREPROCESS
#-------------------------------
# Features engineered dataset
temp_df <- read.delim("Features_engineered_control_included.tsv", stringsAsFactors = FALSE)
unique(temp_df$Study_ID)
# Remove control cohort before analysis
temp_df <- temp_df %>% filter(Study_ID != "Model_Control")
colnames(model_df)


# PAN 2020 SIGNATURE MUTATIONS
#-------------------------------

# Pan 2020 mutations (counts), Responders vs Non-responders
wilcox.test(Pan_2020_muts ~ Treatment_Outcome, data = temp_df)

# Pan 2020 compound mutations (binary), Responders vs Non-responders
comp <- table(temp_df$Pan_2020_compound_muts, temp_df$Treatment_Outcome)
chisq.test(comp)



# NDB GENES & DCB GENES
#-------------------------

table(temp_df$DCB_genes, temp_df$Treatment_Outcome)


table(model_df$NDB_genes, model_df$Treatment_Outcome)


res <- wilcox.test(NDB_genes ~ Treatment_Outcome, data = temp_df,
                   exact = FALSE)
res

res <- wilcox.test(DCB_genes ~ Treatment_Outcome, data = temp_df,
                   exact = FALSE)
res





#=======================================================================
# TMB
#=======================================================================

# Remove max TMB outlier
max(total_df$TMB)
total_df <- total_df %>% filter(TMB < 90)

# Log2-transform TMB
total_df$TMB_log2 <- log2(total_df$TMB)
# Filter -Inf values from TMB
total_df <- total_df %>% filter(!is.infinite(TMB_log2))

# LOG2-TRANSFORMED TMB
#=======================
# TMB, Responders vs. non-responders
# T-test of log2 transformed TMB
res <- t.test(TMB_log2 ~ Treatment_Outcome, data = total_df)
res
# Mann-Whitney
res <- wilcox.test(TMB ~ Treatment_Outcome, data = total_df)
res

# TMB, Two-way ANOVA, test TMB as function of cohort and sequencing type
two_way_anova <- aov(TMB_log2 ~ Study_ID + Sequencing_type, data = total_df)
summary(two_way_anova)


# NORMALIZED & LOG2-TRANSFORMED TMB
#=====================================
total_df <- total_df %>% group_by(Study_ID) %>% mutate(TMB_norm = TMB / mean(TMB))
total_df$TMB_norm_log2 <- log2(total_df$TMB_norm)

# TMB normalized, Responders vs non-responders
# Mann-Whitney
res <- wilcox.test(TMB_norm ~ Treatment_Outcome, data = total_df)
res

# TMB normalized, Two-way ANOVA, test TMB as function of cohort and sequencing type
two_way_anova <- aov(TMB_norm_log2 ~ Study_ID + Sequencing_type, data = total_df)
summary(two_way_anova)



# Divide by mean for each cohort

total_df <- total_df %>% group_by(Study_ID) %>% mutate(TMB_norm = TMB / mean(TMB))
total_df$TMB_log2_norm <- log2(total_df$TMB_norm)

boxp <- total_df %>% ggplot(aes(x = Study_ID, y = TMB_log2_norm)) + 
  geom_boxplot()
boxp



# Perform ANOVA
norm_two_way_anova <- aov(TMB_norm_log2 ~ Study_ID + Sequencing_type, data = total_df)
summary(norm_two_way_anova)

total_df <- total_df %>% filter(!is.infinite(TMB_norm_log2))

log2_norm_two_way_anova <- aov(TMB_log2_norm ~ Study_ID + Sequencing_type, data = total_df)
summary(log2_norm_two_way_anova)





