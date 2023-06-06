library(readr)
library(dplyr)
library(foreach)
library(doParallel)
# setwd("C:/Users/483405/OneDrive - MUNI/Network Science Project")
# setwd("~/Library/CloudStorage/OneDrive-MUNI/Network Science Project")

# Read in the file
raw.data <- data.table::fread(file="features-survey-dataset.csv")

## Parse the list of lists columns quiz_items and save the result as interimData/quiz_items.RDS ----
sample.data <- NULL
sample.data$quiz_items <- raw.data$quiz_items
raw.data <- NULL # get rid of the rest of the dataset. 
## clean data

sample.data$quiz_items <- gsub("\\[\\[u", "\\[\\[",sample.data$quiz_items)
sample.data$quiz_items <- gsub("'", "",sample.data$quiz_items)

# Parse list of lists as JSON
sample.data$quiz_items <- lapply(sample.data$quiz_items, jsonlite::fromJSON)

saveRDS(sample.data,file = "interimData/quiz_items.RDS")

##obtain the name of columns (400 item IDs), response values and their question IDs -------
sample.data <- readRDS("interimData/quiz_items.RDS")

## Get column names and values from quiz items
sample.data <- NULL
quizColNamesList <- sapply(sample.data$quiz_items, function(x) x[,2]) # this is the list of column names within variables
quizValues <- sapply(sample.data$quiz_items, function(y) y[,3])       # this is the list of values - which need to be positioned according to corresponding colum names 

quizColNames <- sort(unique( # Get unique values of column names
  unlist( # Unlist the list of lists
    quizColNamesList)
  ))

saveRDS(quizColNames,file="interimData/quizColNames.RDS") # column names (range 1:400)
saveRDS(quizValues,file="interimData/quizValues.RDS") # self-report responses
saveRDS(quizColNamesList,file="interimData/quizColNamesList.RDS") # IDs of questions each respondent was asked


### Compile the individual responses into a single 400 by n data matrix ------
quizColNames <- readRDS("interimData/quizColNames.RDS")
quizColNamesList <- readRDS("interimData/quizColNamesList.RDS")
quizValues <- readRDS("interimData/quizValues.RDS")

dataframe  <- data.frame(matrix(ncol=length(quizColNames),nrow=1))
colnames(dataframe) <- quizColNames

# This will take about 10 hours (or at least it took 10 hours for me)
for (x in -1:32) {
  timestamp()
  print(paste0("Starting run ",x))
  # Set the number of cores to utilize
  registerDoParallel(cores = 2)

  i = 100001:200000
  i = i+(100000*x)
  
  output <- foreach(values = iter(quizValues[i]), col_indices = iter(quizColNamesList[i]),
                    .verbose = FALSE,.combine = "rbind",.errorhandling = "remove") %dopar% {
                      #values <- quizValues[[i]]  # Rating values for current list
                      #col_indices <- quizColNamesList[[i]]  # Column indices for current list
                      dataframe[1, as.character(col_indices)] <- values
                      dataframe[1,]
                    }
  
  print(paste0("Finished run number ",x," Saving now..."))
  saveRDS(output,paste0("interimData/toSaveN",x,".RDS"))
  print(paste0("Saved successfully at ",paste0("toSaveN",x,".RDS")))
  output <- NULL
  gc()
  stopImplicitCluster()
}

complete <- NULL

## combine the partial datasets into one. 
for (index in -1:32) {
  current <- readRDS(paste0("interimData/toSaveN",index,".RDS"))
  complete <- rbind(complete,current)
  print(index)
}
write.csv(complete,"completeRawData.csv")


## now we are ready to estimate networks on the item level data.

# compute personality networks of item correlations ----

# Self-report real personality network 
## Load data
complete.data <- read.csv("completeRawData.csv")
str(complete.data)
sample.data <- complete.data 

corMatrix <- cor(sample.data,use = "pairwise.complete.obs")
write.csv(corMatrix,"../cormatrix.csv")

## Split the data into two samples and compute networks for the two samples
sample_size = floor(0.5*nrow(complete.data))
set.seed(777)

# compute personality networks of 2 subsamples of personality data

# randomly split data
picked = sample(seq_len(nrow(complete.data)),size = sample_size)
development =complete.data[picked,]
holdout =complete.data[-picked,]

development <- development[,-1]
holdout <- holdout[,-1]
colnames(development) <- 1:400
colnames(holdout) <- 1:400

corMatrix1 <- cor(development,use = "pairwise.complete.obs")
corMatrix2 <- cor(holdout,use = "pairwise.complete.obs")
write.csv(corMatrix1,"../subset1CorMatrix.csv")
write.csv(corMatrix2,"../subset2CorMatrix.csv")

## We do the same for fictional characters ratings
gc()
complete.data <- read.csv("characters-aggregated-scores.csv",sep="\t")
colnames(complete.data) <- c("ID",1:401)
str(complete.data)
sample.data <- complete.data[2:402]

corMatrix <- cor(sample.data,use = "pairwise.complete.obs")
write.csv(corMatrix,"../cormatrixCharacters.csv")

