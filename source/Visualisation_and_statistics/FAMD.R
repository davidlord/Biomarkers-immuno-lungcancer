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
library(FactoMineR)
library(factoextra)

# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

# Read data file
total_df <- read.delim("combined_data.tsv", stringsAsFactors = TRUE)



#=======================================================================  
# VISUALIZE MISSING DATA (CLINICAL FEATURES)
#=======================================================================

# Select relevant columns for visualization of missing data:
colnames(total_df)
# Rename PD-L1 Expression column
total_df <- total_df %>% rename("PD-L1_Expression" = "PD.L1_Expression")
# Subset into separate df
md_df <- total_df %>% select(Histology, 'PD-L1_Expression', Smoking_History, TMB, Diagnosis_Age, Stage_at_diagnosis, Sex, MSI, Study_ID)
# Replace empty string entries with NAs
md_df[md_df == ''] <- NA
# Create heatmap of missing data
gg_miss_fct(x = md_df, fct = Study_ID) + 
  labs(title = "Missing data in Combined Dataset", y = "Feature", x = "Cohort of Origin") +
  theme(axis.text.y = element_text(angle = 45))


#=======================================================================  
# PLOT RAWDATA, FAMD
#=======================================================================

# Read model-ready dataset
model_df <- read.delim("model-ready_combinded_data.tsv", stringsAsFactors = TRUE)

# Remove features
model_df <- model_df %>% select(-c(Treatment_Outcome, TMB, TMB_norm))

# Get FAMD
res_famd <- FAMD (base = model_df, ncp = 5, sup.var = NULL, ind.sup = NULL)

# Get & plot proportion of variances retained by dimensions (eigenvalues)
eig_vals <- get_eigenvalue(res_famd)
head(eig_vals)
fviz_screeplot(res_famd)

fviz_famd_ind(res_famd, habillage = "Study_ID", addEllipses = TRUE, 
              col.ind = "cos2", repel = TRUE, 
              )




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



#============================================================================
# ENGINEERED FEATURES:
# NDB RELATED GENES (STK11, EGFR)
# DCB RELATED GENES ()
# PAN ET AL (2020) COMPOUND MUTATIONS
#============================================================================






# Grid of histograms displaying TMB from clinical data set (from cBioPortal), later also include Biolung data. 
# Also include sequencing platform and N (sample size) as subtitle. 
# Select cool colour. 
df_cbioportal_clinical %>% ggplot(aes(TMB..nonsynonymous.)) + geom_histogram(binwidth = 1) + facet_wrap(~Study.ID)

# Generate boxplots of TMB across different studies. Add gene panel and sample size as sub-title. Facet grid. 

# Generate boxplots of TMB comparison between responders and non-responders in each study, facet grid. 


# Generate barplots of comparison between sexes. 

# Boxplot: Group by age. Facet by study. 