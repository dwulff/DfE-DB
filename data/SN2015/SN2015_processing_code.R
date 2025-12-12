### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Schulze & Newell (2015) Compete, Coordinate, and Cooperate: How to Exploit Uncertain Environments With Social Interaction

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "SN2015"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1
# Black and white tokens (with replacement for constant probabilities)
# Optimal color (70 out of 100) is randomised for every participant
# If only one participant predicted the correct color of the token, she received the full payoff (4 cents);
# if both participants converged on the correct response, the payoff was split equally between them (2 cents each).
# There was no penalty for incorrect predictions.
option <- c("A", "B")
out_1 <- c(1, 1)
pr_1 <- c(0.7, 0.3)
out_2 <- c(0, 0)
pr_2 <- c(0.3, 0.7)
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Study 2 (2a)
options_table2 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Study 3 (2b)
options_table3 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options
file_name1 <- paste0(paper, "_", "1", "_", "options.csv")
file_name2 <- paste0(paper, "_", "2", "_", "options.csv")
file_name3 <- paste0(paper, "_", "3", "_", "options.csv")
setwd(data_path)
write.table(options_table1, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(options_table2, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(options_table3, file = file_name3, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

### Process datasets

### Study 1
# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper","raw_path", "data_path")))
# Back to raw data directory
setwd(raw_path)
setwd("Schulze & Newell_2015/")
study <- 1
if (!requireNamespace("R.matlab", quietly = TRUE)) install.packages("R.matlab")
library(R.matlab)
file_data <- "Schulze & Newell_2015_Experiment 1.mat"
ds <- readMat(file_data)
# Read gender data (this was extracted from the Matlab file)
gender_raw <- unname(unlist(read.table("gender_exp1.txt", header = FALSE, stringsAsFactors = FALSE)))
gender_raw <- ifelse(gender_raw == "male", "m", "f")
# Read conditions (this was extracted from the Matlab file)
condition <- unname(unlist(read.table("condition_exp1.txt", header = FALSE, stringsAsFactors = FALSE)))
# Read relevant data from ds
age_raw <- as.numeric(ds$age)
choice_raw <- ds$choice
payoff <- ds$pay
result_raw <- ds$outcome
problem <- 1
options <- "A_B"
psd_list <- vector(mode = "list", 60) # 60 subjects

for (sb in 1:60) {
  subject <- sb
  sex <- gender_raw[sb]
  age <- age_raw[sb]
  # 1 refers to optimal choice (black tokens = option A)
  choice_sb <- choice_raw[, sb]
  choice <- ifelse(choice_sb == 1, "A", "B")
  trial <- 1:length(choice) # Four blocks of 50 trials
  pay <- payoff[, sb]
  result <- result_raw[, sb]
  success <- ifelse(result == choice_sb, 1, 0) # 1 if outcome matches choice
  # With actual pay (0.04 or 0.02)
  #outcome <- ifelse(success == 0, "0", paste(success, pay, sep = "_"))
  # Just 1 or 0
  outcome <- paste(choice, success, sep = ":")
  note1 <- condition[sb]
  condition <- ifelse(!is.na(note1) & note1 == "probabilities known", 1, 2)
  # Rest of variables
  stage <- response_time <- education <- note2 <- NA
  # Create dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd # Store
}

# Combine and save processed data
ds_st1_final <- do.call("rbind", psd_list)
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_st1_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

### Study 2 & 3

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper","data_path","raw_path")))
# Back to raw data directory
setwd(raw_path)
setwd("Schulze & Newell_2015/")
if (!requireNamespace("R.matlab", quietly = TRUE)) install.packages("R.matlab")
library(R.matlab)
file_exp2a <- "Schulze & Newell_2015_Experiment 2a.mat"
file_exp2b <- "Schulze & Newell_2015_Experiment 2b.mat"

process_st2 <- function (ds, p, option, gender_raw, cnd) {
  # Read relevant data from ds
  age_raw <- as.numeric(ds$age)
  choice_raw <- ds$choice
  payoff <- ds$pay
  result_raw <- ds$outcome
  problem <- 1
  options <- paste(option, collapse = "_")
  psd_list <- vector(mode = "list", 60) # 60 subjects
  
  for (sb in 1:60) {
    if (p == "a") {
      study <- 2
      subject <- sb # Start from 1 (exp2a)
      note1 <- cnd[sb]
      condition <- ifelse(note1 == "Between-dyad competition", 1, 2)
      note2 <- NA
    } else {
      study <- 3
      subject <- sb + 60 # Strt from 61 (exp2b)
      note1 <- cnd[sb]
      condition <- ifelse(note1 == "Between-dyad competition", 1, 2)
      note2 <- "probabilities known"
    }
    sex <- gender_raw[sb]
    age <- age_raw[sb]
    # Four blocks of 50 trials
    # 1 refers to optimal choice (black tokens = option A)
    choice_sb <- choice_raw[, sb]
    choice <- ifelse(choice_sb == 1, option[1], option[2])
    trial <- 1:length(choice)
    pay <- payoff[, sb]
    result <- result_raw[, sb]
    success <- ifelse(result == choice_sb, 1, 0) # 1 if outcome matches choice
    # With actual pay (0.04 or 0.02)
    #outcome <- ifelse(success == 0, "0", paste(success, pay, sep = "_"))
    # Just 1 or 0
    outcome <- paste(choice, success, sep = ":")
    # Rest of variables
    stage <- response_time <- education <- NA
    # Create dataframe
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    psd_list[[sb]] <- psd # Store
  }
  # Combine data
  psd_combined <- do.call("rbind", psd_list)
  return(psd_combined)
}

# Read gender and condition data (extracted from the Matlab file)
gender_raw_a <- unname(unlist(read.table("gender_exp2a.txt", header = FALSE, stringsAsFactors = FALSE)))
gender_raw_a <- ifelse(gender_raw_a == "male", "m", "f")
gender_raw_b <- unname(unlist(read.table("gender_exp2b.txt", header = FALSE, stringsAsFactors = FALSE)))
gender_raw_b <- ifelse(gender_raw_b == "male", "m", "f")
condition_a <- unname(unlist(read.table("condition_exp2a.txt", header = FALSE, stringsAsFactors = FALSE)))
condition_b <- unname(unlist(read.table("condition_exp2b.txt", header = FALSE, stringsAsFactors = FALSE)))
# Function calls
ds_st2a <- process_st2(ds = readMat(file_exp2a), p = "a", option = c("A", "B"), gender_raw = gender_raw_a, cnd = condition_a)
ds_st2b <- process_st2(ds = readMat(file_exp2b), p = "b", option = c("A", "B"), gender_raw = gender_raw_b, cnd = condition_b)

# Combine 2a and 2b and save
# ds_st2_final <- rbind(ds_st2a, ds_st2b)
file_name2 <- paste0(paper, "_", "2", "_", "data.csv")
file_name3 <- paste0(paper, "_", "3", "_", "data.csv")

setwd(data_path)
write.table(ds_st2a, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(ds_st2b, file = file_name3, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
