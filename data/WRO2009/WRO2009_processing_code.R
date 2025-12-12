### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Wunderlich et al. (2009) Neural computations underlying action-based decision making in the human brain

# Open issue: choice code inconsistent...

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "WRO2009"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

##### Create the options sheet

# Eye movement or button press (with interspersed forced choice trials)
option <- c("A", "B")
description <- c("Button press with the right index finger: P(10 cents) varied according to a gaussian random walk process in 200 out of 300 trials. In 100 trials this option/action yielded no reward (forced choice or null trials)",
                 "A saccade from a central fixation cross to a target located at 10 degree of visual angle in the right hemifield. P(10 cents) varied according to a gaussian random walk process in 200 out of 300 trials. In 100 trials this option/action yielded no reward (forced choice or null trials)")
                 
options_table <- data.frame(option, description)

# Save options
file_name <- paste0(paper, "_", "1", "_", "options.csv")
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
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)
setwd("DataforAhmad")
study <- 1
# Read data
if (!requireNamespace("R.matlab", quietly = TRUE)) install.packages("R.matlab")
library(R.matlab)
files <- list.files()
problem <- 1
# Extract subject IDs
subject_ids <- gsub('^.*subj\\s*|\\s*.mat.*$', '', files)
subject_ids <- as.numeric(subject_ids)
# 1=choice, 2=hand trials, 3=eye trials, 4=null choice
note_map <- c(`1`="Both actions could yield a reward", `2`="Only B (saccade) would yield a reward", `3`="Only A (button press) would yield a reward", `4`="Neither action/option would yield a reward")
option <- c("A", "B")
options <- "A_B"
#choice_pairs <- matrix(option, ncol = 2, nrow = 4, byrow = TRUE)

psd_list <- vector(mode = "list", length(files))

for (sb in 1:length(files)) {
  subject <- subject_ids[sb]
  df <- readMat(files[sb])
  df <- df$ep
  result <- as.data.frame(df[[17]], stringsAsFactors = FALSE) # matrix containing the data
  colnames(result) <- c("u1", "trial_type", "reward", "u2", "choice")
  trial <- 1:nrow(result)
  # Sort according to trial_type to check which is which (assuming 1 = hand, 2 = eye)
  #test <- result[order(result$trial_type), ]
  # x <- rle(test$trial_type), 150 free, 50 eye, 50 hand, and 50 null trials
  # If 1=free choice, 2= eye trials, 3=hand trials, 4= null trials, then (re choice, 1=hand, 2=eye)
  choice <- ifelse(result$choice == 1, "A", "B") # A is button press
  #outcome <- result$reward
  outcome <- paste(choice, result$reward, sep = ":")
  note1 <- note_map[as.character(result$trial_type)] # trial type data also in df[[10]]
  # Rest of variables
  response_time <- stage <- sex <- age <- education <- note1 <- note2 <- condition <- NA
  # Processed data
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine data
psd_combined <- do.call("rbind", psd_list)
# Indicate non-choices
psd_combined[substr(psd_combined$outcome, nchar(psd_combined$outcome) - 1, nchar(psd_combined$outcome)) == -1, "choice"] <- NA
psd_combined[substr(psd_combined$outcome, nchar(psd_combined$outcome) - 1, nchar(psd_combined$outcome)) == -1, "outcome"] <- NA
# Save results
ds_final <- psd_combined [order(psd_combined$subject), ]
file_name <- paste0(paper, "_", "1", "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
