##This RScript should run on any system with base R installed and internet access.
##It will download and unzip the original data set and create a tidy dataset as
##described in the README.txt and codebox.txt found with this script.
##To customize it for your own use, modify the data_path to the location in which
##you would like the data stored. It will create a /data folder in that location 
##if it does not already exist and download and extract the research data to the
##/data folder. If you prefer to download and/or unzip manually, you may either
##comment out the relevent lines of code or ensure that your /data directory 
##includes both a zip file named "UCI_HAR_Dataset.zip" and a subdirectory
##/UCI HAR Dataset with the unzipped files as zip creates them.



##specify directories
initial_dir <- getwd()
data_path <- "C:/Users/Liz/Desktop/test" #choose where you want the data 
setwd(data_path)

##create if not present directory structure and download and unzip data if not present
if(!file.exists("./data")) {dir.create("data")}
if(!file.exists("./data/UCI_HAR_Dataset.zip")){
    download.file(url =
    "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
    destfile = "./data/UCI_HAR_Dataset.zip")}
unzip("./data/UCI_HAR_Dataset.zip", exdir="./data" )
data_path <- paste(data_path,"data/UCI HAR Dataset",sep="/")
setwd(data_path)

##create a vector identifying which columns to keep
cols <- read.table("./features.txt", sep = " ")
keep_cols<- grep("mean\\(|std", cols[ ,2]) 
col_names <- cols[ ,2]

##create a vector containing key-value pairs for recoding activity data
act_labels_filename <- "./activity_labels.txt"
temp <- read.table(act_labels_filename, col.names = c("key","value"),
        colClasses = c("character"))
temp$value <- tolower(temp$value)
temp$value <- gsub( "_", " ", temp$value)

##create a vector of tidy variable names  
tidy_varnames <- c("Activity", "Subject", "MeanTimeBodyAccelerationXaxis", 
"MeanTimeBodyAccelerationYaxis", "MeanTimeBodyAccelerationZaxis", 
"StDevTimeBodyAccelerationXaxis", "StDevTimeBodyAccelerationYaxis", 
"StDevTimeBodyAccelerationZaxis", "MeanTimeGravityAccelerationXaxis", 
"MeanTimeGravityAccelerationYaxis", "MeanTimeGravityAccelerationZaxis", 
"StDevTimeGravityAccelerationXaxis", "StDevTimeGravityAccelerationYaxis", 
"StDevTimeGravityAccelerationZaxis", "MeanTimeJerkBodyAccelerationXaxis", 
"MeanTimeJerkBodyAccelerationYaxis", "MeanTimeJerkBodyAccelerationZaxis", 
"StDevTimeJerkBodyAccelerationXaxis", "StDevTimeJerkBodyAccelerationYaxis", 
"StDevTimeJerkBodyAccelerationZaxis", "MeanTimeAngularVelocityXaxis", 
"MeanTimeAngularVelocityYaxis", "MeanTimeAngularVelocityZaxis", 
"StDevTimeAngularVelocityXaxis", "StDevTimeAngularrVelocityYaxis", 
"StDevTimeAngularVelocityZaxis", "MeanTimeJerkAngularVelocityXaxis", 
"MeanTimeJerkAngularVelocityYaxis", "MeanTimeJerkAngularVelocityZaxis", 
"StDevTimeJerkAngularVelocityXaxis", "StDevTimeJerkAngularVelocityYaxis", 
"StDevTimeJerkAngularVelocityZaxis", "MeanMagnitudeTimeBodyAcceleration", 
"StDevMagnitudeTimeBodyAcceleration", "MeanMagnitudeTimeGravityAcceleration", 
"StDevMagnitudeTimeGravityAcceleration", "MeanMagnitudeTimeJerkBodyAcceleration", 
"StDevMagnitudeTimeJerkBodyAcceleration", "MeanMagnitudeTimeAngularVelocity", 
"StDevMagnitudeTimeAngularVelocity", "MeanMagnitudeTimeJerkAngularVelocity", 
"StDevMagnitudeTimeJerkAngularVelocity", "MeanFreqBodyAccelerationXaxis", 
"MeanFreqBodyAccelerationYaxis", "MeanFreqBodyAccelerationZaxis", 
"StDevFreqBodyAccelerationXaxis", "StDevFreqBodyAccelerationYaxis", 
"StDevFreqBodyAccelerationZaxis", "MeanFreqJerkBodyAccelerationXaxis", 
"MeanFreqJerkBodyAccelerationYaxis", "MeanFreqJerkBodyAccelerationZaxis", 
"StDevFreqJerkBodyAccelerationXaxis", "StDevFreqJerkBodyAccelerationYaxis", 
"StDevFreqJerkBodyAccelerationZaxis", "MeanFreqAngularVelocityXaxis", 
"MeanFreqAngularVelocityYaxis", "MeanFreqAngularVelocityZaxis", 
"StDevFreqAngularVelocityXaxis", "StDevFreqAngularrVelocityYaxis", 
"StDevFreqAngularVelocityZaxis", "MeanMagnitudeFreqBodyAcceleration", 
"StDevMagnitudeFreqBodyAcceleration", "MeanMagnitudeFreqJerkBodyAcceleration", 
"StDevMagnitudeFreqJerkBodyAcceleration", "MeanMagnitudeFreqAngularVelocity", 
"StDevMagnitudeFreqAngularVelocity", "MeanMagnitudeFreqJerkAngularVelocity", 
"StDevMagnitudeFreqJerkAngularVelocity")

##this function builds a clean dataframe for test or train
cleanset <- function(directory) {
      body_filename <- paste("./", directory, "/X_",directory,".txt", sep="")
      subjects_filename <- paste("./", directory, "/subject_",directory,".txt", 
            sep="")
      activities_filename <- paste("./", directory, "/y_",directory,".txt", 
            sep="")
      ##create a vector containing subject data
      subject <-scan(subjects_filename)
      ## create a vector containing activities data and recode it
      activity <-scan(activities_filename)
      activity  <- ifelse(activity %in% temp$key, temp$value, "NA")
      #read estimated data to dataframe
      summarytable <- read.table(body_filename, header = FALSE,
        colClasses = "numeric",nrows=7400,comment.char = "", col.names=col_names)
      summarytable <- summarytable[ ,keep_cols] #drop columns identified outside cleanset
      summarytable <- cbind(subject,summarytable) #add subject data to dataframe
      summarytable <- cbind(activity,summarytable) #add activity data to dataframe
      colnames(summarytable) <- tidy_varnames
      summarytable
}

##Use above function to assemble wide tidy dataset
test_table <- cleanset("test")
train_table <- cleanset("train")
big_table <- rbind(test_table,train_table)

##Create final dataset and output to a file
aggdata <- aggregate(big_table[ ,3:68], by=list(big_table$Subject, 
           big_table$Activity), FUN=mean, na.rm=TRUE)
colnames(aggdata)[colnames(aggdata) == "Group.1"] <- "Subject"
colnames(aggdata)[colnames(aggdata) == "Group.2"] <- "Activity"
write.table(aggdata, file="tidydata.txt",sep=",",row.names= FALSE) 

setwd(initial_dir)