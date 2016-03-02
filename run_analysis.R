library(data.table)

# read features.txt and constructs vectors with the indices and names of all
# measures that we are interested in, i.e., the indices of means and standard
# deviations
measures <- scan("features.txt", character(0), sep="\n")
interestingMeasureIndices <- grep("(mean|std)\\(\\)", measures)
interestingMeasureNames <-
    sub("[0-9]* ", "", grep("(mean|std)\\(\\)", measures, value = TRUE))

# read activity names and put them in a vector
activityNames <-
    sub("[0-9]* ", "", scan("activity_labels.txt", character(0), sep="\n"))

# this function loads the subjects, the activities, and the interesting
# features from the files in a directory
# it names the columns appropriately
# it names the activities appropriately
loadMeasurements <- function(dir) {
    mf <- paste(dir, "/X_", dir, ".txt", sep = "")
    sf <- paste(dir, "/subject_", dir, ".txt", sep = "")
    af <- paste(dir, "/y_", dir, ".txt", sep = "")
    m <- fread(mf, sep = " ", header = FALSE,
               select = interestingMeasureIndices,
               col.names = interestingMeasureNames)
    s <- fread(sf, header = FALSE, col.names = "Subject")
    a <- activityNames[ fread(af, header = FALSE, col.names = "Activity")[[1]] ]
    res <- cbind(s, a, m)
    colnames(res)[2] <- "Activity"
    res
}

# merge data sets
allData <- rbind(loadMeasurements("train"), loadMeasurements("test"))

# data set by subject and activity
meansBySubjectActivity <- allData[, lapply(.SD, mean), by=list(Subject, Activity)]