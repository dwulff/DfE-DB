### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Jocham, G., Klein, T., Ullsperger, M. (2011) Dopamine-Mediated Reinforcement Learning Signals in the Striatum and Ventromedial Prefrontal Cortex Underlie Value-Based Choices

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "JKU2011"
study <- 1
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)


### Create the options sheet

# Same options for both the acquisition and tranfer stages
option <- c("A", "B", "C", "D", "E", "F")
out_1 <- c(1, 1, 1, 1, 1, 1)
pr_1 <- c(0.8, 0.2, 0.7, 0.3, 0.6, 0.4)
out_2 <- c(0, 0, 0, 0, 0, 0)
pr_2 <- c(0.2, 0.8, 0.3, 0.7, 0.4, 0.6)
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
# Working directory is in processed/options at this point, so go back to raw_data
setwd(raw_path)
# Enter the sub-directory containing the data files
setwd("behav_data_dolores/")
# PLA for placebo sessions, AMI for the drug, TA for acquisition, and TE for transfer
# Note 16 subjects - the number that were included in the analysis, as mentioned in the paper
file_list <- list.files()
file_list <- file_list[-1] # Remove the readme.txt file from the list
# To allow parallel indexing, subdivide files into vectors each containing one type of drug and stage (file)
files_ac_am <- file_list [c(TRUE, FALSE, FALSE, FALSE)] # Acquisition - drug
files_ac_p <- file_list [c(FALSE, FALSE, TRUE, FALSE)] # Acquisition - placebo
files_tr_am <- file_list [c(FALSE, TRUE, FALSE, FALSE)] # Transfer - drug
files_tr_p <- file_list [c(FALSE, FALSE, FALSE, TRUE)] # Transfer - placebo
num_subjects <- as.numeric(length(files_ac_p))
# In the data the numbers 1-6 in stimuli stand for A/B/C/D/E/F
option <- c("A", "B", "C", "D", "E", "F")

# For each subject, process both datasets (learning/transfer) for both sessions (placebo/drug)
process_session <- function (subject) {
  
  process_ds <- function (ds, subject, phase, note1) {
    # Set condition
    if (note1 == "Placebo") {
      condition <- 1
    } else {
      condition <- 2
    }
    # Remove pause and null trials and replace all NaN (missed responses) with NA 
    ds <- ds[-which(ds$trial_type != 1), ]
    ds[is.na(ds)] <- NA
    ds$trial <- c(1:nrow(ds)) # Fix trial numbering
    # Replace stimuli and choices with option letters
    ds$left_stimulus <- option[ds$left_stimulus]
    ds$right_stimulus <- option[ds$right_stimulus]
    choices <- sapply(1:nrow(ds), function(j) ifelse(ds[j, "choice"] == 1, ds[j, "left_stimulus"], ds[j, "right_stimulus"]))
    ds$choice <- choices
    # Options
    options <- ifelse(match(ds$left_stimulus, option) > match(ds$right_stimulus, option),
                      paste(ds$right_stimulus, ds$left_stimulus, sep = "_"),
                      paste(ds$left_stimulus, ds$right_stimulus, sep = "_"))
    # Outcomes
    outcomes <- sapply(1:nrow(ds), function(j) paste(ds[j, "choice"], ds[j, "outcome"], sep = ":"))
    outcomes <- gsub(":$", "", outcomes)
    ds$outcome <- outcomes
    # Rest of variables
    problem <- ifelse(phase == 1, 1, 2)
    sex <- age <- education <- stage <- NA
    note2 <- ifelse(phase == 1, "Learning", "Transfer")
    # Add variables to dataset
    ds <- cbind(ds, paper, study, subject, problem, condition, options, stage, sex, age, education, note1, note2)
    # Extract and order as required
    ds_processed <- ds[, c("paper", "study", "subject", "problem", "condition", "options", "trial", "choice", "outcome", "response_time", "stage", "sex", "age", "education", "note1", "note2")]
    ds_processed[ds_processed == "NA:NA"] <- NA # Some outcomes are NANA because of NAs that got concatenated, change to NA
    ds_processed[which(is.na(ds_processed$choice)), "response_time"] <- NA
    return(ds_processed)
  }
  
  # This is phase 1 (both placebo and drug sessions)
  dsacp <- read.table(file = files_ac_p[[subject]], header = FALSE,
                     col.names = c("trial", "block_num", "trial_type", "left_stimulus",
                                   "right_stimulus", "stimulus_onset", "choice",
                                   "response_onset", "response_time", "outcome_onset",
                                   "outcome", "what"))
  dsacm <- read.table(file = files_ac_am[[subject]], header = FALSE,
                     col.names = c("trial", "block_num", "trial_type", "left_stimulus",
                                   "right_stimulus", "stimulus_onset", "choice",
                                   "response_onset", "response_time", "outcome_onset",
                                   "outcome", "what"))
  dsacp_processed <- process_ds(dsacp, subject, 1, "Placebo")
  dsacm_processed <- process_ds(dsacm, subject, 1, "Drug Amisulpride")
  
  # This is phase 2 (both placebo and drug sessions)
  dstrp <- read.table(file = files_tr_p[[subject]], header = FALSE,
                     col.names = c("trial", "block_num", "trial_type", "left_stimulus",
                                   "right_stimulus", "stimulus_onset", "choice",
                                   "response_onset", "response_time", "what"))
  dstrm <- read.table(file = files_tr_am[[subject]], header = FALSE,
                     col.names = c("trial", "block_num", "trial_type", "left_stimulus",
                                   "right_stimulus", "stimulus_onset", "choice",
                                   "response_onset", "response_time", "what"))
  dstrp_processed <- process_ds(dstrp, subject, 2, "Placebo")
  dstrm_processed <- process_ds(dstrm, subject, 2, "Drug Amisulpride")
  
  # Combine the processed datasets
  ds_processed_all <- rbind(dsacp_processed, dstrp_processed, dsacm_processed, dstrm_processed)
  # Fix the trials - make consecutive over the two phases learning and transfer (total 540 trials)
  ds_processed_all$trial <- c(1:length(which(ds_processed_all$condition == 1)),
                              1:length(which(ds_processed_all$condition == 2)))
  return(ds_processed_all)
}

# Function call
alldata_processed <- lapply (1:num_subjects, FUN = process_session)

is.na(alldata_processed$choice)

# Combine and save processed data
ds_final <- do.call("rbind", alldata_processed)
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
