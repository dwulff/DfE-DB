### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Yechiam & Busemeyer (2008) Evaluating generalizability and parameter consistency in learning models

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "YB2008"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)


### Create the options sheets

# Study 1
option <- c("A", "B", "C", "D", "E", "F")
#distribution(mean, standard dev)
description <- c("TN(20, 20^2, truncated at (-10,50)), round to nearest 0, +-10 ...", "TN(10, 20^2, truncated at (-20,40)), round to nearest , +-10...",
                 "10 with certainty", "20 with probability of 0.9, otherwise U(-95,-85)",
                 "N(100, 354^2)", "TN(25, 17.7^2, 0)")
options_table1 <- data.frame(option, description)

# Study 2
# Like study 1 but with outcome sign reversed, so most payoffs were negative (loss)
option <- c("A", "B", "C", "D", "E", "F")
description <- c("N(-10, 20^2, truncated at (-40,20)), round to nearest 0, +-10 ...", "N(-20, 20^2 truncated at -50,10), round to nearest 0, +-10 ...",
                 "-20 with a probability of 0.9, otherwise U(85,95)", "-10 with certainty",
                 "TN(-25,17.7^2, 0)", "N(-100, 354^2)")
options_table2 <- data.frame(option, description)

# Save options sheets
file_name1 <- paste0(paper, "_", "1", "_", "options.csv")
file_name2 <- paste0(paper, "_", "2", "_", "options.csv")
setwd(data_path)
write.table(options_table1, file = file_name1, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")
write.table(options_table2, file = file_name2, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

### Process datasets

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper", "study", "raw_path", "data_path")))
# Back to raw data directory
setwd(raw_path)
# Trial by trial data is ordered by problem (tasks 1 to 3)
file_c1 <- "threet.csv"
file_c2 <- "threet_cond2.csv"
# st1 = Study 1
ds_st1 <- read.csv(file_c1, header = FALSE, col.names = c("trial", "pressed", "subject_id", "payoff"))
# st2 = Study 2
ds_st2 <- read.csv(file_c2, header = FALSE, col.names = c("trial", "pressed", "subject_id", "payoff"))

process_ds <- function (ds, st) {
  # Function to process datasets
  
  # Study-specific variables/fixes
  if (st == 1) {
    study <- 1
    option <- c("A", "B", "C", "D", "E", "F")
    x1 <- 1 # H option
    x2 <- 2 # L option
    opts <- c("A_B", "C_D", "E_F")
  } else {
    study <- 2
    option <- c("A", "B", "C", "D", "E", "F")
    x1 <- 2
    x2 <- 1
    opts <- c("A_B", "C_D", "E_F")
    # Fix some stuff
    # Subject ID 1221 (in trial 1) should be 221 (so that rle below works correctly)
    ds[which(ds$subject_id == 1221), "subject_id"] <- 221
    # There are 200 trials in problem 1 for id = 1, and 400 trials in problems 2&3 for id = 207
    # In the paper there were 90 subjects in study 2, so combine to complete the data
    # Get the index of the first occurrence of id=207, then make it 1
    start_index <- match(207, ds$subject_id)
    end_index <- start_index + 400 - 1
    ds[start_index:end_index, "subject_id"] <- 1
  }
  num_trials <- 200 # per problem
  choice_pairs <- matrix (option, ncol = 2, byrow = TRUE)
  # Switch the position of the options for the 3rd problem (see readme file) for correct indexing
  choice_pairs[3,] <- replace(choice_pairs[3,], c(1,2), choice_pairs[3,][c(2, 1)])
  # Values in subject_id and their counts
  subject_freq <- rle(ds$subject_id)
  subject_unq <- 1:length(subject_freq$values)
  subject <- rep(subject_unq, subject_freq$lengths)
  problems_per_subject <- rep(1:3, each = num_trials)
  problem <- rep(problems_per_subject, length(subject_unq))
  options_per_subject <- rep(opts, each = num_trials)
  options <- rep(options_per_subject, length(subject_unq))
  # Map choices to option letters (See threet_readme file)
  # First split "choice/pressed" vector into sublists / blocks of 200 trials (200 trials * 3 problems)
  choice_raw <- as.vector(ds$pressed)
  choice_list <- split(choice_raw, ceiling(seq_along(choice_raw)/200))
  # Now split into sublists - so we get a list of subjects, each with 3 sublists
  choice_list_perProblem <- split(choice_list, rep(1:ceiling(length(choice_list)/3), each=3)[1:length(choice_list)])
  # Same for outcomes
  outcome_raw <- as.character(ds$payoff)
  outcome_list <- split(outcome_raw, ceiling(seq_along(choice_raw)/200))
  outcome_list_perProblem <- split(outcome_list, rep(1:ceiling(length(outcome_list)/3), each=3)[1:length(outcome_list)])
  # Mapping
  mapped_choicesList <- vector(mode = "list", length(choice_list_perProblem))
  mapped_outcomesList <- vector(mode = "list", length(choice_list_perProblem))
  for (sb in 1:length(subject_unq)) {
    subject_choices <- choice_list_perProblem[[sb]] # Choice and outcomes of current subject
    subject_outcomes <- outcome_list_perProblem[[sb]]
    mapped_choices_sublist <- lapply(1:3, function (p) sapply(1:num_trials, function(t)
      ifelse(subject_choices[[p]][t] == 2, choice_pairs[p,x1], choice_pairs[p,x2])))
    # Create outcomes
    mapped_outcomes_sublist <- lapply(1:3, function(p) paste(mapped_choices_sublist[[p]], subject_outcomes[[p]], sep = ":"))
    mapped_choicesList[[sb]] <- mapped_choices_sublist
    mapped_outcomesList[[sb]] <- mapped_outcomes_sublist
    
  }
  # Unlist to create vectors from outcomes and choices
  choice <- unlist(mapped_choicesList, recursive = TRUE)
  outcome <- unlist(mapped_outcomesList, recursive = TRUE)
  # Rest of variables
  trial <- ds$trial
  response_time <- stage <- sex <- age <- education <- condition <- note2 <- note1 <- NA
  # Create final dataframe
  ds_processed <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  return(ds_processed)
}

# Function calls
ds_st1_final <- process_ds(ds_st1, st = 1)
ds_st1_final <- ds_st1_final[!(ds_st1_final$subject==41 & ds_st1_final$problem==2),]
ds_st2_final <- process_ds(ds_st2, st = 2)

# remove subject with too many unexpected values
# ds_st1_final <- subset(ds_st1_final, !(subject == 41))

# Save data
file_name1 <- paste0(paper, "_", "1", "_", "data.csv")
file_name2 <- paste0(paper, "_", "2", "_", "data.csv")
setwd(data_path)
write.table(ds_st1_final, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(ds_st2_final, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
