### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Daw, N., et al. (2011) Model-Based Influences on Humans’ Choices and Striatal Prediction Errors

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "DBDF2016"
study <- 1
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")

setwd(raw_path)

########## Generate the options sheet

# Set as working directory the folder that contains the data as sent by the author
option <- c("A", "B", "C", "D", "E", "F")
description <- c("Stage 1 option, probability of 0.7 to proceed to options set 1 (CD) in stage 2, or options set 2 (EF) otherwise",
                 "Stage 1 option, probability of 0.7 to proceed to options set 2 (EF) in stage 2, or options set 1 (CD) otherwise",
                 "Stage 2 option, set 1, Reward varies according to a randon drifting probability for trials 1-150, then stick to 0.7",
                 "Stage 2 option, set 1, Reward varies according to a randon drifting probability for trials 1-150, then stick to 0.3",
                 "Stage 2 option, set 2, Reward varies according to a randon drifting probability for trials 1-150, then stick to 0.6",
                 "Stage 2 option, set 2, Reward varies according to a randon drifting probability for trials 1-150, then stick to 0.4")

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
rm(list=setdiff(ls(), c("path", "paper", "study", "raw_path", "data_path")))
# Back to raw data directory
setwd(raw_path)
# Read dataset
dataset <- read.csv("twoStepPS_2stepTask_r.csv", header = TRUE, sep = ",")
testset <- read.csv("twoStepPS_PSTask_r.csv", header = TRUE, sep = ",")
# create base variables
option <- c("A", "B", "C", "D", "E", "F")
options_alt1 <- option [c(TRUE, FALSE)]
options_alt2 <- option [c(FALSE, TRUE)]
options_v <- paste(options_alt1, options_alt2, sep = "_")
choice_pairs <- matrix(option, ncol = 2, nrow = 3, byrow = TRUE)
subject_freq <- rle(sort(dataset$number))
# List to store each subject's processed data
psd_list <- vector(mode = "list", length(subject_freq$values))

for (sb in 1:length(subject_freq$values)) {
  subject_id <- subject_freq$values[sb]
  df <- dataset[dataset$number == subject_id, ]
  stage_choice <- rep(c(1, 2), length(df$trial))
  trial_choice <- rep(df$trial, each = 2)
  subject_choice <- rep(subject_id, length(trial_choice))
  problem_choice <- rep(1,length(trial_choice))
  response_time_choice <- c(rbind(round(df$rts1*1000), round(df$rts2*1000))) # Join the response times
  response_time_choice[response_time_choice == 0] <- NA # Change 0 values to NA
  options_stg1 <- sapply(1:nrow(df), function(n)
    ifelse(is.na(df$choice1[n]) || is.na(df$choice2[n]), NA, options_v[1]))
  # Second set of options (CD or EF) - based on variable "st" in dataset
  # But if ch = 0 then too late/ trial abort
  options_stg2 <- sapply(1:nrow(df), function(n)
    ifelse(is.na(df$choice1[n]) || is.na(df$choice2[n]), NA, options_v[df$state[n]]))
  # First fix non-choice trials (find which ones are zero, replace with NA)
  options_choice <- c(rbind(options_stg1, options_stg2))
  condition_choice <- rep(
    ifelse(!is.na(options_stg2) & options_stg2 != "C_D", 2, 1),
    each = 2
  )
  # For aborted trials fix response time
  response_time_choice[which(is.na(options_choice))] <- NA
  # Flip variables just indicate the location, but the choice vars encode the actual choice regardless
  choice_stg1 <- sapply(1:nrow(df), function(n)
    ifelse(is.na(df$choice1[n]) || is.na(df$choice2[n]), NA, choice_pairs[1, df$choice1[n]]))
  choice_stg2 <- sapply(1:nrow(df), function(n)
    ifelse(is.na(df$choice1[n]) || is.na(df$choice2[n]), NA, choice_pairs[df$state[n], df$choice2[n]]))
  choice_choice <- c(rbind(choice_stg1, choice_stg2))
  
  outcome_stg1 <- sapply(1:nrow(df), function(n)
    ifelse(is.na(df$choice1[n]) || is.na(df$choice2[n]), NA, ""))
  outcome_stg2 <- sapply(1:nrow(df), function(n)
    ifelse(is.na(df$choice1[n]) || is.na(df$choice2[n]), NA, df$won[n]))
  outcome_choice <- ifelse(is.na(choice_choice),NA, ifelse(stage_choice==1,"",paste(choice_choice,c(rbind(outcome_stg1, outcome_stg2)),sep = ":"))) # Join in alternating order
  note1_choice <- rep('learning', length(trial_choice))
  # add test data
  df_test <- testset[testset$number == subject_id, ]
  if (nrow(df_test) == 0) {
    # if test not exist, use choice
    message(paste("⚠️ Subject", subject_id, "not found in testset. Using only choice data."))
    
    subject   <- subject_choice
    problem   <- problem_choice
    condition <- condition_choice
    options   <- options_choice
    trial     <- trial_choice
    choice    <- choice_choice
    outcome   <- outcome_choice
    response_time <- response_time_choice
    stage     <- stage_choice
    note1     <- note1_choice
    
  } else {
    # add test if exist
    stage_test <- rep(NA, length(df_test$trial))
    trial_test <- df_test$trial
    subject_test <- rep(subject_id, length(trial_test))
    problem_test <- rep(2, length(trial_test))
    condition_test <- rep(3, length(trial_test))
    response_time_test <- rep(NA, length(trial_test))
    options_test <- sapply(df_test$cond, function(x) paste(strsplit(x, "")[[1]], collapse = "_"))
    choice_test <- ifelse(df_test$choice == 1, option[df_test$left + 2], option[df_test$right + 2])
    outcome_test <- choice_test
    note1_test <- rep('test', length(trial_test))
    
    # add choice and test
    subject   <- c(subject_choice, subject_test)
    problem   <- c(problem_choice, problem_test)
    condition <- c(condition_choice, condition_test)
    options   <- c(options_choice, options_test)
    trial     <- c(trial_choice, trial_test)
    choice    <- c(choice_choice, choice_test)
    outcome   <- c(outcome_choice, outcome_test)
    response_time <- c(response_time_choice, response_time_test)
    stage     <- c(stage_choice, stage_test)
    note1     <- c(note1_choice, note1_test)
  }
  
  sex <- age <- education <- note2 <- NA
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}


# Combine and save processed data
ds_final <- do.call("rbind", psd_list)
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
