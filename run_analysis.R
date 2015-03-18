# read in the needed files
test_s <- read.table("test/subject_test.txt")
test_y <- read.table("test/y_test.txt")
test_x <- read.table("test/X_test.txt")
train_s <- read.table("train/subject_train.txt")
train_y <- read.table("train/y_train.txt")
train_x <- read.table("train/X_train.txt")
features_labels <- read.table("features.txt")
act_labels <- read.table("activity_labels.txt")

# append description variables to the activities variables
# I purposefully chose to supplement the data, instead of replacing the
# numeric values
for (i in 1:dim(test_y)[1]) {
    j <- test_y[i,1]
    test_y[i,2] <- act_labels[j,2]
}
for (i in 1:dim(train_y)[1]) {
    j <- train_y[i,1]
    train_y[i,2] <- act_labels[j,2]
}

# name the variables
names(test_s) <- names(train_s) <- "subject"
names(test_y) <- names(train_y) <- c("activity_code","activity_desc")
names(test_x) <- names(train_x) <- features_labels[,2]

# combine data horizontally (columns)
testdata <- cbind(test_s, test_y, test_x)
traindata <- cbind(train_s, train_y, train_x)

# combine data vertically (rows)
alldata <- rbind(testdata, traindata)
alldata$subject <- as.factor(alldata$subject)
alldata$activity_code <- as.factor(alldata$activity_code)

# subset to required columns
# to be complete, I included all variables with "mean" even though the
# mean frequency measures may not be needed
meancols <- grep(".*mean", names(alldata))
stdcols <- grep(".*std", names(alldata))
neededcols <- sort(c(1:3,meancols,stdcols))
subdata <- alldata[,neededcols]

# create aggregated data frame
attach(subdata)
aggdata <- aggregate(subdata, by=list(subject, activity_code, activity_desc),
                     FUN=mean)
detach(subdata)

# remove excess columns and fix names
aggdata <- aggdata[,c(1:3,7:85)]
names(aggdata)[1:3] <- c("subject", "activity_code", "activity_desc")

# output results
write.table(aggdata, file="tidy_data.txt", row.names=FALSE)
