### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Kim, Shimojo, & O'Doherty (2006) Is Avoiding an Aversive Outcome Rewarding? Neural Substrates of Avoidance Learning in the Human Brain

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "KSO2006"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet
# Reward and loss avoidance, pkus neutral condition
# The neutral options will be included because their outcomes are not random
# In this problem Neutral/scrambled dollar = 1, no feedback = 0

option <- c("A", "B", "C", "D", "E", "F", "G", "H")
out_1 <- c(1,    1,     0,      0,      1,      1,     0,     0)
pr_1 <- c(0.6,   0.3,   0.6,    0.3,    0.6,    0.3,   0.6,    0.3)
out_2 <- c(0,    0,     -1,     -1,     0,     0,    -1,      -1)
pr_2 <- c(0.4,   0.7,   0.4,    0.7,    0.4,    0.7,   0.4,    0.7)
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options sheet
file_name <- paste0(paper, "_", "1", "_", "options.csv")
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
# NOTE: The data available does not resemble the exact experimental run.
# The two sessions were combined and all trials sorted by condition.

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path")))
# Working directory is in processed/options at this point, so go back to raw_data
setwd(raw_path)
setwd("behavioral_data")
study <- 1
# Read the data (two MATLAB files)
if (!requireNamespace("R.matlab", quietly = TRUE)) install.packages("R.matlab")
library(R.matlab)
file_choices <- "choice_data.mat" # choice sequences for four conditions 
file_outcomes <- "outcome_data.mat" # outcome sequences for four conditions
ds_choices <- readMat(file_choices)
ds_outcomes <- readMat(file_outcomes)
conditions_v <- c("Reward condition", "Punishment condition", "Neutral reward", "Neutral punishment")
options_map <- c(`1`="A_B", `2`="C_D", `3`="E_F", `4`="G_H")
option <- c("A", "B", "C", "D", "E", "F", "G", "H")
choice_pairs <- matrix(option, ncol = 2, byrow =  TRUE) # Create matrix
ds_choices <- ds_choices$choice
ds_outcomes <- ds_outcomes$reward
cnd_list <- vector(mode = "list", length(conditions_v)) # To store all psds

for (cnd in 1:length(conditions_v)) {
  condition <- cnd
  problem <- cnd
  options <- unname(options_map[as.character(cnd)])
  note1 <- conditions_v[cnd] # Label
  ch_cond <- ds_choices[[cnd]] # Condition data
  out_cond <- ds_outcomes[[cnd]]
  ch_subj <- ch_cond[[1]] # List for all subjects
  out_subj <- out_cond[[1]]
  # Process subjects for the current condition
  psd_list <- vector(mode = "list", length(ch_subj))
  for (sb in 1:length(ch_subj)) {
    subject <- sb
    choice_raw <- unname(unlist(ch_subj[[sb]]))
    outcome_raw <- unname(unlist(out_subj[[sb]]))
    # 80 trials per condition, but the number is not always 80, total = 80*4 = 320
    trial <- 1:length(choice_raw)
    # Map choices and outcomes
    choice <- ifelse(choice_raw == 2, choice_pairs[cnd, 1], choice_pairs[cnd, 2]) # 2 = optimal choice
    outcome <- paste(choice, outcome_raw, sep = ":")
    response_time <- stage <- sex <- age <- education <- note2 <- NA
    # Create final dataframe
    pdf <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    psd_list[[sb]] <- pdf
  }
  psd_combined <- do.call("rbind", psd_list)
  cnd_list[[cnd]] <- psd_combined
}

cnd_combined <- do.call("rbind", cnd_list)
ds_final <- cnd_combined [order(cnd_combined$subject, cnd_combined$problem, cnd_combined$condition), ] # Sort
# Save processed data
file_name <- paste0(paper, "_", "1", "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
