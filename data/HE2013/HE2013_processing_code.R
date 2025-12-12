### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Hochman & Erev. (2011) The partial-reinforcement extinction effect and the contingent-sampling hypothesis

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "HE2013"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet
# Study 1
# 2 problems (Full and partial reinforcement schedule, learning and extinction option pairs, p. 1338)
option <- c("A", "B", "C", "D", "E", "F", "G", "H")
out_1 <- c(8,  9,  8,  1,   8,   17,   8,  1)
pr_1 <- c(1,   1,  1,  1,   1,   0.5,  1,  1)
out_2 <- c(NA, NA, NA, NA,  NA,  1,   NA, NA)
pr_2 <- c(NA,  NA, NA, NA,  NA,  0.5, NA, NA)
options_table_1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Study 2
# 2 environments with 2 conditions each -> 4 problems in total
# See table 2 (p. 1340)
option <- LETTERS[1:16]
out_1 <- c(5, 9, 5, 1, 5, 17, 5, 1, 2, 9, 2, 1, 2, 17, 2, 1)
pr_1 <- c(1, 1, 1, 1, 1, 0.5, 1, 1, 1, 1, 1, 1, 1, 0.5, 1, 1)
out_2 <- c(NA, NA, NA, NA, NA, 1, NA, NA, NA, NA, NA, NA, NA, 1, NA, NA)
pr_2 <- c(NA, NA, NA, NA, NA, 0.5, NA, NA, NA, NA, NA, NA, NA, 0.5, NA, NA)
options_table_2 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options sheet
file_name_1 <- paste0(paper, "_", "1", "_", "options.csv")
file_name_2 <- paste0(paper, "_", "2", "_", "options.csv")
setwd(data_path)
write.table(options_table_1, file = file_name_1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(options_table_2, file = file_name_2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

### Process dataset

# Study 1
# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path")))
# Working directory is in processed/options at this point, so go back to raw_data
setwd(raw_path)
# Read data file - has studies 1 and 2
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
data_filename <- "Exp_1 and 2_Raw.xls"
dataset <- read_excel(data_filename, sheet = "Sheet1")
ds_st1 <- dataset[dataset$Exp == 1, ]
study <- 1
option <- c("A", "B", "C", "D", "E", "F", "G", "H")
# Sets of 4 options (Learning and extinction stages) for each problem
choice_pairs <- matrix (option, ncol = 2, byrow = TRUE)
option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
options_v <- apply(choice_pairs, 1, function (r) paste(r, collapse = "_"))
subject_freq <- rle(sort(ds_st1$Sub))
# List to store each subject's processed data
psd_list <- vector(mode = "list", length(subject_freq$values))

for (sb in 1:length(subject_freq$values)) {
  subject <- subject_freq$values[sb]
  # Subject data
  df <- ds_st1[ds_st1$Sub == subject, ]
  problem <- ifelse(df$Schedule == "Full", ifelse(df$Phase == "Learning", 1, 2), ifelse(df$Phase == "Learning", 3, 4))
  condition <- problem
  note1 <- ifelse(df$Schedule == "Full", "Full reinforcement", "Partial reinforcement")
  note2 <- df$Phase
  trial <- df$Trial
  options <- option_map[problem]
  choice <- ifelse(df$Choice == 0, choice_pairs[problem,1], choice_pairs[problem,2])
  # Foregone feedback not coded
  outcome <- paste(choice, df$Pay, sep = ":")
  # Rest of variables
  stage <- age <- sex <- education <- response_time <- NA
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine and save processed data
psd_combined <- do.call("rbind", psd_list)
ds_st1_final <- psd_combined [order(psd_combined$subject, psd_combined$problem, psd_combined$trial), ]
ds_st1_final$outcome[ds_st1_final$outcome == 'H:17'] <- NA
file_name_st1 <- paste0(paper, "_", "1", "_", "data.csv")
setwd(data_path)
write.table(ds_st1_final, file = file_name_st1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

### Study 2

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path")))
setwd(raw_path)
study <- 2
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
data_filename <- "Exp_1 and 2_Raw.xls"
dataset <- read_excel(data_filename, sheet = "Sheet1")
ds_st2 <- dataset[dataset$Exp == 2, ]

process_dataset_st2 <- function (ds, subj_ind, option) {
  # The variable subj_ind stands for the subject ID that should come next (betwee-subject design)
  
  num_trials <- 100 # Verified (Total divided by 200 gives number of subjects), Learning then Extinction trials
  # Sets of options (Learning and extinction stages) for each problem
  choice_pairs <- matrix (option, ncol = 2, byrow = TRUE)
  options_v <- apply(choice_pairs, 1, function (r) paste(r, collapse = '_'))
  # Map problems, stages, choices, and payoffs
  ds_p1 <- ds [which(ds$Schedule == "Full"), c("Schedule", "Sub", "Choice", "Phase", "Pay", "Forgone")]
  ds_p2 <- ds [which(ds$Schedule == "Partial"), c("Schedule", "Sub", "Choice", "Phase", "Pay", "Forgone")]
  if (subj_ind == 1) { # Create appropriate consecutive IDs depending on given environment
    subject_unq1 <- seq(subj_ind, length(unique(ds_p1$Sub)), by = 1)
    subject_unq2 <- seq(tail(subject_unq1, n=1) + 1, tail(subject_unq1, n=1) + 1 +
                          length(unique(ds_p2$Sub)) - 1, by = 1)
    next_subj <- tail(subject_unq2, n = 1) + 1 # Next subject ID for the next function call
    subject_p1 <- rep(subject_unq1, each = num_trials*2)
    subject_p2 <- rep(subject_unq2, each = num_trials*2)
  } else {
    subject_unq1 <- seq(subj_ind, subj_ind + length(unique(ds_p1$Sub)) - 1, by = 1)
    subject_unq2 <- seq(tail(subject_unq1, n=1) + 1, tail(subject_unq1, n=1) + 1 +
                          length(unique(ds_p2$Sub)) - 1, by = 1) # tail, n=1 gets the last element
    next_subj <- tail(subject_unq2, n = 1) + 1 # Next subject ID for the next function call
    subject_p1 <- rep(subject_unq1, each = num_trials*2)
    subject_p2 <- rep(subject_unq2, each = num_trials*2)
  }
  # Build vectors for final dataframe
  subject <- c(subject_p1, subject_p2)
  note1_p1 <- ifelse(ds_p1$Schedule == "Full", "Full reinforcement", "Partial reinforcement")
  note1_p2 <- ifelse(ds_p2$Schedule == "Full", "Full reinforcement", "Partial reinforcement")
  note1 <- c(note1_p1, note1_p2)
  options_p1 <- ifelse(ds_p1$Phase == "Learning", options_v[1], options_v[2])
  options_p2 <- ifelse(ds_p2$Phase == "Learning", options_v[3], options_v[4])
  options <- c(options_p1, options_p2)
  problem <- ifelse(ds$Schedule == "Full", ifelse(ds$Phase == "Learning", 1, 2),  ifelse(ds$Phase == "Learning", 3, 4))
  condition <- ifelse(ds$Safe == 5, ifelse(ds$Schedule == "Full", 1, 2),  ifelse(ds$Schedule == "Full", 3, 4))
  if (subj_ind != 1) {
    problem <- problem + 4
  }
  note2_p1 <- ds_p1$Phase
  note2_p2 <- ds_p2$Phase
  note2 <- c(note2_p1, note2_p2)
  # Replace choices with option letters
  choice_p1 <- ifelse(ds_p1$Phase == "Learning", ifelse(ds_p1$Choice == 0, choice_pairs[1,1], choice_pairs[1,2]),
                      ifelse(ds_p1$Choice == 0, choice_pairs[2,1], choice_pairs[2,2]))
  foregone_choice_p1 <- ifelse(ds_p1$Phase == "Learning", ifelse(ds_p1$Choice == 0, choice_pairs[1,2], choice_pairs[1,1]),
                               ifelse(ds_p1$Choice == 0, choice_pairs[2,2], choice_pairs[2,1]))
  choice_p2 <- ifelse(ds_p2$Phase == "Learning", ifelse(ds_p2$Choice == 0, choice_pairs[3,1], choice_pairs[3,2]),
                      ifelse(ds_p2$Choice == 0, choice_pairs[4,1], choice_pairs[4,2]))
  # foregone_choice_p2 <- ifelse(ds_p2$Phase == "Learning", ifelse(ds_p2$Choice == 0, choice_pairs[3,2], choice_pairs[3,1]),
  #                     ifelse(ds_p2$Choice == 0, choice_pairs[4,2], choice_pairs[4,1]))
  choice <- c(choice_p1, choice_p2)
  # foregone_choice <- c(foregone_choice_p1, foregone_choice_p2)
  outcome_p1 <- paste(choice_p1, ds_p1$Pay, sep = ":")
  outcome_p2 <- paste(choice_p2, ds_p2$Pay, sep = ":")
  outcome_fgp1 <- paste(foregone_choice_p1, ds_p1$Forgone, sep = ":")
  # outcome_fgp2 <- paste(foregone_choice_p2, ds_p2$Forgone, sep = ":")
  outcome <- c(paste(outcome_p1, outcome_fgp1, sep = "_"), outcome_p2)
  t <- prod(num_trials, 2)
  ln <- sum(length(subject_unq1), length(subject_unq2))
  trial <- rep(c(1:t), as.numeric(ln))
  # Rest of variables
  stage <- age <- sex <- education <- response_time <- NA
  # Create final dataframe
  processed_ds <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  return(list(processed_ds, next_subj))
}

# Function calls - Process environments 5 and 2 in study 2
option_e5 <- LETTERS[1:8] # Pass the relevant options to the function
option_e2 <- LETTERS[9:16]
processed_ds_e5 <- process_dataset_st2 (ds = ds_st2[ds_st2$Env == 5, ], subj_ind = 1, option = option_e5)
processed_ds_e2 <- process_dataset_st2 (ds = ds_st2[ds_st2$Env == 2, ],
                                        subj_ind = as.numeric(processed_ds_e5[[2]]), option = option_e2)
# subj_in = length(unique(ds_st2[ds_st2$Env == 5, ]$Sub)) + 1
# Concatenate environments in order
ds_st2_final <- rbind(processed_ds_e5[[1]], processed_ds_e2[[1]])

# Save processed data
file_name_st2 <- paste0(paper, "_", "2", "_", "data.csv")
setwd(data_path)
write.table(ds_st2_final, file = file_name_st2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
