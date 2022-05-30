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

# Remove TMB outlier
total_df <- total_df %>% filter(TMB < 90)
# Histogram of raw TMB values
TMB_raw_hist <- total_df %>% ggplot(aes(x = TMB)) +
  geom_histogram(binwidth = 3, fill = "steelblue", col = "dodgerblue4") +
  labs(x = 'TMB', y = 'Count')
TMB_raw_hist

# Log2-transformed histogram (excluding maximum outlier)
TMB_raw_log2 <- total_df %>% ggplot(aes(x = TMB)) +
  geom_histogram(aes(y = ..density..), binwidth = 0.5, fill = "steelblue", col = "dodgerblue4") +
  geom_density(alpha = 0.2, color = "dodgerblue4") +
  labs(x = 'TMB (Log2 scale)', y = 'Density') +
  scale_x_continuous(trans = "log2")
TMB_raw_log2

# NORMALIZE TMB BY COHORT
total_df <- total_df %>% group_by(Study_ID) %>% mutate(TMB_norm = TMB / mean(TMB))

# TMB NORMALIZED
TMB_norm_hist <- total_df %>% ggplot(aes(x = TMB_norm)) +
  geom_histogram(binwidth = 0.3, fill = "steelblue", col = "dodgerblue4") +
  labs(x = 'TMB normalized', y = 'Count')
TMB_norm_hist

# TMB NORMALIZED LOG2-TRANSFORMED
TMB_norm_log2_hist <- total_df %>% ggplot(aes(x = TMB_norm)) +
  geom_histogram(aes(y = ..density..),binwidth = 0.8, fill = "steelblue", col = "dodgerblue4") +
  scale_x_continuous(trans = "log2") +
  geom_density(alpha = 0.2, color = "dodgerblue4") +
  labs(x = 'TMB normalized (Log2 scale)', y = 'Density')
TMB_norm_log2_hist

# COMBINE PLOTS
combined_hists <- ggarrange(ggarrange(TMB_raw_hist, TMB_raw_log2, ncol = 2, labels = c("A", "B")), 
          ggarrange(TMB_norm_hist, TMB_norm_log2_hist, ncol = 2, labels = c("C", "D")), nrow = 2)
combined_hists

total_df$TMB_log2 <- log2(total_df$TMB)
total_df %>% ggplot(aes(x = TMB_log2)) +
  geom_histogram(binwidth = 0.5)



#=======================================================================
# TMB HISTOGRAMS RESPONDERS VS NON-RESPONDERS
#=======================================================================


# TMB color by durable clinical benefit
TMB_hist_clinical_outcome <- total_df %>% ggplot(aes(x = TMB, fill = Treatment_Outcome, color = Treatment_Outcome)) +
  geom_histogram(binwidth = 1, position = "identity", alpha = 0.9, color = "steelblue") + 
  scale_fill_brewer(palette = "Paired", direction = -1) +
  labs(x = "Tumor Mutation Burden", size = 10, fill = "Treatment Outcome", color = "Treatment Outcome")
TMB_hist_clinical_outcome
# No observed differnece in distribution of TMB between responders/non-responders comparing across cohorts. 


# TMB log2 transformed color by treatment outcome
TMB_hist_log2_clinical_outcome <- total_df %>% ggplot(aes(x = TMB, color = Treatment_Outcome, fill = Treatment_Outcome)) +
  geom_histogram(binwidth = 0.5, position = "identity", alpha = 0.65, color = "dodgerblue4") + 
  scale_fill_brewer(palette = "Paired", direction = -1) +
  scale_x_continuous(trans = "log2") +
  labs(x = "TMB (Log2 scale)", y = "Count", size = 10, fill = "Treatment Outcome", 
       color = "Treatment Outcome", title = "TMB Distributions Responders vs Non-responders")
TMB_hist_log2_clinical_outcome


# Normalize TMB: Divide by mean for each study of origin
total_df <- total_df %>% group_by(Study_ID) %>% mutate(TMB_norm = TMB / mean(TMB))


#=======================================================================
# TMB BOXPLOTS
#=======================================================================

# Add total as separate cohort
temp_df <- total_df
temp_df$Study_ID <- "Combined dataset"
total_df <- rbind(total_df, temp_df)

# Rename Cohorts of origin name
total_df$Study_ID <- ifelse(total_df$Study_ID == "Jordan_2017", "Jordan 2017", total_df$Study_ID)
total_df$Study_ID <- ifelse(total_df$Study_ID == "Rivzi_2015", "Rivzi 2015", total_df$Study_ID)
total_df$Study_ID <- ifelse(total_df$Study_ID == "Rivzi_2018", "Rivzi 2018", total_df$Study_ID)
total_df$Study_ID <- ifelse(total_df$Study_ID == "Hellmann_2018", "Hellmann 2018", total_df$Study_ID)
total_df$Study_ID <- ifelse(total_df$Study_ID == "BioLung_2022", "BioLung 2022", total_df$Study_ID)

# Add indices to enable boxplot order
total_df$ind <- NA
total_df$ind <- ifelse(total_df$Study_ID == "Combined dataset", 1, total_df$ind)
total_df$ind <- ifelse(total_df$Study_ID == "Rivzi 2015", 2, total_df$ind)
total_df$ind <- ifelse(total_df$Study_ID == "Rivzi 2018", 3, total_df$ind)
total_df$ind <- ifelse(total_df$Study_ID == "Hellmann 2018", 4, total_df$ind)
total_df$ind <- ifelse(total_df$Study_ID == "Jordan 2017", 5, total_df$ind)
total_df$ind <- ifelse(total_df$Study_ID == "BioLung 2022", 6, total_df$ind)
table(total_df$Study_ID, total_df$ind)

# Responders vs. non-responders, group by cohort
TMB_resp_boxplot <- total_df %>% ggplot(
  aes(x = reorder(Study_ID, ind), y = TMB, fill = Treatment_Outcome)) +
  geom_boxplot() +
  scale_fill_brewer(palette = "Paired", direction = -1) +
  labs(fill = "Treatment Outcome", y = "Tumor Mutation Burden", x = "") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 10))
TMB_resp_boxplot

# Log2 Responders vs non-responders for each cohort
TMB_resp_log2 <- TMB_resp_boxplot + 
  scale_y_continuous(trans = "log2") +
  labs(y = "TMB (Log2 scale)")
TMB_resp_log2


# TMB boxplots group by cohort of origin
TMB_by_cohort <- total_df %>% 
  ggplot(aes(x = reorder(Study_ID, ind), y = TMB, fill = Study_ID)) + 
  geom_boxplot(fill = "steelblue") + 
  scale_y_continuous(trans = "log2") +
  labs(y = "\nTMB (Log2 scale)", x = "", title = "TMB by Cohort of Origin") +
  theme(legend.position="none") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 10))
TMB_by_cohort


# Replace 'Oncopanel_GATCLiquid' with 
total_df$Sequencing_type
total_df$Sequencing_type <- ifelse(total_df$Sequencing_type == "Oncopanel_GATCLiquid", "Oncopanel", total_df$Sequencing_type)

# TMB group by sequencing type
TMB_by_sequencing_type <- total_df %>% 
  ggplot(aes(x = reorder(Sequencing_type, TMB, FUN = median), y = TMB, fill = Sequencing_type)) + 
  geom_boxplot(fill = "steelblue") + 
  scale_y_continuous(trans = "log2") + 
  labs(y = "TMB (Log2 scale)", x = "", title = "TMB by Sequencing Approach") + 
  theme(legend.position="none") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 10))
TMB_by_sequencing_type



#=======================================================================
# VISUALIZE NORMALIZED TMB
#=======================================================================

# HISTOGRAMS
#-------------

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
TMB_norm_log2_resp_boxplot <- total_df %>% 
  ggplot(aes(x = reorder(Study_ID, ind), y = TMB_norm_log2, fill = Treatment_Outcome)) +
  geom_boxplot() +
  scale_fill_brewer(palette = "Paired", direction = -1) +
  labs(fill = "Treatment Outcome", y = "TMB", x = "", title = "Log2-transformed TMB Normalized by Cohort of Origin") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 10))
TMB_norm_log2_resp_boxplot

table(total_df$Study_ID, total_df$ind)



#=======================================================================
# COMBINE PLOTS
#=======================================================================

# Log2 TMB (raw) responders vs. non-responders by cohort
TMB_resp_log2
TMB_by_cohort
TMB_by_sequencing_type

combined_plots <- ggarrange(ggarrange(TMB_by_cohort, TMB_by_sequencing_type, ncol = 2, labels = c("A", "B")), 
                            ggarrange(TMB_norm_log2_resp_boxplot, labels = "C"), nrow = 2)
combined_plots








