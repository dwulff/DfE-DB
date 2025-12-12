### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Niv et. al (2012) Neural Prediction Errors Reveal a Risk-Sensitive Reinforcement-Learning Process in the Human Brain

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "NEDO2012"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Five options, CS1-CS5
option <- c("A", "B", "C", "D", "E")
out_1 <- c(2, 4, 4, 0, 0)
pr_1 <- c(1, 0.5, 1, 1, 1)
out_2 <- c(NA, 0, NA, NA, NA)
pr_2 <- c(NA, 0.5, NA, NA, NA)
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options sheet
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
study <- 1
if (!requireNamespace("R.matlab", quietly = TRUE)) install.packages("R.matlab")
library(R.matlab)
file_data <- "RiskExperimentOnlineData.mat"
ds <- readMat(file_data)
ds <- ds$OnlineData
option <- c("A", "B", "C", "D", "E")
options_map <- c(`1`="A", `2`="B", `3`="C", `4`="D", `5`="E",
                 `6`="A_B", `7`="B_C", `8`="A_C", `9`="B_D", `10`="A_E", `11`="D_E")
# List to process subjects' processed data
psd_list <- vector(mode = "list", length(ds))

for (sb in 1:length(ds)) {
  subject <- as.numeric(sb)
  df <- ds[[sb]] # Subject's data
  df <- df[[1]] # Go into nest
  trial_types <- unname(unlist(df[[3]])) # 3 sessions combined, total 234 trials
  # problem <- trial_types
  problem <- 1
  trial <- 1:length(trial_types)
  options <- unname(options_map[as.character(trial_types)])
  choice_raw <- unname(unlist(df[[5]]))
  choice <- option[choice_raw]
  payoff <- unname(unlist(df[[4]]))
  outcome <- ifelse(is.na(choice), NA, paste(choice, payoff, sep = ":"))
  choice <- ifelse(trial_types <= 5, "", choice)
  # Rest of variables
  note1 <- sapply(options, function (op)
    ifelse(length(unlist(strsplit(op, "_"))) == 1, "Forced choice", ""))
  response_time <- stage <- sex <- age <- education <- note2 <- condition <- NA
  # Processed data
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine data
ds_final <- do.call("rbind", psd_list)

ds_final$choice <- as.character(ds_final$choice)
ds_final$outcome <- as.character(ds_final$outcome)

# Save processed data
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")
