### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Otto et al. (2011) There are at least two kinds of probability matching: Evidence from a secondary task

if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "OTM2011"
study <- 1
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# One problem: predicting a red or green square. In the dual-task condition, subjects had to report
# the count of tones they heard during the last 40 trials. But this does not modify the options, so
# it is still the same problem design. Events: "Red square to appear above the fixation cross" or "Green square to appear below the fixation cross"

# Let A be the high probability event
option <- c("A", "B")
out_1 <- c(1, 1)
pr_1 <- c(0.65, 0.35)
out_2 <- c(0, 0)
pr_2 <- c(0.35, 0.65)
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)

#description <- c("Red square to appear above the fixation cross", "Green square to appear below the fixation cross")
#options_table <- data.frame(option, description)
# Save options sheet
file_name <- paste0(paper, "_", study, "_", "options.csv")
setwd(data_path)
write.table(options_table, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

##### Process data
# Back to raw data directory
rm(list=setdiff(ls(), c("path", "paper", "study","raw_path","data_path")))
setwd(raw_path)
file_data <- "all.csv"
ds <- read.csv(file_data, header = TRUE, stringsAsFactors = FALSE) # Comma-separated values
# Only the data of 123 subjects were analyzed in the paper but here all are listed
ds <- ds[complete.cases(ds), ] # Remove NA rows
subjects_count <- rle(sort(ds$ubj)) # frequencies
subject <- rep(subjects_count$values, subjects_count$lengths)
problem <- 1
options <- "A_B"
response_time <- round(ds$rt)
response_time[response_time == -1] <- NA
choice_raw <- ds$resp
# Code non-response trials as NA so that they remain NA during other transformations
choice_raw[choice_raw == -1] <- NA
choice <- ifelse(choice_raw == 1, "A", "B") # Assuming 1 codes the optimal choice
result <- ds$hit
result[result == -1] <- NA
outcome <- paste(choice, result, sep = ":")
outcome[outcome == "NA:NA"] <- NA
colnames(ds)[which(names(ds) == "trial_num")] <- "trial"
stage <- sex <- age <- education <- note1 <- note2 <- condition <- NA
# Create final dataframe
ds_processed <- cbind(ds, paper, study, subject, problem, condition, options, choice, outcome, response_time, stage, sex, age, education, note1, note2)
# Required order of variables
ds_final <- ds_processed[, c("paper", "study", "subject", "problem", "condition", "options", "trial", "choice", "outcome", "response_time", "stage", "sex", "age", "education", "note1", "note2")]

# Save processed data
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
