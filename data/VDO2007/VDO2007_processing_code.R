### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Valentin et al. (2007) Determining the Neural Substrates of Goal-Directed Learning in the Human Brain

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "VDO2007"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet
# Tomato, orange, chocolate, or a neutral solution
option <- LETTERS[1:8]
#description <- c("P(Tomato juice) = 0.4, P(Orange juice) = 0.3, P(Nothing) = 0.3",
#                 "P(Orange juice) = 0.3, P(Nothing) = 0.7",
#                 "P(Chocolate milk) = 0.4, P(Orange juice) = 0.3, P(Nothing) = 0.3",
#                 "P(Orange juice) = 0.3, P(Nothing) = 0.7",
#                 "P(Neutral solution) = 0.7, P(Nothing) = 0.3",
#                 "P(Neutral solution) = 0.3, P(Nothing) = 0.7")
# First 8 exp 1a (up to 2400)
out_1 <- c('Tomato', 'Orange', 'Chocolate', 'Orange', 'Neutral', 'Neutral', 'DevTomato', 'DevChocolate')
pr_1 <-  c(0.4, 0.3,   0.4, 0.3,  0.7,  0.3, 0.4, 0.4)
out_2 <- c('Orange', '0', 'Orange','0','0','0', 'Orange', 'Orange')
pr_2 <-  c(0.3,  0.7, 0.3,  0.7,   0.3,   0.7, 0.3, 0.3)
out_3 <- c('0',NA,'0', NA,NA, NA, '0', '0')      
pr_3 <-  c(0.3, NA, 0.3,  NA, NA, NA, 0.3, 0.3)
# Save to data frame
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2, out_3, pr_3)

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

# Clear all variables except path, paper, and studies
#rm(list=setdiff(ls(), c("path", "paper")))
study <- 1
# Back to raw data directory
setwd(raw_path)
setwd("BehavioralData_JuiceDev")
# Read the data
if (!requireNamespace("R.matlab", quietly = TRUE)) install.packages("R.matlab")
library(R.matlab)
files <- list.files()
files <- files[-grep("Pleasantness19.xls", files)] # Remove unnecessary file
# Use the updated S24 training file
#file.copy(from = "s24TrainExtra5trials.mat", to = "s24Train.mat", overwrite = TRUE) # Done
files_list <- split(files, ceiling(seq_along(files)/2)) # Create tests/train pairs
# Extract subject IDs
subject_ids <- gsub('^.*s\\s*|\\s*Train.mat.*$', '', files)
subject_ids <- as.numeric(subject_ids) # Convert to numbers
subject_ids <- subject_ids[!is.na(subject_ids)] # Remove NAs
# Extract devalued reward
devalued <- gsub('^.*Dev_\\s*|\\s*.mat.*$', '', files)
devalued_list <- split(devalued, ceiling(seq_along(devalued)/2)) # Pairs like files_list
#problem <- 1
option <- c("A", "B", "C", "D", "E", "F", "G", "B", "H", "D")
#option_dev1 <- c("AG", "AB", "AC", "AD", "AE", "AF")
#option_dev2 <- c("AH", "AB", "AC", "AD", "AE", "AF")
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
#choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
#choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
# 1=tomato condition, 2=chocolate , 3=neutral
options_map <- c(`1`="A_B", `2`="C_D", `3`="E_F", `4`="G_B", `5`="H_D")
response_map <- c(`11`=1, `21`=1, `31`=1, `10`=2, `20`=2, `30`=2, `0`=" ") # Otherwise NA (auto)
# 1=tomato 2=chocolate 3=neutral 4=orange outcome
outcome_map <- c(`0`="0",`1`="Tomato", `2`="Chocolate", `3`="Neutral", `4`="Orange", `5`="DevTomato", `6`="DevChocolate")
psd_list <- vector(mode = "list", length(files_list))

dftest <- readMat(files_list[[3]][2]) # Read subject's training and test data
dftest <- as.data.frame(dftest$s.cue.resp.out)

for (sb in 1:length(files_list)) {
  dftest <- readMat(files_list[[sb]][1]) # Read subject's training and test data
  dftest <- as.data.frame(dftest$s.cue.resp.out)
  colnames(dftest) <- c("trial", "cue", "response", "outcome") # Add column names
  dftrain <- readMat(files_list[[sb]][2])
  dftrain <- as.data.frame(dftrain$s.cue.resp.out)
  colnames(dftrain) <- c("trial", "cue", "response", "outcome")
  
  # Check for task completion and skip violators
  if (nrow(dftrain) != 150 || nrow(dftest) != 150) {
    psd_list[[sb]] <- NA
    # Skip to next iteration
    next
  }

  subject <- subject_ids[sb]
  trial <- unname(c(dftrain$trial, dftest$trial))
  
  if (grepl('Tomat', files_list[[sb]][1], fixed = TRUE)) {
    dftest$cue <- ifelse(dftest$cue==1, dftest$cue+3, dftest$cue)
    dftest$outcome <- ifelse(dftest$outcome==1, dftest$outcome+4, dftest$outcome)
    problem <- unname(c(dftrain$cue, dftest$cue))
  }
  else if (grepl('Choco', files_list[[sb]][1], fixed = TRUE)) {
    dftest$cue <- ifelse(dftest$cue==2, dftest$cue+3, dftest$cue)
    dftest$outcome <- ifelse(dftest$outcome==2, dftest$outcome+4, dftest$outcome)
    problem <- unname(c(dftrain$cue, dftest$cue))
  }
  options <- unname(options_map[as.character(problem)])
  # Replace choice data with indices (1 for A,C,E, and 2 for B,D,F) and map afterwards
  choice_index_train <- unname(response_map[as.character(dftrain$response)])
  choice_index_test <- unname(response_map[as.character(dftest$response)])
  choice_train <- sapply(1:nrow(dftrain), function (n)
    choice_pairs[as.numeric(dftrain$cue[n]), as.numeric(choice_index_train[n])])
  choice_test <- sapply(1:nrow(dftest), function (n)
    choice_pairs[as.numeric(dftest$cue[n]), as.numeric(choice_index_test[n])])
  choice <- c(choice_train, choice_test)
  outcome_train <- ifelse(dftrain$response == 0, NA, paste(choice_train, outcome_map[as.character(dftrain$outcome)], sep = ":"))
  outcome_test <- ifelse(dftest$response == 0, NA, paste(choice_test, outcome_map[as.character(dftest$outcome)], sep = ":"))
  outcome <- c(outcome_train, outcome_test)
  note1 <- c(rep("Training phase", length(dftrain$trial)), rep("Testing phase", length(dftest$trial)))
  if (devalued_list[[sb]][1] == "Choco") {
    condition <- 1
    note2 <- c(rep("", length(dftrain$trial)), rep("Devalued chocolate milk", length(dftest$trial)))
  } else {
    condition <- 2
    note2 <- c(rep("", length(dftrain$trial)), rep("Devalued tomato juice", length(dftest$trial)))
  }
  # Rest of variables
  response_time <- sex <- age <- education <- stage <- NA
  # Processed data
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine and save processed data
psd_list <- psd_list[!is.na(psd_list)]
psd_combined <- do.call("rbind", psd_list)
ds_final <- psd_combined [order(psd_combined$subject), ]

ds_final$choice <- as.character(ds_final$choice)
ds_final$outcome <- as.character(ds_final$outcome)

file_name <- paste0(paper, "_", "1", "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
