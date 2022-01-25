# Load necessary libraries
library(tidyverse)
library(ggplot2)
library(ggthemes)
library(readxl)

# Set working directory (also place data to read in working directory).
WORK_DIR <- "/Users/davidlord/Documents/Results/msi_status"
setwd(WORK_DIR)

# Pipe the data to ggplot, read the '% MSI' column as numerical data, store in object MSI
MSI <- msi_status_biolung %>% ggplot(aes(as.numeric(msi_status_biolung$`% MSI`))) +
    # Set geometry to histogram
    geom_histogram(binwidth = 1) +
    # Add xlabel
    xlab("% MSI") +
    # Add title
    ggtitle("% MSI histogram") +
    # Move title to the middle of the plot
    theme(plot.title = element_text(hjust = 0.5))

# Print plot
MSI
