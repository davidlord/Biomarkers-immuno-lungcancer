#============================================================================
#
# The purpose of this script is to generate supervised machine learning models (using the Caret package) 
# of the preprocessed and harmonized data deriving from the Biomarkers-Immuno-Lung project.
#
#============================================================================
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

# Read combined dataset
combined_df <- read.delim("combined_data.tsv")
# Read control df
control_df <- read.delim("control_data.tsv")

# Merge to single cohort
control_df$Study_ID <- "Control_cohort"
total_df <- rbind(combined_df, control_df)

#===========================================================================
# FEATURE ENGINEERING
#===========================================================================

# SUM PAN 2020 MUTATIONS IN NEW COLUMN
#---------------------------------------
  # Create a vector of all mutations column names
  colnames(total_df)
  mutations_cols <- colnames(total_df)[13:71]
  # Define genes of interest
  genes_of_interest <- c("EGFR", "PTEN", "MSH2", "TP53", "STK11", "POLD1", "KRAS", "KEAP1", "POLE")
  # Define Pan et al 2020 genes
  pan_2020_genes <- mutations_cols[! mutations_cols %in% c("EGFR", "PTEN", "TP53", "STK11", "POLD1", "KRAS", "KEAP1")]
  # Sum Pan 2020 gene-mutations
  temp <- total_df %>% select(pan_2020_genes) %>% mutate(Pan_2020_muts = rowSums(.))
  total_df$Pan_2020_muts <- temp$Pan_2020_muts
  
  ####
  #### DEV: Add additional column containing binary data whether or not Pan_2020_muts >= 2
  ####
  

# COMBINE SPECIFIC GENE-MUTATIONS TO SINGLE SCORES
#---------------------------------------------------
### Enriched in non-responders: EGFR, STK11
### Enriched in responders: PTEN, KRAS, POLE, POLD1, MSH2

# Define vectors for durable clinical benefit (DCB) & no durable benefit (NDB) associated genes
  NDB_genes <- c("EGFR", "STK11")
  DCB_genes <- c("PTEN", "KRAS", "POLE", "POLD1", "MSH2")

# Combine sums to columns
  temp <- total_df %>% select(DCB_genes) %>% mutate(DCB_genes = rowSums(.))
  total_df$DCB_genes <- temp$DCB_genes
  temp <- total_df %>% select(NDB_genes) %>% mutate(NDB_genes = rowSums(.))
  total_df$NDB_genes <- temp$NDB_genes


#===========================================================================
# PREPROCESSING
#===========================================================================

# Convert columns to factors
colz <- c('Durable_clinical_benefit', 'Histology', 'Smoking_history', 'Sex')
data[colz] <- lapply(data[colz], factor)


# Normalize TMB across cohorts 


# Log2 transform TMB

# Filter infinite values from TMB_norm_log2

# Log2 Transform TMB
data$TMB <- log2(data$TMB)
data <- data %>% rename(log2_TMB = TMB)
# Remove Inf / -Inf entries (log2 of 0)
data$log2_TMB <- ifelse(is.infinite(data$log2_TMB), 0, data$log2_TMB)




# Exclude features
# Exclude features not to be included when making predictions
str(total_df)
total_df <- total_df %>% select(-Sequencing_type, -Study_ID, -Patient_ID, -PFS_months, -Stage_at_diagnosis, -MSI_MSISensorPro)
# Exclude mutations columns
gene_cols <- colnames(total_df[8:66])
temp <- total_df %>% select(-gene_cols)



### Convert columns to factors
# Convert mutation data to type factor
gene_columns <- c('KEAP1_mut', 'KRAS_mut', 'ARID1A_mut', 'STK11_mut', 'TP53_mut', 'ARID1B_mut', 'EGFR_mut', 'PTEN_mut')
data[gene_columns] <- lapply(data[gene_columns], factor)




#========================================================================
# POTENTIALLY REMOVE UNRELEVANT (NO VARIANCE) NUMERIC FEATURES
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
