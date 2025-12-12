### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Knox et al. (2012) The nature of belief-directed exploratory choice in human decision-making

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "KOSL2012"
study <- 1
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Generate the options sheet

# Three conditions/problems with two options each. A problem is associated with a different P(jump) to increase the option's payoff.
option <- c("A", "B", "C", "D", "E", "F")
description <- c("Payoff is 10 or 20 points when the task starts, and on every trial there is a fixed probability of 0.025 that this option's payoff will increase by 20 points if it is currently smaller than the other option's payoff.",
                 "Payoff is 10 or 20 points when the task starts, and on every trial there is a fixed probability of 0.025 that this option's payoff will increase by 20 points if it is currently smaller than the other option's payoff.",
                 "Payoff is 10 or 20 points when the task starts, and on every trial there is a fixed probability of 0.075 that this option's payoff will increase by 20 points if it is currently smaller than the other option's payoff.",
                 "Payoff is 10 or 20 points when the task starts, and on every trial there is a fixed probability of 0.075 that this option's payoff will increase by 20 points if it is currently smaller than the other option's payoff.",
                 "Payoff is 10 or 20 points when the task starts, and on every trial there is a fixed probability of 0.125 that this option's payoff will increase by 20 points if it is currently smaller than the other option's payoff.",
                 "Payoff is 10 or 20 points when the task starts, and on every trial there is a fixed probability of 0.125 that this option's payoff will increase by 20 points if it is currently smaller than the other option's payoff.")
options_table <- data.frame(option, description)

# Save options sheet
file_name <- paste0(paper, "_", study, "_", "options.csv")
setwd(data_path)
write.table(options_table, file = file_name, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

### Process dataset

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper", "study","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)
# Read data file
file_name <- "choice_data.dat.txt"
ds <- read.table(file = file_name, header = TRUE)
option <- c("A", "B", "C", "D", "E", "F")
# Map to problem numbers and sort dataset by problem
problem_map <- c(`0.025` = 1, `0.075` = 2, `0.125` = 3) # named vector
cond_vector <- ds[, "cond"]
problem <- problem_map[as.character(cond_vector)] # Map to problem numbers
condition <- problem
ds$cond <- problem # Replace column in dataset
colnames(ds)[2] <- "problem"
rt <- ds$rt
rt <- rt * 1000
ds$rt <- rt
colnames(ds)[6] <- "response_time"
ds <- ds [order(ds$problem), ]
# Trials verified (use rle(ds$subj))
num_trials <- 500
# Create consecutive subject IDs
subject_unq <- 1:length(unique(ds$subj))
subject <- rep(subject_unq, each = num_trials)
# Map options
option_map <- c(`1` = "A_B", `2` = "C_D", `3` = "E_F")
options <- option_map[as.character(problem)]
# Map choices
option_1 <- c(`0` = "A", `1` = "B")
option_2 <- c(`0` = "C", `1` = "D")
option_3 <- c(`0` = "E", `1` = "F")
choice_map <- list(option_1, option_2, option_3)
# For each problem, take the vector of problem numbers (would be repeated 1s, or reapted 2s...), and
# Map it to the one of the option letters in choice_map depending on choice (resp)
choice_list <- sapply(1:3, function (x) sapply (ds[ds$problem == x, "resp"],
                                           function (y)  as.character(choice_map[[x]][as.character(y)])))
choice <- unlist(choice_list)
# Outcomes
outcome_raw <- ds$outcome
outcome <- paste(choice, outcome_raw, sep = ":")
ds$outcome <- outcome
# Rest of variables
ds$response_time <- round(ds$response_time) # Just in case
stage <- sex <- age <- education <- note1 <- note2 <- NA
# Bind new variables to dataset
ds_processed <- cbind (ds, paper, study, subject, problem, condition, options, choice, stage, sex, age, education, note1, note2)
# Extract and order as required
ds_final <- ds_processed[, c("paper", "study", "subject", "problem", "condition", "options", "trial", "choice", "outcome", "response_time", "stage", "sex", "age", "education", "note1", "note2")]

# Save processed data
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
