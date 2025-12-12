### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Rosati & Hare (2016) Reward currency modulates human risk preferences

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "RH2016"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

### Study 1
# Three conditions, one problem
# Safe and risky options
option <- c("A", "B", "C", "D", "E", "F")
out_1 <- c("low", "good", "low", "good", "low", "good")
pr_1 <- c(0.33, 0.5, 0.33, 0.5, 0.33, 0.5)
out_2 <- c("medium", "bad", "medium", "bad", "medium", "bad")
pr_2 <- c(0.33, 0.5, 0.33, 0.5, 0.33, 0.5)
out_3 <- c("high", NA, "high", NA, "high", NA)
pr_3 <- c(0.33, NA, 0.33, NA, 0.33, NA)
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2, out_3, pr_3)

### Study 2
# One problem, two conditions (get to keep the monetary gains in the end, or will have to exchange
# them for prizes)
option <- c("A", "B") # Safe and risky, in that order
out_1 <- c(0.5, 1)
pr_1 <- c(1, 0.5)
out_2 <- c(NA, 0.01)
pr_2 <- c(NA, 0.5)
options_table2 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options
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
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
# Read datasets
file_st1 <- "Rosati&Hare_2016_Study1_TrialData_10.20.17.xlsx"
file_st2 <- "Rosati&Hare_2016_Study2_TrialData_10.20.17.xlsx"
ds_st1 <- read_excel(file_st1, sheet = "Trial Data")
ds_st2 <- read_excel(file_st2, sheet = "Trial Data")

process_st <- function (ds, st) {
  study <- st
  subject_freq <- rle(ds$`DEIDENTIFIED-ID`) # Subject IDs and frequencies
  options_all <- c("A_B", "C_D", "E_F")
  option <- c("A", "B", "C", "D", "E", "F")
  choice_pairs <- matrix (option, ncol = 2, byrow = TRUE) # Used when mapping choices
  
  psd_list <- vector(mode = "list", length(subject_freq$values))
  
  for (sb in 1:length(subject_freq$values)) {
    subject <- subject_freq$values[sb]
    df <- ds[ds$`DEIDENTIFIED-ID` == subject, ] # Subject data
    trial <- df$Trial
    choice <- ifelse(df$Choice_Risky == 0, option[1], option[2])
    if (st == 1) {
      riskyOutcome_map <- c(`G`="good", `B`="bad")
      payoff <- ifelse(df$Choice_Risky == 0, df$Safe_value, riskyOutcome_map[as.character(df$Risk_payoff)])
      note_map <- c(`Food`="Food rewards", `Money`="Monetary rewards", `Prize`="Prize rewards")
      cnd_map <- c(`Food`=1, `Money`=2, `Prize`=3)
      note1 <- note_map[as.character(df$Condition)]
      problem <- cnd_map[as.character(df$Condition)]
      options <- options_all[problem]
      choice <- ifelse(df$Choice_Risky == 0, choice_pairs[problem, 1], choice_pairs[problem, 2])
      condition <- 1
      problem <- cnd_map[as.character(df$Condition)]
      note2 <- "All possible outcomes were shown beforehand"
      outcome_opt1 <- paste0(option[1], df$Safe_value)
      outcome_opt2 <- paste0(option[2], riskyOutcome_map[as.character(df$Risk_payoff)])
      outcome <- paste(choice, payoff, sep = ":")
    } else {
      riskyOutcome_map <- c(`G`=1, `B`=0.01)
      payoff <- ifelse(df$Choice_Risky == 0, 0.5, riskyOutcome_map[as.character(df$Risk_payoff)])
      note_map <- c(`Keep`="Could keep monetary gains", `Trade`="Will exchange monetary gains for prizes")
      note1 <- note_map[as.character(df$Condition)]
      problem <- 1
      options <- options_all[problem]
      condition <- ifelse(df$Condition == "Keep", 1, 2)
      note2 <- "All possible outcomes were shown beforehand"
      outcome <- paste(choice, payoff, sep = ":")
    }
    sex <- tolower(df$Sex)
    age <- df$Age
    response_time <- stage <- education <- NA
    # Create final dataframe
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    psd_list[[sb]] <- psd
  }
  # Combine processed data
  psd_combined <- do.call("rbind", psd_list)
  return(psd_combined)
}

# Function calls
ds_st1_final <- process_st (ds = ds_st1, st = 1)
ds_st2_final <- process_st (ds = ds_st2, st = 2)
# Save processed data
file_name1 <- paste0(paper, "_", "1", "_", "data.csv")
file_name2 <- paste0(paper, "_", "2", "_", "data.csv")
setwd(data_path)
write.table(ds_st1_final, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(ds_st2_final, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
