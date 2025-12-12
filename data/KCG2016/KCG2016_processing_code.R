### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Kool et al. (2013) When Does Model-Based Control Pay Off?

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "KCG2016"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/tradeoffs-master/data/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

##### Create the options sheet

# Study 
# Problem 1 (ABCD): First stage has two options, each deterministically takes the subject to a forced choice trial (press space to get payoff)
# Problem 2 (EF: First stage has two options, each probabilistically takes the subject to another binary choice
option <- c("A", "B", "C", "D")
description <- c("Transition to stage 2 option C",
                 "Transition to stage 2 option D",
                 "Reward varies according to a gaussian random walk",
                 "Reward varies according to a gaussian random walk")
options_table1 <- data.frame(option, description)

option <- c("A", "B", "C", "D","E", "F")
description <- c("P(Transitioning to stage 2 options CD)= 0.7, P(Transitioning to stage 2 options EF)= 0.3",
                 "P(Transitioning to stage 2 options CD)= 0.3, P(Transitioning to stage 2 options EF)= 0.7",
                 "Reward varies according to a gaussian random walk",
                 "Reward varies according to a gaussian random walk",
                 "Reward varies according to a gaussian random walk",
                 "Reward varies according to a gaussian random walk")
options_table2 <- data.frame(option, description)

# Save options
file_name_1 <- paste0(paper, "_", "1", "_", "options.csv")
file_name_2 <- paste0(paper, "_", "2", "_", "options.csv")
setwd(data_path)
write.table(options_table1, file = file_name_1, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")
write.table(options_table2, file = file_name_2, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

### Process dataset

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("paper", "raw_path", "data_path")))
study <- 1
# Back to raw data directory
setwd(raw_path)

## problem 1 Novel paradigm
problem <- 1 # Novel paradigm
condition <- 1
setwd("novel paradigm")
# Read data
# The original one is a Matlab file, it was saved as an csv file because it is easy to read and use
ds <- read.csv("novel_paradigm.csv")
ds_sub <- read.csv("novel_paradigm_subinfo.csv")
# List of data, each row contains datastructures for the respective participant
# 15 vars and 199 subjects
#{'subject'     }, {'state1'.     }, {'stim_1_left' }, {'stim_1_right'}, {'rt1'         }
#{'choice1'     }, {'rt2'         }, {'points'      }, {'state2'      }, {'score'       }
#{'practice'    }, {'rews1'       }, {'rews2'       }, {'trial'       }, {'N'           }

subject_freq <- rle(sort(ds$subject))
psd_list <- vector(mode = "list", length(subject_freq$value))

for (sb in 1:length(subject_freq$values)) {
  subject_id <- subject_freq$values[sb]
  df <- ds[complete.cases(ds) & ds$subject == subject_id & ds$practice == 0, ]
  df_sub <- ds_sub[ds_sub$subject == subject_id,]
  #stage
  stage <- rep(c(1, 2), length(df$trial))
  #trial
  trial <- rep(df$trial+1, each = 2)
  #subject
  subject <- rep(subject_id, length(trial))
  #rt
  response_time <- c(rbind(df$rt1, df$rt2)) # Join the response times
  response_time[response_time == -1] <- NA # Change -1 values to NA
  #options
  options_stg1 <- sapply(1:nrow(df), function(n)
    ifelse(df$choice1[n]==-1, NA, "A_B"))
  options_stg2 <- sapply(1:nrow(df), function(n)
    ifelse(df$choice1[n]==-1, NA, "C_D"))
  options <- c(rbind(options_stg1, options_stg2))
  #choice
  choice_pairs <- matrix(c("A", "B", "C", "D"),ncol = 2, nrow = 2, byrow = TRUE)
  choice_stg1 <- sapply(1:nrow(df), function(n)
    ifelse(df$choice1[n]==-1, NA, choice_pairs[1, df$state2[n]]))
  choice_stg2 <- sapply(1:nrow(df), function(n)
    ifelse(df$choice1[n]==-1, NA, choice_pairs[2, df$state2[n]]))
  choice <- c(rbind(choice_stg1, choice_stg2))
  # outcome
  outcome_stg1 <- sapply(1:nrow(df), function(n)
    ifelse(df$choice1[n]==-1, NA, ""))
  outcome_stg2 <- sapply(1:nrow(df), function(n)
    ifelse(df$choice1[n]==-1, NA, df$points[n]))
  outcome <- c(rbind(outcome_stg1, outcome_stg2)) # Join in alternating order
  outcome <- ifelse(stage == 1, "", ifelse(is.na(choice),NA,paste(choice,outcome,sep = ":")))
  # choice adjust
  choice[choice == "C" ] <- ""  # determined, no choice made
  choice[choice == "D" ] <- ""  # determined, no choice made
  # note1
  note1 <- rep(paste0("state in stage1:", df$state1),each=2)
  # age
  age_num <- df_sub$age
  age <- rep(age_num, length(note1))
  # gender
  sex_num <- df_sub$gender
  sex <- rep(sex_num, length(note1))
  #rest
  education <- note2 <- NA
  # Processed data
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd <- psd [order(psd$subject, psd$problem), ] # Order the dataset
  psd_list[[sb]] <- psd
}

# Combine data
psd_combined <- do.call("rbind", psd_list)
ds_final <- psd_combined [order(psd_combined$subject), ]
# Save
file_name <- paste0(paper, "_", problem, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

## problem 2, Daw paradigm
study <- 2
problem <- 2 # Daw paradigm
setwd(raw_path)
setwd("daw paradigm")
# Read data
# The original one is a Matlab file, it was saved as an csv file because it is easy to read and use
ds <- read.csv("daw_paradigm.csv")
ds_sub <- read.csv("daw_paradigm_subinfo.csv")
# List of data, each row contains datastructures for the respective participant
# 20 vars and 206 subjects
#{'subject'.    }, {'stim_1_left' }, {'stim_1_right'}, {'rt1'         }, {'choice1'     }
#{'stim_2_left' }, {'stim_2_right'}, {'rt2'         }, {'choice2'     }, {'win'         }
#{'state2'      }, {'common'      }, {'score'       }, {'practice'    }, {'ps1a1'       }
#{'ps1a2'       }, {'ps2a1'       }, {'ps2a2'       }, {'trial'       }, {'N'           }
subject_freq <- rle(sort(ds$subject))
psd_list <- vector(mode = "list", length(subject_freq$value))

for (sb in 1:length(subject_freq$values)) {
  subject_id <- subject_freq$values[sb]
  df <- ds[complete.cases(ds) & ds$subject == subject_id & ds$practice == 0, ]
  df_sub <- ds_sub[ds_sub$subject == subject_id,]
  #stage
  stage <- rep(c(1, 2), length(df$trial))
  #trial
  trial <- rep(df$trial+1, each = 2)
  #subject
  subject <- rep(subject_id, length(trial))
  #rt
  response_time <- c(rbind(df$rt1, df$rt2)) # Join the response times
  response_time[response_time == -1] <- NA # Change -1 values to NA
  #options
  option <- c("A", "B", "C", "D", "E", "F")
  options_alt1 <- option [c(TRUE, FALSE)]
  options_alt2 <- option [c(FALSE, TRUE)]
  options_v <- paste(options_alt1, options_alt2, sep = "_")
  choice_pairs <- matrix(option, ncol = 2, nrow = 3, byrow = TRUE)
  options_stg1 <- sapply(1:nrow(df), function(n)
    ifelse(df$choice1[n]==-1, NA, options_v[1]))
  options_stg2 <- sapply(1:nrow(df), function(n)
    ifelse(df$choice1[n]==-1 || df$choice2[n]==-1 , NA, options_v[df$state2[n]+1]))
  options <- c(rbind(options_stg1, options_stg2))
  condition <- rep(df$state2, each=2)
  #choice
  choice_stg1 <- sapply(1:nrow(df), function(n)
    ifelse(df$choice1[n]==-1, NA, choice_pairs[1, df$choice1[n]]))
  choice_stg2 <- sapply(1:nrow(df), function(n)
    ifelse(df$choice1[n]==-1 || df$choice2[n]==-1 , NA, choice_pairs[df$state2[n]+1, df$choice2[n]]))
  choice <- c(rbind(choice_stg1, choice_stg2))
  #outcome
  outcome_stg1 <- sapply(1:nrow(df), function(n)
    ifelse(df$choice1[n]==-1, NA, ""))
  outcome_stg2 <- sapply(1:nrow(df), function(n)
    ifelse(df$choice1[n]==-1 || df$choice2[n]==-1 , NA, df$win[n]))
  outcome <- c(rbind(outcome_stg1, outcome_stg2)) # Join in alternating order
  outcome <- ifelse(stage == 1, "", ifelse(is.na(choice),NA,paste(choice,outcome,sep = ":")))
  # age
  age_num <- df_sub$age
  age <- rep(age_num, length(outcome))
  # gender
  sex_num <- df_sub$gender
  sex <- rep(sex_num, length(outcome))
  #rest
  education <-note1 <- note2 <- NA
  # Processed data
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd <- psd [order(psd$subject, psd$problem), ] # Order the dataset
  psd_list[[sb]] <- psd
}

# Combine data
psd_combined <- do.call("rbind", psd_list)
ds_final <- psd_combined [order(psd_combined$subject), ]
# Save
file_name <- paste0(paper, "_", problem, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
