### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Biele, Erev, & Ert (2009) Learning, risk attitude and hot stoves in restless bandit problems
# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "BEE2009"

raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
# Set as working directory the folder that contains the data as sent by the author
setwd(raw_path)

### Create the options sheet (review)

### Study 1
# Two problems, two options each, safe and risky, in that order
# Problem 1 = Condition 0.95, Problem 2 = Condition 0.5, AC safe, BD risk
option <- c("A", "B", "C", "D")
description <- c('always get a 0',
                'P(reward(1)[t]|reward(1)[t-1] = 0.95, P(reward(1)[t]|Lose(-1)[t-1] = 0.05, P(lose(-1)[t]|lose(-1)[t-1] = 0.95, P(reward(1)[t]|lose(-1)[t-1] = 0.05', 
                'always get a 0',
                'P(reward(1)[t]|reward(1)[t-1] = 0.5, P(lose(-1)[t]|lose(-1)[t-1] = 0.5')
options_table1 <- data.frame(option,description)

### Study 2
# Twenty problems, two options each, safe and risky. pr is not the proportion of 
# the entire experiment in which an outcome occurs, but rather the probability 
# that after an outcome occurs, another outcome will occur in the next selection.
e <- 40 - length(LETTERS)
option <- c(LETTERS, paste("A",LETTERS[1:e],sep = ""))
description <- c('always get a -5',
                 'P(reward(6)[t]|reward(6)[t-1] = 0.9, P(reward(6)[t]|lose(-8)[t-1] = 0.5', 
                 'always get a 1',
                 'P(reward(6)[t]|reward(6)[t-1] = 0.2, P(reward(6)[t]|lose(-3)[t-1] = 0.9',
                 'always get a -6',
                 'P(reward(0)[t]|reward(0)[t-1] = 0.1, P(reward(0)[t]|lose(-10)[t-1] = 0.2', 
                 'always get a -4',
                 'P(reward(-1)[t]|reward(-1)[t-1] = 0.2, P(reward(-1)[t]|lose(-10)[t-1] = 0.9',
                 'always get a 1',
                 'P(reward(3)[t]|reward(3)[t-1] = 0.7, P(reward(3)[t]|lose(-4)[t-1] = 0.6', 
                 'always get a 7',
                 'P(reward(9)[t]|reward(9)[t-1] = 0.1, P(reward(9)[t]|lose(5)[t-1] = 0.2',
                 'always get a 7',
                 'P(reward(10)[t]|reward(10)[t-1] = 0.8, P(reward(10)[t]|lose(3)[t-1] = 0.2', 
                 'always get a 0',
                 'P(reward(7)[t]|reward(0)[t-1] = 0.1, P(reward(7)[t]|lose(-6)[t-1] = 0.3',
                 'always get a -5',
                 'P(reward(4)[t]|reward(4)[t-1] = 0.9, P(reward(4)[t]|lose(-7)[t-1] = 0.7', 
                 'always get a 2',
                 'P(reward(5)[t]|reward(5)[t-1] = 0.9, P(reward(5)[t]|lose(-8)[t-1] = 0.7',
                 'always get a -1',
                 'P(reward(10)[t]|reward(10)[t-1] = 0.9, P(reward(10)[t]|lose(-5)[t-1] = 0.7', 
                 'always get a 7',
                 'P(reward(9)[t]|reward(9)[t-1] = 0.4, P(reward(9)[t]|lose(1)[t-1] = 0.1',
                 'always get a 4',
                 'P(reward(6)[t]|reward(6)[t-1] = 0.8, P(reward(6)[t]|lose(-1)[t-1] = 0.1', 
                 'always get a -8',
                 'P(reward(9)[t]|reward(9)[t-1] = 0.6, P(reward(9)[t]|lose(-10)[t-1] = 0.1',
                 'always get a -1',
                 'P(reward(10)[t]|reward(10)[t-1] = 0.8, P(reward(10)[t]|lose(-3)[t-1] = 0.4', 
                 'always get a -1',
                 'P(reward(2)[t]|reward(2)[t-1] = 0.8, P(reward(2)[t]|lose(-4)[t-1] = 0.4',
                 'always get a 0',
                 'P(reward(1)[t]|reward(1)[t-1] = 0.1, P(reward(1)[t]|lose(-3)[t-1] = 0.1', 
                 'always get a 1',
                 'P(reward(10)[t]|reward(10)[t-1] = 0.7, P(reward(10)[t]|lose(-9)[t-1] = 0.7',
                 'always get a 1',
                 'P(reward(8)[t]|reward(8)[t-1] = 0.2, P(reward(8)[t]|lose(0)[t-1] = 0.9', 
                 'always get a -6',
                 'P(reward(-5)[t]|reward(-5)[t-1] = 0.5, P(reward(-5)[t]|lose(-9)[t-1] = 0.9')
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
# Clear all variables except path, paper
rm(list=setdiff(ls(), c("path", "paper", "raw_path", "data_path")))
# Back to raw data directory
setwd(raw_path)
# raw_path1 = paste0("/Users/yang/Desktop/material/ARC/项目/3_Data/Final_Yujia/",paper,"/raw_data/EXP1/")
setwd(paste0(raw_path, "EXP1/"))
study <- 1
# Read dataset
files <- list.files()
# Remove extension
nms <- gsub(pattern = ".txt", replacement = "", files)
# Extract subject IDs
subject_ids <- as.numeric(substr(x = nms, start = 8, stop = nchar(files)))
option <- c("A", "B", "C", "D")
options_map <- c(`1`="A_B", `2`="C_D")
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
# Store processed data
psd_list <- vector(mode = "list", length(files))

for (sb in 1:length(files)) {
  df <- read.table(files[sb], header = FALSE, stringsAsFactors = FALSE, fill = TRUE,
                   col.names = c("problem", "trial", "order", "decision", "reward", "safe", "risk", "b", "m", "g", "p", "q"))
  # The two games are for testing order effects
  df <- df[df$problem %in% c(1,2), ]
  subject <- subject_ids[sb] # Subject identifier
  problem <- df$problem
  condition <- problem
  options <- unname(options_map[as.character(df$problem)])
  trial <- df$trial
  choice <- sapply(1:nrow(df), function(ch)
    ifelse(df$decision[ch] == 0, choice_pairs[problem[ch], 1], choice_pairs[problem[ch], 2]))
  outcome <- paste(choice, df$reward, sep = ":")
  response_time <- stage <- sex <- age <- education <- note1 <- note2 <- NA
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine and save processed data
psd_combined <- do.call("rbind", psd_list)
ds_st1_final <- psd_combined [order(psd_combined$subject, psd_combined$problem, psd_combined$trial), ]
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
rm(list=setdiff(ls(), c("path", "paper", "raw_path", "data_path")))
# Back to raw data directory
setwd(paste0(raw_path, "EXP2/"))
study <- 2
# Read dataset
files <- list.files()
e <- 40 - length(LETTERS)
option <- c(LETTERS, paste("A",LETTERS[1:e],sep = ""))
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
opts <- apply(choice_pairs, MARGIN = 1, FUN = function (ch) paste(ch, collapse = "_"))
prob_matrix <- matrix(
  c(0.9, 0.5,
    0.2, 0.9,
    0.1, 0.2,
    0.2, 0.9,
    0.7, 0.6,
    0.1, 0.2,
    0.8, 0.2,
    0.1, 0.3,
    0.9, 0.7,
    0.9, 0.7,
    0.9, 0.7,
    0.4, 0.1,
    0.8, 0.1,
    0.6, 0.1,
    0.8, 0.4,
    0.8, 0.4,
    0.1, 0.1,
    0.7, 0.7,
    0.2, 0.9,
    0.5, 0.9), nrow = 20, ncol = 2, byrow = TRUE)
val_matrix <- matrix(c(-5, -8, 6,
                       1, -3, 6,
                       -6, -10, 0,
                       -4, -10, -1,
                       1, -4, 3,
                       7, 5, 9,
                       7, 3, 10,
                       0, -6, 7,
                       -5, -7, 4,
                       2, -8, 5,
                       -1, -5, 10,
                       7, 1, 9,
                       4, -1, 6,
                       -8, -10, 9,
                       -1, -3, 10,
                       -1, -4, 2,
                       0, -3, 1,
                       1, -9, 10,
                       1, 0, 8,
                       -6, -9, -5), nrow = 20, ncol = 3, byrow = TRUE)
pvm <- apply(val_matrix, MARGIN = 1, function (m) paste(m, collapse = ""))
# List to store processed data
psd_list <- vector(mode = "list", length(files))

for (sb in 1:length(files)) {
  df <- read.table(files[sb], header = FALSE, stringsAsFactors = FALSE, fill = TRUE,
                   col.names = c("problem", "trial", "order", "decision", "reward", "safe", "risk", "b", "m", "g", "p", "q"))
  # The last is probably an end of data row, so we keep only the rows we want
  df <- df[df$problem %in% c(1:20), ]
  # Assign subject ID
  subject <- sb
  p <- paste(df$m, df$b, df$g, sep = "")
  problem <- match(p, pvm)
  options <- opts[problem]
  # One hundred trials per problem
  trial <- df$trial
  choice <- sapply(1:nrow(df), function(ch)
      ifelse(df$decision[ch] == 0, choice_pairs[problem[ch],1], choice_pairs[problem[ch],2]))
  outcome <- paste(choice, df$reward, sep = ":")
  response_time <- stage <- sex <- age <- education <- condition <- note1 <- note2 <- NA
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine and save processed data
psd_combined <- do.call("rbind", psd_list)
ds_st2_final <- psd_combined [order(psd_combined$subject, psd_combined$problem, psd_combined$trial), ]
# exclude participants with unexpected value
ds_st2_final <- ds_st2_final[!(ds_st2_final$subject %in% c(26,29)),]
file_name <- paste0(paper, "_", "2", "_", "data.csv")
setwd(data_path)
write.table(ds_st2_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

