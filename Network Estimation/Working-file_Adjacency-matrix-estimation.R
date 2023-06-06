# Human personality network 
## Load data
setwd("C:/Users/483405/OneDrive - MUNI/Network Science Project")
library(naniar)
complete.data <- read.csv("Network Estimation/completeRawData.csv")
str(complete.data)
sample.data <- complete.data 

prop_complete(complete.data)


corMatrix <- cor(sample.data,use = "pairwise.complete.obs")
covMatrix <- cov(sample.data,use="pairwise.complete.obs")

colSums(is.na(covMatrix))
covMatrix[is.na(covMatrix)] <- 0

pcorMatrix <- corpcor::cor2pcor(covMatrix)

colSums(is.nan(pcorMatrix))
colSums(pcorMatrix > 1)
pcorMatrix[is.nan(pcorMatrix)] <- 0

write.csv(corMatrix,"cormatrix.csv")
write.csv(pcorMatrix,"pcormatrix.csv")

## For now take a subset of the data 
library(dplyr)

sample.data <- complete.data %>% sample_n(1000000)

## Try to estimate a network using bootnet
library(bootnet)
network <- estimateNetwork(sample.data[1:40],default="ggmModSelect",corMethod="cor_auto",missing="fiml",verbose=TRUE,nCores=3,stepwise=FALSE)
plot(network)

## We do the same for fictional characters ratings
gc()
complete.data <- read.csv("characters-aggregated-scores.csv",sep="\t")
colnames(complete.data) <- c("ID",1:401)
str(complete.data)
sample.data <- complete.data[2:402]

corMatrix <- cor(sample.data,use = "pairwise.complete.obs")
covMatrix <- cov(sample.data,use="pairwise.complete.obs")
pcorMatrix <- corpcor::cor2pcor(covMatrix)
write.csv(corMatrix,"cormatrixCharacters.csv")

