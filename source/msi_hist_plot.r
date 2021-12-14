library(tidyverse)
library(ggplot2)
library(ggthemes)

msi <- msi_status_trimmed %>% ggplot(aes(as.numeric(msi_status_trimmed$`% MSI`))) +
  geom_histogram(binwidth = 1) +
  xlab("% MSI") +
  ggtitle("% MSI histogram") +
  theme(plot.title = element_text(hjust = 0.5))

msi
