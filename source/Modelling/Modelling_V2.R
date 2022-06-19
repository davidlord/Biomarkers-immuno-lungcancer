#============================================================================
# The purpose of this script is to create supervised classification models (using the Caret package) of the harmonized NSCLC-data. 
#============================================================================



#============================================================================
# LOAD LIBRARIES & READ FILES
#============================================================================
library(ggplot2)
library(lattice)
library(caret)
library(dplyr)
library(pROC)
library(tidymodels)
library(DiagrammeR)
library(rattle)
library(MLeval)


# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

# Read data
total_df <- read.delim("Features_engineered_control_included.tsv")



#========================================================================
# REMOVE IRRELEVANT FEATURES
#========================================================================

# Select relevant columns
  colnames(total_df)
  # Remove Pan 2020 gene-mutations
  signature_genes_cols <- colnames(total_df)[15:64]
  total_df <- total_df %>% select(-signature_genes_cols)
  
# Remove additional excess columns
  colnames(total_df)
  rm_cols <- c("Patient_ID", "Sequencing_type", "PFS_months", "Stage_at_diagnosis", "PD.L1_Expression", 
               "Immunotherapy", "MSI", "TMB", "TMB_norm")
  # Keep Study ID for now as this is used to normalize numeric values downstream
  total_df <- total_df %>% select(-rm_cols)
  colnames(total_df)
  
# To avoid downstream bug in the modelling step, remove special characters from response variable
  total_df$Treatment_Outcome[total_df$Treatment_Outcome == "Non-Responders"] <- "NonResponders"


  
#========================================================================
# IMPUTE MISSING VALUES 
#========================================================================

# Identify columns with NAs
colSums(is.na(total_df))

# Add placeholder for treatment type in Jordan 2017 cohort and Model Control set. 
table(total_df$Treatment_Type)
total_df$Treatment_Type <- ifelse(total_df$Study_ID == "Jordan_2017", "Unknown", total_df$Treatment_Type)
total_df$Treatment_Type <- ifelse(total_df$Study_ID == "Model_Control", "Not_immunotherapy", total_df$Treatment_Type)
table(total_df$Study_ID)

colSums(is.na(total_df))
# Since all remaining missing values are located in the BioLung cohort, 
# subset the BioLung cohort when assessing appropriate imputations
temp_df <- total_df %>% filter(Study_ID == "BioLung_2022")

# IMPUTE HISTOLOGY
table(temp_df$Histology)
total_df$Histology <- ifelse(is.na(total_df$Histology), "Lung Adenocarcinoma", total_df$Histology)

# IMPUTE PATIENT AGE
mean_age <- as.integer(mean(temp_df$Diagnosis_Age, na.rm = TRUE))
total_df$Diagnosis_Age <- ifelse(is.na(total_df$Diagnosis_Age), mean_age, total_df$Diagnosis_Age)

# IMPUTE PATIENT SMOKING HISTORY
table(temp_df$Smoking_History)
total_df$Smoking_History <- ifelse(is.na(total_df$Smoking_History), "Former", total_df$Smoking_History)

# IMPUTE PATIENT SEX
table(temp_df$Sex)
total_df$Sex <- ifelse(is.na(total_df$Sex), "Female", total_df$Sex)
sum(is.na(total_df))  



#========================================================================
# CONVERT DATA TYPES
#========================================================================
str(total_df)

# Convert binary mutations columns to factors
muts_cols <- c("POLE", "KEAP1", "KRAS", "POLD1", "STK11", "TP53", "MSH2", "EGFR", "PTEN", 
               "Pan_2020_compound_muts")
total_df[muts_cols] <- lapply(total_df[muts_cols], factor)

# Convert relevant columns to factors
str(total_df)
fac_cols <- c("Study_ID", "Sex", "Histology", "Smoking_History", "Treatment_Outcome", "Treatment_Type")
total_df[fac_cols] <- lapply(total_df[fac_cols], factor)



#========================================================================
# EXPORT MODEL-READY DATASET
#========================================================================
write.table(total_df, file = "model-ready_combinded_data.tsv", sep = "\t")



#========================================================================
# POTENTIALLY REMOVE CORRELATED- AND/OR FEATURES DISPLAYING NO VARIANCE
#========================================================================

# Potentially remove near-0 variance features
numeric_cols = sapply(total_df, is.numeric)
variance = nearZeroVar(total_df[numeric_cols], saveMetrics = TRUE)
variance
# No observed near-0 variance numeric features. 

# Potentially remove correlated numeric features (if any)
data_correlated = cor(total_df[numeric_cols])
findCorrelation(data_correlated)
# No observed correlated numeric variables. 

# Remove excess features (based on RFE output)
colnames(total_df)
rm_cols <- c("Diagnosis_Age", "Sex", "Histology", "Pan_2020_compound_muts", 
             "KEAP1", "POLD1", "POLE", "TP53", "MSH2")
total_df <- total_df %>% select(-rm_cols)


#========================================================================
# SPLIT CONTROL- & VALIDATION COHORTS
#========================================================================
unique(total_df$Study_ID)

# Control df
control_df <- total_df %>% filter(Study_ID == "Model_Control") %>% select(-Study_ID)

# Validation df (Jordan 2017 cohort)
validation_df <- total_df %>% filter(Study_ID == "Jordan_2017") %>% select(-Study_ID)

# Combined df
total_df <- total_df %>% filter(Study_ID != "Model_Control") %>% 
  filter(Study_ID != "Jordan_2017") %>% select(-Study_ID)



#========================================================================
# CREATE DUMMY VARIABLES (ONE-HOT ENCODING)
#========================================================================

# Store X and Y for later use...
X = total_df %>% select(-Treatment_Outcome)
Y = total_df$Treatment_Outcome

# Create dummy variable "model" (excluding response variable)
dummies_model <- dummyVars(Treatment_Outcome ~ ., data = total_df)
# "Predict" dummy variables (response variable)
dummies_data <- predict(dummies_model, newdata = total_df)
# Convert to dataframe
total_df <- data.frame(dummies_data)
str(total_df)



#========================================================================
# DATA TRANSFORMATION
#========================================================================

# Normalize data, range between 0 and 1
process_range_model <- preProcess(total_df, method='range')
total_df <- predict(process_range_model, newdata = total_df)

# Append response variable column
total_df$Treatment_Outcome <- Y
str(total_df)



#========================================================================
# RECURSIVE FEATURE ELIMINATION (RFE)
#========================================================================

set.seed(100)
# Run RFE using the Random Forest algorithm for a range of input features (1 - max)
ctrl <- rfeControl(functions = rfFuncs, method = "repeatedcv", repeats = 10)
rfeprofile <- rfe(x = total_df[, 1:(length(total_df) - 1)], y = total_df$Treatment_Outcome, 
                  sizes = c(1:length(total_df)), rfeControl = ctrl)
rfeprofile

# View top predictors
predictors(rfeprofile)


# EXCLUDE EXCESS FEATURES 
#==========================
# Exclude excess features
input_cols <- append(predictors(rfeprofile), "Treatment_Outcome")
total_df <- total_df %>% select(input_cols)



#========================================================================
# SPLIT TRAIN- & TEST SET
#========================================================================

# Split randomly (retaining proportion) using createDataPartition function
set.seed(100)
indexes <- createDataPartition(total_df$Treatment_Outcome, p = 0.8, list = FALSE)

train_set <- total_df[indexes,]
test_set <- total_df[-indexes,]



#========================================================================
# MODEL TRAINING
#========================================================================

# Define training control
set.seed(100)
ctrl <- trainControl(method = "repeatedcv", 
                     number = 10, 
                     repeats = 5,
                     search = "random",
                     savePredictions = 'final')
                     #classProbs = TRUE, 
                     #summaryFunction = twoClassSummary)


# (BOOSTED) LOGISTIC REGRESSION
#=================================
# Train model
set.seed(100)
bag_logreg_model = train(Treatment_Outcome ~ ., 
                 data = train_set, 
                 method = "LogitBoost", 
                 tunelength = 30, 
                 trControl = ctrl)
bag_logreg_model


# RANDOM FOREST
#====================
# Train model
set.seed(100)
rf_model = train(Treatment_Outcome ~ ., 
                 data = train_set, 
                 method = "rf", 
                 tunelength = 20, 
                 trControl = ctrl)
rf_model


# K NEAREST NEIGHBOURS
#=======================
# Train model
set.seed(100)
knn_model = train(Treatment_Outcome ~ ., 
                       data = train_set, 
                       method = "kknn", 
                       tunelength = 20, 
                       trControl = ctrl)
knn_model


# RECURSIVE PARTITIONING
#==========================
# Train model
set.seed(100)
rpart_model <- train(Treatment_Outcome ~ ., data = train_set, 
                    method = "rpart",
                    trControl = ctrl)
rpart_model



#========================================================================
# COMMPARE MODELS
#========================================================================

compare_models <- resamples(list("Logistic Regression" = bag_logreg_model,
                                 "K Nearest Neighbours" = knn_model,
                                 "Recursive Partitioning" = rpart_model,
                                 "Random Forest" = rf_model))
summary(compare_models)

# Plot comparisons
scales <- list(x = list(relation = "free"), y = list(relation = "free"))
bwplot(compare_models, scales = scales)



#========================================================================
# PLOT ROC CURVES 
#========================================================================

# Convert response variable entries to numeric
set.seed(100)
res <- evalm(list(rf_model, rpart_model, bag_logreg_model, knn_model),
             gnames=c('\nRandom Forest', '\nRecursive Partitioning', '\nLogistic Regression', '\nK Nearest Neighbours'))



#========================================================================
# PLOT DECISION TREE & FEATURE IMPORTANCE
#========================================================================

library(rpart.plot)
rpart.plot(rpart_model$finalModel, fallen.leaves = FALSE)

varimp_rf <- varImp(rf_model)
plot(varimp_rf, main="Variable Importance")

#========================================================================
# MODEL VALIDATION P1
# PREDICT TREATMENT OUTCOME ON TEST SET
#========================================================================

# Logistic regression: 
pred_logreg <- predict(bag_logreg_model, test_set)
cm_logreg <- confusionMatrix(reference = test_set$Treatment_Outcome, 
                         data = pred_logreg, 
                         mode = 'everything', 
                         positive = 'NonResponders')
cm_logreg

# K Nearest Neighbours:
pred_knn <- predict(knn_model, test_set)
cm_knn <- confusionMatrix(reference = test_set$Treatment_Outcome, 
                             data = pred_knn, 
                             mode = 'everything', 
                             positive = 'NonResponders')
cm_knn

# Recursive Partitioning:
pred_rpart <- predict(rpart_model, test_set)
cm_rpart <- confusionMatrix(reference = test_set$Treatment_Outcome, 
                         data = pred_rpart, 
                         mode = 'everything', 
                         positive = 'NonResponders')
cm_rpart

# Random Forest: 
pred_rf <- predict(rf_model, test_set)
cm_rf <- confusionMatrix(reference = test_set$Treatment_Outcome, 
                         data = pred_rf, 
                         mode = 'everything', 
                         positive = 'NonResponders')
cm_rf



#========================================================================
# MODEL VALIDATION P2
# EVALUATE MODEL PERFORMANCE ON VALIDATION- & CONTROL COHORTS
#========================================================================

# SEPARATE RESPONSE VARIABLE
#==============================
Xcontrol <- control_df %>% select(-Treatment_Outcome)
Ycontrol <- control_df$Treatment_Outcome

Xvalidation <- validation_df %>% select(-Treatment_Outcome)
Yvalidation <- validation_df$Treatment_Outcome

# CREATE DUMMY VARIABLES
#========================
dummies_control <- predict(dummies_model, newdata = control_df)
dummies_validation <- predict(dummies_model, newdata = validation_df)

control_df <- data.frame(dummies_control)
validation_df <- data.frame(dummies_validation)

# NORMALIZE NUMERIC VALUES
#===========================
control_df <- predict(process_range_model, newdata = control_df)
validation_df <- predict(process_range_model, newdata = validation_df)

# APPEND RESPONSE VARIABLE
#===========================
control_df$Treatment_Outcome <- Ycontrol
validation_df$Treatment_Outcome <- Yvalidation
str(control_df)
str(validation_df)


# MAKE PREDICTIONS ON VALIDATION SET
#======================================

# Logistic regression: 
pred_logreg <- predict(bag_logreg_model, validation_df)
cm_logreg <- confusionMatrix(reference = validation_df$Treatment_Outcome, 
                             data = pred_logreg, 
                             mode = 'everything', 
                             positive = 'NonResponders')
cm_logreg

# K Nearest Neighbours:
pred_knn <- predict(knn_model, validation_df)
cm_knn <- confusionMatrix(reference = validation_df$Treatment_Outcome, 
                          data = pred_knn, 
                          mode = 'everything', 
                          positive = 'NonResponders')
cm_knn

# Recursive Partitioning:
pred_rpart <- predict(rpart_model, validation_df)
cm_rpart <- confusionMatrix(reference = validation_df$Treatment_Outcome, 
                            data = pred_rpart, 
                            mode = 'everything', 
                            positive = 'NonResponders')
cm_rpart

# Random Forest: 
pred_rf <- predict(rf_model, validation_df)
cm_rf <- confusionMatrix(reference = validation_df$Treatment_Outcome, 
                         data = pred_rf, 
                         mode = 'everything', 
                         positive = 'NonResponders')
cm_rf




# MAKE PREDICTIONS ON CONTROL SET
#=====================================

# Logistic regression: 
pred_logreg <- predict(bag_logreg_model, control_df)
cm_logreg <- confusionMatrix(reference = control_df$Treatment_Outcome, 
                             data = pred_logreg, 
                             mode = 'everything', 
                             positive = 'NonResponders')
cm_logreg

# K Nearest Neighbours:
pred_knn <- predict(knn_model, control_df)
cm_knn <- confusionMatrix(reference = control_df$Treatment_Outcome, 
                          data = pred_knn, 
                          mode = 'everything', 
                          positive = 'NonResponders')
cm_knn

# Recursive Partitioning:
pred_rpart <- predict(rpart_model, control_df)
cm_rpart <- confusionMatrix(reference = control_df$Treatment_Outcome, 
                            data = pred_rpart, 
                            mode = 'everything', 
                            positive = 'NonResponders')
cm_rpart

# Random Forest: 
pred_rf <- predict(rf_model, control_df)
cm_rf <- confusionMatrix(reference = control_df$Treatment_Outcome, 
                         data = pred_rf, 
                         mode = 'everything', 
                         positive = 'NonResponders')
cm_rf
















