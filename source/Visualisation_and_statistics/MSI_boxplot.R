# Set working directory for output
setwd("/Users/davidlord/Documents/Results/Visualization")

# Script generating a histogram of msi-data from biolung project. Different color depending on durable clinical benefit or not. 

### Load msi and clinical outcome files manually for now, script later...


# Read MSI-status into dataframe
MSI <- msi_status_biolung %>% select("BioLungnr", "percent_MSI")

# Read responders vs non-responders into dataframe
CO <- responders_vs_non_responders %>% select("BioLungnr", "clinical_outcome")

# Merge the data frames 
MERGED <- merge(MSI, CO, by="BioLungnr")

# Filter missing data. 
FMERGED <- MERGED %>% filter(clinical_outcome == "Responder" | clinical_outcome == "Non responder")

# Pipe data to ggplot, set global aesthetics, store in object MSI_BOXP
MSI_BOXP <- FMERGED %>% ggplot(aes(x = clinical_outcome, y = as.numeric(percent_MSI), fill = clinical_outcome)) +
# Plot boxplots, choose cool colors. 
  geom_boxplot(alpha = 0.8) + scale_color_brewer(palette="Dark2", direction = -1) + scale_fill_brewer(palette="Dark2", direction = -1) +
  # Set label names: 
  labs(color="clinical_outcome", x = "", y="% MSI", title="% MSI boxplots") +
  # Move title to middle of plot, remove legend, and 
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")


MSI_BOXP

# Save MSI boxplot
ggsave("msi_boxplot_biolung.pdf", MSI_BOXP)
