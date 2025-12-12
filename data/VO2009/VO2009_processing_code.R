### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Valentin & O'Doherty (2009) Overlapping Prediction Errors in Dorsal Striatum During Instrumental Learning With Juice and Money Reward in the Human Brain

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "VO2009"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet
# Money, juice, scrambled money, and neutral trial types
# Different options though identical outcome probabilities
# There is either a reward or not (nothing), so we can code them as 1 and 0

option <- LETTERS[1:8]
out_1 <- c(1, 1, 1, 1, 1, 1, 1, 1)
pr_1 <- c(0.6, 0.3, 0.6, 0.3, 0.6, 0.3, 0.6, 0.3)
out_2 <- c(0, 0, 0, 0, 0, 0, 0, 0)
pr_2 <- c(0.4, 0.7, 0.4, 0.7, 0.4, 0.7, 0.4, 0.7)
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)

# description <- c("P(+5 cents) = 0.6, P(Nothing) = 0.4",
#                  "P(+5 cents) = 0.3, P(Nothing) = 0.7",
#                  "P(Juice) = 0.6, P(Nothing) = 0.4",
#                  "P(Juice) = 0.3, P(Nothing) = 0.7",
#                  "P(Scrambled 5 cents) = 0.6, P(Nothing) = 0.4",
#                  "P(Scrambled 5 cents) = 0.3, P(Nothing) = 0.7",
#                  "P(Neutral solution) = 0.6, P(Nothing) = 0.4",
#                  "P(Neutral solution) = 0.3, P(Nothing) = 0.7")

# Save options sheet
file_name <- paste0(paper, "_", "1", "_", "options.csv")
setwd(data_path)
write.table(options_table, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

################################################################################################

### Process dataset

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper","data_path","raw_path")))
study <- 1
# Back to raw data directory
setwd(raw_path)
setwd("BehavioralData_JuiceMoney")

# Read the data
if (!requireNamespace("R.matlab", quietly = TRUE)) install.packages("R.matlab")
library(R.matlab)
files <- list.files()
files_list <- split(files, ceiling(seq_along(files)/2))
# Extract subject IDs
subject_ids <- gsub('^.*s\\s*|\\s*_run.*$', '', files)
subject_ids <- as.numeric(subject_ids) # Convert to numbers
subject_ids_list <- split(subject_ids, ceiling(seq_along(subject_ids)/2))
#problem <- 1
option <- LETTERS[1:8]
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
options_map <- c(`1`="A_B", `2`="C_D", `3`="E_F", `4`="G_H")
reward_map <- c(`1`=1, `2`=0, `0`=0)
psd_list <- vector(mode = "list", length(files_list))


for (sb in 1:length(files_list)) {
  subject <- subject_ids_list[[sb]][1]
  # Read subject's data
  dfrun1 <- readMat(files_list[[sb]][1])
  dfrun1 <- dfrun1$Data
  dfrun2 <- readMat(files_list[[sb]][2])
  dfrun2 <- dfrun2$Data
  # For some subjects, the desired data structures are in different locations
  if (sb %in% c(6,9)) {
    sex <- as.character(dfrun1[[3]]) # Subject's gender
    # Extract trial data
    df1 <- as.data.frame(dfrun1[[32]])
    df2 <- as.data.frame(dfrun2[[34]])
  } else if (sb %in% c(2,5)) {
    sex <- as.character(dfrun1[[3]])
    df1 <- as.data.frame(dfrun1[[32]])
    df2 <- as.data.frame(dfrun2[[32]])
  } else {
    sex <- as.character(dfrun1[[5]])
    df1 <- as.data.frame(dfrun1[[34]])
    df2 <- as.data.frame(dfrun2[[34]])
  }
  #[run trialnum trialtype(1=Money,2=Juice,3=Scramb,4=Neut) choicetype(1=60%,2=30%,0=omitted) Rewarded(1=yes,2=no) onscue onsresp rt onsout]
  colnames(df1) <- c("run", "trial", "condition", "choice_type", "rewarded", "onscue", "onsresp", "rt", "onsout")
  colnames(df2) <- c("run", "trial", "condition", "choice_type", "rewarded", "onscue", "onsresp", "rt", "onsout")
  # Build variables
  # problem <- c(df1$condition, df2$condition)
  problem <- 1
  options <- c(options_map[as.character(df1$condition)], options_map[as.character(df2$condition)])
  trial <- c(df1$trial, df2$trial)
  note1 <- c(rep("Session 1", nrow(df1)), rep("Session 2", nrow(df2)))
  choice_1 <- ifelse(df1$choice_type == 1, choice_pairs[df1$condition, 1],
                     ifelse(df1$choice_type == 2, choice_pairs[df1$condition, 2], NA))
  choice_2 <- ifelse(df2$choice_type == 1, choice_pairs[df2$condition, 1],
                     ifelse(df2$choice_type == 2, choice_pairs[df2$condition, 2], NA))
  choice <- c(choice_1, choice_2)
  # Rewarded(1=yes,2=no)
  rewarded <- c(reward_map[as.character(df1$rewarded)], reward_map[as.character(df2$rewarded)])
  unknown_reward_ind <- which(is.na(rewarded))
  outcome <- paste(choice, rewarded, sep = ":")
  response_time <- c(round(df1$rt), round(df2$rt))
  no_response <- which(response_time == 0)
  response_time[no_response] <- NA
  outcome[no_response] <- NA
  outcome[unknown_reward_ind] <- NA
  # Rest of variables
  age <- education <- stage <- note2 <- condition <- NA
  # Processed data
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine and save processed data
psd_combined <- do.call("rbind", psd_list)
ds_final <- psd_combined [order(psd_combined$subject), ]

ds_final$choice <- as.character(ds_final$choice)
ds_final$outcome <- as.character(ds_final$outcome)

file_name <- paste0(paper, "_", "1", "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")


