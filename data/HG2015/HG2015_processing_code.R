### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Harman & Gonzales. (2015) Allais from Experience: Choice Consistency, Rare Events, and Common Consequences in Repeated Decisions

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "HG2015"
studies <- c(1, 2)
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet
# A number of participants do the incentivized version while another group do the unincentivized (p. 5 PDF)
option <- c("A", "B", "C", "D")
out_1 <- c(1000, 1000, 1000, 5000)
pr_1 <- c(1, 0.89, 0.11, 0.1)
out_2 <- c(NA, 5000, 0, 0)
pr_2 <- c(NA, 0.1, 0.89, 0.9)
out_3 <- c(NA, 0, NA, NA)
pr_3 <- c(NA, 0.01, NA, NA)

# Create options table
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2, out_3, pr_3)

# Save options sheet
file_name_1 <- paste0(paper, "_", studies[1], "_", "options.csv")
file_name_2 <- paste0(paper, "_", studies[2], "_", "options.csv")

setwd(data_path)
write.table(options_table, file = file_name_1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(options_table, file = file_name_2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

### Process dataset

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper", "studies","raw_path","data_path")))
# Working directory is in processed/options at this point, so go back to raw_data
setwd(raw_path)
# Read data file (excel sheet)
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
data_filename <- "Harman & Ganzalez 2015 all participants raw data.xlsx"
ds_inc <- read_excel(data_filename, sheet = "Allais-1")
ds_non <- read_excel(data_filename, sheet = "133_Allais_Version_2-1 (2)")
# Datasets cluttered - Clean up first for readability
# Remove extraneous columns (necessary for clarity and for removing rows that have NAs, otherwise all data gets removed)
ds_inc <- ds_inc [, -c(which(names(ds_inc) == "V1"):which(names(ds_inc) == "Q21"),
                                       which(names(ds_inc) == "Country"), which(names(ds_inc) == "EdOther"),
                                       which(names(ds_inc) == "Major"),
                                       which(names(ds_inc) == "Q5"):which(names(ds_inc) == "Q23(100)"),
                                       which(names(ds_inc) == "Q34"):which(names(ds_inc) == "Q24(100)"),
                                       which(names(ds_inc) == "Q11"))]
# Remove first row (contains unwanted labels) and empty rows
ds_inc <- ds_inc [-c(1, 113:nrow(ds_inc)), ]
# Note: for a couple of subjects there is incompelete data (not all were included in the paper as well)
# Remove subjects/rows with incomplete data
ds_inc[ds_inc == ""] <- NA # To make sure all empty cells have NAs
ds_inc <- ds_inc[complete.cases(ds_inc), ] # Keep only complete entries
# Second sheet
ds_non <- ds_non [, -c(which(names(ds_non) == "V1"):which(names(ds_non) == "ConDis"),
                       which(names(ds_non) == "Country"), which(names(ds_non) == "EdOther"),
                       which(names(ds_non) == "Major"):sum(which(names(ds_non) == "TOChoice(1)"),-1))]
# Remove first row (contains unwanted labels) and last two rows (empty)
ds_non <- ds_non [-c(1, 102, 103), ]

process_dataset <- function (study, ds, subj_start_ind, inc) {
  # Function to process dataset
  
  # Prepare vectors to create final dataframe (Allais 1 - incentivized group)
  num_trials <- 100 # Verified
  education <- c("Less than High School", "High School / GED", "Some College", "2-year College Degree",
                 "4-year College Degree", "Masters Degree", "Doctoral Degree", "Professional Degree (JD, MD)")
  option <- c("A", "B", "C", "D")
  choice_pairs <- matrix (option, ncol = 2, byrow = TRUE)
  options_v <- c("A_B", "C_D")
  # Extract choice and outcome data of the two problems
  if (isTRUE(inc)) { # Incentivized group (ds_inc)
    condition <- 1
    note1 <- "Incentivised"
    # First problem
    s_ch <- 4
    e_out <- s_ch + 200 - 1 # Start of choices column, plus 100 choices and 100 outcomes minus 1 for correction
    # Second problem
    s_ch2 <- e_out + 1 # Index of next problem comes after the last outcome of the first problem
    e_out2 <- s_ch2 + 200 - 1
    data_prob1 <- ds[, c(s_ch:e_out)]
    data_prob2 <- ds[, c(s_ch2:e_out2)]
  } else { # Non-incentivised group
    condition <- 2
    note1 <- "Non-incentivised"
    # Second problem
    s_ch2 <- which(names(ds_non) == "TOChoice(1)")
    e_ch2 <- s_ch2 + 100 - 1
    s_out2 <- which(names(ds_non) == "TOResult(1)")
    e_out2 <- s_out2 + 100 - 1
    # First problem
    s_ch <- which(names(ds_non) == "MOChoice(1)")
    e_ch <- s_ch + 100 - 1
    s_out <- which(names(ds_non) == "MOResult(1)")
    e_out <- s_out + 100 - 1
    data_prob1 <- ds[, c(s_ch:e_ch, s_out:e_out)]
    data_prob2 <- ds[, c(s_ch2:e_ch2, s_out2:e_out2)]
  }
  
  # Replace choices with option letters
  # Taking into account that each participant got a different order (i.e., 1 and 2 are not tied to a specific option)
  replace_values <- function(r, p) {
    # This is a function within the main function
    # Variable r stands for the vector containing the choices followed by the outcomes for one subject
    # This function determines which options the subject chose and returns a choice-outcome vector
    # For the first gamble pair if there is an outcome of 5000 or 0 then that's gamble B (option B)
    # For the second gamble pair if there is an outcome of 1000 it's A' & if there is an outcome of 5000 it's B' (for the particular participant)
    # Find index of first occurrence of val
    val <- 5000
    ind_outcome <- match(val, r)
    # Find corresponding choice in vector
    key <- r[ind_outcome - 100]
    # Make all choices with this key (1 or 2) to option B (or D), otherwise option A (or C)
    if (p == 1) {
      choices <- ifelse(r[1:100] == key, "B", "A")
    } else {
      choices <- ifelse(r[1:100] == key, "D", "C")
    }
    # Make outcomes
    outcomes <- paste(choices, r[101:200], sep = ":")
    return(c(choices, outcomes))
  }
  # Apply function replace_values to each row and return transposed dataframe
  choice_outcome_p1 <- apply(data_prob1, 1, replace_values, p = 1)
  choice_outcome_p2 <- apply(data_prob2, 1, replace_values, p = 2)
  # Split choices and outcomes, combine by row, then concatenate by columns (no transpose as it was already by apply function)
  choice <- as.vector(rbind(choice_outcome_p1[1:100, ], choice_outcome_p2[1:100, ]), mode = "character")
  outcome <- as.vector(rbind(choice_outcome_p1[101:200, ], choice_outcome_p2[101:200, ]), mode = "character")
  outcome[grepl(pattern = "NA", x = outcome, ignore.case = FALSE)] <- NA # Fix non-choice outcomes
  # Create consecutive subject IDs (new participants in each dataset)
  subject_unq <- seq(subj_start_ind, subj_start_ind + nrow(ds) - 1, by = 1)
  subject <- rep(subject_unq, each = num_trials*2)
  # Education
  education_unq <- education[as.numeric(ds$EdLevel)] # Map education codes to descriptions
  education <- rep(education_unq, each = num_trials*2) # 2 problems
  # Rest of variables
  sex_incent <- ifelse(ds_inc$Gender == 1, "m", "f") # 1 = male
  sex <- rep(sex_incent, each = num_trials*2) # 2 problems
  age_incent <- ds_inc$Age
  age <- rep(age_incent, each = num_trials*2) # 2 problems
  problem_per_subject <- rep(c(1, 2), each = num_trials)
  problem <- rep(problem_per_subject, length(subject_unq))
  options_per_subject <- rep(options_v, each = num_trials)
  options <- rep(options_per_subject, length(subject_unq))
  trial_per_subject <- rep(1:num_trials, 2) # 2 problems
  trial <- rep(trial_per_subject, length(subject_unq))
  stage <- response_time <- note2 <- NA
  # Create final dataframe
  processed_ds <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
}

processed_ds_inc <- process_dataset (studies[1], ds = ds_inc, subj_start_ind = 1, inc = TRUE) # incentivised group
processed_ds_non <- process_dataset (studies[2], ds = ds_non, subj_start_ind = nrow(ds_inc) + 1, inc = FALSE) # non-incentivised group

processed_ds_inc$choice <- as.character(processed_ds_inc$choice)
processed_ds_inc[is.na(processed_ds_inc$choice), "choice"] <- NA
processed_ds_inc$outcome <- as.character(processed_ds_inc$outcome)
processed_ds_inc[is.na(processed_ds_inc$outcome), "outcome"] <- NA
processed_ds_non$choice <- as.character(processed_ds_non$choice)
processed_ds_non[is.na(processed_ds_non$choice), "choice"] <- NA
processed_ds_non$outcome <- as.character(processed_ds_non$outcome)
processed_ds_non[is.na(processed_ds_non$outcome), "outcome"] <- NA
# remove participants and problem with unexpected outcome value
processed_ds_inc <- subset(processed_ds_inc, options == 'C_D')
processed_ds_non <- processed_ds_non[!(processed_ds_non$subject %in% c(106, 109, 112, 126, 198)), ]

# Combine ans save processed datasets
#ds_final <- rbind(processed_ds_inc, processed_ds_non)
#file_name <- paste0(paper, "_", study, "_", "data.csv")

file_name_1 <- paste0(paper, "_",  studies[1], "_", "data.csv")
file_name_2 <- paste0(paper, "_",  studies[2], "_", "data.csv")

setwd(data_path)
write.table(processed_ds_inc, file = file_name_1, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")
write.table(processed_ds_non, file = file_name_2, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")

