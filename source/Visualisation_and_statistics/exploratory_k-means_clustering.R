library(tidyverse)
library(cluster)
install.packages("factoextra")
library(factoextra)
library(gridExtra)

df <- df_cbioportal_clinical
df <- df %>% select(Age, Smoking.Status, Durable.Clinical.Benefit, Sex, TMB..nonsynonymous.)

table(df$Smoking.Status)
  df$Smoking.Status[df$Smoking.Status=="Current"]<-2
  df$Smoking.Status[df$Smoking.Status=="Former"]<-1
  df$Smoking.Status[df$Smoking.Status=="Never"]<-0

table(df$Durable.Clinical.Benefit)
  df$Durable.Clinical.Benefit[df$Durable.Clinical.Benefit=="Durable Clinical Benefit"]<-1
  df$Durable.Clinical.Benefit[df$Durable.Clinical.Benefit=="No Durable Benefit"]<-0

table(df$Sex)
  df$Sex[df$Sex=="Male"]<-1
  df$Sex[df$Sex=="Female"]<-2

str(df)
df[, c(1,2,3,4)] <- sapply(df[, c(1,2,3,4)], as.numeric)

kmeans2 <- kmeans(df, centers = 2, nstart = 25) 
kmeans3 <- kmeans(df, centers = 3, nstart = 25)
kmeans4 <- kmeans(df, centers = 4, nstart = 25)
kmeans5 <- kmeans(df, centers = 5, nstart = 25)

plot1 <- fviz_cluster(kmeans2, geom = "point", data = df) + ggtitle("k = 2")
plot2 <- fviz_cluster(kmeans3, geom = "point", data = df)
plot3 <- fviz_cluster(kmeans4, geom = "point", data = df)
plot4 <- fviz_cluster(kmeans5, geom = "point", data = df)
grid.arrange(plot1, plot2, plot3, plot4, nrow=2)

plot1


