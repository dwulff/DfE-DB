### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Rakow et al. (2015) Forgone but not forgotten: the effects of partial and full feedback in "harsh" and "kind" environments

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "RNW2015"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet
# Study 1 - Eight choice pairs, optimal and suboptimal (loss-minimizing or gain-maximizing)
option <- LETTERS[1:16]
out_1 <- rep(3, length(option))
pr_1 <- c(0.3, 0.1, 0.256, 0.1, 0.5, 0.258, 0.5, 0.3, 0.9, 0.7, 0.9, 0.744, 0.742, 0.5, 0.7, 0.5)
out_2 <- rep(-3, length(option))
pr_2 <- 1 - pr_1
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)


# Study 2 - pairs 1,3,5,7
option <- c('A','B', 'E', 'F', 'I', 'J', 'M', 'N')
out_1 <- rep(3, length(option))
pr_1 <- c(0.3, 0.1, 0.5, 0.258, 0.9, 0.7, 0.742, 0.5)
out_2 <- rep(-3, length(option))
pr_2 <- 1 - pr_1
options_table2 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options sheet
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
# Back to raw directory
setwd(raw_path)
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
# Read demographic data (study 1)
st1_dmg <- readxl::read_excel("Study 4b aka FBNF Study 1 Demographics.xlsx", sheet = "Sheet1")
## Read data
# Go to study 1 directory
setwd("Study 4b (Series G) for Eldad")
ds1_gain <- read.csv(file = "Trial_By_Trial_Data_Study4b_GainD.csv", header = TRUE, stringsAsFactors = FALSE)
ds1_loss <- read.csv(file = "Trial_By_Trial_Data_Study4b_LossD.csv", header = TRUE, stringsAsFactors = FALSE)
# Go to study 2 directory
setwd("../Study 9 (Series G) for Eldad")
ds2 <- read.csv(file = "Trial_By_Trial_Study_9_Data_ALL.csv", header = TRUE, stringsAsFactors = FALSE)

# Condition NA because it is only defined by feedback
# Type of environment is just informational (goes in notes)
process_st <- function (ds, st) {
  study <- st
  subject_freq <- rle(sort(ds$PptNum))
  psd_list <- vector(mode = "list", length(subject_freq$values))
  # Make choice pairs matrix
  option <-  LETTERS[1:16]
  choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
  # To map optimal choice codes from 1,0 to 1,2 for use with choice_pairs
  opt_map <- c(`1`=1, `0`=2)
  # The reverse to map non-chosen options
  opt_map_rev <- c(`1`=2, `0`=1)
  # Feedback
  fb_map <- c(`1`=2, `0`=1)
  # Reverse map, to retrieve foregone outcomes
  fgfb_map <- c(`1`=1, `0`=2)
  
  for (sb in 1:length(subject_freq$values)) {
    subject <- as.numeric(subject_freq$values[sb])
    # Extract this subject's data
    df <- ds[ds$PptNum == subject, ]
    # Process the data
    problem <- df$PairPlayed
    options <- sapply(problem, function (p) paste(choice_pairs[p, ], collapse = "_"))
    trial <- df$TrialNum
    choice <- sapply(1:nrow(df), function (k)
      choice_pairs[problem[k], opt_map[as.character(df$OptionPicked[k])]])
    choice_foregone <- sapply(1:nrow(df), function (k)
      choice_pairs[problem[k], opt_map_rev[as.character(df$OptionPicked[k])]])
    # Map feedback on choices as well as foregone feedback, if any
    #feedback_choice <- sapply(1:nrow(df), function (k)
    #  feedback_matrix[k, fb_map[as.character(df$OptionPicked[k])]])
    feedback_choice <- ifelse(df$OutcomeObtained == 1, 3, -3)
    # Extract feedback columns
    v <- c(which(colnames(ds) == "SeenLowEV"), which(colnames(ds) == "SeenHighEV"))
    feedback_matrix <- as.matrix(df[, v])
    # Concerning learning type (feedback), codes 1 and 2 are for full feedback trials
    ffb_code <- ifelse(st == 1, c(1), c(1,2))
    feedback_foregone <- sapply(1:nrow(df), function (k)
      ifelse(df$LearningTypePlayed[k] %in% ffb_code,
             feedback_matrix[k, fgfb_map[as.character(df$OptionPicked[k])]], ""))
    outcome_raw <- sapply(1:length(feedback_foregone), function (k)
      ifelse(feedback_foregone[k] == "", paste(choice[k], feedback_choice[k], sep = ":"),
             paste(paste(choice[k], feedback_choice[k], sep = ":"),
                   paste(choice_foregone[k], feedback_foregone[k], sep = ":"), sep = "_")))
    stage <- ifelse(df$Phase == 0, 1, 2)
    # In study 2, no feedback was provided in stage 2, so set as empty string
    if (st == 2) {
      outcome <- sapply(1:length(outcome_raw), function (m)
        ifelse(stage[m] == 2, "", outcome_raw[m]))
    } else {
      outcome <- outcome_raw
    }
    sex <- ifelse(as.numeric(st1_dmg[st1_dmg$PptNum == subject, "Sex"]) == 1, "m", "f")
    age <- as.numeric(st1_dmg[st1_dmg$PptNum == subject, "Age"])
    note1 <- ifelse(problem %in% c(1,2,3,4), "Harsh env/loss", "Kind env/gain")
    condition <- response_time <- education <- note2 <- NA
    LowEV <- df$SeenLowEV
    HighEV <- df$SeenHighEV
    
    df$note2[df$LearningTypePlayed==1 & df$ExploitTypePlayed==1] <- 'FullFeedback20/PolicyChoice20'
    df$note2[df$LearningTypePlayed==1 & df$ExploitTypePlayed==2] <- 'FullFeedback20/TrialByTrialChoice20'
    df$note2[df$LearningTypePlayed==2 & df$ExploitTypePlayed==1] <- 'PartialFeedback20/PolicyChoice20'
    df$note2[df$LearningTypePlayed==2 & df$ExploitTypePlayed==2] <- 'PartialFeedback20/TrialByTrialChoice20'
    df$note2[df$LearningTypePlayed==3 & df$ExploitTypePlayed==1] <- 'PartialFeedback40/PolicyChoice20'
    df$note2[df$LearningTypePlayed==3 & df$ExploitTypePlayed==2] <- 'PartialFeedback40/TrialByTrialChoice20'
    note2 <- df$note2
    
    # Create final dataframe
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    #psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2, LowEV, HighEV)
    psd_list[[sb]] <- psd
  }
  
  # Combine and return processed data
  psd_combined <- do.call("rbind", psd_list)
  return(psd_combined)
}

# Function calls

ds_st1 <- rbind(process_st (ds = ds1_gain, st = 1),
                process_st (ds = ds1_loss, st = 1))
ds_st1_final <- ds_st1 [order(ds_st1$subject, ds_st1$problem), ]

ds_st2 <- process_st (ds = ds2, st = 2)
ds_st2_final <- ds_st2 [order(ds_st2$subject, ds_st2$problem), ]


ds_st1_final$choice <- as.character(ds_st1_final$choice)
ds_st1_final$outcome <- as.character(ds_st1_final$outcome)
ds_st2_final$choice <- as.character(ds_st2_final$choice)
ds_st2_final$outcome <- as.character(ds_st2_final$outcome)


# Save
file_name1 <- paste0(paper, "_", "1", "_", "data.csv")
file_name2 <- paste0(paper, "_", "2", "_", "data.csv")
setwd(data_path)
write.table(ds_st1_final, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(ds_st2_final, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
