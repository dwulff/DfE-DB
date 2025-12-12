### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Turi et al. (2015) Transcranial direct current stimulation over the left prefrontal cortex increases randomness of choice in instrumental learning

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "TMOP2015"
study <- 1
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

option <- c("A", "B", "C", "D", "E", "F")
out_1 <- c(1, 1, 1, 1, 1, 1)
pr_1 <- c(0.8, 0.2, 0.7, 0.3, 0.6, 0.4)
out_2 <- c(0, 0, 0, 0, 0, 0)
pr_2 <- c(0.2, 0.8, 0.3, 0.7, 0.4, 0.6)
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options
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
rm(list=setdiff(ls(), c("path", "paper", "study","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)
setwd("cortex_analysis-master/data/raw")
# All files are in order
# Go to learning subfolder and read the data
setwd("Learning/A") # Learning mode A
dfiles_A <- list.files()
ds_learningModeA <- lapply(dfiles_A, function (f) read.table(f, header = TRUE, stringsAsFactors = FALSE))
setwd("../B") # Learning mode B
dfiles_B <- list.files()
ds_learningModeB <- lapply(dfiles_B, function (f) read.table(f, header = TRUE, stringsAsFactors = FALSE))
# Go to transfer subfolder and read the data
setwd("../../Transfer/A") # Transfer mode A
dfiles_A <- list.files()
ds_transferModeA <- lapply(dfiles_A, function (f) read.table(f, header = TRUE, stringsAsFactors = FALSE))
setwd("../B") # Transfer mode B
dfiles_B <- list.files()
ds_transferModeB <- lapply(dfiles_B, function (f) read.table(f, header = TRUE, stringsAsFactors = FALSE))
# Two stimulation conditions - anodal tDCS vs sham tDCS (encoded as A vs B modes)
modeA <- "Real tDCS"
modeB <- "Sham tDCS"
#problem <- 1
options_map_learning <- c(`1`="A_B", `2`="C_D", `3`="E_F")
options_map_transfer <- c(`1`="A_B", `2`="A_C", `3`="A_D", `4`="A_E", `5`="A_F", `6`="B_C", `7`="B_D",
                          `8`="B_E", `9`="B_F", `10`="C_D", `11`="C_E", `12`="C_F", `13`="D_E", `14`="D_F",
                          `15`="E_F")
option <- c("A", "B", "C", "D", "E", "F")
choice_pairs_learning <- matrix(option, ncol = 2, byrow = TRUE) # Row number corresponds to pair
options_reward_sorted <- c("A", "C", "E", "F", "D", "B") # From highest to lowest reward probability
# To store processed data (each subject with learning and transfer stages)
psd_list <- vector(mode = "list", 16)

for (sb in 1:16) {
  # Subject data
  dflearningA <- ds_learningModeA[[sb]]
  dftransferA <- ds_transferModeA[[sb]]
  dflearningB <- ds_learningModeB[[sb]]
  dftransferB <- ds_transferModeB[[sb]]
  # Mapping and processing - Learning
  process_learning <- function (df, mode, subj_ID) {
    condition <- ifelse(mode == "Real tDCS", 1, 2)
    subject <- subj_ID
    # problem <- df$Pair_type
    problem <- 1
    options <- options_map_learning[as.character(df$Pair_type)]
    trial <- 1:nrow(df)
    response_time <- df$RT
    no_response_ind <- which(as.character(df$ACC) == "missed")
    response_time[no_response_ind] <- NA
    note1 <- rep(mode, length(trial))
    note2 <- "Learning phase"
    #note2 <- rep(NA, length(trial))
    #note2[no_response_ind] <- "No decision within 1700 msec"
    # ACC = 1: options with the higher reward probability were chosen
    # For ACC not equal to 1 or 0, NA is introduced
    choice <- sapply(1:nrow(df), function (n)
      ifelse(df$ACC[n] == 1, choice_pairs_learning[df$Pair_type[n], 1],
             ifelse(df$ACC[n] == 0, choice_pairs_learning[df$Pair_type[n], 2], NA)))
    outcome <- paste(choice, df$Feedback_type, sep = ":")
    outcome[no_response_ind] <- NA #  A confused-face emoticon was used in case of no answer
    # Rest of variables
    sex <- age <- education <- stage <- NA
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    return(psd)
  }
  
  process_transfer <- function (df, mode, subj_ID) {
    condition <- ifelse(mode == "Real tDCS", 1, 2)
    subject <- subj_ID
    # problem <- df$Type
    problem <- 2
    options <- options_map_transfer[as.character(df$Type)]
    trial <- 1:nrow(df)
    response_time <- df$RT
    no_response_ind <- which(as.character(df$ACC) == "missed")
    response_time[no_response_ind] <- NA
    note1 <- rep(mode, length(trial))
    note2 <- "Transfer phase"
    #note2 <- rep(NA, length(trial))
    #note2[no_response_ind] <- "No decision within 1700 msec"
    # For ACC not equal to 1 or 0, NA is introduced
    # Determine choice
    choice <- sapply(1:nrow(df), function (n) {
      opts <- options[n] # Which options were available on this trial
      choices <- unlist(strsplit(opts, split = "_")) # Split the options
      pos_ind <- match(choices, options_reward_sorted) # Positions in reward-sorted options
      ans <- ifelse(as.numeric(df$ACC[n]) == 1, options_reward_sorted[min(pos_ind)],
             options_reward_sorted[max(pos_ind)])
      return(ans)
    })
    # No feedback in the transfer phase
    outcome <- choice
    outcome[no_response_ind] <- NA # To differentiate a no-feedback trial (empty string) from a no-response trial
    # Rest of variables
    sex <- age <- education <- stage <- NA
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    return(psd)
  }
  dflearnA_processed <- process_learning(dflearningA, modeA, sb)
  dftranA_processed <- process_transfer(dftransferA, modeA, sb)
  dfA_final <- rbind(dflearnA_processed, dftranA_processed)
  dflearnB_processed <- process_learning(dflearningB, modeB, sb)
  dftranB_processed <- process_transfer(dftransferB, modeB, sb)
  dfB_final <- rbind(dflearnB_processed, dftranB_processed)
  df_final <- rbind(dfA_final, dfB_final)
  psd_list[[sb]] <- df_final
}

ds_final <- do.call("rbind", psd_list)

# Save processed data
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
