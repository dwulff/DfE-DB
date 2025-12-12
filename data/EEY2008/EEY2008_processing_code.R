### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Erev, Ert & Yechiam (2008) Loss Aversion, Diminishing Sensitivity, and the Effect of Experience on Repeated Decisions

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "EEY2008"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)
##### Create the options sheet

# Study 1 (Only 1a is available/coded)
option <- LETTERS[1:8]
# First 8 exp 1a (up to 2400)
out_1 <- c(0,   1000,   1000,   2000,   400,   1400,   1400,   2400)#,   200,   1000,   1200,   2000)
pr_1 <- c(1,    0.5,    1,      0.5,    1,     0.5,    1,      0.5)#,    0.5,   0.5,    0.5,    0.5)
out_2 <- c(NA, -1000,   NA,     0,      NA,   -600,    NA,     400)#,   -200,  -1000,   800,    0)
pr_2 <- c(NA,   0.5,    NA,     0.5,    NA,    0.5,    NA,     0.5)#,    0.5,   0.5,    0.5,    0.5)
# Save to data frame
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Study 3
# Notation
# TN(25,17.7,0) = Truncated normal distribution (at zero) with a mean of 25 and a standard deviation of 17.7 (with an implied mean of 25.63)
# U(0,1) = Uniform distribution, a draw from the specified interval.
option <- LETTERS[1:16]
# Note that problems 1 & 2 (7 & 8 in the paper) - ABCD -  were associated with a binomial distribution
# and problems 3 & 4 (9 & 10 in the paper) - EFGH - were associated with a normal distribution
description <- c("U(0,1)", "U(-1,0) with probability 0.5, otherwise U(2,3)",
                 "U(3,4)", "U(2,3) with probability 0.5, otherwise U(5,6)",
                 "TN(0.25,0.177^2,0)", "N(1,3.54^2)",
                 "TN(12.25,0.177^2,12)", "N(13,3.54^2)",
                 "100*U(0,1)", "100*U(-1,0) with probability 0.5, otherwise 100*U(2,3)",
                 "100*U(3,4)", "100*U(2,3) with probability 0.5, otherwise 100*U(5,6)",
                 "100*TN(0.25,0.177^2,0)", "100*N(1,3.54^2)",
                 "100*TN(12.25,0.177^2,12)", "100*N(13,3.54^2)")
options_table2 <- data.frame(option, description)

# Save options
file_name1 <- paste0(paper, "_", "1", "_", "options.csv")
file_name2 <- paste0(paper, "_", "3", "_", "options.csv")

setwd(data_path)
write.table(options_table1, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(options_table2, file = file_name2, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

### Process dataset
### Study 1

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper", "raw_path", "data_path")))
setwd(raw_path)
setwd("Raw_nf1000")
study <- 1
files <- list.files()
# Extract subject IDs
subject_ids <- gsub('^.*NoNoise_tous_\\s*|\\s*.txt.*$', '', files)
subject_ids <- as.numeric(subject_ids)
option <- LETTERS[1:8]
choice_pairs <- matrix(option, ncol = 2, nrow = 4, byrow = TRUE)
game_to_problem <- c(`1`=1, `2`=3, `3`=2, `4`=4) # Order as in the paper
options_map <- c(`1`="A_B", `2`="C_D", `3`="E_F", `4`="G_H")
trial <- rep(c(1:100), 4)
psd_list <- vector(mode = "list", length(files))

for (sb in 1:length(psd_list)) {
  # Study 1 variables are organized as follows: trial; game; order(of game); safe outcome; risky outcome; decision (0 for choosing safe, 1 for choosing risk); reward
  df <- read.table(files[sb], header = FALSE, stringsAsFactors = FALSE, fill = NA,
                 col.names = c("trial", "game", "order", "safe_outcome", "risky_outcome", "decision", "reward"))
  df <- df[-nrow(df), ] # Remove last row (contains total)
  subject <- subject_ids[sb] # Subject
  problem <- unname(game_to_problem[as.character(df$game)])
  options <- unname(options_map[as.character(problem)])
  choice <- ifelse(df$decision == 0, choice_pairs[problem, 1], choice_pairs[problem, 2])
  outcome <- paste(choice, df$reward, sep = ":")
  response_time <- stage <- sex <- age <- education <- note1 <- note2 <- condition <- NA
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine and save processed data
ds_st1_final <- do.call("rbind", psd_list)
ds_st1_final$choice[ds_st1_final$trial == 100] <- NA
ds_st1_final$outcome[ds_st1_final$trial == 100] <- NA
file_name1 <- paste0(paper, "_", "1", "_", "data.csv")
setwd(data_path)
write.table(ds_st1_final, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

# Study 3
# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper", "raw_path", "data_path")))
# Back to directory and read data

setwd(raw_path)
study <- 3
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
file_data <- "raw12_5_send.xlsx"
ds_low <- read_excel(file_data, sheet = "smallamounts", col_names = c("trial", "decision", "game", "payoff"))
ds_high <- read_excel(file_data, sheet = "largeamounts", col_names = c("trial", "decision", "game", "payoff"))
option <- LETTERS[1:16]
choice_pairs <- matrix(option, ncol = 2, nrow = 8, byrow = TRUE)
options_map <- c(`1`="A_B", `2`="C_D", `3`="E_F", `4`="G_H", `5`="I_J", `6`="K_L", `7`="M_N", `8`="O_P")
process_condition <- function (ds, cnd) {
  pd <- data.frame()
  # Split dataset into list of subject-level data (# 4 games X 100 trials each)
  ds_list <- split(ds, (as.numeric(rownames(ds))-1) %/% 400)
  psd_list <- vector(mode = "list", length(ds_list))
  for (sb in 1:length(ds_list)) {
    # Read data
    df <- ds_list[[sb]]
    if (cnd == "Condition Low") {
      subject <- sb
      df$pay <- df$payoff
    } else {
      subject <- sb + 50 # Start from 51 for the second group
      df$pay <- df$payoff/100
    }
    # The game variable gives the order rather than the problems, so identify the problem order for each subject
    # Split df into 4 blocks
    df_list <- split(df, rep(1:ceiling(nrow(df)/100), each=100, length.out=nrow(df)))
    problem_list <- vector(mode = "list", length(df_list))
    ## problem
    for (d in 1:length(df_list)) {
      f <- df_list[[d]]
      
      # calculate mean，exclude NA
      m <- mean(f[f$decision == 1, ]$pay, na.rm = TRUE)
      m2 <- mean(f[f$decision == 2, ]$pay, na.rm = TRUE)
      pay_values <- f[f$decision == 1, ]$pay
      # calculate min/max
      min_pay <- ifelse(all(!is.na(f$pay)), min(f$pay, na.rm = TRUE), NA)
      max_pay <- ifelse(all(!is.na(f$pay)), max(f$pay, na.rm = TRUE), NA)
      
      # add problem
      if (!is.na(m) && min_pay >= -1 && max_pay <= 3 && all(pay_values <= 0 | pay_values >= 2, na.rm = TRUE)) {
        f$problem <- 1
      }else if(is.na(m) && m2 >= 0.3 && m2 <= 0.7 ){
        f$problem <- 1
      }else if (!is.na(m) && min_pay >= 2 && max_pay <= 6 && all(pay_values <= 3 | pay_values >= 5, na.rm = TRUE)) {
        f$problem <- 2
      } else if(is.na(m) && m2 >= 3 && m2 <= 4 ){
        f$problem <- 2
      }else if ((!is.na(m) && m >= 10) ||( !is.na(m2) && m2 >= 10)) {
        f$problem <- 4
      } else {
        f$problem <- 3
      }
      problem <- ifelse(cnd == "Condition Low", f$problem, f$problem + 4)
      options <- unname(options_map[as.character(problem)])
      trial <- f$trial
      # Decision = 2 = safe option
      choice <- ifelse(f$decision == 2, choice_pairs[problem, 1], choice_pairs[problem, 2])
      outcome <- paste(choice, f$payoff, sep = ":")
      # Condition high is condition low payoffs times 100 (p. 584)
      condition <- ifelse(cnd == "Condition Low", 1, 2)
      note1 <- cnd
      response_time <- stage <- sex <- age <- education <- note2 <- NA
      # Create final dataframe
      psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
      pd <- rbind(pd, psd)
    }
  }
  return(pd)
}

# Combine processed data
psd_combined1 <- process_condition(ds = ds_low, cnd = "Condition Low")
psd_combined2 <- process_condition(ds = ds_high, cnd = "Condition High")
psd_combined <- rbind(psd_combined1, psd_combined2)
ds_st2_final <- psd_combined [order(psd_combined$subject, psd_combined$problem, psd_combined$trial), ]
# Save
file_name2 <- paste0(paper, "_", "3", "_", "data.csv")
setwd(data_path)
write.table(ds_st2_final, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
