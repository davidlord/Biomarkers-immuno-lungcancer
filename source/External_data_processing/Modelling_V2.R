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
# Preprocessing
#===========================================================================

# Exclude features not to be included when making predictions
data <- data %>% select(-Sequencing_type, -Study_ID, -Patient_ID, -Sample_ID, -PFS_months, -Stage_at_diagnosis, -PD.L1_expression)

# Convert mutation data to type factor
gene_columns <- c('KEAP1_mut', 'KRAS_mut', 'ARID1A_mut', 'STK11_mut', 'TP53_mut', 'ARID1B_mut', 'EGFR_mut', 'PTEN_mut')
data[gene_columns] <- lapply(data[gene_columns], factor)

# Convert additional columns to factors
colz <- c('Durable_clinical_benefit', 'Histology', 'Smoking_history', 'Sex')
data[colz] <- lapply(data[colz], factor)

str(data)


#========================================================================
# CREATE DUMMY VARIABLES ("ONE-HOT ENCODING")
#========================================================================

# Store X and Y for later use...
X = data %>% select(-Durable_clinical_benefit)
Y = data$Durable_clinical_benefit


# Create dummy variable "model" (excluding clinical outcome column)
dummies_model <- dummyVars(Durable_clinical_benefit ~ ., data = data)
# "Predict" dummy variables (excluding clinical outcome column)
dummy_data <- predict(dummies_model, newdata = data)
# Convert to dataframe
data <- data.frame(dummy_data)
str(data)

# Append response variable column
data$Durable_clinical_benefit <- Y


#========================================================================
# SPLIT DATA (INTO TRAINING DATA AND TEST DATA)
#========================================================================

# Split randomly (retaining proportion) using createDataPartition function
set.seed(100)
indexes <- createDataPartition(data$Durable_clinical_benefit, p = 0.7, list = FALSE)

data.train <- data[indexes,]
data.test <- data[-indexes,]


#========================================================================
# TRAINING MODEL
#========================================================================
  
set.seed(100)

# Define training control
ctrl <- trainControl(method = 'cv', 
                     number = 10, 
                     savePredictions = 'final', 
                     classProbs = TRUE, 
                     summaryFunction = twoClassSummary)

# Random Forest
set.seed(100)
rf_model = train(Durable_clinical_benefit ~ ., 
                 data = data.train, 
                 method = "rf", 
                 tunelength = 5, 
                 trControl = ctrl)
rf_model

# xgBoost Dart
set.seed(100)
xgbTree_model = train(Durable_clinical_benefit ~ ., 
                      data = data.train, 
                      method = 'xgbTree', 
                      tunelength = 5, 
                      trControl = ctrl)
xgbTree_model

# Support vector machine
set.seed(100)
SVM_model = train(Durable_clinical_benefit ~ ., 
                  data = data.train, 
                  method = 'svmRadial', 
                  tunelength = 15, 
                  trControl = ctrl)
SVM_model


# Compare models

compare_models <- resamples(list(RANDOM_FOREST=rf_model, 
                                 XGBTree=xgbTree_model, 
                                 SVM=SVM_model))
summary(compare_models)

# Plot the output from resamples
scales <- list(x = list(relation = "free"), y = list(relation = "free"))
bwplot(compare_models, scales = scales)


# Try on test data
predictions_rf <- predict(rf_model, data.test)
rf_cm <- confusionMatrix(reference = data.test$Durable_clinical_benefit, 
                data = predictions_rf, 
                mode = 'everything', 
                positive = 'YES')
rf_cm

predictions_xgbTree <- predict(xgbTree_model, data.test)
xgbTree_cm <- confusionMatrix(reference = data.test$Durable_clinical_benefit, 
                              data = predictions_xgbTree, 
                              mode = 'everything', 
                              positive = 'YES')
xgbTree_cm


predictions_svm <- predict(SVM_model, data.test)
SVM_cm <- confusionMatrix(reference = data.test$Durable_clinical_benefit, 
                          data = predictions_svm, 
                          mode = 'everything', 
                          positive = 'YES')
SVM_cm

y <- sum(data.train$Durable_clinical_benefit == 'YES')
100 / 254
x <- sum(data.train$Durable_clinical_benefit == 'YES')