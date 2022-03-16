library(ggplot2)
library(dplyr)
library(tidyverse)


# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)
# Read clinical data tsv file:
  clinical_df <- read.delim("cbioportal_clinical_data.tsv")

# Read tsv as data frame:
  clinical_df <- as.data.frame(clinical_df)


# Calculate summary statistics
  # TMB:
    # TMB for each cohort:
    clinical_df %>% group_by(Study_ID) %>% summarize(
      average_TMB = mean(TMB), standard_deviation_TMB = sd(TMB)
    )
    # TMB for entire dataset: 
      clinical_df %>% summarize(average_TMB = mean(TMB), standard_deviation_TMB = sd(TMB))

  # Age:
      # Age for each cohort:
      clinical_df %>% group_by(Study_ID) %>% summarize(
        average_age = mean(Diagnosis_age), standard_deviation_age = sd(Diagnosis_age)
      )
      # Age for entire set:
      clinical_df %>% summarize(average_age = mean(Diagnosis_age), standard_deviation_age = sd(Diagnosis_age))
  
  # Durable clinical benefit: 
      # Fraction durable clinical benefit for each cohort:
      clinical_df %>% group_by(Study_ID) %>% summarize(
        fraction_DCB = (sum(Durable_clinical_benefit == 'YES') / length(Durable_clinical_benefit)),
        fraction_NDB = 1 - fraction_DCB
      )
      # Fraction durable clinical benefit for entire dataset: 
      clinical_df %>% summarize(
        fraction_DCB = (sum(Durable_clinical_benefit == 'YES') / length(Durable_clinical_benefit)),
        fraction_NDB = 1 - fraction_DCB
      )
  # Progression free survival:
      clinical_df %>% 
      
      
# Calculate some summary statistics, for each study and for all: 
  clinical_df %>% summarize(
  # Calculate sex ratio:
  
  # Calculate mean and sd Progression free survival: 
  
  # Smoking history distribution: 
  





# Histogram TMB
TMB_hist <- clinical_df %>% ggplot(aes(x = TMB)) +
  geom_histogram(binwidth = 1, fill = "mediumpurple2", col = "mediumpurple4") +
  labs(x = "Tumor Mutation Burden (Log2 scale)", y = "Count (Log2 scale") +
  scale_x_continuous(trans = "log2") +
  scale_y_continuous(trans = "log2")
TMB_hist


# Boxplot comparison, TMB in responders vs non-responders all samples:
clinical_df %>% ggplot(aes(x = Study_ID, y = TMB, fill = Durable_clinical_benefit)) +
  geom_boxplot() +
  scale_y_continuous(trans = "log2") +
  scale_fill_brewer(palette = "Accent", direction = -1) +
  labs(fill = "Durable Clinical Benefit", y = "Tumor Mutation Burden (Log2 scale)", x = "Cohort") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Boxplot comparison, TMB across sequencing methods
## NEEDS FIX: Reorder boxplots so that they are grouped by Sequencing type. 
# https://www.r-graph-gallery.com/267-reorder-a-variable-in-ggplot2.html
clinical_df %>%
  ggplot(aes(x = Study_ID, y = TMB, fill = Sequencing_type)) +
  geom_boxplot() +
  scale_y_continuous(trans = "log2") +
  scale_fill_brewer(palette = "Accent", direction = -1) +
  labs(fill = "Sequencing type", y = "Tumor Mutation Burden (Log2 scale)", x = "Cohort") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))




# Grid of histograms displaying TMB from clinical data set (from cBioPortal), later also include Biolung data. 
# Also include sequencing platform and N (sample size) as subtitle. 
# Select cool colour. 
df_cbioportal_clinical %>% ggplot(aes(TMB..nonsynonymous.)) + geom_histogram(binwidth = 1) + facet_wrap(~Study.ID)

# Generate boxplots of TMB across different studies. Add gene panel and sample size as sub-title. Facet grid. 

# Generate boxplots of TMB comparison between responders and non-responders in each study, facet grid. 


# Generate barplots of comparison between sexes. 

# Boxplot: Group by age. Facet by study. 