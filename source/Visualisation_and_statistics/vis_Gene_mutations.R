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
# MUTATION FREQUENCIES
#=======================================================================

##### EXPERIMENTAL #####
##### EXPERIMENT





colnames(total_df)
genes_of_interest <- c("POLE", "KEAP1", "KRAS", "POLD1", "STK11", "TP53", "MSH2", "EGFR", "PTEN")
temp_df <- total_df %>% select(Study_ID, Treatment_Outcome, genes_of_interest)

total_df %>% group_by(Study_ID, Treatment_Outcome) %>% summarise("POLE" = sum(POLE))
POLD1 <- total_df %>% group_by(Study_ID, Treatment_Outcome) %>% summarise("POLD1" = sum(POLD1))
KEAP1 <- total_df %>% group_by(Study_ID, Treatment_Outcome) %>% summarise("KEAP1" = sum(KEAP1))
KRAS <- total_df %>% group_by(Study_ID, Treatment_Outcome) %>% summarise("KRAS" = sum(KRAS))
STK11 <- total_df %>% group_by(Study_ID, Treatment_Outcome) %>% summarise("STK11" = sum(STK11))
TP53 <- total_df %>% group_by(Study_ID, Treatment_Outcome) %>% summarise("TP53" = sum(TP53))
MSH2 <- total_df %>% group_by(Study_ID, Treatment_Outcome) %>% summarise("MSH2" = sum(MSH2))
EGFR <- total_df %>% group_by(Study_ID, Treatment_Outcome) %>% summarise("EGFR" = sum(EGFR))
PTEN <- total_df %>% group_by(Study_ID, Treatment_Outcome) %>% summarise("PTEN" = sum(PTEN))

temp_df <- merge(POLE, POLD1, by = c("Study_ID", "Treatment_Outcome"))

temp2_df <- temp_df %>% filter(Study_ID == "BioLung_2022") %>% select(-Study_ID)







# 1. Select genes of interest cols

# 2. Group by study id, treatment outcome

# 3. calc. sums muts for each mutation (loop over cols?)

for (i in 2:ncol(temp_df)) {
  print(colnames(temp_df[i]))
  print(temp_df[ , i])
}

for (i in 2:ncol(temp_df)) {
  print(temp_df[ , i])
}


total_df %>% group_by(Study_ID, Treatment_Outcome) %>% summarise(sum())




##### EXPERIMENTAL #####
##### EXPERIMENTAL #####



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




