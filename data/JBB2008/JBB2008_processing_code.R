### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Jessup, R., Bishara, A., & Busemeyer, J. (2008) Feedback Produces Divergence From Prospect Theory in Descriptive Choice

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "JBB2008"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Two problems (high prob cond and low prob cond)
# These two problems are run in two different feedback conditions
option <- c("A", "B", "C", "D")
out_1 <- c(3, 3.75, 3, 60)
pr_1 <- c(1, 0.16, 1, 0.01)
out_2 <- c(NA, 3.9, NA, 61.4)
pr_2 <- c(NA, 0.16, NA, 0.01)
out_3 <- c(NA, 4, NA, 64)
pr_3 <- c(NA, 0.16, NA, 0.01)
out_4 <- c(NA, 4.1, NA, 65.6)
pr_4 <- c(NA, 0.16, NA, 0.01)
out_5 <- c(NA, 4.25, NA, 68)
pr_5 <- c(NA, 0.16, NA, 0.01)
out_6 <- c(NA, 0, NA, 0)
pr_6 <- c(NA, 0.2, NA, 0.95)

options_table <- data.frame(option, out_1, pr_1, out_2, pr_2, out_3, pr_3, out_4, pr_4,  out_5, pr_5, out_6, pr_6)

# Save options sheet
file_name <- paste0(paper, "_", "1", "_", "options.csv")
setwd(data_path)
write.table(options_table, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

### Process dataset

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path")))
# Working directory is in processed/options at this point, so go back to raw_data
setwd(raw_path)
study <- 1
# Read the MATLAB matrix containing the data
if (!requireNamespace("R.matlab", quietly = TRUE)) install.packages("R.matlab")
library(R.matlab)
file_name <- "x.mat"
dataset <- as.data.frame(readMat(file_name)) # Data already sorted by subject number, trial
# Add column labels to dataset (see the More info file)
colnames(dataset) <- c("subject","cb_group", "trial", "block", "sure_choice",
                       "cumulative_earnings", "feedback", "high_prob_cond", "stimulus_seen", "win_amount",
                       "won", "ten_block")
# Read the files containing gender and age information
setwd("Demographic Data/")
file_list <- list.files()
demg_list <- lapply(file_list,
                    FUN = function(files)
                    {read.table(files, header = FALSE, fill = TRUE)})
# Extract subjet, gender, and age data
subject_raw <- unlist(lapply(demg_list, FUN = function (dem) as.character(dem[which(dem$V1 == "Subject:")[1], 2])))
subject_raw <- as.numeric(subject_raw)
# Subjects # Verified (unique(dataset$subject) = subject_raw)
gender_raw <- unlist(lapply(demg_list, FUN = function (dem) as.character(dem[which(dem$V1 == "Gender.RESP:"), 2])))
gender_raw <- c(rep(NA, 3), gender_raw) # The 3 first subjects in dataset have no age or gender data
age_raw <- unlist(lapply(demg_list, FUN = function (dem) as.character(dem[which(dem$V1 == "Age.RESP:"), 2])))
age_raw <- as.numeric(age_raw)
age_raw <- c(rep(NA, 3), age_raw)
# Finished extracting available demographic data
# Continue processing the dataset
dataset[is.na(dataset)] <- NA # Replace all occurrences of NaN with NA
num_trials <- 120 # Verified - For each of the two conditions/problems
# Create new consecutive subject IDs
subject_unq <- seq(1, length(unique(dataset$subject)), by = 1)
subject <- rep(subject_unq, each = num_trials*2)
dataset$subject <- subject
# Age and sex
age <- rep(age_raw, each = prod(num_trials, 2))
sex <- rep(gender_raw, each = prod(num_trials, 2))
# Options
option <- c("A", "B", "C", "D")
choice_pairs <- matrix (option, ncol = 2, byrow = TRUE)
options_v <- apply(choice_pairs, 1, function (r) paste(r, collapse = '_'))
# Map problems, stages, choices, and payoffs
# Note: P1 is the high-probability condition, and P2 is the low-probability condition
problem <- ifelse(dataset$high_prob_cond == 1, 1, 2)
options <- ifelse(dataset$high_prob_cond == 1, options_v[1], options_v[2])
# The rewards varied only slightly around the values in the options sheet
# The "stimulus seen" variable codes the indices of the risky rewards here (from More info)
hp_risky_rewards <- c(4, 4.25, 3.75, 4, 4.1, 3.9) # Replace options sheet with these?
lp_risky_rewards <- c(64, 68, 60, 64, 65.6, 62.4)
# Map choices to option letters
choice <- ifelse(dataset$high_prob_cond == 1, ifelse(dataset$sure_choice == 1, choice_pairs[1,1], choice_pairs[1,2]),
                              ifelse(dataset$sure_choice == 1, choice_pairs[2,1], choice_pairs[2,2]))
# Map feedback to outcomes
feedback <- dataset$feedback
# No feedback = condition 1, with feedback = condition 2
condition <- ifelse(dataset$feedback == 0, 1, 2)
note1 <- ifelse(dataset$feedback == 0, "No feedback condition", "Feedback condition")
win_amount <- dataset$win_amount
# For feedback trials, create an outcome, and for non-feedback trials create empty strings
outcome <- sapply(1:length(choice), function (x)
  ifelse(feedback[x] == 1, paste(choice[x], win_amount[x], sep = ":"), choice[x]))
# Add new variables to data set
response_time <- stage <- education <- note2 <- NA
dataset <- cbind(dataset, paper, study, problem, condition, options, choice, outcome, response_time, stage, sex, age, education, note1, note2)
# Re-arrange data set variables
# Required order of variables: paper, study, subject, problem, options, trial, choice, outcome
dataset_processed <- dataset[, c("paper", "study", "subject", "problem", "condition", "options", "trial", "choice", "outcome", "response_time", "stage", "sex", "age", "education", "note1", "note2")]
# Some outcomes are NANA because of NAs that got concatenated, change to NA
dataset_processed[dataset_processed == "NA:NA"] <- NA
# Sort by subject, problem, trial
ds_final <- dataset_processed [order(dataset_processed$subject, dataset_processed$problem, dataset_processed$trial), ]

# Save processed data
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
