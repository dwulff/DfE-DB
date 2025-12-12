### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Schulze et al. (2015) Of matchers and maximizers: How competition shapes choice under risk and uncertainty

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "SRN2015"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1
# Two light bulbs
option <- c("A", "B")
out_1 <- c(1, 1)
pr_1 <- c(0.7, 0.3)
out_2 <- c(0, 0)
pr_2 <- c(0.3, 0.7)
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Study 2
# Red or green face on a ten-sided dice with seven green and three red sides
option <- c("A", "B")
out_1 <- c(1, 1)
pr_1 <- c(0.7, 0.3)
out_2 <- c(0, 0)
pr_2 <- c(0.3, 0.7)
options_table2 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options
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

### Study 1
# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper", "raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)
setwd("Schulze et al_2015")
study <- 1
if (!requireNamespace("R.matlab", quietly = TRUE)) install.packages("R.matlab")
library(R.matlab)
file_data <- "Schulze et al_2015_Experiment 1.mat"
ds <- readMat(file_data)
# Read gender data (this was extracted from the Matlab file)
gender_raw <- unname(unlist(read.table("gender_exp1.txt", header = FALSE, stringsAsFactors = FALSE)))
gender_raw <- ifelse(gender_raw == "male", "m", "f")
# Read conditions (this was extracted from the Matlab file)
cnd <- unname(unlist(read.table("condition_exp1.txt", header = FALSE, stringsAsFactors = FALSE)))
# Read relevant data from ds
age_raw <- as.numeric(ds$age)
choice_raw <- ds$choice
payoff <- ds$pay
result_raw <- ds$outcome
trial_raw <- ds$trial
problem <- 1
options <- "A_B"
psd_list <- vector(mode = "list", 50) # 50 subjects

for (sb in 1:50) {
  subject <- sb
  sex <- gender_raw[sb]
  age <- age_raw[sb]
  trial <- trial_raw[, sb]
  # 1 refers to optimal choice (black tokens = option A)
  choice_sb <- choice_raw[, sb]
  choice <- ifelse(choice_sb == 1, "A", "B")
  pay <- payoff[, sb]
  result <- result_raw[, sb]
  success <- ifelse(result == choice_sb, 1, 0) # 1 if outcome matches choice
  #outcome <- ifelse(success == 0, "0", paste(success, pay, sep = "_"))
  outcome <- paste(choice, success, sep = ":")
  note1 <- cnd[sb]
  condition <- ifelse(note1 == "Mimicry-Competitor", 1, 2)
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

### Study 2

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)
setwd("Schulze et al_2015")
study <- 2
if (!requireNamespace("R.matlab", quietly = TRUE)) install.packages("R.matlab")
library(R.matlab)
file_data <- "Schulze et al_2015_Experiment 2.mat"
ds <- readMat(file_data)
# Read gender data (this was extracted from the Matlab file)
gender_raw <- unname(unlist(read.table("gender_exp2.txt", header = FALSE, stringsAsFactors = FALSE)))
gender_raw <- ifelse(gender_raw == "male", "m", "f")
# Read conditions (this was extracted from the Matlab file)
cnd <- unname(unlist(read.table("condition_exp2.txt", header = FALSE, stringsAsFactors = FALSE)))
# Read relevant data from ds
age_raw <- as.numeric(ds$age)
choice_raw <- ds$choice
payoff <- ds$pay
result_raw <- ds$outcome
trial_raw <- ds$trial
problem <- 1
options <- "A_B"
psd_list <- vector(mode = "list", 50) # 50 subjects

for (sb in 1:50) {
  subject <- sb
  sex <- gender_raw[sb]
  age <- age_raw[sb]
  trial <- trial_raw[, sb]
  # 1 refers to optimal choice (black tokens = option A)
  choice_sb <- choice_raw[, sb]
  choice <- ifelse(choice_sb == 1, "A", "B")
  pay <- payoff[, sb]
  result <- result_raw[, sb]
  success <- ifelse(result == choice_sb, 1, 0) # 1 if outcome matches choice
  #outcome <- ifelse(success == 0, "0", paste(success, pay, sep = "_"))
  outcome <- paste(choice, success, sep = ":")
  note1 <- cnd[sb]
  condition <- ifelse(note1 == "Mimicry-Competitor", 1, 2)
  note2 <- "probabilities known"
  # Rest of variables
  stage <- response_time <- education <- NA
  # Create dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine and save processed data
ds_st2_final <- do.call("rbind", psd_list)
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_st2_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
