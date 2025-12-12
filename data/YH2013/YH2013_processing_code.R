### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Yechiam & Hochman (2013) Loss-aversion or loss-attention: The impact of losses on cognitive performance

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "YH2013"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheets

# Study 1
# Partitioned as two problems, each with two conditions
# Represent as four problems, each with two options, low expected-value option and high expected-value, in that order
# NOTE: noise added [-5, 5] to the outcome every trial
option <- LETTERS[1:8]
out_1 <- c(30,   -1,    30,    1,    125,  -1,   125,   1)
pr_1 <- c(1/11,   0.5,   1/11,   0.5,  1/11,  0.5,  1/11,   0.5)
out_2 <- c(31,   200,    31,    200,    126,  200,   126,   200)
pr_2 <- c(1/11,   0.5,   1/11,   0.5,  1/11,  0.5,  1/11,   0.5)
out_3 <- c(32,   NA,    32,    NA,    127,  NA,   127,   NA)
pr_3 <- c(1/11,   NA,   1/11,   NA,  1/11,  NA,  1/11,   NA)
out_4 <- c(33,   NA,    33,    NA,    128,  NA,   128,   NA)
pr_4 <- c(1/11,   NA,   1/11,   NA,  1/11,  NA,  1/11,   NA)
out_5 <- c(34,   NA,    34,    NA,    129,  NA,   129,   NA)
pr_5 <- c(1/11,   NA,   1/11,   NA,  1/11,  NA,  1/11,   NA)
out_6 <- c(35,   NA,    35,    NA,    130,  NA,   130,   NA)
pr_6 <- c(1/11,   NA,   1/11,   NA,  1/11,  NA,  1/11,   NA)
out_7 <- c(36,   NA,    36,    NA,    131,  NA,   131,   NA)
pr_7 <- c(1/11,   NA,   1/11,   NA,  1/11,  NA,  1/11,   NA)
out_8 <- c(37,   NA,    37,    NA,    132,  NA,   132,   NA)
pr_8 <- c(1/11,   NA,   1/11,   NA,  1/11,  NA,  1/11,   NA)
out_9 <- c(38,   NA,    38,    NA,    133,  NA,   133,   NA)
pr_9 <- c(1/11,   NA,   1/11,   NA,  1/11,  NA,  1/11,   NA)
out_10 <- c(39,   NA,    39,    NA,    134,  NA,   134,   NA)
pr_10 <- c(1/11,   NA,   1/11,   NA,  1/11,  NA,  1/11,   NA)
out_11 <- c(40,   NA,    40,    NA,    135,  NA,   135,   NA)
pr_11 <- c(1/11,   NA,   1/11,   NA,  1/11,  NA,  1/11,   NA)
# Save to data frame
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2, out_3, pr_3, out_4, pr_4, out_5, pr_5, out_6, pr_6, out_7, pr_7, out_8, pr_8, out_9, pr_9, out_10, pr_10, out_11, pr_11)

# Study 4
# One problem, two option pairs, each with low-ev and high-ev options
# Only one pair of the "x" options appears in each trial (randomly) see p. 224 in paper
# So one setup for the loss condition (ABCD), one for the gain condition (ABEF)
option <- c("A", "B", "C", "D")
out_1 <- c(1,   1,    1,    1)
pr_1 <- c(0.25, 0.15, 0.25, 0.15)
out_2 <- c(200, 200,  200,  200)
pr_2 <- c(0.25, 0.35, 0.25, 0.35)
out_3 <- c(5,   5,   -5,    -5)
pr_3 <- c(0.5,  0.5,  0.5,    0.5)

# Save to data frame
options_table4 <- data.frame(option, out_1, pr_1, out_2, pr_2, out_3, pr_3)

# Save options sheet
file_name1 <- paste0(paper, "_", "1", "_", "options.csv")
file_name4 <- paste0(paper, "_", "4", "_", "options.csv")
setwd(data_path)
write.table(options_table1, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(options_table4, file = file_name4, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

### Process datasets

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper", "studies","raw_path","data_path")))
setwd(raw_path)
setwd('YH2013study1')

### Study 1
study <- 1
subjectID_counter <<- 1 # Global variable
# Read data files
f_dataGain <- "data_gain.csv"
f_dataLoss <- "data_loss.csv"
f_gainRev <- "gain_rev.csv"
f_lossRev <- "loss_rev.csv"
ds_dataLoss <- read.csv(f_dataLoss, header = FALSE) # Problem 1 (Advantageous-losing) options AB
ds_dataGain <- read.csv(f_dataGain, header = FALSE) # Problem 2 (Advantageous-gain) options CD
ds_lossRev <- read.csv(f_lossRev, header = FALSE) # Problem 3 (Disadvantageous-losing) options EF
ds_gainRev <- read.csv(f_gainRev, header = FALSE) # Problem 4 (Disadvantageous-gain) options GH
options_v <- c("A_B", "C_D", "E_F", "G_H")
option <- LETTERS[1:8]
choice_pairs <- matrix (option, ncol = 2, byrow = TRUE)
problems_v <- c(1, 2, 3, 4)
note_map <- c(`1`="Advantageous losing - Loss", `2`="Advantageous losing - Win",
              `3`="Disadvantageous losing - Loss", `4`="Disadvantageous losing - Loss")
ds_list <- list(ds_dataLoss, ds_dataGain, ds_lossRev, ds_gainRev) # Make list on which to operate
ds_list <- lapply(ds_list, function (df) setNames(df, c("trial", "pressed", "subject", "payoff", "foregone")))
ds_processed_list <- vector(mode = "list", length(ds_list))

for (ls in 1:length(ds_list)) {
  ds <- ds_list[[ls]] # Get dataset
  if (ls == 3) { # Fix an issue with the ds_lossRev dataset (problem 2 options EF)
    ds <- ds[-c(nrow(ds), nrow(ds)-1), ] # Remove last two rows
    ds[3001, "V3"] <- 12 # Assign ID 12 to extra trial
  }
  problem <- problems_v[ls] # Problem number
  options <- options_v[ls]
  condition <- ifelse(problem %in% c(1,2), 1, 2)
  note1 <- unname(note_map[as.character(problem)])
  # Get frequencies and IDs
  subject_freq <- rle(ds$subject)
  # Some IDs are repeated (so create new and consecutive IDs)
  subdf_list <- split(ds, cut(1:nrow(ds), length(subject_freq$values), FALSE)) # Split dataframe into subjects
  psd_list <- vector(mode = "list", length(subject_freq$values))
  for (sb in 1:length(subdf_list)) {
    subdf <- subdf_list[[sb]]
    subject <- subjectID_counter # Take ID from global counter
    subjectID_counter <<- subjectID_counter + 1 # Increment
    trial <- subdf$trial
    choice <- ifelse(subdf$pressed == 1, choice_pairs[ls, 1], choice_pairs[ls, 2])
    choice_fg <- ifelse(subdf$pressed == 1, choice_pairs[ls, 2], choice_pairs[ls, 1])
    outcome <- paste(paste(choice, subdf$payoff, sep = ":"), paste(choice_fg, subdf$foregone, sep = ":"), sep = "_")
    # Rest of variables
    response_time <- stage <- sex <- age <- education <- note2 <- NA
    # Create dataframe
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    psd_list[[sb]] <- psd
  }
  # Combine and store
  ds_processed <- do.call("rbind", psd_list)
  ds_processed_list[[ls]] <- ds_processed
}

# Combine and save processed data
ds_st1_final <- do.call("rbind", ds_processed_list)
# remove participant with unexpected value
ds_st1_final <- ds_st1_final[!(ds_st1_final$subject == 116), ]
file_name1 <- paste0(paper, "_", "1", "_", "data.csv")
setwd(data_path)
write.table(ds_st1_final, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

################################################################################################

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)

# Study 4
study <- 4
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
file_data <- "results3_web_study4.xlsx"
# 48 subjects concatenated side-wise, odd numbers in loss condition, even number in gain condition
ds <- as.data.frame(read_excel(file_data, sheet = "Sheet1", skip = 7))
# Remove first column
ds <- ds[, -1]
ds_loss <- ds[, 1:prod(24,4)]
ds_gain <- ds[, -c(1:prod(24,4))]
split_df_byCol <- function (df, num_subjects) {
  ds_list <- vector(mode = "list", num_subjects) # New list
  temp_df <- df
  for (j in 1:num_subjects) { # Every 4 columns
    df <- temp_df
    if (ncol(df) == 4) {
      ds_cut <- df
    } else {
      ds_cut <- df[, -c(5:ncol(df))]
    }
    temp_df <- df[, -c(1,2,3,4)]
    ds_list[[j]] <- ds_cut
  }
  return(ds_list)
}
# Split into list of subject dataframes
ds_loss_list <- split_df_byCol (df = ds_loss, num_subjects = 24)
ds_gain_list <- split_df_byCol (df = ds_gain, num_subjects = 24)
# Set column labels
ds_loss_list <- lapply(ds_loss_list, function (df) setNames(df, c("subject", "pressed", "payoff", "foregone")))
ds_gain_list <- lapply(ds_gain_list, function (df) setNames(df, c("subject", "pressed", "payoff", "foregone")))
# fix one coding mistake: change the second subject 21 ID to 18
ds_loss_list[[11]]$subject <- 18
# Function to map options, choices, and outcomes, and bind the variables
process_frame <- function (ds, val, note1) {
  problem <- ifelse(note1 == "Loss condition", 2, 1)
  condition <- problem
  trial <- 1:200
  subject <- unique(ds$subject)
  payoff <- ds$payoff
  foregone <- ds$foregone
  if (val == -5) { # The value of the two options in trial type b
    opts <- c("C_D")
    sel <- c("C", "D")
  } else {
    opts <- c("A_B")
    sel <- c("A", "B")
  }
  options <- opts

  ds$choice <- NA
  ds$choice_fg <- NA
  if (options=="A_B") {
    ds$choice <- ifelse(ds$pressed==0, "A", "B")
    ds$choice_fg <- ifelse(ds$pressed==0, "B", "A")
  } else {
    ds$choice <- ifelse(ds$pressed==0, "C", "D")
    ds$choice_fg <- ifelse(ds$pressed==0, "D", "C")
  }
  
  choice <- ds$choice
  choice_fg <- ds$choice_fg
  outcome <- paste(paste(choice, payoff, sep = ":"), paste(choice_fg, foregone, sep = ":"), sep = "_")
  # Rest of variables
  response_time <- stage <- sex <- age <- education <- note2 <- NA
  ds <- cbind(ds, paper, study, subject, options, condition, problem, trial, choice, outcome, response_time, sex, stage, age, education, note1, note2)
  # Required order of variables: paper, study, subject, problem, options, trial, choice, outcome
  psd <- ds[, c("paper", "study", "subject", "problem", "condition", "options", "trial", "choice", "outcome", "response_time", "stage", "sex", "age", "education", "note1", "note2")]
  return(psd)
}

#test$options

#test <- process_frame(ds = df_loss, val = -5, note1 = note_l)

# Loop through both lists and process data using above function
for (sb in 1:24) {
  note_l <- "Loss condition"
  df_loss <- ds_loss_list[[sb]]
  psd_loss <- process_frame(ds = df_loss, val = -5, note1 = note_l)
  # Store updated frame
  ds_loss_list[[sb]] <- psd_loss
  
  note_g <- "Gain condition"
  df_gain <- ds_gain_list[[sb]]
  psd_gain <- process_frame(ds = df_gain, val = 5, note1 = note_g)
  # Store updated frame
  ds_gain_list[[sb]] <- psd_gain
}

# Combine and save processed data
ds_loss_final <- do.call("rbind", ds_loss_list)
ds_gain_final <- do.call("rbind", ds_gain_list)
ds_st4_final <- rbind(ds_loss_final, ds_gain_final)


file_name4 <- paste0(paper, "_", "4", "_", "data.csv")
setwd(data_path)
write.table(ds_st4_final, file = file_name4, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
