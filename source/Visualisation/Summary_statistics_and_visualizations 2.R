#=================================================================================
# LOAD LIBRARIES & READ FILES
#=================================================================================
library(ggplot2)
library(dplyr)
library(tidyverse)
library(naniar)


# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)
# Read clinical data tsv file:
  clinical_df <- read.delim("merged_cBioPortal_clinical_mutation_data.tsv")

# Read tsv as data frame:
  clinical_df <- as.data.frame(clinical_df)

#=================================================================================
# CALCULATE SUMMARY STATISTICS
#=================================================================================

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
      # Progression free survival for each cohort:
      clinical_df %>% group_by(Study_ID) %>% filter(!is.na(PFS_months)) %>% summarize(
        average_PFS = mean(PFS_months),
        standard_deviation_PFS = sd(PFS_months)
      )
      # Progression free survial for entire dataset:
      clinical_df %>% filter(!is.na(PFS_months)) %>% summarize(
        average_PFS = mean(PFS_months),
        standard_deviation_PFS = sd(PFS_months)
      )

  # Sex ratio:
      # Sex ratio for each cohort:
      clinical_df %>% group_by(Study_ID) %>% summarize(
        fraction_male = sum(Sex == "Male") / length(Sex),
        fraction_female = sum(Sex == "Female") / length(Sex)
      )
      # Sex ratio for entire dataset: 
      clinical_df %>% summarize(
        fraction_male = sum(Sex == "Male") / length(Sex),
        fraction_female = sum(Sex == "Female") / length(Sex)
      )
      
  
#=======================================================================  
# SIMPLE BARPLOTS
#=======================================================================

# Study ID fractions (how large fractions derive from different data sets) barplot/pie chart.

# Sequencing types barplot/pie charts.  

# Smoking history distribution barplot. 
      

# Specific mutations

      

#=================================================================================
# Visualizations
#=================================================================================

# NOTE: Rstudio can be a bit moody sometimes and not allow us to create the 
# plots. If Rstudio is in a bad mood, you can generate the plots in a new script file
# (running on the same instance).

      

# Heatmap of missing data:
# DEV: May make this one prettier...
missing_data <- vis_miss(clinical_df)



# Non-transformed histogram:
TMB_hist <- clinical_df %>% ggplot(aes(x = TMB)) +
  geom_histogram(binwidth = 1, fill = "mediumpurple2", col = "mediumpurple4") +
  labs(x = 'Tumor Mutation Burden', y = 'Count')
TMB_hist
# Remove max TMB outlier from dataset:
clinical_df <- clinical_df %>% filter(TMB < 75)


# Log2-transformed histogram (excluding maximum outlier)
TMB_hist_trans <- clinical_df %>% ggplot(aes(x = TMB)) +
  geom_histogram(binwidth = 1, fill = "mediumpurple2", col = "mediumpurple4") +
  labs(x = 'Tumor Mutation Burden (Log2 scale)', y = 'Count (Log2 scale)') +
  scale_x_continuous(trans = "log2") +
  scale_y_continuous(trans = "log2")
TMB_hist_trans


# TMB boxplot responders vs non-responders for each cohort
TMB_boxp_DCB_vs_NCB <- clinical_df %>% ggplot(aes(x = Study_ID, y = TMB, fill = Durable_clinical_benefit)) +
  geom_boxplot() +
  scale_fill_brewer(palette = "Accent", direction = -1) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(fill = "Durable Clinical Benefit", y = "Tumor Mutation Burden", x = "Cohort")
TMB_boxp_DCB_vs_NCB

# TMB boxplot responders vs non-responders for each cohort log2 transformed
TMB_boxp_DCB_vs_NCB_log2 <- TMB_boxp_DCB_vs_NCB +
  scale_y_continuous(trans = "log2") +
  labs(y = "Tumor Mutation Burden (Log2 scale)")
TMB_boxp_DCB_vs_NCB_log2


# Boxplot comparison, TMB across sequencing methods
## DEV: Reorder boxplots so that they are grouped by Sequencing type. 
clinical_df %>% mutate(Study_ID = reorder(Study_ID, TMB, FUN = median)) %>%
  ggplot(aes(x = Study_ID, y = TMB, fill = Sequencing_type)) +
  geom_boxplot() +
  #scale_y_continuous(trans = "log2") +
  scale_fill_brewer(palette = "Accent") +
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