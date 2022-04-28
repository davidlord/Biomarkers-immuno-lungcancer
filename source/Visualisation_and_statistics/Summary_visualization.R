#=================================================================================
# LOAD LIBRARIES & READ FILES
# DEV: Read total_df from summary statistics instead...
#=================================================================================
library(ggplot2)
library(dplyr)
library(tidyverse)
library(naniar)
library(visdat)
library(readxl)

# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

# Read data file
total_df <- read.delim("total_df.tsv", stringsAsFactors = TRUE)


#=======================================================================  
# PLOT RAWDATA
#=======================================================================


#=======================================================================
# TMB HISTOGRAMS
#=======================================================================
# Histogram of raw TMB values
TMB_hist <- total_df %>% ggplot(aes(x = TMB)) +
  geom_histogram(binwidth = 1, fill = "skyblue1", col = "skyblue4") +
  labs(x = 'Tumor Mutation Burden', y = 'Count')
TMB_hist

# Remove max TMB outlier from dataset and plot histogram again:
total_df <- total_df %>% filter(TMB < 90)
TMB_hist <- total_df %>% ggplot(aes(x = TMB)) +
  geom_histogram(binwidth = 1, fill = "skyblue1", col = "skyblue4") +
  labs(x = 'Tumor Mutation Burden', y = 'Count')
TMB_hist

# Log2-transformed histogram (excluding maximum outlier)
TMB_hist_trans <- total_df %>% ggplot(aes(x = TMB)) +
  geom_histogram(binwidth = 1, fill = "skyblue1", col = "skyblue4") +
  labs(x = 'Tumor Mutation Burden (Log2 scale)', y = 'Count (Log2 scale)') +
  scale_x_continuous(trans = "log2") +
  scale_y_continuous(trans = "log2")
TMB_hist_trans

# TMB color by durable clinical benefit
TMB_hist_clinical_outcome <- total_df %>% ggplot(aes(x = TMB, color = Durable_clinical_benefit, fill = Durable_clinical_benefit)) +
  geom_histogram(binwidth = 1, position = "identity", alpha = 0.9) + 
  scale_color_brewer(palette = "Paired", direction = -1) +
  scale_fill_brewer(palette = "Paired", direction = -1) +
  labs(x = "Tumor Mutation Burden", size = 10)
TMB_hist_clinical_outcome
# No observed differnece in distribution of TMB between responders/non-responders comparing across cohorts. 


#=======================================================================
# TMB BOXPLOTS
#=======================================================================

# Responders vs. non-responders, group by cohort
TMB_by_cohort_boxplot <- total_df %>% mutate(Study_ID = reorder(Study_ID, TMB, FUN = median)) %>% ggplot(
  aes(x = Study_ID, y = TMB, fill = Durable_clinical_benefit)) +
  geom_boxplot() +
  scale_fill_brewer(palette = "Paired", direction = -1) +
  labs(fill = "Durable Clinical Benefit", y = "Tumor Mutation Burden", x = "Cohort") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 10))
TMB_by_cohort_boxplot

# Log2 Responders vs non-responders for each cohort
TMB_by_cohort_boxplot_log2 <- TMB_by_cohort_boxplot + 
  scale_y_continuous(trans = "log2") +
  labs(y = "Tumor Mutation Burden (Log2 scale)")
TMB_by_cohort_boxplot_log2


# TMB boxplots group by study
TMB_by_cohort <- total_df %>% mutate(Study_ID = reorder(Study_ID, TMB, FUN = median)) %>%
  ggplot(aes(x = Study_ID, y = TMB, fill = Study_ID)) + 
  geom_boxplot() + 
  scale_y_continuous(trans = "log2") +
  labs(y = "Tumor Mutation Burden (Log2 scale)", x = "Cohort") +
  scale_fill_brewer(palette = "Blues") +
  theme(legend.position="none") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 10))
TMB_by_cohort

# TMB group by study and sequencing type
TMB_by_sequencing_type <- total_df %>% mutate(Sequencing_type = reorder(Sequencing_type, TMB, FUN = median)) %>%
  ggplot(aes(x = Sequencing_type, y = TMB, fill = Sequencing_type)) + 
  geom_boxplot() + 
  scale_y_continuous(trans = "log2") + 
  labs(y = "Tumor Mutation Burden (Log2 scale)", x = "Sequencing type") + 
  scale_fill_brewer(palette = "Blues") +
  theme(legend.position="none") +
  theme(axis.text.x = element_text(angle = 30, hjust = 1, size = 10))
TMB_by_sequencing_type


#=======================================================================
# VISUALIZE MISSING DATA
#=======================================================================

# Convert empty entries to NA
total_df <- total_df %>% mutate_all(na_if, "")

# DEV: First deselect mutation columns

# Heatmap of missing data (and percentages)
vis_miss(total_df)

# Barplots of missing data (counts)
gg_miss_var(total_df) + 
  labs(y = "Missing data")


#=======================================================================
# MUTATION FREQUENCIES
#=======================================================================

# Read gene frequencies file (excel file)
gene_freq_df <- read_excel("Gene_frequencies_2.xlsx")
gene_freq_df$Gene_freq <- as.numeric(gene_freq_df$Gene_freq)

# Barplots facet by column
barplot <- gene_freq_df %>% ggplot(aes(x = Study_ID, y = Gene_freq, fill = Study_ID, color = Study_ID)) +
  geom_bar(stat = "identity", color = "black") + 
  facet_wrap(~ Gene_mut) +
  scale_fill_brewer(palette = "Blues") +
  scale_y_continuous(limits = c(0, 0.7)) +
  theme(axis.text.x = element_blank()) +
  labs(x = "", y = "Gene mutation frequency")
barplot

test <- gene_freq_df %>% ggplot(aes(x =))
class(gene_freq_df$Gene_freq)

ylim = c(0, 0.5)
#=======================================================================
# MSI
#=======================================================================
biolung_df <- total_df %>% filter(Study_ID == "BioLung_2022")

MSI_boxplot <- biolung_df %>% ggplot(aes(
  x = Durable_clinical_benefit, y = MSI_MSISensorPro, fill = Durable_clinical_benefit)) +
  geom_boxplot() +
  scale_fill_brewer(palette = "Paired", direction = -1) + 
  labs(x = "Durable clinical benefit", y = "% Microsatellite instability", subtitle = "N = 34", size = 10) +
  theme(legend.position = "none")
MSI_boxplot



# Grid of histograms displaying TMB from clinical data set (from cBioPortal), later also include Biolung data. 
# Also include sequencing platform and N (sample size) as subtitle. 
# Select cool colour. 
df_cbioportal_clinical %>% ggplot(aes(TMB..nonsynonymous.)) + geom_histogram(binwidth = 1) + facet_wrap(~Study.ID)

# Generate boxplots of TMB across different studies. Add gene panel and sample size as sub-title. Facet grid. 

# Generate boxplots of TMB comparison between responders and non-responders in each study, facet grid. 


# Generate barplots of comparison between sexes. 

# Boxplot: Group by age. Facet by study. 