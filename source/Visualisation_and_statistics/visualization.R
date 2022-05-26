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
library(ggpubr)

# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/External_data/script_running"
setwd(WORK_DIR)

# Read data file
total_df <- read.delim("combined_data.tsv", stringsAsFactors = FALSE)


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
# HISTOLOGY
#=======================================================================

unique(total_df$Histology)
# Remove NAs in a temporary df
temp_df <- total_df %>% filter(!is.na(Histology))

# Replace entries with abbreviations
unique(temp_df$Histology)
temp_df$Histology[temp_df$Histology == "Large Cell Neuroendocrine Carcinoma"] <- "LCNEC"
temp_df$Histology[temp_df$Histology == "Lung Adenocarcinoma"] <- "LUAD"
temp_df$Histology[temp_df$Histology == "Lung Squamous Cell Carcinoma"] <- "LSCC"
temp_df$Histology[temp_df$Histology == "Non-Small Cell Lung Cancer"] <- "NSCLC"

# Calculate numbers of each
table(temp_df$Histology)
counts <- c(6, 40, 322, 14)
nrow(temp_df)

histology_barplot <- temp_df %>% ggplot(aes(x = Histology)) +
  geom_bar(color = "dodgerblue4", fill = "steelblue") +
  scale_y_continuous(trans = "log10") +
  #scale_x_discrete(labels = test) +
  labs(x = "\n Histology", y = "Count (log10 scale) \n") +
  theme(text = element_text(size = 14))
histology_barplot


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

# MSI HISTOGRAMS
#-----------------
MSI_hist <- biolung_df %>% ggplot(aes(x = MSI)) + geom_histogram(binwidth = 5)
MSI_hist


# MSI BOXPLOTS
#--------------
biolung_df$Treatment_Outcome <- ifelse(biolung_df$Treatment_Outcome == "Responder", "Responders \n (N = 20)", "Non-responders \n (N = 14)")

MSI_boxplot <- biolung_df %>% ggplot(aes(
  x = Treatment_Outcome, y = MSI, fill = Treatment_Outcome)) +
  geom_boxplot() +
  scale_fill_brewer(palette = "Paired", direction = -1) + 
  labs(x = "\n Treatment Outcome", y = "% Microsatellite Instability \n", subtitle = "N = 34", size = 10) +
  theme(legend.position = "none", text = element_text(size = 14))
MSI_boxplot


# MSI CORRELATIONS
#-------------------

# MSI vs TMB
biolung_df %>% ggplot(aes(x = MSI, y = TMB)) + 
  geom_point(color = "dodgerblue4") + 
  scale_x_continuous(trans = "log2") + 
  scale_y_continuous(trans = "log2") + 
  geom_smooth(method = lm, se=FALSE, linetype = "dashed", color = "dodgerblue3") + 
  labs(x = "\n % Microsatellite instability (log2)", y = "Tumor Mutation Burden (log2) \n", subtitle = "N = 34") +
  theme(text = element_text(size = 14))

biolung_df$PD.L1_Expression <- as.numeric(biolung_df$PD.L1_Expression)
biolung_df %>% ggplot(aes(MSI, y = PD.L1_Expression)) + 
  geom_point() +
  scale_x_continuous(trans = "log2")




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