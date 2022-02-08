library("tidyverse")
library("ggplot2")

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

# Pipe data to ggplot, set global aesthetics, store in object MSI_HIST
MSI_HIST <- FMERGED %>% ggplot(aes(x = as.numeric(percent_MSI),fill = clinical_outcome, color = clinical_outcome)) +
# Plot histogram, make partly transparent, choose cool colors
geom_histogram(binwidth = 1, position = "identity", alpha = 0.5) + scale_color_brewer(palette="Dark2", direction = -1) + scale_fill_brewer(palette="Dark2", direction = -1) +
  # label axes
labs(color="clinical_outcome", x="% MSI", y="Count", title="% MSI histogram", subtitle="N=36") +
# Move title to middle of plot
    theme(plot.title = element_text(hjust = 0.5))

MSI_HIST

# Save MSI histogram
ggsave("msi_histogram_biolung.pdf", MSI_HIST)





