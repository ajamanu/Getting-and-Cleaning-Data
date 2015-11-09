# run_analysis.R
# R Script for Getting and Cleaning Data Course Project
# Created by Aja Manu 9/11/15

# clear environment and set work directory
rm(list=ls())
setwd("U:/Data/Aja/Coursera/Getting and Cleaning Data/UCI HAR Dataset")

# Load libraries 
library(data.table)
library(dplyr)

# Load Activity Labels
activity_labels <- read.table("activity_labels.txt") # Links the class labels 
                                                     #  with their activity name

# Load Features
features <- read.table("features.txt") # List of all features

# Make variables more user freindly 
features$V2 <- gsub("\\(|\\)", "", features$V2) # remove brackets
features$V2 <- gsub(",", "_", features$V2) # remove commas and replace with _
features$V2 <- gsub("-", "_", features$V2) # remove dash and replace with _

# Load training Data
subject_train <- read.table("./train/subject_train.txt") # Each row identifies 
                                                         #  the subject who 
                                                         #  performed the 
                                                         #  activity for each 
                                                         #  window sample
X_train <- fread("./train/X_train.txt") # Training data. Note: using fread 
                                        #  because it's a large file
y_train <- read.table("./train/y_train.txt") # Training labels

# Load test Data
subject_test <- read.table("./test/subject_test.txt") # Each row identifies 
                                                         #  the subject who 
                                                         #  performed the 
                                                         #  activity for each 
                                                         #  window sample
X_test <- fread("./test/X_test.txt") # Test data. Note: using fread 
                                     #  because it's a large file
y_test <- read.table("./test/y_test.txt") # Test labels

# Change the column names for X_train and X_test dataset to be called features
colnames(X_train) <- as.character(features$V2)
colnames(X_test) <- as.character(features$V2)

# Based on the following link
# http://stackoverflow.com/questions/28549045/dplyr-select-error-found-duplicated-column-name
#  need to make valid column names so that we can subset data down the line
valid_column_names <- make.names(names=names(X_train), unique=TRUE, 
                                 allow_ = TRUE)
names(X_train) <- valid_column_names
names(X_test) <- valid_column_names

# Merge training and testing data
subject_data <- rbind(subject_train, subject_test)
X_data <- rbind(X_train, X_test)
y_data <- rbind(y_train, y_test)

# Merge activity_labes data to the y_train data to give discriptive names to the
#  activities in the data set
y_data1 <- left_join(y_data, activity_labels, by = "V1")
y_data1 <- data.frame(y_data1[,-1]) # drop the numeric variables

# Change the name of subject_train variable to subject
colnames(subject_data) <- "subject"

# Change the names of y_train1 variable to activity
colnames(y_data1) <- "activity"

# Column Bind the subject_train data to the y_train1
data_merged <- cbind(subject_data, y_data1)

# Column bind data_train variable with X_train
data_merged <- cbind(data_merged, X_data)

# Extract only the measurements on the mean and standard deviation for 
#  each measurement
data_merged1 <- select(data_merged, contains("subject"), contains("activity"),
                      contains("mean"), contains("std"))

# find the average for each variable by subject and activity
tidy <- data_merged1 %>%
      group_by(subject, activity) %>%
      summarise_each(funs(mean))

# Check if there are any NAs.
sum(is.na(tidy))

# Write output to working directory
write.table(tidy, file = "tidy.txt", row.name=FALSE)
