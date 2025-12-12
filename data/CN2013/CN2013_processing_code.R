### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Camilleri & Newell (2013) The long and short of it: Closing the description-experience ‘‘gap’’ by taking the long-run view

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "CN2013"
study <- 1
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

########## Generate the options sheet

# Experience-based condition (decription-based condition excluded)
# Safe-Risky choices in that order
# 32 problems for a total of 64 options
option <- c(LETTERS, paste('A',LETTERS,sep=""), paste('B',LETTERS,sep="")[1:12] )


out_1 <- c(-20.1, -95.5, 20.1, 95.5, 21.3, 25.4, -21.3, -25.4, -22.5, -156.7, 22.5, 156.7, 23.7,
           29.1, -23.7, -29.1, -24.9, -239.0, 24.9, 239.0, 26.1, 27.9, -26.1, -27.9, -27.3, 
           -566.0, 27.3, 566.0, 28.5, 31.1, -28.5, -31.1, -29.7, -153.5, 29.7, 153.5, 30.9, 39.9, 
           -30.9, -39.9, -32.1, -207.3, 32.1, 207.3, 33.3, 38.0, -33.3, -38.0, -34.5, -355.0, 34.5, 
           355.0, 35.7, 40.8, -35.7, -40.8, -36.9, -718.0, 36.9, 718.0, 38.1, 39.1, -38.1, -39.1)
pr_1 <- c(1, 0.2, 1, 0.2, 1, 0.8, 1, 0.8, 1, 0.15, 1, 0.15, 1, 0.85, 1, 0.85, 1, 0.1, 1,
          0.1, 1, 0.9, 1, 0.9, 1, 0.05, 1, 0.05, 1, 0.95, 1, 0.95, 1, 0.2, 1, 0.2, 1, 0.8,
          1, 0.8, 1, 0.15, 1, 0.15, 1, 0.85, 1, 0.85, 1, 0.1, 1, 0.1, 1, 0.9, 1, 0.9, 1,
          0.05, 1, 0.05, 1, 0.95, 1, 0.95)
out_2 <-c(NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0,
          NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA,
          0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0)
pr_2 <- c(NA, 0.8, NA, 0.8, NA, 0.2, NA, 0.2, NA, 0.85, NA, 0.85, NA, 0.15, NA, 0.15, NA, 0.9, NA,
          0.9, NA, 0.1, NA, 0.1, NA, 0.95, NA, 0.95, NA, 0.05, NA, 0.05, NA, 0.8, NA, 0.8, NA, 0.2,
          NA, 0.2, NA, 0.85, NA, 0.85, NA, 0.15, NA, 0.15, NA, 0.9, NA, 0.9, NA, 0.1, NA, 0.1, NA,
          0.95, NA, 0.05, NA, 0.05, NA, 0.05)

options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)
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
rm(list=setdiff(ls(), c("path", "paper", "study", "raw_path", "data_path")))
# Back to raw data directory
setwd(raw_path)

if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
data_file_name <- "C&N 2013 Cognition.xlsx"
# Read the three data sheets in the excel file
dataset_a <- read_excel(data_file_name, sheet = "A - Data") # data for 16 problems here
dataset_b <- read_excel(data_file_name, sheet = "B - Data") # data for the other 16 problems here
# Keep only rows with repeated choices (experience-based)
dataset_a <-dataset_a [(dataset_a$`Condition (1=D 2=E)` != 1), ]
dataset_b <-dataset_b [(dataset_b$`Condition (1=D 2=E)` != 1), ]
# Remove extraneous columns
dataset_a <- dataset_a [, -c(1,2,4,5,6,9,10:13,15:27)]
dataset_b <- dataset_b [, -c(1,2,4,5,6,9,10:13,15:27)]
dataset_a <- dataset_a [, -which(names(dataset_a) == "Points")]
dataset_b <- dataset_b [, -which(names(dataset_b) == "Points")]
# Options and choice pairs for all problems
option <- c(LETTERS, paste('A',LETTERS,sep=""), paste('B',LETTERS,sep="")[1:12] )
options_alt1 <- option [c(TRUE, FALSE)]
options_alt2 <- option [c(FALSE, TRUE)]
options_v <- paste(options_alt1, options_alt2, sep = "_")
# A matrix of choice pairs where row numbers correspond to problem numbers
choice_pairs <- matrix (option, ncol = 2, byrow = TRUE)

process.dataset.sp <- function (ds, problem_range) {
  # Function to process datasets based on data sheet
  
  # Set trial (R and S) and outcome indices
  num_trials <- 40
  trial_start_index <- which(names(ds) == "Choice1")
  trial_end_index <- which(names(ds) == "Choice40")
  outcome_start_index <- which(names(ds) == "Outcome1")
  outcome_end_index <- which(names(ds) == "Outcome40")
  # Sort data by ascending order of problem number
  dataset_byprob <- ds [order(ds$Problem), ]
  # Get raw values and convert to required format
  subject_raw <- dataset_byprob$Participant
  subject <- rep(subject_raw, each = num_trials)
  problem_raw <- dataset_byprob$Problem
  # 16 problems per participant (p. 58)
  problem_raw_actual <- problem_range[problem_raw] # Map to actual problem numbers
  dataset_byprob$Problem <- problem_raw_actual # Set actual problem numbers in working dataset
  problem <- rep(problem_raw_actual, each = num_trials)
  age_raw <- dataset_byprob$Age
  age <- rep(age_raw, each = num_trials)
  sex_raw <- dataset_byprob$`Gender`
  sex_r <- rep(sex_raw, each = num_trials)
  sex <- ifelse(sex_r == 1, "m", "f") # Verify...
  options_raw <- options_v[problem_raw_actual] # Get the corresponding options
  options <- rep(options_raw, each = num_trials)
  # Map R and S choices based on problem number (not the mapped one, but its okay)
  choices_mapped_list <- vector (mode = "list", length = length(problem_range))
  for (p in 1:length(problem_range)) {
    prob <- problem_range[p] # Get the problem number to use as index
    choice_raw <- dataset_byprob [which(dataset_byprob$Problem == prob), trial_start_index:trial_end_index]
    choice_raw <- ifelse(choice_raw == "S", choice_pairs[prob,1], choice_pairs[prob,2]) # Set options
    choices_mapped_list[[p]] <- choice_raw
  }
  choice_raw_all <- do.call("rbind", choices_mapped_list) # Recombine choices
  # Transposed first t() because as.vector works column-wise, and the trials are recorded row-wise
  choice <- as.vector(t(choice_raw_all), mode = "character")
  outcome_raw <- as.vector(t(dataset_byprob [, outcome_start_index:outcome_end_index]), mode = "character")
  # Make the outcomes by joining the choice and outcome vectors element-wise
  outcome <- paste(choice, outcome_raw, sep = ":")
  # Extend rest of variables
  trial <- rep(1:num_trials, times = length(subject_raw)) # Notice it is extended over all repeated subjects
  response_time <- stage <- education <- condition <- note1 <- note2 <- NA
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  return(psd)
}

# The two 16-problem sets label problems 1-16, so to map to the correct number the correct range is passed
# to the function
problems_in_a <- seq(1, 32, 2) #{1,3,5,7,9,11,13,15,19,21,23,25,27,29,31}
problems_in_b <- seq(2, 32, 2) #{(2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32}
processed_dataset_a <- process.dataset.sp (ds = dataset_a, problem_range = problems_in_a)
processed_dataset_b <- process.dataset.sp (ds = dataset_b, problem_range = problems_in_b)

# Combine all processed datasets and sort by subject, problem, trial
combined_processed_dataset <- rbind(processed_dataset_a, processed_dataset_b)
ds_final <- combined_processed_dataset [order(combined_processed_dataset$problem), ]

# Save combined processed data
file_name <- paste0(paper, "_", study, "_", "data.csv")

setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
