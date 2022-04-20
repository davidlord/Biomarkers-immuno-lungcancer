#============================================================================
# LOAD LIBRARIES & READ FILES
#============================================================================
library(ggplot2)
library(lattice)
library(caret)
library(dplyr)

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


#============================================================================
# FEATURE SELECTION
#============================================================================

# REMOVE NEAR-ZERO VARIANCE VARIABLES
#-------------------------------------
# Want to exclude variables for which variance is 0 or close to 0. 
# As these tend to add more noise than value to our model. 

# Identify numeric columns
numeric_cols = sapply(data, is.numeric)
# Compute whether or not numerical variables display near-zero variance
variance = nearZeroVar(data[numeric_cols], saveMetrics = TRUE)
variance


# IDENTIFY CORRELATED VARIABLES
#--------------------------------

data_correlated = cor(data[numeric_cols])
findCorrelation(data_correlated)
# Observe no correlated variables. 


#============================================================================
# DATA TRANSFORMATION
#============================================================================

# CREATE DUMMY VARIABLES
#------------------------

# drop2nd: If a factor has two levels, return a single binary vector.
pre_dummy = dummyVars(Durable_clinical_benefit ~ ., data = data, drop2nd = TRUE)
data_dummy = predict(pre_dummy, data)



# DATA SCALING
#---------------




# DIMENSIONALITY REDUCTION
#---------------------------





