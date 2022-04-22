#HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
# The purpose of this script is to create ML models of the preprocessed and harmonized 
# data in the Biomarkers-Immuno-Lung project.
#
#HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
#
#
#
#============================================================================
# LOAD LIBRARIES & READ FILES
#============================================================================
library(ggplot2)
library(lattice)
library(caret)
library(dplyr)
library(doSNOW)


# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

data <- read.delim("merged_cBioPortal_clinical_mutation_data.tsv")

#===========================================================================
# PREPROCESSING
#===========================================================================

# Exclude features not to be included when making predictions
data <- data %>% select(-Sequencing_type, -Study_ID, -Patient_ID, -Sample_ID, -PFS_months, -Stage_at_diagnosis, -PD.L1_expression)

# Convert mutation data to type factor
gene_columns <- c('KEAP1_mut', 'KRAS_mut', 'ARID1A_mut', 'STK11_mut', 'TP53_mut', 'ARID1B_mut', 'EGFR_mut', 'PTEN_mut')
data[gene_columns] <- lapply(data[gene_columns], factor)

# Convert additional columns to factors
colz <- c('Durable_clinical_benefit', 'Histology', 'Smoking_history', 'Sex')
data[colz] <- lapply(data[colz], factor)

# Log2 Transform TMB
data$TMB <- log2(data$TMB)
data <- data %>% rename(log2_TMB = TMB)
# Remove Inf / -Inf entries (log2 of 0)
data$log2_TMB <- ifelse(is.infinite(data$log2_TMB), 0, data$log2_TMB)


#========================================================================
# REMOVE UNRELEVANT FEATURES
#========================================================================

# Remove near-0 variance features (if any)
numeric_cols = sapply(data, is.numeric)
variance = nearZeroVar(data[numeric_cols], saveMetrics = TRUE)
variance
# No observed near-0 variance numeric features. 

# Remove correlated numeric features (if any)
data_correlated = cor(data[numeric_cols])
findCorrelation(data_correlated)
# No observed correlated numeric variables. 


#========================================================================
# CREATE DUMMY VARIABLES (ONE-HOT ENCODING)
#========================================================================

# Store X and Y for later use...
X = data %>% select(-Durable_clinical_benefit)
Y = data$Durable_clinical_benefit


# Create dummy variable "model" (excluding 'clinical outcome column'Durable_clinical_outcome' response variable)
dummies_model <- dummyVars(Durable_clinical_benefit ~ ., data = data)
# "Predict" dummy variables (excluding clinical outcome column)
dummy_data <- predict(dummies_model, newdata = data)
# Convert to dataframe
data <- data.frame(dummy_data)
str(data)

# Normalize data, range between 0 and 1
process_data_model <- preProcess(data, method='range')
data <- predict(process_data_model, newdata = data)

# Append response variable column
data$Durable_clinical_benefit <- Y

str(data)

#========================================================================
# SPLIT DATA (INTO TRAINING DATA AND TEST DATA)
#========================================================================

# Split randomly (retaining proportion) using createDataPartition function
set.seed(100)
indexes <- createDataPartition(data$Durable_clinical_benefit, p = 0.8, list = FALSE)

data.train <- data[indexes,]
data.test <- data[-indexes,]



#========================================================================
# MODEL TRAINING
#========================================================================

# Define training control
set.seed(100)
ctrl <- trainControl(method = 'cv', 
                     number = 10, 
                     savePredictions = 'final', 
                     classProbs = TRUE, 
                     summaryFunction = twoClassSummary)


# Train Random Forest model
set.seed(100)
rf_model = train(Durable_clinical_benefit ~ ., 
                 data = data.train, 
                 method = "rf", 
                 tunelength = 10, 
                 trControl = ctrl)
rf_model

# Train Extreme Gradient Boosting Tree model
set.seed(100)
xgbTree_model = train(Durable_clinical_benefit ~ ., 
                      data = data.train, 
                      method = 'xgbTree', 
                      tunelength = 10, 
                      trControl = ctrl)
xgbTree_model

# Train Support Vector Machine model
set.seed(100)
svm_model = train(Durable_clinical_benefit ~ ., 
                  data = data.train, 
                  method = 'svmRadial', 
                  tunelength = 15, 
                  trControl = ctrl)
svm_model

# Adaboost
set.seed(100)
AdaB_model = train(Durable_clinical_benefit ~ ., 
                   data = data.train, 
                   method = 'adaboost', 
                   tunelength = 2, 
                   trControl = ctrl)
AdaB_model



#========================================================================
# MODEL VALIDATION
#========================================================================

# Compare models
compare_models <- resamples(list(RANDOM_FOREST=rf_model, 
                                 XGBTree=xgbTree_model, 
                                 SVM=svm_model, 
                                 AdaB=AdaB))
summary(compare_models)


# Plot the output from resamples
scales <- list(x = list(relation = "free"), y = list(relation = "free"))
bwplot(compare_models, scales = scales)


# Try to make predictions using the models on the test data, create confusion matrix for each model
# Random Forest: 
predictions_rf <- predict(rf_model, data.test)
rf_cm <- confusionMatrix(reference = data.test$Durable_clinical_benefit, 
                data = predictions_rf, 
                mode = 'everything', 
                positive = 'YES')
rf_cm

# xgbTree:
predictions_xgbTree <- predict(xgbTree_model, data.test)
xgbTree_cm <- confusionMatrix(reference = data.test$Durable_clinical_benefit, 
                              data = predictions_xgbTree, 
                              mode = 'everything', 
                              positive = 'YES')
xgbTree_cm

# Support Vector Machine:
predictions_svm <- predict(svm_model, data.test)
svm_cm <- confusionMatrix(reference = data.test$Durable_clinical_benefit, 
                          data = predictions_svm, 
                          mode = 'everything', 
                          positive = 'YES')
svm_cm

# AdaBoost: 
predictions_AdaB <- predict(AdaB_model, data.test)
AdaB_cm <- confusionMatrix(reference = data.test$Durable_clinical_benefit, 
                          data = predictions_AdaB, 
                          mode = 'everything', 
                          positive = 'YES')
AdaB_cm
