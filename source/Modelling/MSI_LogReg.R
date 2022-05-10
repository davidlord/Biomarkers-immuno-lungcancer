#============================================================================
# The purpose of this script is to create ML models of the preprocessed and harmonized 
# data in the Biomarkers-Immuno-Lung project.
#
#============================================================================



#============================================================================
# LOAD LIBRARIES & READ FILES
#============================================================================
library(ggplot2)
library(lattice)
library(tidyverse)
library(caret)
library(dplyr)
library(doSNOW)


# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

data <- read.delim("total_df.tsv")

#===========================================================================
# SUBSET DATA
#===========================================================================

msi_df <- data %>% filter(Study_ID == 'BioLung_2022') %>% select(Durable_clinical_benefit, MSI_MSISensorPro)


#===========================================================================
# PLOT RAWDATA
#===========================================================================

# MSI hisogram:
msi_hist <- msi_df %>% ggplot(aes(x = MSI_MSISensorPro)) +
  geom_histogram(binwidth = 1)
msi_hist

# MSI histogram log2-transformed
msi_hist + scale_x_continuous(trans = "log2")

msi_point <- msi_df %>% ggplot(aes(x = MSI_MSISensorPro, y = Durable_clinical_benefit)) + 
  geom_point()
msi_point



#===========================================================================
# TRIAL 2
#===========================================================================
library(pROC)
### NOTE: Sort data based on MSI before plot lines. 
# SUBSET DATA

msi_df <- data %>% filter(Study_ID == 'BioLung_2022') %>% select(Durable_clinical_benefit, MSI_MSISensorPro)

# Convert Durable clinical benefit column from chr to binary values
msi_df <- msi_df %>% mutate(Durable_clinical_benefit = ifelse(Durable_clinical_benefit == "YES", 1, 0))

# Sort data based on MSI
msi_df <- msi_df[order(msi_df$MSI_MSISensorPro),]

# Use glm function to fit a logistic regression curve to the data
glm_fit = glm(Durable_clinical_benefit ~ MSI_MSISensorPro, family = binomial, data = msi_df)

plot(x=msi_df$MSI_MSISensorPro, y=msi_df$Durable_clinical_benefit)

lines(msi_df$MSI_MSISensorPro, glm_fit$fitted.values)


# Draw ROC curve using known classifications and estimated probabilities
# Pass known classifications as first argument, then estimated probabilities, then 
roc(msi_df$Durable_clinical_benefit, glm_fit$fitted.values, plot=TRUE)
roc

# Remove padding from graph using par function:
par(pty = "s")
roc(msi_df$Durable_clinical_benefit, glm_fit$fitted.values, plot=TRUE)

# Convert x-axis to 1 - specificity
roc(msi_df$Durable_clinical_benefit, glm_fit$fitted.values, plot=TRUE, legacy.axes = TRUE)

# Alter axes further, change to percentages
roc(msi_df$Durable_clinical_benefit, glm_fit$fitted.values, plot=TRUE, legacy.axes = TRUE, 
    percent=TRUE, xlab = "False Positive Percentage", ylab = "True Positive Percentage")

# Change color of ROC curve
test <- roc(msi_df$Durable_clinical_benefit, glm_fit$fitted.values, plot=TRUE, legacy.axes = TRUE, 
    percent=TRUE, xlab = "False Positive Percentage", ylab = "True Positive Percentage", 
    col="#377eb8", lwd=4)


# Acces thresholds: 
roc_info <- roc(msi_df$Durable_clinical_benefit, glm_fit$fitted.values, plot=TRUE, legacy.axes = TRUE)

roc_info <- data.frame(
  tpp=roc_info$sensitivities*100,
  fpp=(1 - roc_info$specificities)*100,
  thresholds=roc_info$thresholds
)
# Isolate the peak we want to investigate
roc_info[roc_info$tpp > 50 & roc_info$tpp < 70,]

# How to find value? 


# Find optimal threshold

msi_df_2 <- msi_df %>% mutate(Group = ifelse(MSI_MSISensorPro > 10, 1, 2))




