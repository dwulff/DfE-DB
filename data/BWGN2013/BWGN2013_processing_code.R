### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Beevers et al. (2013) Influence of depression symptoms on history-independent reward and punishment processing

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "BWGN2013"

raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
# Set as working directory the folder that contains the data as sent by the author
setwd(raw_path)

study <- 1
##### Create the options sheet

# Four options in the reward maximizing problem, and four in the punishment-minimization problem
# A, B, C, D - reward maximizing problem
# E, F, G, H - punishment minimizing problem
# A, B, E, and F are so-called A options
# C, D, G, and H are B options
option <- c("A", "B", "C", "D", "E", "F", "G", "H")
description <- c("(x_i): x is in [1-5] and i is in {1,2,...,50} followed by (x_i): x is in [5-9] and i is in {51,52,...,80}",
                 "B = A",
                 "(x_i): x is in [4-10] and i is in {1,2,...,50} followed by (x_i): x is in [1-5] and i is in {51,52,...,80}",
                 "D = C",
                 "A-11: (x-11_i): x is in [1-5] and i is in {1,2,...,50} followed by (x-11_i): x is in [5-9] and i is in {51,52,...,80}",
                 "F = E",
                 "C-11: (x-11_i): x is in [4-10] and i is in {1,2,...,50} followed by (x-11_i): x is in [1-5] and i is in {51,52,...,80}",
                 "H = G")
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
# Working directory is in processed/options at this point, so go back to raw_data
setwd(raw_path)
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
# Read the xls file containing the group to which each file/subject belongs
data_depgroup <- read_excel("hist_ind_paper_reward_punish.xlsx", sheet = "Sheet1")
# n=47 low depression (dep_grp = 1) and n=48 high depression (dep_grp = 2)
depression_group <- ifelse(data_depgroup$dep_grp == 1, "Low depression", "High depression")
condition_group <- ifelse(data_depgroup$dep_grp == 1, 1, 2)
subject_ids_raw <- unlist(strsplit(data_depgroup$subject, split = ".exp"))
# Remove the file extension characters from the subject names
subject_ids <- substr(subject_ids_raw, nchar(subject_ids_raw) - 4 + 1, nchar(subject_ids_raw))
# Read data files - Gains subfolder
setwd("Beeversetal2013PsychiatryResearch_Data/Gains/")
gains_data_files <- list.files() # One file per subject
data_list_gains <- lapply(gains_data_files,
                          FUN = function(files)
                          {read.table(files, header = FALSE,
                                      col.names = c("points_rm", "choice", "points", "points_cum", "response_time", "outcome"))})
# Read data files - Losses subfolder
setwd("../Losses/") # Change directory
losses_data_files <- list.files()
data_list_losses <- lapply(losses_data_files,
                          FUN = function(files)
                          {read.table(files, header = FALSE,
                                      col.names = c("points_rm", "choice", "points", "points_cum", "response_time", "outcome"))})
# Remove the extension part from the file names (each is a subject) and extract the last 4 numbers
gains_subject_ids_raw <- unlist(strsplit(gains_data_files, split = ".dat"))
losses_subject_ids_raw <- unlist(strsplit(losses_data_files, split = ".dat"))
gains_subject_ids <- substr(gains_subject_ids_raw, nchar(gains_subject_ids_raw) - 4 + 1, nchar(gains_subject_ids_raw))
losses_subject_ids <- substr(losses_subject_ids_raw, nchar(losses_subject_ids_raw) - 4 + 1, nchar(losses_subject_ids_raw))

option <- c("A", "B", "C", "D", "E", "F", "G", "H")
choice_pairs <- matrix (option, ncol = 4, nrow = 2, byrow = TRUE)
options_v <- c("A_B_C_D", "E_F_G_H")
# List to store each subject's processed data
psd_list <- vector(mode = "list", length(subject_ids))

for (sb in 1:length(subject_ids)) {
  subject <- subject_ids[sb]
  # Find the index of the two datasets corresponding to subject k
  ds_gains <- data_list_gains[[which(grepl(subject, gains_data_files))]]
  ds_losses <- data_list_losses[[which(grepl(subject, losses_data_files))]]
  trial <- c(1:nrow(ds_gains), 1:nrow(ds_losses))
  options <- c(rep(options_v[1], nrow(ds_gains)), rep(options_v[2], nrow(ds_losses)))
  problem <- c(rep(1, nrow(ds_gains)), rep(2, nrow(ds_losses)))
  response_time <- round(c(ds_gains$response_time, ds_losses$response_time))
  # Extract and concatenate choices
  # 0 and 1 are the A choices (A,B,E,F) and 2 and 3 are the B choices (C,D,G,H)
  choice_gains_raw <- ds_gains$choice
  choice_losses_raw <- ds_losses$choice
  choice_gains <- sapply(choice_gains_raw, function(ch) choice_pairs[1, ch + 1])
  choice_losses <- sapply(choice_losses_raw, function(ch) choice_pairs[2, ch + 1])
  choice <- c(choice_gains, choice_losses)
  # Create outcomes
  outcome_gains <- paste(choice_gains, ds_gains$outcome, sep = ":")
  outcome_losses <- paste(choice_losses, ds_losses$outcome, sep = ":")
  outcome <- c(outcome_gains, outcome_losses)
  # Determine depression group
  note1 <- depression_group[sb]
  condition <- condition_group[sb]
  # Rest of variables
  stage <- sex <- age <- education <- note2 <- NA
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine and Save data
ds_final <- do.call("rbind", psd_list)
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
