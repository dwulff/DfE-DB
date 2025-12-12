### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Camilleri, A. R., & Newell, B. R. (2011b). When and why rare events are underweighted: A direct comparison of the sampling, partial feedback, full feedback
# and description choice paradigms
# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "CN2011b"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1 sampling paradigm experienced condition. description data only have one choice data, not useful. Study 1 and 2 use the same problem set.
# A safe, B risky
option <- LETTERS[1:8]
out_1 <- c(9, 10, -3, -4, 2, 14, -3, -32)
pr_1 <- c(1, 0.9, 1, 0.8, 1, 0.15, 1, 0.1)
out_2 <- c(NA, 0, NA, 0, NA, 0, NA, 0)
pr_2 <- c(NA, 0.1, NA, 0.2, NA, 0.85, NA, 0.9)
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Study 2 lottery bandit
# Problem 1: A,B  Problem 2: C,D  Problem 3: E,F  Problem 4 G,H
# Safe-Risky choices in that order
option <- c("A", "B", "C", "D", "E", "F", "G", "H")
out_1 <- c(9, 10, -3, -4, 2, 14, -3, -32)
pr_1 <- c(1.0, 0.9, 1.0, 0.8, 1.0, 0.15, 1.0, 0.1)
out_2 <- c(NA, 0, NA, 0, NA, 0, NA, 0)
pr_2 <- c(NA, 0.1, NA, 0.2, NA, 0.85, NA, 0.9)
options_table2 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options sheet
file_name1 <- paste0(paper, "_", "1", "_", "options.csv")
file_name2 <- paste0(paper, "_", "2", "_", "options.csv")

setwd(data_path)
write.table(options_table1, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(options_table2, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

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
# Back to raw data directory
setwd(raw_path)

# Study 1
d<-read.csv("C&N 2011 PB&R_MAX_experience.csv")
d<-data.frame(d)
option <- LETTERS[1:8]
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
out_safe <- c(9, -3, 2, -3)
condition_list <- c('sampling')
study <-1
pd <- data.frame()
for (participant in unique(d$ID)) {
  subject <- participant
  smp_s <- d[d$ID==participant, ]
  for (p in unique(smp_s$Problem)) {
    smp_p <- smp_s[smp_s$Problem==p, ]
    problem <- p
    options <- option_map[problem]
    feedback <- smp_p$option
    choice <- ifelse(feedback==out_safe[problem], choice_pairs[problem, 1], choice_pairs[problem, 2])
    outcome <- paste(choice, feedback, sep = ":")
    trial<- smp_p$trial
    decision <- ifelse(smp_p$Choice == 0, choice_pairs[problem, 1], choice_pairs[problem, 2])
    condition <- smp_p$Condition
    note1 <- condition_list[smp_p$Condition-1]
    sex <- ifelse(smp_p$Gender==0, 'f', 'm')
    age <- smp_p$Age
    # Rest of variables
    response_time<- stage <- education<- note2<- NA
    # Create final dataframe
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, decision, response_time, stage, sex, age, education, note1, note2)
    pd <- rbind(pd, psd)
  }
}

# Combine and save processed data
ds_final1 <- pd [order(pd$subject), ]
file_name1 <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final1, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")


# Study 2
study <-2
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
# Back to raw data directory
setwd(raw_path)
data_file_name <- "C&N 2011 PB&R.xlsx"
# Read the three data sheets in the excel file
# Participants were assigned to three different choice paradigms
dataset_partial <- read_excel(data_file_name, sheet = "Data (PF)") # partial feedback (n=20)
dataset_full <- read_excel(data_file_name, sheet = "Data (FF)") # full feedback (n=20)
option <- c("A", "B", "C", "D", "E", "F", "G", "H")
choice_pairs <- matrix (option, ncol = 2, byrow = TRUE) # Used when mapping choices
options_v <- c("A_B", "C_D", "E_F", "G_H")

# fix !?
names(dataset_partial)[10:109] = 1:100

num_trials <- 100
trial_start_index <- which(names(dataset_partial) == "1")[1]
trial_end_index <- which(names(dataset_partial) == "100")[1]
outcome_start_index <- trial_end_index + 1
outcome_end_index <- outcome_start_index + num_trials - 1
dataset_partial[, 10:109][dataset_partial[, 10:109] == 0]

process.dataset.sp <- function (cnd, paradigm, ds) {
  # Function to process datasets based on paradigm/data sheet
  
  # Set trial start index according to paradigm / data sheet
  num_trials <- 100
  trial_start_index <- which(names(ds) == "1")[1]
  trial_end_index <- which(names(ds) == "100")[1]
  outcome_start_index <- trial_end_index + 1
  outcome_end_index <- outcome_start_index + num_trials - 1
  outcome_fg_start_index <- outcome_end_index + 1
  outcome_fg_end_index <- outcome_fg_start_index + num_trials - 1
  colnames(ds)[3] <- "Gender" # Make it consistent with FF
  safe_outcome <- c(9, -3, 2, -3)
  if (paradigm == "Full feedback") {
    # Fix problem labels
    ds$Problem[ds$Problem == "Problem1"] <- 1
    ds$Problem[ds$Problem == "Problem2"] <- 2
    ds$Problem[ds$Problem == "Problem3"] <- 3
    ds$Problem[ds$Problem == "Problem4"] <- 4
    colnames(ds)[4] <- "Problem Number"
    # Fix choice labels - set 0 to S and 1 to R as in the other sheets
    ds[, trial_start_index:trial_end_index] <- sapply(ds[, trial_start_index:trial_end_index], as.character)
    ds[, trial_start_index:trial_end_index][ds[, trial_start_index:trial_end_index] == 0] <- "S"
    ds[, trial_start_index:trial_end_index][ds[, trial_start_index:trial_end_index] == 1] <- "R"
    # Set Male to 1 and Female to 0 as in the other sheets
    ds$Gender [ds$Gender == "Male"] <- 1
    ds$Gender [ds$Gender == "Female"] <- 0
  }
  
  # Sort data by ascending order of problem number
  dataset_by_problem <- ds [order(ds$`Problem Number`, ds$`Participant Number`), ]
  # Get raw values and convert to required format
  subject_raw <- dataset_by_problem$`Participant Number`
  subject <- rep(subject_raw + cnd * 100, each = num_trials)
  problem_raw <- dataset_by_problem$`Problem Number`
  problem <- rep(problem_raw, each = num_trials)
  age_raw <- dataset_by_problem$Age
  age <- rep(age_raw, each = num_trials)
  sex_raw <- dataset_by_problem$`Gender`
  sex_r <- rep(sex_raw, each = num_trials)
  sex <- ifelse(sex_r == 1, "m", "f")
  options <- rep(options_v, each = num_trials * (length(subject_raw)/length(unique(problem_raw))))
  # Map R and S options based on problem number
  choices_mapped_list <- vector (mode = "list", length = length(unique(problem_raw)))
  choices_mapped_fg_list <- vector(mode = "list", length = length(unique(problem_raw)))
  choices_mapped_risky_list <- vector(mode = "list", length = length(unique(problem_raw)))
  choices_mapped_risky_p_list <- vector(mode = "list", length = length(unique(problem_raw)))
  
  for (p in 1:length(unique(problem_raw))) {
    choice_raw <- dataset_by_problem [which(dataset_by_problem$`Problem Number` == p), trial_start_index:trial_end_index]
    choice_c_raw <- ifelse(choice_raw == "S", choice_pairs[p,1], choice_pairs[p,2])
    choice_rg_raw <- ifelse(choice_raw == "S", choice_pairs[p,2], choice_pairs[p,1])
    choice_risky <- ifelse(choice_raw == "S", FALSE, TRUE)
    choice_risky_problem <- ifelse(choice_raw == "S", FALSE, safe_outcome[p])
    choices_mapped_list[[p]] <- choice_c_raw
    choices_mapped_fg_list[[p]] <- choice_rg_raw
    choices_mapped_risky_list[[p]] <- choice_risky
    choices_mapped_risky_p_list[[p]] <- choice_risky_problem
  }
  choice_raw_all <- do.call("rbind", choices_mapped_list) # Recombine choices
  choice_raw_fg_all <- do.call("rbind", choices_mapped_fg_list) # Recombine forgone choices
  choice_raw_risky_all <- do.call("rbind", choices_mapped_risky_list) # Recombine forgone choices
  choice_raw_risky_p_all <- do.call("rbind", choices_mapped_risky_p_list) # Recombine forgone choices
  # Transposed first t() because as.vector works column-wise, and the trials are recorded row-wise
  choice <- as.vector(t(choice_raw_all), mode = "character")
  choice_fg <- as.vector(t(choice_raw_fg_all), mode = "character")
  choice_r <- as.vector(t(choice_raw_risky_all), mode = "character")
  choice_r_p <- as.vector(t(choice_raw_risky_p_all), mode = "character")
  #  if (paradigm == "Sampling with feedback") {
  #   # Non-consequential choice, so prefix the choice with a zero
  #  choice <- paste("0", choice, sep = "")
  #}
  outcome_raw <- as.vector(t(dataset_by_problem[, outcome_start_index:outcome_end_index]), mode = "character")
  if (paradigm == "Full feedback") {
    outcome_fg_raw <- as.vector(t(dataset_by_problem[, outcome_fg_start_index:outcome_fg_end_index]), mode = "character")
    # Make the outcomes by joining the choice and outcome vectors element-wise
    outcome <- ifelse(choice_r, paste(paste(choice, outcome_raw, sep = ":"), paste(choice_fg, choice_r_p, sep = ":"), sep = "_"),paste(paste(choice, outcome_raw, sep = ":"), paste(choice_fg, outcome_fg_raw, sep = ":"), sep = "_") )
  }else{
    # Make the outcomes by joining the choice and outcome vectors element-wise
    outcome <- paste(choice, outcome_raw, sep = ":")
  }
  # Extend rest of variables
  trial <- rep(1:num_trials, length(subject_raw)) # Notice it is extended over all repeated subjects
  response_time <- stage <- education <- note2 <- NA
  condition <- cnd
  note1 <- paradigm
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  return(psd)
}

# Function calls
# Between-subject design based on choice-paradigm
processed_dataset_partial <- process.dataset.sp (cnd = 1, paradigm = "Partial feedback", ds = dataset_partial)
processed_dataset_full <- process.dataset.sp (cnd = 3, paradigm = "Full feedback", ds = dataset_full)

# Combine all processed datasets
combined_processed_dataset <- rbind(processed_dataset_partial, processed_dataset_full)
ds_final <- combined_processed_dataset 

# Save data
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
