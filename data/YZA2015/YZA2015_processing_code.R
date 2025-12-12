### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Yechiam et al. (2015) Loss restlessness and gain calmness: durable effects of losses and gains on choice switching

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "YZA2015"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)
### Create the options sheets

# Study 1
# Four problems, safe and risky choices, in that order
# Gain-low, Gain-high, Loss-low, Loss-high
option <-  LETTERS[1:8]
out_1 <- c(1,    0,     100,  0,    -1,    0,    -100,   0)
pr_1 <- c(1.0,   0.5,   1.0,  0.5,  1.0,   0.5,   1.0,   0.5)
out_2 <- c(NA,   2,     NA,   200,  NA,    -2,    NA,    -200)
pr_2 <- c(NA,    0.5,   NA,   0.5,  NA,    0.5,   NA,    0.5)
# Save to data frame
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Study 2
# Four problems, safe and risky choices, in that order
# Gain-low, Gain-high, Mixed-low, Mixed-high
option <- LETTERS[1:8]
out_1 <- c(1,     0,      100,    0,      1,    2,     100,   200)
pr_1 <- c(1.0,    0.5,    1.0,    0.5,    0.5,  0.5,   0.5,   0.5)
out_2 <- c(NA,    2,      NA,     200,    -1,   -2,   -100,   -200)
pr_2 <- c(NA,     0.5,    NA,     0.5,    0.5,  0.5,   0.5,   0.5)
# Save to data frame
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

### Process datasets

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)

# Study 1
study <- 1
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
# Read the data file
file_data <- "data_send.xlsx"
ds_st1 <- read_excel(file_data, sheet = "Sheet1")
ds_st2 <- read_excel(file_data, sheet = "Sheet2")
# Friendly warnings because of "X" characters in some choice/outcome columns
# Remove incomplete data (will be reflected in "rle")
# Could have used "complete.cases" but some entries have "X" so needs conversion to NA first
ds_st1 <- ds_st1[!is.na(as.numeric(as.character(ds_st1$outcome))),]
ds_st2 <- ds_st2[!is.na(as.numeric(as.character(ds_st2$outcome))),]
st1_problems <- list(c(1,0,2), c(100,0,200), c(-1,0,-2), c(-100,0,-200))
st2_problems <- list(c(1,0,2), c(100,0,200), c(1,-1,2,-2), c(100,-100,200,-200))
option <-  LETTERS[1:8]
choice_pairs <- matrix (option, ncol = 2, byrow = TRUE)
paired_opts <- c("A_B", "C_D", "E_F", "G_H")
response_time <- stage <- sex <- age <- education <- note2 <- note1 <- condition <- NA

process_st <- function (ds, st) {
  
  if (st == 1) {
    study <- 1
    problem_elms <- st1_problems
  } else {
    study <- 2
    problem_elms <- st2_problems
  }
  # Subject frequencies
  subject_freq <- rle(ds$`subject number`)
  # Not all subjects have data for all 4 problems - they will be included nonetheless (the "problem" column shows which task they performed)
  processed_list <- vector(mode = "list", length(subject_freq$values))
  for (sb in 1:length(subject_freq$values)) {
    # Get the number of trials associated with the unique subject number
    num_trials <- subject_freq$lengths[sb]
    # Get subject number from dataset
    subject <- subject_freq$values[sb]
    # Get choice data
    choice_raw <- unname(unlist(ds[ds$`subject number` == subject_freq$values[sb], "choice"]))
    # Get payoffs
    payoffs <- unname(unlist(ds[ds$`subject number` == subject_freq$values[sb], "outcome"]))
    # Make list of 100-trial blocks (100 trials per problem)
    choice_list <- split(choice_raw, ceiling(seq_along(choice_raw)/100))
    payoff_list <- split(payoffs, ceiling(seq_along(payoffs)/100))
    # For storing results
    problem_list <- vector(mode = "list", length(payoff_list))
    options_list <- vector(mode = "list", length(payoff_list))
    mapped_choiceList <- vector(mode = "list", length(payoff_list))
    mapped_outcomeList <- vector(mode = "list", length(payoff_list))
    for (p in 1:length(payoff_list)) {
      # Figure out which problems the subject faced, and map the data
      task <- payoff_list[[p]]
      unq_elements <- unique(task)
      problem_num <- ifelse (all(unq_elements %in% problem_elms[[1]]), 1,
                      ifelse(all(unq_elements %in% problem_elms[[2]]), 2,
                             ifelse(all(unq_elements %in% problem_elms[[3]]), 3, 4)))
      # Map options, choices, and outcomes
      options_list[[p]] <- rep(paired_opts[problem_num], length(task))
      problem_list[[p]] <- rep(problem_num, length(task)) # Repeat problem number
      mapped_choices <- ifelse(choice_list[[p]] == 0, choice_pairs[problem_num,1], choice_pairs[problem_num,2]) # (0 safe, 1 risky)
      mapped_choiceList[[p]] <- mapped_choices
      mapped_outcomeList[[p]] <- paste(mapped_choiceList[[p]], payoff_list[[p]], sep = ":")
    }
    # Create this subject's dataframe
    trial <- unname(unlist(lapply(payoff_list, function(d) 1:length(d))))
    choice <- unlist(mapped_choiceList)
    outcome <- unlist(mapped_outcomeList)
    problem <- unlist(problem_list)
    options <- unlist(options_list)
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    psd <- psd[order(psd$subject, psd$problem, psd$trial), ] # Sort
    # Store in main list
    processed_list[[sb]] <- psd
  }
  processed_all <- do.call("rbind", processed_list) # Combine
  return(processed_all)
}

# Function calls
ds_st1_final <- process_st(ds = ds_st1, st = 1)
ds_st2_final <- process_st(ds = ds_st2, st = 2)

# exclude subjects with unexpected values
ds_st1_final <- ds_st1_final[!(ds_st1_final$subject %in% c(43, 52)),]

# Save processed data
file_name1 <- paste0(paper, "_", "1", "_", "data.csv")
file_name2 <- paste0(paper, "_", "2", "_", "data.csv")
setwd(data_path)
write.table(ds_st1_final, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(ds_st2_final, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
