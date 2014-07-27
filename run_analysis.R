library(reshape2)
library(stringr)

## variables holding the filenames
test_x  <- "./UCI HAR Dataset/test/X_test.txt"
test_y  <- "./UCI HAR Dataset/test/y_test.txt"
test_subj <- "./UCI HAR Dataset/test/subject_test.txt"

train_x <- "./UCI HAR Dataset/train/X_train.txt"
train_y <- "./UCI HAR Dataset/train/y_train.txt"
train_subj <- "./UCI HAR Dataset/train/subject_train.txt"

featuresfile  <- "./UCI HAR Dataset/features.txt"


## read features and filter out mean and std variables
features <- read.table(featuresfile)
keep     <- grepl("mean\\(\\)|std\\(\\)", features$V2)
features <- features[keep,2]
# here comes a mean trick: this classes vector can be used for reading a table
# when NULL, the column will be skipped, speeding up the parsing time
classes <- sapply(keep, function(x) if (x) c("numeric") else NULL)

## read test data and connect it with activities and subjects
test <- read.table(test_x, colClasses = classes)
names(test) <- features
act  <- read.table(test_y, col.names = "activity")
subj <- read.table(test_subj, col.names = "subject")
test <- cbind(test, act, subj)

## read training data and connect it with activities and subjects
train <- read.table(train_x, colClasses = classes)
names(train) <- features
act   <- read.table(train_y, col.names = "activity")
subj  <- read.table(train_subj, col.names = "subject")
train <- cbind(train, act, subj)

## join test data and training data, melt the whole thing and re-cast it
## using subject and activity as IDs and the mean function to aggregate
uci <- rbind(test, train)
melted <- melt(uci,(id.vars=c("activity","subject")))
tidied <- dcast(melted, subject + activity ~ variable, mean)

# use factors for giving descriptive activity names
tidied$activity <- as.factor(tidied$activity)
levels(tidied$activity) <- c("Walking",
                             "Walking upstairs",
                             "Walking downstairs",
                             "Sitting",
                             "Standing",
                             "Laying")

## write tidied data to "tidied.csv"
write.csv(tidied, "tidied.csv")
