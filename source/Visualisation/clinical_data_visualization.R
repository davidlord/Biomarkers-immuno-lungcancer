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

# Pie chart of sexes
## NEEDS DEBUGGING
percent_males <- sum(clinical_df$Sex=='Male') / length(clinical_df$Sex)
percent_females <- sum(clinical_df$Sex=='Female') / length(clinical_df$Sex)
sum(clinical_df$Sex=='Male')
sum(clinical_df$Sex=='Female')
clinical_df %>% ggplot(aes(x="", y=Sex, fill=Sex)) +
  # First create barplot:
  geom_bar(stat="identity", width=1) +
  # Transformt o pie chart:
  coord_polar("y", start=0) +
  # Remove background grid:
  theme_void() +
  # Set cool color: 
  scale_fill_brewer(palette="Blues")
  # Set labels in pie chart instead and add percentages. 


# Histogram of TMB:
TMB_hist <- clinical_df %>% ggplot(aes(x = TMB)) +
  geom_histogram(binwidth = 1, fill = "lightblue", col = "darkblue") +
  labs(x="Tumor Mutation Burden", y="Count")
TMB_hist

# Histogram of TMB x-scale log2-transformed (outlier, max value not included)
TMB_hist +
  scale_x_continuous(trans = "log2")

# Histogram of TMB x-scale and y-scale log2-transformed (outlier, max value not included)
TMB_hist +
  scale_x_continuous(trans = "log2") +
  scale_y_continuous(trans = "log2")
## Dev: Remove decimals from x-axis values. 


# Boxplot comparison, responders vs non-responders all samples:
clinical_df %>% ggplot(aes(x = Study_ID, y = TMB, fill = Durable_clinical_benefit)) +
  geom_boxplot() +
  scale_y_continuous(trans = "log2") +
  scale_fill_brewer(palette = "Dark2", direction = -1) +
  labs(fill = "Durable Clinical Benefit", y = "Tumor Mutation Burden (Log2 scale)", x = "Cohort") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


  


# Grid of histograms displaying TMB from clinical data set (from cBioPortal), later also include Biolung data. 
# Also include sequencing platform and N (sample size) as subtitle. 
# Select cool colour. 
df_cbioportal_clinical %>% ggplot(aes(TMB..nonsynonymous.)) + geom_histogram(binwidth = 1) + facet_wrap(~Study.ID)

# Generate boxplots of TMB across different studies. Add gene panel and sample size as sub-title. Facet grid. 

# Generate boxplots of TMB comparison between responders and non-responders in each study, facet grid. 


# Generate barplots of comparison between sexes. 

# Boxplot: Group by age. Facet by study. 