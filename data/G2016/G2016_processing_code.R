### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Gershman (2016) Empirical priors for reinforcement learning models

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "G2016"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

##### Create the options sheet
# dataset 1
# Problem 1-8, new data - 8 option pairs (optimal and suboptimal choices)
study <- 1
option <- LETTERS[1:16]

pr_1 <- c(0.8, 0.6, 
          0.4, 0.2, 
          0.9, 0.7, 
          0.3, 0.1, 
          0.9, 0.8, 
          0.2, 0.1, 
          0.8, 0.7, 
          0.3, 0.2)
pr_2 <- c(0.2, 0.4, 
          0.6, 0.8, 
          0.1, 0.3, 
          0.7, 0.9, 
          0.1, 0.2, 
          0.8, 0.9, 
          0.2, 0.3, 
          0.7, 0.8)
out_1 <- c(rep(1, 16))
out_2 <- c(rep(0, 16))

options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)
# Save options
file_name <- paste0(paper, "_", study, "_", "options.csv")
setwd(data_path)
write.table(options_table, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")


# dataset 2
# Problem 1-4, new data - 4 option pairs (optimal and suboptimal choices)
study <- 2
option <- LETTERS[1:8]

pr_1 <- c(0.8, 0.2, 
          0.7, 0.3, 
          0.1, 0.9, 
          0.4, 0.6)
pr_2 <- c(0.2, 0.8, 
          0.3, 0.7, 
          0.9, 0.1, 
          0.6, 0.4)
out_1 <- c(rep(1, 8))
out_2 <- c(rep(0, 8))

options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)
# Save options
file_name <- paste0(paper, "_", study, "_", "options.csv")
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

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper", "study", "raw_path", "data_path")))
# Back to raw data directory
setwd(raw_path)
setwd("RL-models-master/jmp")
# Read dataset
if (!requireNamespace("R.matlab", quietly = TRUE)) install.packages("R.matlab")
library(R.matlab)
ds1 <- readMat("RL_data.mat")
ds2 <- readMat("RL_data_folds.mat")
ds1 <- ds1[["data"]]
ds2 <- ds2[["folds"]]

# study 1 (dataset 1)
study <- 1
# Split ds1 list into groups of six elements
data_list <- split(ds1, rep(1:ceiling(length(ds1)/6), each=6)[1:length(ds1)])
# Remove subject 12 because it has only 75 trials
data_list <- data_list[-12]
# List to store each subject's processed data
psd_list <- vector(mode = "list", length(data_list))
option <- c(LETTERS[1:16])
choice_matrix <- matrix(option, ncol = 2, byrow = TRUE)
cnd_map <- c(`2`="Low reward options", `1`="High reward options")
prob_pairs_list <- list(c(0.8,0.6), c(0.4,0.2), c(0.9,0.7), c(0.3,0.1), c(0.9,0.8), c(0.2,0.1), c(0.8,0.7), c(0.3,0.2))
names(prob_pairs_list) <- c("1", "2", "3", "4", "5", "6", "7", "8")

for (sb in 1:length(data_list)) {
  subject <- as.numeric(names(data_list)[sb])
  # Extract this subject's data
  df_list <- data_list[[sb]]
  prob_matrix <- df_list[[3]]
  selection <- df_list[[4]]
  # Determine problem number
  # Split probability matrix into 25X2 submatrices
  num_blocks <- length(selection) / 25
  prob_matrix_by_block <- split(as.data.frame(prob_matrix), rep(1:num_blocks, each = 25))
  problem_list <- lapply(prob_matrix_by_block, function (df)
    as.numeric(names(prob_pairs_list[Position(function(x) identical(x, sort(unname(unlist(unique(df))), decreasing = TRUE)), prob_pairs_list, nomatch = 0)])))
  problem <- rep(unname(unlist(problem_list)), each = 25)
  # Determine the options in each block of 25 trials
  options_list <- lapply(prob_matrix_by_block, function (df)
    choice_matrix[Position(function(x) identical(x, sort(unname(unlist(unique(df))), decreasing = TRUE)), prob_pairs_list, nomatch = 0), ])
  options <- unname(unlist(lapply(options_list, function (opts) rep(paste(unname(opts), collapse = "_"), each = 25))))
  trial <- 1:length(selection)
  # Condition in each block
  condition_list <- lapply(prob_matrix_by_block, function (df)
    ifelse(all(sort(unname(unlist(unique(df))), decreasing = TRUE) > 0.5), 1, 2))
  condition <- rep(unname(unlist(condition_list)), each = 25)
  note1 <- cnd_map[as.character(condition)]
  # Determine choices
  options_indices <- unname(unlist(lapply(prob_matrix_by_block, function (df)
    Position(function(x) identical(x, sort(unname(unlist(unique(df))), decreasing = TRUE)), prob_pairs_list, nomatch = 0))))
  options_unsorted_list <- vector(mode = "list", length(options_list))
  for (n in 1:length(options_unsorted_list)) {
    if(identical(unname(unlist(unique(prob_matrix_by_block[[n]]))), prob_pairs_list[[options_indices[n]]]) && 
       setequal(unname(unlist(unique(prob_matrix_by_block[[n]]))), prob_pairs_list[[options_indices[n]]])) {
      options_unsorted_list[[n]] <- choice_matrix[options_indices[n], ]
    } else {
      options_unsorted_list[[n]] <- sort(choice_matrix[options_indices[n], ], decreasing = TRUE)
    }
  }
  # Split selections into blocks of 25
  selection_list <- split(selection, ceiling(seq_along(selection)/25))
  choice <- unname(unlist(lapply(1:length(selection_list), function (b)
    options_unsorted_list[[b]][selection_list[[b]]])))
  outcome <- paste(choice, df_list[[5]], sep = ":")
  response_time <- stage <- sex <- age <- education <- note2 <- NA
  # Create final dataframe
  payoff <- df_list[[5]]
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine and save processed data
psd_combined <- do.call("rbind", psd_list)
ds_final <- psd_combined [order(psd_combined$subject, psd_combined$problem, psd_combined$trial), ]
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")


# study 2 (dataset 2)
study <- 2
# read raw data divided into train data and test data
ds2_1 <- ds2[[1]]
ds2_2 <- ds2[[2]]
# Split ds2 list into groups of six elements
data_list_1 <- split(ds2_1, rep(1:ceiling(length(ds2_1)/6), each=6)[1:length(ds2_1)])
data_list_2 <- split(ds2_2, rep(1:ceiling(length(ds2_2)/6), each=6)[1:length(ds2_2)])
# List to store each subject's processed data
psd_list <- vector(mode = "list", length(data_list_1))
option <- c(LETTERS[1:8])
choice_matrix <- matrix(option, ncol = 2, byrow = TRUE) 
names(choice_matrix) <- c("1", "2", "3", "4")
Prob_map <- c(
  "0.2" = 1, "0.8" = 1,
  "0.3" = 2, "0.7" = 2,
  "0.9" = 3, "0.1" = 3,
  "0.6" = 4, "0.4" = 4
)

for (sb in 1:length(data_list_1)) {
  subject <- as.numeric(names(data_list_1)[sb])
  # Extract this subject's data
  df_list_1 <- data_list_1[[sb]]
  prob_matrix_1 <- df_list_1[[1]]
  selection_1 <- df_list_1[[3]]
  df_list_2 <- data_list_2[[sb]]
  prob_matrix_2 <- df_list_2[[1]]
  selection_2 <- df_list_2[[3]]
  selection <- c(selection_1, selection_2)
  # Determine problem number
  # Split probability matrix in train data into 25X2 submatrices
  #train
  num_blocks <- length(selection_1) / 25
  prob_matrix_by_block <- split(as.data.frame(prob_matrix_1), rep(1:num_blocks, each = 25))
  problem_1 <- as.numeric(Prob_map[as.character(prob_matrix_1[, 1])])
  #test
  problem_2 <- as.numeric(Prob_map[as.character(prob_matrix_2[, 1])])
  problem <- c(problem_1, problem_2)
  # Determine the options in each block of 25 trials
  options_1 <- sapply(problem_1, function(x) paste(choice_matrix[x, ], collapse = "_"))
  options_2 <- sapply(problem_2, function (x) paste(choice_matrix[x, ], collapse = "_"))
  options <- c(options_1, options_2)
  trial <- 1:(length(selection_1) + length(selection_2))
  # Determine choices
  choice_1 <- c()
  p <- problem_1[c(1, 26, 51)]
  for (block in 1:3){
    choice_1_1 <- choice_matrix[p[block], selection_1[(25*(block-1)+1): (25*block)]]
    choice_1 <- c(choice_1, choice_1_1)
  } 
  choice_2 <- choice_matrix[problem_2[1], selection_2[,1]]
  outcome_1 <- ifelse(is.na(choice_1), NA, paste(choice_1, df_list_1[[4]][,1], sep = ":"))
  outcome_2 <- ifelse(is.na(choice_2), NA, paste(choice_2, df_list_2[[4]][,1], sep = ":"))
  choice <- c(choice_1, choice_2)
  outcome <- c(outcome_1, outcome_2)
  condition <- response_time <- stage <- sex <- age <- education <- note1 <- note2 <- NA
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine and save processed data
psd_combined <- do.call("rbind", psd_list)
ds_final <- psd_combined [order(psd_combined$subject, psd_combined$trial,  psd_combined$problem), ]
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
