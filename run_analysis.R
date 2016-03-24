##################################################################
# 0. Prepare the environment.
##################################################################

# Set the Working directory
#setwd("~/Coursera/Data Scientist/Getting and Cleaning Data/week4/getting-cleaning-data-week4-project")

# Load relevant Packages
#install.packages("readr")
#install.packages("dplyr")
#install.packages("data.table")
#library(data.table)
#library(readr)
#library(dplyr)

# Load raw data
input_activity_labels<-read_table("activity_labels.txt", col_names = FALSE)
input_features<-read.table("features.txt", colClasses = c("character"))
input_X_test <-read_table("./test/X_test.txt",col_names = FALSE)
input_y_test <-read_table("./test/Y_test.txt",col_names = FALSE)
input_subject_test <-read_table("./test/subject_test.txt",col_names = FALSE)
input_X_train <-read_table("./train/X_train.txt",col_names = FALSE)
input_Y_train <-read_table("./train/Y_train.txt",col_names = FALSE)
input_subject_train <-read_table("./train/subject_train.txt",col_names = FALSE)

# Define the tables
tbl_subject_train <- tbl_df(input_subject_train)
tbl_y_train <- tbl_df(input_Y_train)
tbl_x_train <- tbl_df(input_X_train)
tbl_subject_test <- tbl_df(input_subject_test)
tbl_x_test <- tbl_df(input_X_test)
tbl_y_test <- tbl_df(input_y_test)
tbl_features <- tbl_df(input_features)
tbl_activity_labels <- tbl_df(input_activity_labels)

##################################################################
# 1. Merge the training and the test sets and generate one data set.
##################################################################


tbl_training_sensor<-tbl_x_train %>%
  bind_cols(tbl_subject_train)%>%
  bind_cols(tbl_y_train)
tbl_testing_sensor<-tbl_x_test %>%
  bind_cols(tbl_subject_test)%>%
  bind_cols(tbl_y_test)
tbl_sensor_data <-rbind(tbl_training_sensor, tbl_testing_sensor)

# Provide column names to senor data table
sensor_labels <- tbl_features%>% rbind( c(562, "Subject"))%>% rbind(c(563, "Activity_Id"))
names(tbl_sensor_data) <-sensor_labels$V2
names(tbl_activity_labels) <-c(X1="Activity_Id", X2="Activity_Description")

############################################################################################
# 2. Do extract only the mean and standard deviation for each measurement of all observations
############################################################################################

tbl_sensor_data_mean_std <-tbl_sensor_data[,grepl("mean|std|Subject|Activity_Id", names(tbl_sensor_data))]

###########################################################################
# 3. Apply descriptive activity names to name the activities in the data set
###########################################################################

tbl_sensor_data_mean_std <-left_join( tbl_sensor_data_mean_std, tbl_activity_labels, by = "Activity_Id")
# Documentation
org_names <- names(tbl_sensor_data_mean_std)
##############################################################
# 4. Perform appropriate Labelling using descriptive names.
##############################################################
# "Acc" to be replaced with "Accelerometer"
names(tbl_sensor_data_mean_std)<-gsub("Acc", "_Accelerometer", names(tbl_sensor_data_mean_std))
# "Gyro" to be replaced with "Gyroscope" 
names(tbl_sensor_data_mean_std)<-gsub("Gyro", "_Gyroscope", names(tbl_sensor_data_mean_std))
# "-mean()" to be replaced with "Mean" 
names(tbl_sensor_data_mean_std) <-gsub( "-mean()", "_Mean", names(tbl_sensor_data_mean_std), ignore.case= TRUE)
# "-std()" to be replaced with "StandardDeviation" 
names(tbl_sensor_data_mean_std)<-gsub("-std()", "_Standard_Deviation", names(tbl_sensor_data_mean_std), ignore.case = TRUE)
# "BodyBody" to be replaced with " Body"
names(tbl_sensor_data_mean_std)<-gsub("BodyBody", "Body", names(tbl_sensor_data_mean_std))
# "angle" to be replaced with "Angle"
names(tbl_sensor_data_mean_std)<-gsub("angle", "Angle", names(tbl_sensor_data_mean_std))
# "gravity" to be replaced with " Gravity"
names(tbl_sensor_data_mean_std)<-gsub("gravity", "_Gravity", names(tbl_sensor_data_mean_std))
# "tBody" to be replaced with " TimeBody"
names(tbl_sensor_data_mean_std)<-gsub("tBody", "Time_Body_", names(tbl_sensor_data_mean_std))
names(tbl_sensor_data_mean_std)<-gsub("Time_Body__", "Time_Body_", names(tbl_sensor_data_mean_std))
names(tbl_sensor_data_mean_std)<-gsub("TimeGravity", "Time_Gravity_", names(tbl_sensor_data_mean_std))
# "^f" to be replaced with " Frequency"
names(tbl_sensor_data_mean_std)<-gsub("^f", "Frequency", names(tbl_sensor_data_mean_std))
# "^t" to be replaced with " Time"
names(tbl_sensor_data_mean_std)<-gsub("^t", "Time", names(tbl_sensor_data_mean_std)) 
# "-freq()" to be replaced with " Frequency"
names(tbl_sensor_data_mean_std)<-gsub("-freq()", "_Frequency", names(tbl_sensor_data_mean_std))
names(tbl_sensor_data_mean_std)<-gsub("-_MeanFreq", "_Mean_Frequency", names(tbl_sensor_data_mean_std))
names(tbl_sensor_data_mean_std)<-gsub("_MeanFreq", "_Mean_Frequency", names(tbl_sensor_data_mean_std))
# "FrequencyBody" to be replaced with "Frequency Body"
names(tbl_sensor_data_mean_std)<-gsub("FrequencyBody", "Frequency_Body", names(tbl_sensor_data_mean_std)) 
# "Mag"  to be replaced with  "Magnitude"
names(tbl_sensor_data_mean_std)<-gsub("Mag", "_Magnitude", names(tbl_sensor_data_mean_std))
names(tbl_sensor_data_mean_std)<-gsub("Jerk", "_Jerk", names(tbl_sensor_data_mean_std))
# Remove Special Characters
names(tbl_sensor_data_mean_std)<-gsub("-", "_", names(tbl_sensor_data_mean_std))
names(tbl_sensor_data_mean_std)<-gsub("\\(", "", names(tbl_sensor_data_mean_std))
names(tbl_sensor_data_mean_std)<-gsub("\\)", "", names(tbl_sensor_data_mean_std))
# Documentation
new_names <- names(tbl_sensor_data_mean_std)

######################################################################################################################
# 5. Generate  a new tidy data set with the average of each variable for each activity and each subject.
######################################################################################################################
#Remove redundant data not meeting Codd's 3rd normal form (Codd 1990)
tbl_sensor_data_mean_std_2<-select(tbl_sensor_data_mean_std, -contains("Description"))
#Provide tempory table
x <- 1:79
x<-as.character(x)
names(tbl_sensor_data_mean_std_2)<- c(x,"subject", "activity")
tbl_sensor_data_mean_std_avg <-tbl_sensor_data_mean_std_2 %>% group_by("subject","activity") %>% summarise_each(funs(mean), 1:79)
tmp_names <- c(new_names[80:81],new_names[1:79])
names(tbl_sensor_data_mean_std_avg) <- c(tmp_names)
#Provide tidy result file
write.table(tbl_sensor_data_mean_std_avg, file="sensor_data_avg_grpd.txt")
