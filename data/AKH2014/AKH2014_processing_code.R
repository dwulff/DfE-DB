### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
# Avrahami et al. (2014) Taking the sting out of choice: Diversification of investments

paper <- "AKH2014"

raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

##### Create the options sheet

### Study 1 data not available
### Study 2
# Safer, medium, and riskier options
# 2 (paradigm, diversification or choice) X 2 (world, good or bad) - Only the choice paradigm is considered
# Both independent variables were manipulated between subjects
# So Problem 1: good world (A,B,C), Problem 2: bad world (D,E,F)
option <- c("A", "B", "C", "D", "E", "F")
out_1 <- c(9, 8, 7,                  9,8, 7)
pr_1 <- c(0.667, 0.71, 0.75,         0.333, 0.31, 0.25)
out_2 <- c(-3, -2,-1,                -3, -2, -1)
pr_2 <- c(0.333, 0.29, 0.25,         0.667, 0.69, 0.75)
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options
file_name <- paste0(paper, "_", "2", "_", "options.csv")

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

# Clear all variables except path, paper
rm(list=setdiff(ls(), c("path", "paper", "raw_path", "data_path")))
# Back to raw data directory
setwd(raw_path)
study <- 2
# Read dataset
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
file_data <- "Diversification for Ahmed bare.xlsx"
ds <- read_excel(file_data, sheet = "Sheet1")
# Analyse the choice paradigm only (condition = 1)
ds <- ds[ds$condition1s2a == 1, ]
# Subject IDs and frequencies
subject_freq <- rle(sort(ds$realSN))
### Options table - in case variable got deleted
option <- c("A", "B", "C", "D", "E", "F")
out_1 <- c(7,     8,     9,         7,        8,      9)
pr_1 <- c(0.75,   0.71,  0.667,     0.25,     0.31,   0.333)
out_2 <- c(-1,    -2,    -3,        -1,       -2,     -3)
pr_2 <- c(0.25,   0.29,   0.333,    0.75,     0.69,   0.667)
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)
###
# Reorder options table and cast to a list
opts_table <- options_table[, c(1,4,5,2,3)]
opts_table <- opts_table[, -1]
opts_table_asList <- lapply(1:nrow(opts_table), function(n) unname(unlist(opts_table[n, ])))
choice_matrix <- matrix(option, ncol = 3, nrow = 2, byrow = TRUE)
# List to store each subject's processed data
psd_list <- vector(mode = "list", length(subject_freq$values))

for (sb in 1:length(subject_freq$values)) {
  # Subject was assigned to one problem only (good or bad world) under one condition
  subject <- as.numeric(subject_freq$values[sb])
  # Extract this subject's data
  df <- ds[ds$realSN == subject, ]
  sex <- ifelse(df$female == 0, "m", "f")
  note1 <- "Choice paradigm"
  # Options
  n <- 1
  opts_list <- list(c(df$val00[n], df$prob00[n], df$val01[n], df$prob01[n]), c(df$val10[n], df$prob10[n], df$val11[n], df$prob11[n]),
                    c(df$val20[n], df$prob20[n], df$val21[n], df$prob21[n]))
  mapped_options_logical <- lapply(opts_list, function(vec1)
    lapply (opts_table_asList, function (vec2) all(unname(unlist(vec1)) == vec2)))
  mapped_options <- lapply(mapped_options_logical, function(lst)
    option[which(unname(unlist(lst)) == TRUE)])
  options <- paste(sort(unname(unlist(mapped_options))), collapse = "_")
  # Determine problem number based on presented options
  problem <- ifelse(all(unname(unlist(mapped_options)) %in% c("A", "B", "C")), 1, 2)
  condition <- problem
  trial <- df$round
  choice <- sapply(1:nrow(df), function (n) choice_matrix[problem, which(c(df$bid0[n], df$bid1[n], df$bid2[n]) == 100)])
  feedback_choice <- sapply(1:nrow(df), function (n) c(df$out0[n], df$out1[n], df$out2[n])[which(c(df$bid0[n], df$bid1[n], df$bid2[n]) == 100)])
  outcome_chosen <- paste(choice, feedback_choice, sep = ":")
  if (unique(df$seeCounterf) == 1) {
    foregone_choices <- lapply(1:nrow(df), function (n) choice_matrix[problem, which(c(df$bid0[n], df$bid1[n], df$bid2[n]) != 100)])
    foregone_feedback <- lapply(1:nrow(df), function (n) c(df$out0[n], df$out1[n], df$out2[n])[which(c(df$bid0[n], df$bid1[n], df$bid2[n]) != 100)])
    foregone_outcomes <- lapply(1:length(foregone_choices), function (n)
      paste(foregone_choices[[n]], foregone_feedback[[n]], sep = ":"))
    outcome <- unname(unlist(lapply(1:length(foregone_outcomes), function (n) paste(c(outcome_chosen[n], foregone_outcomes[[n]]), collapse = "_"))))
  } else {
    outcome <- outcome_chosen
  }
  response_time <- stage <- age <- education <- note2 <- NA
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine and save processed data
ds_st2_final <- do.call("rbind", psd_list)
file_name <- paste0(paper, "_", "2", "_", "data.csv")

setwd(data_path)
write.table(ds_st2_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
