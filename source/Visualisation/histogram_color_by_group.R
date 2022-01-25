library("dplyr")
library("ggplot2")

# Generating a histogram with different color depending on clinical benefit, data from external dataset. 

# Select TMB and durable clinical effect from 
TMB <- test_table %>% select(Durable.Clinical.Benefit, TMB..nonsynonymous.)
# Pipe data to ggplot, set global aesthetics, store in object TMB_PLOT
TMB_PLOT <- TMB %>% ggplot(aes(x = as.numeric(TMB$TMB..nonsynonymous.), color = Durable.Clinical.Benefit, fill = Durable.Clinical.Benefit)) +
# Plot histogram, make partly transparent, choose cool colors
geom_histogram(binwidth = 1, position = "identity", alpha = 0.5) + scale_color_brewer(palette="Dark2") + scale_fill_brewer(palette="Dark2")

# Plot da plot
TMB_PLOT

# ToDo: Change xlab, change names of side thingy, add header. 