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
library(pROC)


# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

# Read data
total_df <- read.delim("Features_engineered_control_included.tsv")

### DEV: REMOVE TMB MAX OUTLIER


#========================================================================
# REMOVE IRRELEVANT FEATURES
#========================================================================

# Select relevant columns
  colnames(total_df)
  # Remove Pan 2020 gene-mutations
  pan_2020_genes_cols <- colnames(total_df)[14:63]
  total_df <- total_df %>% select(-pan_2020_genes_cols)
  
# Remove additional excess columns
  colnames(total_df)
  rm_cols <- c("Patient_ID", "Sequencing_type", "PFS_months", "Stage_at_diagnosis", "PD.L1_Expression", 
               "Immunotherapy", "MSI")
  # Keep Study ID for now as this is used to normalize numeric values downstream
  ### DEV: Determine which TMB to keep...
  total_df <- total_df %>% select(-rm_cols)
  colnames(total_df)

# To avoid downstream bug in the modelling step, remove special characters from response variable
  total_df$Treatment_Outcome[total_df$Treatment_Outcome == "Non-Responder"] <- "NonResponder"

  
#========================================================================
# IMPUTE MISSING VALUES & CONVERT DATA TYPES
#========================================================================

# Since all missing values are located in the BioLung cohort, 
# subset the BioLung cohort when assessing appropriate imputations
temp_df <- total_df %>% filter(Study_ID == "BioLung_2022")

# Identify columns with NAs
colSums(is.na(total_df))
  
# Impute histology with mode
table(temp_df$Histology)
total_df$Histology <- ifelse(is.na(total_df$Histology), "Lung Adenocarcinoma", total_df$Histology)

# Impute patient diagnosis age with mean
mean_age <- as.integer(mean(temp_df$Diagnosis_Age, na.rm = TRUE))
total_df$Diagnosis_Age <- ifelse(is.na(total_df$Diagnosis_Age), mean_age, total_df$Diagnosis_Age)

# Impute patient smoking history with mode
table(temp_df$Smoking_History)
total_df$Smoking_History <- ifelse(is.na(total_df$Smoking_History), "Former", total_df$Smoking_History)

# Impute patient sex with mode
### DEV: Use random sampling imputation
table(temp_df$Sex)
total_df$Sex <- ifelse(is.na(total_df$Sex), "Female", total_df$Sex)
sum(is.na(total_df))  


# CONVERT DATA TYPES
#--------------------
str(total_df)

# Convert binary mutations columns to factors
muts_cols <- c("POLE", "KEAP1", "KRAS", "POLD1", "STK11", "TP53", "MSH2", "EGFR", "PTEN", 
               "Pan_2020_compound_muts")
total_df[muts_cols] <- lapply(total_df[muts_cols], factor)

# Convert relevant columns to factors
str(total_df)
fac_cols <- c("Study_ID", "Sex", "Histology", "Smoking_History", "Treatment_Outcome")
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


#========================================================================
# EXCLUDE EXCESS FEATURES - BASED ON RESULTS FROM DOWNSTREAM RFE
#========================================================================

# Exclude excess features
colnames(total_df)
unselect_cols <- c("Histology", "Sex", "Pan_2020_compound_muts", "TMB_norm", "TMB")
total_df <- total_df %>% select(-unselect_cols)

# Exclude excess mutations columns
colnames(total_df)
unselect_cols <- c("POLE", "KEAP1", "TP53", "MSH2", "EGFR", "PTEN", "DCB_genes")
total_df <- total_df %>% select(-unselect_cols)

#========================================================================
# SPLIT CONTROL- & VALIDATION COHORTS
#========================================================================

unique(total_df$Study_ID)

# Control df
control_df <- total_df %>% filter(Study_ID == "Model_Control") %>% select(-Study_ID)

# Validation df
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

### DEV: Add TMB normalization and log2 transformation here... 

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
                  sizes = c(1:20), rfeControl = ctrl)
rfeprofile
predictors(rfeprofile)


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
ctrl <- trainControl(method = 'cv', 
                     number = 10, 
                     savePredictions = 'final', 
                     classProbs = TRUE, 
                     summaryFunction = twoClassSummary)



# TEST CONTROL
set.seed(100)
ctrl <- trainControl(method = "repeatedcv", number = 10, repeats = 3, search = "random")



# (BOOSTED) LOGISTIC REGRESSION
#---------------------------------

# Train model
set.seed(100)
bag_logreg_model = train(Treatment_Outcome ~ ., 
                 data = train_set, 
                 method = "LogitBoost", 
                 tunelength = 20, 
                 trControl = ctrl)
bag_logreg_model


# RANDOM FOREST
#----------------------
# Note: Decision trees

# Train model
set.seed(100)
rf_model = train(Treatment_Outcome ~ ., 
                 data = train_set, 
                 method = "rf", 
                 tunelength = 10, 
                 trControl = ctrl)
rf_model


# BAGGED MARS 
#----------------
# Note: Multivariate adaptive regression splines, non-linear regression. 

# Train model
set.seed(100)
bag_mars_model = train(Treatment_Outcome ~ ., 
                 data = train_set, 
                 method = "bagEarth", 
                 tunelength = 10, 
                 trControl = ctrl)
bag_mars_model


# EXTREME GRADIENT BOOSTING BAG DECISION TREE
#-----------------------------------------------

# Train model
set.seed(100)
xgbtree_model = train(Treatment_Outcome ~ ., 
                       data = train_set, 
                       method = "xgbTree", 
                       tunelength = 10, 
                       trControl = ctrl)
xgbtree_model


#========================================================================
# COMMPARE MODELS
#========================================================================

compare_models <- resamples(list("Logistic Regression" = bag_logreg_model, 
                                 "Random Forest" = rf_model, 
                                 "Extreme Gradient Boosting" = xgbtree_model))
summary(compare_models)

# Plot comparisons
scales <- list(x = list(relation = "free"), y = list(relation = "free"))
bwplot(compare_models, scales = scales)

help(bwplot)


#========================================================================
# MODEL VALIDATION
#========================================================================

# Use models to make predictions on test data

# Logistic regression: 
pred_logreg <- predict(bag_logreg_model, test_set)
cm_logreg <- confusionMatrix(reference = test_set$Treatment_Outcome, 
                         data = pred_logreg, 
                         mode = 'everything', 
                         positive = 'Responder')
cm_logreg

# Random Forest: 
pred_rf <- predict(rf_model, test_set)
cm_rf <- confusionMatrix(reference = test_set$Treatment_Outcome, 
                         data = pred_rf, 
                         mode = 'everything', 
                         positive = 'Responder')
cm_rf

# Extreme Gradient Boosting
pred_xgbtree <- predict(xgbtree_model, test_set)
cm_xgbtree <- confusionMatrix(reference = test_set$Treatment_Outcome, 
                         data = pred_xgbtree, 
                         mode = 'everything', 
                         positive = 'Responder')
cm_xgbtree




#========================================================================
# PLOT ROC CURVES
#========================================================================

# Convert response variable entries to numeric

pred_xgbtree <- ifelse(pred_xgbtree == "Responder", 1, 0)
pred_rf <- ifelse(pred_rf == "Responder", 1, 0)

roc(test_set$Treatment_Outcome, pred_xgbtree, plot = TRUE)
plot.roc(test_set$Treatment_Outcome, pred_rf)




