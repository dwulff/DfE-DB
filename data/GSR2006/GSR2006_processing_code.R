### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Gaissmaier et al. (2006) Simple Predictions Fueled by Capacity Limitations: When Are They Successful?

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "GSR2006"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

##### Create the options sheet

# Study 1
# Two options (Coin marked with X or O), multiple conditions.
# At first each condition was made to a problem but now only one in different conditions.
# In the first constant condition, no shift occurred
# in the second early shift condition, probabilities switch after the first block of trials
# in the third late shift condition, probabilities switch after the second block of trials
# and in the fourth back shift condition, probabilities switch after the first block, then switch back after the second block of trials.

option <- c("A", "B", "C", "D")
description <- c("P(X in red envelope) = 0.6875, switch to P(X in red envelope) = 0.3125 depending on condition.",
                 "P(O in red envelope) = 0.3125, switch to P(X in red envelope) = 0.6875 depending on condition.",
                 "P(X in green envelope) = 0.3125, switch to P(X in green envelope) = 0.6875 depending on condition.",
                 "P(O in green envelope) = 0.6875, switch to P(X in green envelope) = 0.3125 depending on condition.")

options_table1 <- data.frame(option, description)

# Study 2
option <- c("A", "B", "C", "D")
description <- c("P(X in red envelope) = 0.6875, switch to P(X in red envelope) = 0.3125 after the second block of trials (t=128).",
                 "P(O in red envelope) = 0.3125, switch to P(X in red envelope) = 0.6875 after the second block of trials (t=128).",
                 "P(X in green envelope) = 0.3125, switch to P(X in green envelope) = 0.6875 after the second block of trials (t=128).",
                 "P(O in green envelope) = 0.6875, switch to P(X in green envelope) = 0.3125 after the second block of trials (t=128).")
#option <- c("A", "B")
#description <- c("P(X in red envelope) = 0.6875 and P(X in green envelope) = 0.3125. Probabilities switch after the second block of trials (t=128)",
#                 "P(O in red envelope) = 0.3125 and P(O in green envelope) = 0.6875. Probabilities switch after the second block of trials (t=128)")
options_table2 <- data.frame(option, description)

# Save options
file_name1 <- paste0(paper, "_", "1", "_", "options.csv")
file_name2 <- paste0(paper, "_", "2", "_", "options.csv")
setwd(data_path)
write.table(options_table1, file = file_name1, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")
write.table(options_table2, file = file_name2, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

### Process dataset

# Study 1
# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper","data_path", "raw_path")))
# Back to raw data directory
setwd(raw_path)
study <- 1
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
# Read the raw data
exp1_file <- "Gaissmaier_et_al_2006_Exp1_Choice_Data.xlsx"
dsex1_resp <- read_excel(exp1_file, sheet = "RESP") # Responses
dsex1_resp <- dsex1_resp[-c(1:8), -2] # Remove extraneous rows/columns
dsex1_cresp <- read_excel(exp1_file, sheet = "CRESP") # Response that would have been correct
dsex1_cresp <- dsex1_cresp[-c(1:8), -2]
dsex1_acc <- read_excel(exp1_file, sheet = "ACC") # Whether the response was accurate
dsex1_acc <- dsex1_acc[-c(1:8), -2]
# ImageEnvClosed was the cue that was provided ahead of each trial. This was either a red or green
# envelope, cueing different probabilities of the binary outcomes.
# (i.e., each binary outcome was associated with a color.) - 1=red 0=green
dsex1_cue <- read_excel(exp1_file, sheet = "Cue")
dsex1_cue <- dsex1_cue[-c(1:8), -2]
# Read demographic data
dmg_file <- "Gaissmaier_et_al_2006_Exps_1_2_Demographics.sav"
ds_dmg <- read.spss(dmg_file, to.data.frame = TRUE)
# Sort by experiment and subject numbers
ds_dmg <- ds_dmg [order(ds_dmg$experim, ds_dmg$vp), ]
subject_ids <- as.numeric(unname(unlist((dsex1_cue[2:nrow(dsex1_cue), 1])))) # Subject ids
# To map from condition to problem, and from problem to options
condition_map <- c(`constant`=1, `early change`=2, `late change`=3, `back change`=4)
#options_map <- c(`1`="AB", `2`="CD", `3`="EF", `4`="GH")
# Choice pairs
option <- c("A", "B", "C", "D")#, "C", "D", "E", "F", "G", "H")
options_pair <- c("A_B", "C_D")
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
# To store processed data
psd_list <- vector(mode = "list", length(subject_ids))

for (sb in subject_ids) {
  subject <- sb
  condition <- unname(condition_map[as.character(as.vector(ds_dmg[ds_dmg$experim == 1 & ds_dmg$vp == subject, 5]))])
  note1 <- as.character(as.vector(ds_dmg[ds_dmg$experim == 1 & ds_dmg$vp == subject, 5]))
  #options <- unname(options_map[as.character(problem)])
  problem <- ifelse(as.numeric(unname(unlist(dsex1_cue[subject, 2:ncol(dsex1_cue)]))) == 1, 1, 2)
  trial <- as.numeric(unname(unlist(dsex1_acc[1, 2:ncol(dsex1_acc)])))
  options <- ifelse(problem == 1, options_pair[1], options_pair[2])
  choice <- ifelse(as.numeric(unname(unlist(dsex1_resp[subject, 2:ncol(dsex1_resp)]))) == 1,ifelse(problem==1, choice_pairs[1, 1], choice_pairs[2, 1]), ifelse(problem==1, choice_pairs[1, 2], choice_pairs[2, 2]))
  # Correct predictions are awarded with 3
  outcome <- ifelse(as.numeric(unname(unlist(dsex1_acc[subject, 2:ncol(dsex1_acc)]))) == 1,
                    paste(choice, "3", sep = ":"), paste(choice, "0", sep = ":"))
  sex <- ifelse(as.character(as.vector(ds_dmg[ds_dmg$experim == 1 & ds_dmg$vp == subject, 4])) == "male", "m", "f")
  age <- as.numeric(as.vector(ds_dmg[ds_dmg$experim == 1 & ds_dmg$vp == subject, 3]))
  note2<- response_time <- stage <- education <- NA
  #note1 <- ifelse(as.numeric(unname(unlist(dsex1_cue[subject, 2:ncol(dsex1_cue)]))) == 1,"Red envelope", "Green envelope")
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine processed data
ds_st1_final <- do.call("rbind", psd_list)
# Save
file_name <- paste0(paper, "_", "1", "_", "data.csv")
setwd(data_path)
write.table(ds_st1_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

# Study 2
# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)
study <- 2
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
# Read the raw data
exp2_file <- "Gaissmaier_et_al_2006_Exp2_Choice_Data.xlsx"
dsex2_resp <- read_excel(exp2_file, sheet = "RESP") # Responses
dsex2_resp <- dsex2_resp[-c(1:8), -2] # Remove extraneous rows/columns
dsex2_cresp <- read_excel(exp2_file, sheet = "CRESP") # Response that would have been correct
dsex2_cresp <- dsex2_cresp[-c(1:8), -2]
dsex2_acc <- read_excel(exp2_file, sheet = "ACC") # Whether the response was accurate
dsex2_acc <- dsex2_acc[-c(1:8), -2]
dsex2_cue <- read_excel(exp2_file, sheet = "Cue")
dsex2_cue <- dsex2_cue[-c(1:8), -2]
# Read demographic data
dmg_file <- "Gaissmaier_et_al_2006_Exps_1_2_Demographics.sav"
ds_dmg <- read.spss(dmg_file, to.data.frame = TRUE)
# Sort by experiment and subject numbers
ds_dmg <- ds_dmg [order(ds_dmg$experim, ds_dmg$vp), ]
subject_ids <- as.numeric(unname(unlist((dsex2_cue[2:nrow(dsex2_cue), 1])))) # Subject ids
options <- c("A_B", "C_D")
option <- c("A", "B", "C", "D")
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
trial <- as.numeric(unname(unlist(dsex2_cue[1, 2:ncol(dsex2_cue)])))
# Remove trial row
dsex2_resp <- dsex2_resp[-1, ]
dsex2_cresp <- dsex2_cresp[-1, ]
dsex2_acc <- dsex2_acc[-1, ]
dsex2_cue <- dsex2_cue[-1, ]
# To store processed data
psd_list <- vector(mode = "list", length(subject_ids))

for (sb in subject_ids) {
  subject <- sb
  # Where 1 = X and 5 = O
  problem <- ifelse(as.numeric(unname(unlist(dsex2_cue[subject, 2:ncol(dsex2_cue)]))) == 1, 1, 2)
  option <- ifelse(problem == 1, options[1], options[2])
  choice <- ifelse(as.numeric(unname(unlist(dsex2_resp[subject, 2:ncol(dsex2_resp)]))) == 1, ifelse(problem==1, choice_pairs[1, 1], choice_pairs[2, 1]), ifelse(problem==1, choice_pairs[1, 2], choice_pairs[2, 2]))
  # Correct predictions are awarded with 3
  outcome <- ifelse(as.numeric(unname(unlist(dsex2_acc[subject, 2:ncol(dsex2_acc)]))) == 1,
                    paste(choice, "3", sep = ":"), paste(choice, "0", sep = ":"))
  sex <- ifelse(as.character(as.vector(ds_dmg[ds_dmg$experim == 2 & ds_dmg$vp == subject, 4])) == "male", "m", "f")
  age <- as.numeric(as.vector(ds_dmg[ds_dmg$experim == 2 & ds_dmg$vp == subject, 3]))
  response_time <- stage <- education <- note1 <- note2 <- condition <- NA
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine processed data
ds_st2_final <- do.call("rbind", psd_list)
# Save
file_name2 <- paste0(paper, "_", "2", "_", "data.csv")
setwd(data_path)
write.table(ds_st2_final, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
