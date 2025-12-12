### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Zaghloul et al. (2012) Neuronal Activity in the Human Subthalamic Nucleus Encodes Decision Conflict during Action Selection

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "ZWLJ2012"
study <- 1
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet
# Optimal and suboptimal options
option <- LETTERS[1:6]
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
setwd("Archive")
files_data <- list.files()
# Extract subject IDs - there are some redundant data
subject_ids <- substr(x = files_data, start = 1, stop = 7)
if (!requireNamespace("R.matlab", quietly = TRUE)) install.packages("R.matlab")
library(R.matlab)
# There are several pairs of test and training files. Create a list of pairs
testTraining_list <- split(files_data, ceiling(seq_along(files_data)/2))
optsMap_rewardProb <- c(`0.8`="A", `0.2`="B", `0.7`="C", `0.3`="D", `0.6`="E", `0.4`="F")
# Now for each pair, create a processed dataframe
psd_list <- vector(mode = "list", length(testTraining_list))

# testing
file_test = readMat("CABG089orLtest.mat")
df_test = file_test$behData 
df_test[[2]] 

#sb_files <- testTraining_list[[1]]
for (sb in 1:length(testTraining_list)) {
  sb_files <- testTraining_list[[sb]]
  dt_test <- readMat(sb_files[1], verbose = FALSE) # Test data (first element)
  dt_train <- readMat(sb_files[2], verbose = FALSE) # Training data (second element)
  dt_test <- dt_test$behData # The Matlab struct
  dt_train <- dt_train$behData
 
  # Process the training dataset
  process_dt <- function (dt, part) {
    
    #dt <- dt_train
    subject <- as.character(dt[[1]])
    sex <- tolower(as.character(dt[[4]]))
    # High prob vector
    hiProb <- round(as.vector(dt[[5]]), 1)
    # Low prob vector
    loProb <- round(as.vector(dt[[6]]), 1)
    # Replace hiProb and loProb with options
    hiProb_opts <- unname(optsMap_rewardProb[as.character(hiProb)])
    loProb_opts <- unname(optsMap_rewardProb[as.character(loProb)])
    if (part == "training") {
      pairBool <- dt[[12]] # which option pair was presented on each trial
      response_time <- round(as.vector(dt[[11]]))
      corrButt <- as.vector(dt_train[[9]]) # whether they pressed the button corresponding to the card with the higher probability 
      reward <- as.character(dt[[7]]) # corrList contains the outcome of the choice (reward or no reward)
      note1 <- "Training phase"
      problem <- 1
    } else {
      pairBool <- dt[[11]]
      response_time <- round(as.vector(dt[[10]]))
      corrButt <- as.vector(dt[[8]])
      reward <- rep(2,times=length(response_time))
      note1 <- "Testing phase"
      problem <- 2
    }
    
    # Which pair indey was presented on each trial (returns indices)
    pair_index <- apply(pairBool, MARGIN = 2, FUN = function (p) as.numeric(match(1, p)))
    options <- sapply(1:length(pair_index), function (p)
      paste(hiProb_opts[pair_index[p]], loProb_opts[pair_index[p]], sep = "_"))
    # Map choices and outcomes
    choice <- sapply(1:length(corrButt), function(p)
      ifelse(corrButt[p] == 1, as.character(hiProb_opts[pair_index[p]]), as.character(loProb_opts[pair_index[p]])))
    trial <- 1:length(choice)
    # Feedback during training only
    outcome <- ifelse(reward==2, choice, paste(choice, reward, sep = ":"))
    stage <- age <- education <- note2 <- condition <- NA
    # Create dataframe (trial will be added later)
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    return(psd)
  }
  # Function call
  psd_training <- process_dt (dt = dt_train, part = "training")
  psd_test <- process_dt (dt = dt_test, part = "test")
  psd_list[[sb]] <- rbind (psd_training, psd_test)
}

# Combine and save processed data
ds_final <- do.call("rbind", psd_list)
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
