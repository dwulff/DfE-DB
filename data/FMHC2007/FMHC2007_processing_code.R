### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Frank et al. (2007) Genetic triple dissociation reveals multiple roles for dopamine in reinforcement learning

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "FMHC2007"
study <- 1
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

##### Create the options sheet
# Reinformcement learning task with 6 options
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
rm(list=setdiff(ls(), c("path", "paper", "study", "raw_path", "data_path")))
# Back to raw data directory
setwd(raw_path)
# Read dataset
ds_main <- read.csv(file = "PS_ERN_DNA.txt", header = TRUE, stringsAsFactors = FALSE)
# Fix column names to make consistent with others
colnames(ds_main) <- c("Subject", "Session", "acc", "cond", "Running", "trn_ACC", "trn_RT", "tst_ACC", "tst_RT", "trn_cycle", "trltype")
ds_63 <- read.csv(file = "PS_ERN_DNA_S63+.txt", header = TRUE, stringsAsFactors = FALSE)
unique(ds_main$Session)
option <- c("A", "B", "C", "D", "E", "F")
choice_matrix <- matrix(option, nrow = 3, ncol = 2, byrow = TRUE)
trn_trial_map <- c(`AB`=1, `CD`=2, `EF`=3)
# Maps option to reward probability
option_rewardProb_map <- c(`A`=0.8, `B`=0.2, `C`=0.7, `D`=0.3, `E`=0.6, `F`=0.4)

process_st <- function (ds) {
  # Function to process study for adhd patient and control groups
  subject_freq <- rle(sort(ds$Subject))
  # List to store each subject's processed data
  psd_list <- vector(mode = "list", length(subject_freq$values))
  
  process_dfs <- function (dfs, session) {
    # Function to process session-level data for both groups
    note1 <- paste("Session", session, sep = " ")
    options <- sapply(dfs$cond, function(cnd) paste(unlist(strsplit(cnd, split = "")), collapse = "_"))
    # Make training and test trial numbering consecutive
    trial <- 1:nrow(dfs)
    # Index of training options in choice_matrix
    ind_trn <- unname(trn_trial_map[as.character(as.vector(dfs[dfs$Running == "TrainInterleaved", "cond"]))])
    ## Choices on training trials
    optimal_choice <- as.vector(dfs[dfs$Running == "TrainInterleaved", "acc"])
    choice_trn <- sapply(1:length(optimal_choice), function (n)
      ifelse(optimal_choice[n] == 1, choice_matrix[ind_trn[n], 1], choice_matrix[ind_trn[n], 2]))
    result_trn <- as.vector(dfs[dfs$Running == "TrainInterleaved", "trn_ACC"])
    outcome_trn <- paste(choice_trn, result_trn, sep = ":")
    ## Choices on test trials
    test_optionPairs <- as.vector(dfs[dfs$Running == "TestInterleaved", "cond"])
    # Split each option pair
    test_options <- lapply(test_optionPairs, function (p) unlist(strsplit(p, split = "")))
    test_reward_probs <- lapply(test_options, function (p) unname(option_rewardProb_map[as.character(p)]))
    optimal_option_indices <- unlist(lapply(test_reward_probs, function (p) which.max(p)))
    suboptimal_option_indices <- ifelse(optimal_option_indices == 1, 2, 1)
    # Test trial choices
    optimal_tst_choice <- as.vector(dfs[dfs$Running == "TestInterleaved", "tst_ACC"])
    # Choices based on previous vectors
    choice_tst <- sapply(1:length(optimal_tst_choice), function (n)
      ifelse(optimal_tst_choice[n] == 1,
             test_options[[n]][optimal_option_indices[n]], test_options[[n]][suboptimal_option_indices[n]]))
    # No feedback on test trials
    outcome_tst <- choice_tst
    # Concatenate training and test vectors
    choice <- c(choice_trn, choice_tst)
    outcome <- c(outcome_trn, outcome_tst)
    response_time <- sapply(1:nrow(dfs), function (n)
      ifelse(dfs$Running[n] == "TrainInterleaved", round(dfs$trn_RT[n]), round(dfs$tst_RT[n])))
    stage <- education <- age <- sex <- note2 <- NA
    note2 <- dfs$Running
    problem <- ifelse(note2=="TrainInterleaved", 1, 2)
    condition <- ifelse(note2=="TrainInterleaved", 1, 2)
    # Create final dataframe
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    # Set as NA trials with no response (RT=0)
    psd[psd$response_time == 0, which(colnames(psd) == "choice")] <- NA
    psd[psd$response_time == 0, which(colnames(psd) == "outcome")] <- NA
    psd[psd$response_time == 0, which(colnames(psd) == "response_time")] <- NA
    return(psd)
  }
  
  for (sb in 1:length(subject_freq$values)) {
    subject <- subject_freq$values[sb]
    # Extract subject data
    df <- ds[ds$Subject == subject, ]
    # Keep training and test trials only (remove extraneous breaks)
    df <- df[df$Running %in% c("TestInterleaved", "TrainInterleaved"), ]
    # For some subjects there is only one of two sessions
    if (all(unique(df$Session) == c(1, 2))) {
      sessions_processed <- rbind(process_dfs(dfs = df[df$Session == 1, ], session = 1),
                                  process_dfs(dfs = df[df$Session == 2, ], session = 2))
    } else {
      sessions_processed <- process_dfs(dfs = df[df$Session == as.numeric(unique(df$Session)), ], session = as.numeric(unique(df$Session)))
    }
    psd_list[[sb]] <- sessions_processed
  }
  # Combine and save processed data
  psd_combined <- do.call("rbind", psd_list)
  return(psd_combined)
}

ds_final <- rbind(process_st(ds = ds_main), process_st(ds = ds_63))
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

