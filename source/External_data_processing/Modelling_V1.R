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

str(data)

## TROUBLESHOOTING:
# Log2 Transform TMB
data$TMB <- log2(data$TMB)
data <- data %>% rename(log2_TMB = TMB)


#========================================================================
# SPLIT DATA (INTO TRAINING DATA AND TEST DATA)
#========================================================================

# Split randomly (retaining proportion) using createDataPartition function
set.seed(100)
indexes <- createDataPartition(data$Durable_clinical_benefit, p = 0.7, list = FALSE)

data.train <- data[indexes,]
data.test <- data[-indexes,]

# Store X and Y for later use...
X = data.train %>% select(-Durable_clinical_benefit)
Y = data.train$Durable_clinical_benefit


#========================================================================
# CREATE DUMMY VARIABLES ("ONE-HOT ENCODING") FOR THE TRAINING SET
#========================================================================

# Create dummy variable "model" (excluding clinical outcome column)
dummies_model <- dummyVars(Durable_clinical_benefit ~ ., data = data.train)
# "Predict" dummy variables (excluding clinical outcome column)
dummy.train <- predict(dummies_model, newdata = data.train)
# Convert to dataframe
data.train <- data.frame(dummy.train)
str(data.train)


#========================================================================
# TRANSFORM DATA
#========================================================================

#TROUBLESHOOT:
TMB_col <- data.train$log2_TMB
data.train <- data.train %>% select(-log2_TMB)

# Preprocess data using range: Normaliz values so range is between 0 and 1.
preProcess_range_model <- preProcess(data.train, method = 'range')
data.train <- predict(preProcess_range_model, newdata = data.train)

#TROUBLESHOOT:
#Append TMB
data.train$log2_TMB <- TMB_col

# Append y-variable to data. 
data.train$Durable_clinical_benefit <- Y


#========================================================================
# MODEL TRAINING
#========================================================================

# Set training control
ctrl <- trainControl(method = 'cv', 
                     number = 10, 
                     savePredictions = 'final', 
                     classProbs = TRUE, 
                     summaryFunction = twoClassSummary)


# Train Random Forest
set.seed(100)
rf_model = train(Durable_clinical_benefit ~ ., 
                 data = data.train, 
                 method = "rf", 
                 tunelength = 10, 
                 trControl = ctrl)
rf_model

# Extreme Gradient Boosting Tree
set.seed(100)
xgbTree_model = train(Durable_clinical_benefit ~ ., 
                      data = data.train, 
                      method = 'xgbTree', 
                      tunelength = 10, 
                      trControl = ctrl)
xgbTree_model

# Support vector machine
set.seed(100)
svm_model = train(Durable_clinical_benefit ~ ., 
                  data = data.train, 
                  method = 'svmRadial', 
                  tunelength = 15, 
                  trControl = ctrl)
svm_model

# Compare models

compare_models <- resamples(list(RANDOM_FOREST=rf_model, 
                                 XGBTree=xgbTree_model, 
                                 SVM=svm_model))
summary(compare_models)



#========================================================================
# MODEL VALIDATION
#========================================================================

# Transform the test data using the same models:
  # 1. Separate DCB column from test data
  Y.test = data.test$Durable_clinical_benefit
  # 2. Create dummy variables
  dummy.test <- predict(dummies_model, data.test)
  data.test2 <- data.frame(dummy.test)
  # 3. Transform data
  data.test3 <- predict(preProcess_range_model, data.test2)
  # 4. Append DCB column to test data
  data.test3$Durable_clinical_benefit <- Y.test



