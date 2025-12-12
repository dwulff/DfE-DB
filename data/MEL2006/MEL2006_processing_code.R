### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Munichor et al. (2006) Risk Attitude in Small Timesaving Decisions

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "MEL2006"
studies <- c(1, 2)
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

#### Create options sheets

### Study 1
# Two problems, but the data of only ONE problem (Problem 1) is available
# Two options - safe and risky, in that order
option <- c("A", "B")
out_1 <- c(-2.8, -3)
pr_1 <- c(1, 0.9)
out_2 <- c(NA, -1)
pr_2 <- c(NA, 0.1)
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

### Study 2
# Identical to problem 1 experiment 1 (with limited feedback)
option <- c("A", "B")
out_1 <- c(-2.8, -3)
pr_1 <- c(1, 0.9)
out_2 <- c(NA, -1)
pr_2 <- c(NA, 0.1)
options_table2 <- data.frame(option, out_1, pr_1, out_2, pr_2)

### Study 3 - data unavailable
### Study 4 - data unavailable

# Save options
file_name1 <- paste0(paper, "_", studies[1], "_", "options.csv")
file_name2 <- paste0(paper, "_", studies[2], "_", "options.csv")
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

### Process datasets

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper", "studies","data_path","raw_path")))
# Back to raw data directory
setwd(raw_path)
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)

### Study 1
study <- studies[1]
# Data file for experiment 1 problem 1 (problem 2 not available - data lost)
file_exp1 <- "Exp1-Problem1-data_time_2.8_FP.xls"
dse1 <- read_excel(file_exp1, sheet = "time FP raw choices") # Data on choices and payoffs
dse1_fg <- read_excel(file_exp1, sheet = "time FP raw forgone") # Data on foregone payoffs
subj_id <- dse1$ID # Subject IDs (n=24 for problem 1)
problem <- 1
trial <- 1:100
options <- "A_B"
psd_st1_list <- vector(mode = "list", length(subj_id))

for (sb in 1:length(subj_id)) {
  subject <- subj_id[sb] # Subject ID
  df <- dse1[dse1$ID == subject, ] # Subject data (choices and outcomes)
  df_foregone <- dse1_fg[dse1_fg$ID == subject, ] # Foregone payoffs
  # Map choices (0 = safe choice) and outcomes
  choice_raw <- df[which(names(df) == "button1"):which(names(df) == "button100")]
  choice <- ifelse(as.numeric(choice_raw) == 0, "A", "B")
  payoff <- df[which(names(df) == "Outcome1"):which(names(df) == "Outcome100")]
  foregone_choice <- ifelse(choice == "A", "B", "A")
  foregone_payoff <- df_foregone[which(names(df_foregone) == "FP1"):which(names(df_foregone) == "FP100")]
  outcome_choose <- paste(choice, as.character(payoff),sep = ":")
  outcome_forgone <- paste(foregone_choice, as.character(foregone_payoff),sep = ":")
  outcome <- paste(outcome_choose, outcome_forgone, sep = "_")
  # Rest of variables
  response_time <- stage <- sex <- age <- education <- condition <- note1 <- note2 <- NA
  # Create dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_st1_list[[sb]] <- psd # Store
}
# Combine all dataframes in the list
ds_st1_final <- do.call("rbind", psd_st1_list)

### Study 2
study <- studies[2]
file_exp2 <- "Exp2-data_time_2.8.xls"
dse2 <- read_excel(file_exp2, sheet = "time raw") # Data on choices and payoffs
problem <- 1
trial <- 1:100
options <- "A_B"
subj_id <- dse2$ID # Subject IDs
psd_st2_list <- vector(mode = "list", length(subj_id))

for (sb in 1:length(subj_id)) {
  subject <- subj_id[sb] # Subject ID
  df <- dse2[dse2$ID == subject, ] # Subject data (choices and outcomes)
  # Map choices (0 = safe choice) and outcomes
  choice_raw <- df[which(names(df) == "button1"):which(names(df) == "button100")]
  payoff_raw <- df[which(names(df) == "outcome1"):which(names(df) == "outcome100")]
  choice <- ifelse(as.numeric(choice_raw) == 0, "A", "B")
  # Only feedback on obtained payoffs
  outcome <- paste(choice, as.character(payoff_raw), sep = ":")
  # Rest of variables
  response_time <- stage <- sex <- age <- education <- note1 <- note2 <- condition <- NA
  # Create dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_st2_list[[sb]] <- psd # Store
}
# Combine all dataframes in the list
ds_st2_final <- do.call("rbind", psd_st2_list)

# Save data
file_name1 <- paste0(paper, "_", studies[1], "_", "data.csv")
file_name2 <- paste0(paper, "_", studies[2], "_", "data.csv")
setwd(data_path)
write.table(ds_st1_final, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(ds_st2_final, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
