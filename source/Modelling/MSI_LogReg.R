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
library(pROC)
library(rpart)

# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

data <- read.delim("combined_data.tsv")


# Subset df
msi_df <- data %>% filter(Study_ID == 'BioLung_2022') %>% select(Treatment_Outcome, MSI)


#===========================================================================
# LOGISTIC REGRESSION
#===========================================================================

# PLOT RAWDATA
#--------------
msi_point <- msi_df %>% ggplot(aes(x = MSI, y = Treatment_Outcome)) + 
  geom_point()
msi_point


# PREPROCESS DATA
#--------------------
# Replace Treatment outcome column with numeric values
# Responder = 1, Non-responder = 0
msi_df <- msi_df %>% mutate(Treatment_Outcome = ifelse(Treatment_Outcome == "Responder", 1, 0))

model <- glm(Treatment_Outcome ~., data = msi_df, family = binomial)
summary(model)

# Sort data based on MSI
msi_df <- msi_df[order(msi_df$MSI),]

# Use glm function to fit a logistic regression curve to the data
glm_fit = glm(Treatment_Outcome ~ MSI, family = binomial, data = msi_df)
plot(x=msi_df$MSI, y=msi_df$Treatment_Outcome)
lines(msi_df$MSI, glm_fit$fitted.values)

msi_df %>% ggplot(aes(x = MSI, y = Treatment_Outcome)) + 
  geom_point()



# Draw ROC curve using known classifications and estimated probabilities
# Pass known classifications as first argument, then estimated probabilities, then 
roc(msi_df$Treatment_Outcome, glm_fit$fitted.values, plot=TRUE)
roc

# Remove padding from graph using par function:
par(pty = "s")
roc(msi_df$Treatment_Outcome, glm_fit$fitted.values, plot=TRUE)

# Convert x-axis to 1 - specificity
roc(msi_df$Treatment_Outcome, glm_fit$fitted.values, plot=TRUE, legacy.axes = TRUE)

# Alter axes further, change to percentages
roc(msi_df$Treatment_Outcome, glm_fit$fitted.values, plot=TRUE, legacy.axes = TRUE, 
    percent=TRUE, xlab = "False Positive Percentage", ylab = "True Positive Percentage")

# Change color of ROC curve
test <- roc(msi_df$Treatment_Outcome, glm_fit$fitted.values, plot=TRUE, legacy.axes = TRUE, 
    percent=TRUE, xlab = "False Positive Percentage", ylab = "True Positive Percentage", 
    col="#377eb8", lwd=4)


# Acces thresholds: 
roc_info <- roc(msi_df$Treatment_Outcome, glm_fit$fitted.values, plot=TRUE, legacy.axes = TRUE)

roc_info <- data.frame(
  tpp=roc_info$sensitivities*100,
  fpp=(1 - roc_info$specificities)*100,
  thresholds=roc_info$thresholds
)
# Isolate the peak we want to investigate
roc_info[roc_info$tpp > 50 & roc_info$tpp < 70,]

# How to find value? 







