#=================================================================================
# LOAD LIBRARIES & READ FILES
# DEV: Read total_df from summary statistics instead...
#=================================================================================
library(ggplot2)
library(dplyr)
library(tidyverse)
library(ggpubr)


# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

# Read data file
total_df <- read.delim("Features_engineered_control_included.tsv", stringsAsFactors = FALSE)
unique(total_df$Study_ID)
total_df <- total_df %>% filter(Study_ID != "Model_Control")



#=======================================================================
# PREPROCESS
#=======================================================================
temp_df <- total_df

# Investigate vector
class(temp_df$PD.L1_Expression)
# Investigate vector
table(temp_df$PD.L1_Expression)
# Change to numeric
temp_df$PD.L1_Expression <- as.numeric(temp_df$PD.L1_Expression)


#=======================================================================
# VISUALIZE
#=======================================================================

# HISTOGRAM
#------------

hist <- temp_df %>% ggplot(aes(x = PD.L1_Expression, fill = Treatment_Outcome)) +
  geom_histogram(binwidth = 10, color = "dodgerblue4", alpha = 0.65) +
  scale_fill_brewer(palette = "Paired", direction = -1) +
  #scale_y_continuous(trans = "log2") +
  labs(x = "PD-L1 Expression\n", y = "Count", subtitle = "N = 164", 
       fill = "Treatment Outcome", title = "Distribution of PD-L1 Expression values")
hist



# BOXPLOT FOR EACH COHORT
#-------------------------
# Calculate sample sizes for each cohort
biolung <- temp_df %>% filter(Study_ID == "BioLung_2022") %>% select(PD.L1_Expression)
sum(!is.na(biolung))

hellmann <- temp_df %>% filter(Study_ID == "Hellmann_2018") %>% select(PD.L1_Expression)
sum(!is.na(hellmann))

rivzi_2018 <- temp_df %>% filter(Study_ID == "Rivzi_2018") %>% select(PD.L1_Expression)
sum(!is.na(rivzi_2018))

# Add sample sizes to names
temp_df$Study_ID <- ifelse(temp_df$Study_ID == "BioLung_2022", "BioLung 2022\n(N = 28)", temp_df$Study_ID)
temp_df$Study_ID <- ifelse(temp_df$Study_ID == "Hellmann_2018", "Hellmann 2018\n(N = 70)", temp_df$Study_ID)
temp_df$Study_ID <- ifelse(temp_df$Study_ID == "Rivzi_2018", "Rivzi 2018\n(N = 66)", temp_df$Study_ID)

table(temp_df$Study_ID)


# Plot boxplot
boxp_cohorts <- temp_df %>% filter(Study_ID != "Jordan_2017") %>% 
  filter(Study_ID != "Rivzi_2015") %>% 
  ggplot(aes(y = PD.L1_Expression, x = Study_ID)) +
  geom_boxplot(fill = "steelblue", color = "dodgerblue4") +
  labs(x = "", y = "PD-L1 Expression", title = "PD-L1 Expression", 
       subtitle = "Comparison between cohorts of origin")
boxp_cohorts


# BOXPLOT RESPONDERS VS NON-RESPONDERS
#--------------------------------------
temp2_df <- temp_df

# Count numbers of responders & non-responders
temp <- temp2_df %>% filter(Treatment_Outcome == "Responder")
sum(!is.na(temp$PD.L1_Expression))
# N responders = 73
temp <- temp2_df %>% filter(Treatment_Outcome == "Non-Responder")
sum(!is.na(temp$PD.L1_Expression))
# N non-responders = 91

# Add N to treatment outcomes
temp2_df$Treatment_Outcome <- ifelse(temp2_df$Treatment_Outcome == "Responders", "Responders\n(N = 73)", "Non-responders\n(N = 91)")

boxp_resp <- temp2_df %>% ggplot(aes(x = Treatment_Outcome, y = PD.L1_Expression)) +
  geom_boxplot(fill = "steelblue", color = "dodgerblue4") +
  labs(x = "", y = "PD-L1 Expression", title = "PD-L1 Expression", 
       subtitle = "Responders vs. Non-responders")
boxp_resp

temp2_df <- temp2_df %>% filter(!is.na(PD.L1_Expression))
temp2_df %>% group_by(Treatment_Outcome) %>% summarize(median = median(PD.L1_Expression))



# COMBINE PLOTS
#-----------------

ggarrange(boxp_resp, boxp_cohorts, ncol = 1, nrow = 2, labels = c("A", "B"))

boxp_cohorts
boxp_resp


ggarrange(hist, ggarrange(boxp_resp, boxp_cohorts, ncol = 2, labels = c("B", "C"))
          , nrow = 2, labels = "A")



