### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Barron & Erev (2003) Small Feedback-based Decisions and Their Limited Correspondence to Description-based Decisions

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "BE2003"
studies <- c(1, 2, 3, 4, 5)

raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")

setwd(raw_path)
##### Create the options sheet

##### Study 1 (Problems 1,2,3)
option <- c("A", "B", "C", "D", "E", "F")
# TN (25, 17.7, 0) = Truncated normal distribution (at zero) centered at 25 and a standard deviation of 17.7 (with an implied mean of 25.63)
# N (100, 354) = Normal distribution with a mean of 100 and a standard deviation of 354

description <- c("N(100,354^2)", "TN(25,17.7^2,0)", "N(1300,354^2)", "N(1225,17.7^2)", "N(1300,17.7^2)", "N(1225,17.7^2)")

options_table_1 <- data.frame(option, description)

##### Study 2 (Problems 4,5)
option <- c("A", "B", "C", "D")
out_1 <- c(4, 3, 4, 3)
pr_1 <- c(0.8, 1, 0.2, 0.25)
out_2 <- c(0, NA, 0, 0)
pr_2 <- c(0.2, NA, 0.8, 0.75)

options_table_2 <- data.frame(option, out_1, pr_1, out_2, pr_2)

##### Study 3 (3a) (Problems 4,6)
# Note that in 3a (4,6) problem 4 was taken from study 2, new subjects played problem 6 only
option <- c("A", "B", "C", "D")
out_1 <- c(4, 3, -3, -4)
pr_1 <- c(0.8, 1, 1, 0.8)
out_2 <- c(0, NA, NA, 0)
pr_2 <- c(0.2, NA, NA, 0.2)

options_table_3 <- data.frame(option, out_1, pr_1, out_2, pr_2)

##### Study 4 (3b) (Problems 7,8)
option <- c("E", "F", "G", "H")
out_1 <- c(9, 10, -9, -10)
pr_1 <- c(1, 0.9, 1, 0.9)
out_2 <- c(NA, 0, NA, 0)
pr_2 <- c(NA, 0.1, NA, 0.1)

options_table_4 <- data.frame(option, out_1, pr_1, out_2, pr_2)

##### Study 5(4) (Problems 9,10,11)
option <- c("A", "B", "C", "D", "E", "F")
out_1 <- c(32, 3, 32, 3, -3, -32)
pr_1 <- c(0.1, 1, 0.025, 0.25, 1, 0.1)
out_2 <- c(0, NA, 0, 0, NA, 0)
pr_2 <- c(0.9, NA, 0.975, 0.75, NA, 0.9)
options_table_5 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options sheet

file_name_1 <- paste0(data_path,paper, "_", studies[1], "_", "options.csv")
file_name_2 <- paste0(data_path,paper, "_", studies[2], "_", "options.csv")
file_name_3 <- paste0(data_path,paper, "_", studies[3], "_", "options.csv")
file_name_4 <- paste0(data_path,paper, "_", studies[4], "_", "options.csv")
file_name_5 <- paste0(data_path,paper, "_", studies[5], "_", "options.csv")
write.table(options_table_1, file = file_name_1, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")
write.table(options_table_2, file = file_name_2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(options_table_3, file = file_name_3, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(options_table_4, file = file_name_4, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(options_table_5, file = file_name_5, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

################################################################################################

### Process dataset
# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper", "studies", "data_path", "raw_path")))
# Back to raw data directory
setwd(raw_path)

data_file_name <- paste0(raw_path, "BarronErev2003 11 no forg problems 2.txt")
dataset <- read.table(data_file_name, header = TRUE, skip = 3)
# Fix some column names
colnames(dataset)[1] <- "problem"
colnames(dataset)[10] <- "subject"
colnames(dataset)[13] <- "outcome"
# Extract data for study 1 (problems 1,2,3)
dataset_st1 <- dataset [which(dataset$problem %in% c(1,2,3)), ]
option_st1 <- c("A", "B", "C", "D", "E", "F")
# Extract data for study 2 (problems 4,5)
dataset_st2 <- dataset [which(dataset$problem %in% c(4,5)), ]
option_st2 <- c("A", "B", "C", "D")
# Extract data for study 3a and 3b (problems 4,6,7,8)
dataset_st3 <- dataset [which(dataset$problem %in% c(4,6)), ]
dataset_st4 <- dataset [which(dataset$problem %in% c(7,8)), ]
option_st3 <- c("A", "B", "C", "D")
option_st4 <- c("E", "F", "G", "H")
# Extract data for study 4 (problems 9,10,11)
dataset_st5 <- dataset [which(dataset$problem %in% c(9,10,11)), ]
option_st5 <- c("A", "B", "C", "D", "E", "F")

process.dataset.sp <- function (ds, option, st) {
  # Function to process data
  
  options_alt1 <- option [c(TRUE, FALSE)] # ???
  options_alt2 <- option [c(FALSE, TRUE)] # ???
  options_v <- paste(options_alt1, options_alt2, sep = "_") # "A_B" "C_D" "E_F"
  choice_pairs <- matrix (option, ncol = 2, byrow = TRUE)

  # Rest of variables
  response_time <- stage <- age <- sex <- education <- note1 <- note2 <- NA

  # Order by problem
  ds_byprob <- ds [order(ds$problem), ]
  problems <- unique(ds_byprob$problem) # problems in this dataset
  
  # List to store this study's processed data
  processed_data_per_problem_list <- vector (mode = "list", length = length(problems))
  next_start_element <- 1 # The first element in the first sequence of the first problem
  for (p in 1:length(problems)) {
    prob <- problems[p]
    problem <- ds_byprob [which(ds_byprob$problem == prob), c("problem")]
    condition <- p
    trial <- ds_byprob [which(ds_byprob$problem == prob), c("trial")]
    subjects <- ds_byprob [which(ds_byprob$problem == prob), c("subject")]
    
    # Each subject faced only one problem, but subject numbers reset for each problem,
    # Hence, within each study make subject numbers continuous
    # Create a consecutive sequence
    subject_seq <- seq(next_start_element, next_start_element + length(unique(subjects)) - 1, by = 1)
    # Now replace the original subject vector with the consecutive elements
    original_subs <- unique(subjects)
    map_locations <- match(subjects, original_subs) # Get indices of subject in original_subs
    # Map the indices in map_location with the numbers in subject_seq
    subject <- subject_seq[map_locations]
    # Store the last subject number so that for the next problem the sequence continues from there
    next_start_element <- subject_seq[length(subject_seq)] + 1
    
    # Map choices
    choice_raw <- ds_byprob [which(ds_byprob$problem == prob), c("choice")]
    choice <- ifelse(choice_raw == "1", choice_pairs[p,1], choice_pairs[p,2]) # Set options
    # Map options
    current_options <- options_v[p]
    options <- rep(current_options, length(trial))
    # Make the outcomes by joining the choice_raw and outcome_raw vectors element-wise
    outcome_raw <- ds_byprob [which(ds_byprob$problem == prob), c("outcome")]
    outcome <- paste(choice, outcome_raw, sep = ":")
    
    # Create interim dataframe
    study <- studies[st]
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    processed_data_per_problem_list[[p]] <- psd
  }
  
  processed_data_combined <- do.call("rbind", processed_data_per_problem_list) # Recombine frames
  return(processed_data_combined)
}

# Function calls
processed_dataset_st1 <- process.dataset.sp(ds = dataset_st1, option = option_st1, st = 1)
processed_dataset_st2 <- process.dataset.sp(ds = dataset_st2, option = option_st2, st = 2)
processed_dataset_st3 <- process.dataset.sp(ds = dataset_st3, option = option_st3, st = 3)
processed_dataset_st4 <- process.dataset.sp(ds = dataset_st4, option = option_st4, st = 4)
processed_dataset_st5 <- process.dataset.sp(ds = dataset_st5, option = option_st5, st = 5)
# Concatenate 3a and 3b
# processed_dataset_st3 <- rbind(processed_dataset_st3a, processed_dataset_st3b)

# Sort studies by subject, problem, trial
ds_final_st1 <- processed_dataset_st1 [order(processed_dataset_st1$subject, processed_dataset_st1$problem, processed_dataset_st1$trial), ]
ds_final_st2 <- processed_dataset_st2 [order(processed_dataset_st2$subject, processed_dataset_st2$problem, processed_dataset_st2$trial), ]
ds_final_st3 <- processed_dataset_st3 [order(processed_dataset_st3$subject, processed_dataset_st3$problem, processed_dataset_st3$trial), ]
ds_final_st4 <- processed_dataset_st4 [order(processed_dataset_st4$subject, processed_dataset_st4$problem, processed_dataset_st4$trial), ]
ds_final_st5 <- processed_dataset_st5 [order(processed_dataset_st5$subject, processed_dataset_st5$problem, processed_dataset_st5$trial), ]

# remove participants with unexpected values
ds_final_st4 <-  subset(ds_final_st4, !(subject %in% c(20, 50)))

# Save combined processed data
file_name_1 <- paste0(data_path, paper, "_", studies[1], "_", "data.csv")
file_name_2 <- paste0(data_path, paper, "_", studies[2], "_", "data.csv")
file_name_3 <- paste0(data_path, paper, "_", studies[3], "_", "data.csv")
file_name_4 <- paste0(data_path, paper, "_", studies[4], "_", "data.csv")
file_name_5 <- paste0(data_path, paper, "_", studies[5], "_", "data.csv")
write.table(ds_final_st1, file = file_name_1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(ds_final_st2, file = file_name_2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(ds_final_st3, file = file_name_3, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(ds_final_st4, file = file_name_4, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(ds_final_st5, file = file_name_5, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
