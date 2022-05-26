#=================================================================================
# LOAD LIBRARIES & READ FILES
# DEV: Read total_df from summary statistics instead...
#=================================================================================
library(ggplot2)
library(dplyr)
library(tidyverse)
library(readxl)
library(ggpubr)

# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

# Read data file
total_df <- read.delim("combined_data.tsv", stringsAsFactors = FALSE)


#=======================================================================
# TMB QQ-PLOTS
#=======================================================================

# Read model-ready dataset
model_df <- read.delim("model-ready_combinded_data.tsv", stringsAsFactors = TRUE)

# Remove TMB max outlier
model_df <- model_df[-which.max(model_df$TMB), ]

# QQ-plot of raw TMB values
qqTMB <- ggqqplot(model_df$TMB, ylab = "")

# QQ-plot of log2-transformed TMB-values
model_df$TMB_log2 <- log2(model_df$TMB)
qqTMB_log2 <- ggqqplot(model_df$TMB_log2, ylab = "")

# QQ-plot of normalized TMB values
qqTMB_norm <- ggqqplot(model_df$TMB_norm, ylab = "")

# QQ-plot of normalized log2-transformed TMB values
qqTMB_norm_log2 <- ggqqplot(model_df$TMB_norm_log2, ylab = "")

# Plot on same page
ggarrange(qqTMB, qqTMB_log2, qqTMB_norm, qqTMB_norm_log2, labels = c("A", "B", "C", "D"))



#=======================================================================
# TMB HISTOGRAMS
#=======================================================================
# Histogram of raw TMB values
TMB_hist <- total_df %>% ggplot(aes(x = TMB)) +
  geom_histogram(binwidth = 1, fill = "dodgerblue3", col = "dodgerblue4") +
  labs(x = 'Tumor Mutation Burden', y = 'Count')
TMB_hist

# Remove max TMB outlier from dataset and plot histogram again:
total_df <- total_df %>% filter(TMB < 90)
TMB_hist <- total_df %>% ggplot(aes(x = TMB)) +
  geom_histogram(binwidth = 1, fill = "dodgerblue3", col = "dodgerblue4") +
  labs(x = 'Tumor Mutation Burden', y = 'Count')
TMB_hist

# TMB color by durable clinical benefit
TMB_hist_clinical_outcome <- total_df %>% ggplot(aes(x = TMB, fill = Treatment_Outcome, color = Treatment_Outcome)) +
  geom_histogram(binwidth = 1, position = "identity", alpha = 0.9) + 
  scale_color_brewer(palette = "Paired", direction = -1) +
  scale_fill_brewer(palette = "Paired", direction = -1) +
  labs(x = "Tumor Mutation Burden", size = 10, fill = "Treatment Outcome", color = "Treatment Outcome")
TMB_hist_clinical_outcome
q# No observed differnece in distribution of TMB between responders/non-responders comparing across cohorts. 

# Log2-transformed histogram (excluding maximum outlier)
TMB_hist_trans <- total_df %>% ggplot(aes(x = TMB)) +
  geom_histogram(binwidth = 0.5, fill = "dodgerblue3", col = "dodgerblue4") +
  labs(x = 'Tumor Mutation Burden (Log2 scale)', y = 'Count') +
  scale_x_continuous(trans = "log2")
TMB_hist_trans

# TMB log2 transformed color by treatment outcome
TMB_hist_clinical_outcome <- total_df %>% ggplot(aes(x = TMB, color = Treatment_Outcome, fill = Treatment_Outcome)) +
  geom_histogram(binwidth = 0.5, position = "identity", alpha = 0.65) + 
  scale_color_brewer(palette = "Paired", direction = -1) +
  scale_fill_brewer(palette = "Paired", direction = -1) +
  scale_x_continuous(trans = "log2") +
  labs(x = "Tumor Mutation Burden", size = 10, fill = "Treatment Outcome", color = "Treatment Outcome")
TMB_hist_clinical_outcome


#=======================================================================
# TMB BOXPLOTS
#=======================================================================

# Responders vs. non-responders, group by cohort
TMB_by_cohort_boxplot <- total_df %>% mutate(Study_ID = reorder(Study_ID, TMB, FUN = median)) %>% ggplot(
  aes(x = Study_ID, y = TMB, fill = Treatment_Outcome)) +
  geom_boxplot() +
  scale_fill_brewer(palette = "Paired", direction = -1) +
  labs(fill = "Treatment Outcome", y = "Tumor Mutation Burden", x = "Cohort") +
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

# TMB group by sequencing type
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
# VISUALIZE NORMALIZED TMB
#=======================================================================

# NORMALIZE VARIABLE
#---------------------
# Normalize TMB: Divide by mean for each study of origin
total_df <- total_df %>% group_by(Study_ID) %>% mutate(TMB_norm = TMB / mean(TMB))

# HISTOGRAMS
#-------------

# Histogram, log2 x-axis:
TMB_norm_hist <- total_df %>% ggplot(aes(x = TMB_norm)) +
  geom_histogram(binwidth = 0.5, fill = "dodgerblue3", col = "dodgerblue4") +
  labs(x = 'Tumor Mutation Burden', y = 'Count')
TMB_norm_hist

# Histogram, log2 x-axis:
TMB_norm_hist <- total_df %>% ggplot(aes(x = TMB_norm)) +
  geom_histogram(binwidth = 0.5, fill = "dodgerblue3", col = "dodgerblue4") +
  scale_x_continuous(trans = "log2") +
  labs(x = 'Tumor Mutation Burden', y = 'Count')
TMB_norm_hist

# TMB histogram by treatment outcome
TMB_norm_hist_clinical_outcome <- total_df %>% ggplot(aes(x = TMB_norm, color = Treatment_Outcome, fill = Treatment_Outcome)) +
  geom_histogram(binwidth = 0.5, position = "identity", alpha = 0.65) + 
  scale_color_brewer(palette = "Paired", direction = -1) +
  scale_fill_brewer(palette = "Paired", direction = -1) +
  scale_x_continuous(trans = "log2") +
  labs(x = "Tumor Mutation Burden", size = 10, fill = "Treatment Outcome", color = "Treatment Outcome")
TMB_norm_hist_clinical_outcome
# More resembles a normal ditribution on log2-scale. 


# Therefore, log2-transforms normalized TMB value... 
total_df$TMB_norm_log2 <- log2(total_df$TMB_norm)


# BOXPLOTS
#------------

# Responders vs. non-responders, group by cohort
TMB_by_cohort_boxplot <- total_df %>% mutate(Study_ID = reorder(Study_ID, TMB, FUN = median)) %>% ggplot(
  aes(x = Study_ID, y = TMB_norm_log2, fill = Treatment_Outcome)) +
  geom_boxplot() +
  scale_fill_brewer(palette = "Paired", direction = -1) +
  labs(fill = "Treatment Outcome", y = "Tumor Mutation Burden", x = "Cohort") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 10))
TMB_by_cohort_boxplot


