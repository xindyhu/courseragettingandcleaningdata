#purpose of this script is to 
#1. Merges the training and the test sets to create one data set.
#2. Extracts only the measurements on the mean and standard deviation for each measurement.
#3. Uses descriptive activity names to name the activities in the data set
#4. Appropriately labels the data set with descriptive variable names.
#5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

library(dplyr)

#read in training and testing
Xtrain<-read.table('../UCI HAR Dataset/train/X_train.txt',header=FALSE,stringsAsFactors = FALSE)
Ytrain<-read.table('../UCI HAR Dataset/train/Y_train.txt',header=FALSE,stringsAsFactors = FALSE)
subtrain<-read.table('../UCI HAR Dataset/train/subject_train.txt',header=FALSE,stringsAsFactors = FALSE)
Xtest<-read.table('../UCI HAR Dataset/test/X_test.txt',header=FALSE,stringsAsFactors = FALSE)
Ytest<-read.table('../UCI HAR Dataset/test/Y_test.txt',header=FALSE,stringsAsFactors = FALSE)
subtest<-read.table('../UCI HAR Dataset/test/subject_test.txt',header=FALSE,stringsAsFactors = FALSE)
#merge datasets together
master<-rbind(cbind(subtrain,Xtrain, Ytrain),cbind(subtest,Xtest,Ytest))

#add names to master
colnames(master)[1]<-'subjectID'
names<-read.table('../UCI HAR Dataset/features.txt',header=FALSE,stringsAsFactors = FALSE)[,2]
colnames(master)[2:562]<-names
colnames(master)[563]<-'activity'

#extract only the measurements on the mean and standard deviation for each measurement
extract_indices<-c(grep('mean()',colnames(master)),grep('std()',colnames(master)))
extract_df<-subset(master,select = extract_indices)
extract_df$activity<-master$activity
extract_df$subjectID<-master$subjectID

#add activity labels
activity_label<-read.table('../UCI HAR Dataset/activity_labels.txt',header=FALSE,stringsAsFactors = FALSE)
extract_df2<-left_join(extract_df,activity_label,by=c('activity'='V1'))
table(extract_df2$V2)
table(extract_df$activity)

#change 'V2' to 'activity_desc'
colnames(extract_df2)[colnames(extract_df2)=='V2']<-'activity_desc'
#drop number activity
extract_df2$activity<-NULL
#create a second, independent tidy data set with the average of each variable for each activity and each subject
tidy_data<-aggregate(.~activity_desc+subjectID, extract_df2, mean)
write.table(tidy_data,'tidy_data.txt', row.names = FALSE)
