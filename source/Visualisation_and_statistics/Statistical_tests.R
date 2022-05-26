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
total_df <- read.delim("combined_data.tsv", stringsAsFactors = TRUE)


#=======================================================================
# MSI STATISTICAL ANALYSES
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
res <- t.test(Diagnosis_Age ~ Treatment_Outcome, data = total_df)
res

# PATIENT SEX



res <- t.test(Diagnosis_Age ~ Treatment_Outcome, data = total_df)
res




#=======================================================================
# GENES OF INTEREST
#=======================================================================

# Define genes of interest
genes_of_interest <- c("PTEN", "POLD1", "STK11", "TP53", "POLE", "KEAP1", "MSH2", "EGFR", "KRAS")

for (gene in genes_of_interest) {
  print(gene)
  print("Responders: ")
  print(sum(biolung_df[gene]))
  print("Nonresponders: ")
  print(nrow(biolung_df) - sum(biolung_df[gene]))
  # value in list as gene name.
}
# https://statsandr.com/blog/fisher-s-exact-test-in-r-independence-test-for-a-small-sample/





#=======================================================================
# PD-L1 EXPRESSION RESPONDERS VS NON-RESPONDERS BIOLUNG COHORT
#=======================================================================





#=======================================================================
# SIGNIFICANT DIFFERENCE IN TMB BETWEEN COHORTS AND/OR WES/GENE PANELS
#=======================================================================

# Remove TMB outlier:
total_df <- total_df %>% filter(TMB < 90)

# Two-way ANOVA, test TMB as function of cohort and sequencing type
two_way_anova <- aov(TMB ~ Study_ID + Sequencing_type, data = total_df)
summary(two_way_anova)
# Sequencing type p-value = 0.68
# Study_ID p-value = 0.0056
# Will need to normalize TMB by study ID, not by sequencing type. 

# Add column for log2 transformed TMB values
# Filter potentially infinite values
total_df$TMB_log2 <- log2(total_df$TMB)
total_df <- total_df %>% filter(!is.infinite(TMB_log2))
# Perform ANOVA
log2_two_way_anova <- aov(TMB_log2 ~ Study_ID + Sequencing_type, data = total_df)
summary(log2_two_way_anova)


#=======================================================================
# NORMALIZE TMB ACROSS COHORTS
#=======================================================================

# Divide TMB by mean for each 


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


#=======================================================================
# DO MANUALLY...
#=======================================================================


table(total_df$Study_ID)


length(test_df$Study_ID)
test_df <- total_df %>% filter(!is.na(TMB)) %>% mutate(TMB_normalized = )

grouped_df <- total_df %>% group_by(Study_ID)



