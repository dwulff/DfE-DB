# Jessup, R., Busemeyer, J., & Brown, J. (2010) Error Effects in Anterior Cingulate Cortex Reverse when Error Likelihood Is High

# Note: Same experimental design as in JBB2008, but here each participant goes through both problem
# with and without feedback (60 trials each). But basically there are two problems only, the
# high-probability condition and the low-probability condition.

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "JBB2010"
study <- 1
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# High probability and low probability conditions/with feedback, without feedback/problems in that order
option <- c("A", "B", "C", "D", "E", "F", "G", "H")
out_1 <- c(3, 3.75, 3, 60, 3, 3.75, 3, 60)
pr_1 <- c(1, 0.16, 1, 0.01, 1, 0.16, 1, 0.01)
out_2 <- c(NA, 3.9, NA, 61.4, NA, 3.9, NA, 61.4)
pr_2 <- c(NA, 0.16, NA, 0.01, NA, 0.16, NA, 0.01)
out_3 <- c(NA, 4, NA, 64, NA, 4, NA, 64)
pr_3 <- c(NA, 0.16, NA, 0.01, NA, 0.16, NA, 0.01)
out_4 <- c(NA, 4.1, NA, 65.6, NA, 4.1, NA, 65.6)
pr_4 <- c(NA, 0.16, NA, 0.01, NA, 0.16, NA, 0.01)
out_5 <- c(NA, 4.25, NA, 68, NA, 4.25, NA, 68)
pr_5 <- c(NA, 0.16, NA, 0.01, NA, 0.16, NA, 0.01)
out_6 <- c(NA, 0, NA, 0, NA, 0, NA, 0)
pr_6 <- c(NA, 0.2, NA, 0.95, NA, 0.2, NA, 0.95)

options_table <- data.frame(option, out_1, pr_1, out_2, pr_2, out_3, pr_3, out_4, pr_4,  out_5, pr_5, out_6, pr_6)

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

### Process dataset

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper", "study","data_path","raw_path")))
# Working directory is in processed/options at this point, so go back to raw_data
setwd(raw_path)
# Read the MATLAB matrix containing the data
if (!requireNamespace("R.matlab", quietly = TRUE)) install.packages("R.matlab")
library(R.matlab)
dataset_raw <- as.data.frame(readMat("fMRI_beh_data.mat"))
# Dataset looks like two big matrices placed side by side, the first has values corresponding to the
# column numbers in the second (so pretty much redundant information). So reduce/clean for clarity.
dataset <- dataset_raw [, c("x.1", "x.8", "x.12", "x.14", "x.16", "x.20", "x.19", "x.22", "x.13")] # Data
# Change column labels
colnames(dataset) <- c("subject","feedback", "high_prob_cond", "trial", "response_time", "sure_choice",
                       "won", "win_amount", "stimulus_seen")
# Read the files containing gender and age information
setwd("fMRI Demographics/")
file_list <- list.files()
demg_list <- lapply(file_list,
                    FUN = function(files)
                    {read.table(files, header = FALSE, fill = TRUE)})
# Extract subject, gender, and age data
subject_raw <- unlist(lapply(demg_list, FUN = function (dem) as.character(dem[which(dem$V1 == "Subject:")[1], 2])))
subject_raw <- as.numeric(subject_raw) # Subject 30 that has been excluded from analysis is also removed here
# Subjects # Verified (unique(dataset$subject) = subject_raw)
gender_raw <- unlist(lapply(demg_list, FUN = function (dem) as.character(dem[which(dem$V1 == "Gender.RESP:"), 2])))
age_raw <- unlist(lapply(demg_list, FUN = function (dem) as.character(dem[which(dem$V1 == "Age.RESP:"), 2])))
age_raw <- as.numeric(age_raw)
# Finished extracting available demographic data
# Continue processing the dataset
dataset[is.na(dataset)] <- NA # Replace all NaN (missed responses) with NA 
# Sort dataset by subject, problem, trial
dataset <- dataset [order(dataset$subject, dataset$high_prob_cond), ]
num_trials <- 120 # Verified - For each of the two conditions/problems (60 trials for each of the feedback/no feedback blocks, but that's within the same problem)
dataset$trial <- 1:num_trials # Replace the two blocks of 1-60 trials for each problem
# Create new consecutive subject IDs
subject_unq <- seq(1, length(unique(dataset$subject)), by = 1)
subject <- rep(subject_unq, each = num_trials*2)
dataset$subject <- subject # Replace subject IDSs
# Age and sex
age <- rep(age_raw, each = prod(num_trials, 2))
sex <- rep(gender_raw, each = prod(num_trials, 2))
# Options
option <- c("A", "B", "C", "D", "E", "F", "G", "H")
choice_pairs <- matrix (option, ncol = 2, byrow = TRUE)
options_v <- apply(choice_pairs, 1, function (r) paste(r, collapse = '_'))
# Map problems, stages, choices, and payoffs
# Note: P1 is the high-probability condition, and P2 is the low-probability condition
problem <- ifelse(dataset$high_prob_cond == 1, ifelse(dataset$feedback == 0, 3, 1), ifelse(dataset$feedback == 0, 4, 2))
options <- options_v[problem]
# As in JBB2008 the rewards varied only slightly around the values in the options sheet
# The "stimulus seen" variable codes the indices of the risky rewards here (from More info)
hp_risky_rewards <- c(4, 4.25, 3.75, 4, 4.1, 3.9)
lp_risky_rewards <- c(64, 68, 60, 64, 65.6, 62.4)
# Map choices to option letters
choice <- ifelse(dataset$sure_choice == 1, choice_pairs[problem,1], choice_pairs[problem,2])
# Map feedback to outcomes
feedback <- dataset$feedback
condition <- ifelse(dataset$feedback == 0, 1, 2)
note1 <- ifelse(dataset$feedback == 0, "No feedback condition", "Feedback condition")
win_amount <- dataset$win_amount
# For feedback trials, create an outcome, and for non-feedback trials create empty strings
outcome <- sapply(1:length(choice), function (x)
  ifelse(feedback[x] == 1, paste(choice[x], win_amount[x], sep = ":"), choice[x]))
# Add new variables to data set
stage <- education <- note2 <- NA
dataset <- cbind(dataset, paper, study, problem, condition, options, choice, outcome, stage, sex, age, education, note1, note2)
# Required order of variables
dataset_processed <- dataset[, c("paper", "study", "subject", "problem", "condition", "options", "trial", "choice", "outcome", "response_time", "stage", "sex", "age", "education", "note1", "note2")]
# Some outcomes are NANA because of NAs that got concatenated, change to NA
dataset_processed[dataset_processed == "NA:NA"] <- NA
# Sort by subject, problem, trial
ds_final <- dataset_processed [order(dataset_processed$subject, dataset_processed$problem, dataset_processed$trial), ]

# Save processed data
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
