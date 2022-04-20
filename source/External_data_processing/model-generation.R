
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


#===================================================
# REMOVE UNRELEVANT FEATURES
#===================================================

# REMOVE NEAR-0 VARIANCE FEATURES (if any)
numeric_cols = sapply(data, is.numeric)
variance = nearZeroVar(data[numeric_cols], saveMetrics = TRUE)
variance
# No observed near-0 variance numeric features. 

# REMOVE CORRELATED NUMERIC VARIABLES
data_correlated = cor(data[numeric_cols])
findCorrelation(data_correlated)
# No observed correlated numeric variables. 



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
# IMPUTATION
#========================================================================

# Exclude PD-L1 expression for now, try imputing later...


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

# Not sure which transformations to use here. 
# Log2 transform TMB.
# Account for batch effect for: TMB & PD-L1 expression.

# Preprocess data using range: Normaliz values so range is between 0 and 1.
preProcess_range_model <- preProcess(data.train, method = 'range')
data.train <- predict(preProcess_range_model, newdata = data.train)

# Append y-variable to data. 
data.train$Durable_clinical_benefit <- Y


#========================================================================
# VISUALIZE IMPORTANCE OF VARIABLES
#========================================================================

data.train_excluding_y <- data.train %>% select(-Durable_clinical_benefit)

featurePlot(x = data.train_excluding_y, 
            y = data.train$Durable_clinical_benefit, 
            plot = "density", 
            strip = strip.custom(par.strip.text=list(cex=.7)), 
            scales = list(x = list(relation="free"), 
                          y = list(relation="free")))




#========================================================================
# FEATURE SELECTION RFE
#========================================================================

# Perform recursive feature elimination (RFE) on the data using the random forest function.
set.seed(100)

ctrl <- rfeControl(functions = rfFuncs, 
                   method = "repeatedcv", 
                   repeats = 5, 
                   number = 10)
# Set number of features for RFE
colnum <- ncol(data.train)
colnum <- colnum - 1

# Subset training data to exclude response variable (Durable clinical benefit)
rfe_train_data <- data.train %>% select(-Durable_clinical_benefit)

# Run RFE through repeated cross-validation using random forest algorithm. 
# Note: Can change the number of features to select by altering "sizes".
result_rfe = rfe(x = rfe_train_data, 
                 y = data.train$Durable_clinical_benefit, 
                 sizes = c(1:colnum), 
                 rfeControl = ctrl,
                 number = 10)
result_rfe
View(result_rfe)
# STK11 and TMB seems to be most important features. 


#========================================================================
# TRAINING MODEL
#========================================================================

# From data science dojo:

data.train <- data.train %>% select(Durable_clinical_benefit, TMB, STK11_mut.0, STK11_mut.1)

train.control <- trainControl(method = "repeatedcv", 
                              number = 10, 
                              repeats = 3, 
                              search = "grid")

tune.grid <- expand.grid(eta = c(0.05, 0.075, 0.1),
                         nrounds = c(50, 75, 100),
                         max_depth = 6:8,
                         min_child_weight = c(2.0, 2.25, 2.5),
                         colsample_bytree = c(0.3, 0.4, 0.5),
                         gamma = 0,
                         subsample = 1)
View(tune.grid)

cl <- makeCluster(4, type = "SOCK")

registerDoSNOW(cl)

xgbTree_model <- train(Durable_clinical_benefit ~ ., 
      data = data.train, 
      method = "xgbTree", 
      tuneGrid = tune.grid, 
      trControl = train.control)

stopCluster(cl)

xgbTree_model

confusionMatrix(xgbTree_model)


#--------------------------------------------------------




set.seed(100)
model_mars = train(Durable_clinical_benefit ~ ., data = data.train, 
                   method = 'earth')
fitted <- predict(model_mars)


model_mars
plot(model_mars, main="test")
