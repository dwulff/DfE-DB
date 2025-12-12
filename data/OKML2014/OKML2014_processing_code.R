### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Otto et al. (2014) Physiological and behavioral signatures of reflective exploratory choice

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "OKML2014"
studies <- c(1, 2)
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1
# One problem two options.
option <- c("A", "B")
description <- c("Payoff begins with 10 points, and every trial a probability of 0.075 the payoff will increase by 20 points if it is smaller than the other option's payoff.",
                 "Payoff begins with 20 points, and every trial a probability of 0.075 the payoff will increase by 20 points if it is smaller than the other option's payoff.")
options_table_1 <- data.frame(option, description)

# Study 2
# One problem, two options
option <- c("A", "B", "C", "D")
description <- c("Payoff begins with 10 points, and every trial a probability of 0.025 (the change happens after 100 trials) the payoff will increase by 20 points if it is smaller than the other option's payoff.",
                 "Payoff begins with 20 points, and every trial a probability of 0.025 (the change happens after 100 trials) the payoff will increase by 20 points if it is smaller than the other option's payoff.",
                 "Payoff begins with 10 points, and every trial a probability of 0.125 (the change happens after 100 trials) the payoff will increase by 20 points if it is smaller than the other option's payoff.",
                 "Payoff begins with 20 points, and every trial a probability of 0.125 (the change happens after 100 trials) the payoff will increase by 20 points if it is smaller than the other option's payoff.")
options_table_2 <- data.frame(option, description)


# Save options sheet
file_name_1 <- paste0(paper, "_", studies[1], "_", "options.csv")
file_name_2 <- paste0(paper, "_", studies[2], "_", "options.csv")
setwd(data_path)
write.table(options_table_1, file = file_name_1, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")
write.table(options_table_2, file = file_name_2, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")

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
# Back to raw data directory
setwd(raw_path)
# Enter the sub-directory containing the data files
setwd("cabn_data/")
file_list <- list.files()

process_ds <- function (ds_name, st) {
  
  study <- studies[st]
  # Read data file
  ds <- read.table(file = ds_name, header = TRUE)
  # Fix response times
  rt <- ds$rt
  rt <- round(rt * 1000)
  ds$rt <- rt
  # Trials where response was too late are indicated with -.001 in column rt (now -1 after *1000)
  # These trials get excluded
  ds <- ds[-which(ds$rt == -1), ]
  # Subject IDs and frequencies
  subject_freq <- rle(sort(ds$subj))
  option <- c("A", "B", "C", "D")
  options_raw <- c("A_B", "C_D")
  problem <- 1
  choice_pairs <- matrix (option, ncol = 2, byrow = TRUE)
  # List to store each subject's processed data
  psd_list <- vector(mode = "list", length(subject_freq$values))
  
  for (sb in 1:length(subject_freq$values)) {
    subject <- subject_freq$values[sb]
    df <- ds[ds$subj == subject, ]
    trial <- df$trial
    if (st == 2) {
      cond <- df$cond
      problem_map <- c(`0.025` = 1, `0.125` = 2) # named vector
      cond_vector <- df[, "cond"]
      problem <- problem_map[as.character(cond_vector)] # Map to problem numbers
      note1 <- paste("P(jump) =", cond, sep = " ")
    }
    # Map choices to options
    choice <- ifelse(df$resp == 1, choice_pairs[problem, 1], choice_pairs[problem, 2])
    outcome_raw <- df$outcome
    outcome <- paste(choice, outcome_raw, sep = ":")
    options <- options_raw[problem]
    response_time <- df$rt
    stage <- sex <- age <- education <- condition <- note2 <- note1 <- NA
    # Create final dataframe
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    psd_list[[sb]] <- psd
  }
  # Combine processed data
  psd_combined <- do.call("rbind", psd_list)
  return(psd_combined)
}

ds_final_st1 <- process_ds (ds_name = file_list[[1]], st = 1)
ds_final_st2 <- process_ds (ds_name = file_list[[2]], st = 2)

# Save processed data
file_name_1 <- paste0(paper, "_", studies[1], "_", "data.csv")
file_name_2 <- paste0(paper, "_", studies[2], "_", "data.csv")
setwd(data_path)
write.table(ds_final_st1, file = file_name_1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(ds_final_st2, file = file_name_2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
