### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Yechiam & Ert (2007) Evaluating the reliance on past choices in adaptive learning models

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "YE2007"
study <- 1
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Three problems, with three options each
# Safe, medium, and risky options, in that order
#study1
option <- LETTERS[1:12]
out_1 <- c(0,    1,    2,    0,    2,     4,      2,    1,     0,    2,    1,    0)
pr_1 <- c(1.0,   0.5,  0.5,  1.0,  0.5,   0.5,    1.0,  0.5,   0.5,  1.0,  0.5,  0.5)
out_2 <- c(NA,   -1,   -2,   NA,   -1,    -2,     NA,   3,     4,    NA,   4,    6)
pr_2 <- c(NA,    0.5,  0.5,  NA,   0.5,   0.5,    NA,   0.5,   0.5,  NA,   0.5,  0.5)
# Save to data frame
options_grid <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options sheet
file_name <- paste0(paper, "_", 1, "_", "options.csv")
setwd(data_path)
write.table(options_grid, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

#study 2
option <- LETTERS[1:12]
out_1 <- c("0+U[0,1]", "1+U[0,1]", "2+U[0,1]", "0+U[0,1]", "2+U[0,1]", "4+U[0,1]", "2+U[0,1]", "1+U[0,1]", "0+U[0,1]", "2+U[0,1]", "1+U[0,1]", "0+U[0,1]")
pr_1 <- c(1.0,   0.5,  0.5,  1.0,  0.5,   0.5,    1.0,  0.5,   0.5,  1.0,  0.5,  0.5)
out_2 <- c(NA,   "-1+U[0,1]", "-2+U[0,1]",   NA, "-1+U[0,1]", "-2+U[0,1]", NA, "3+U[0,1]", "4+U[0,1]", NA, "4+U[0,1]", "6+U[0,1]")
pr_2 <- c(NA,    0.5,  0.5,  NA,   0.5,   0.5,    NA,   0.5,   0.5,  NA,   0.5,  0.5)
# Save to data frame
options_grid <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options sheet
file_name <- paste0(paper, "_", 2, "_", "options.csv")
setwd(data_path)
write.table(options_grid, file = file_name, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")



################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

### Process dataset

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper", "study","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)
# Read dataset
# Note: Half of the participants were presented with the GAIN condition before the LOSS condition, and the opposite order for the
# other half.
# Noise was added ([0,1]) to outcomes
file_data <- "math_psych.csv"
ds <- read.csv(file_data, header = FALSE, stringsAsFactors = FALSE,
               col.names = c("trial", "choice", "subject", "payoff")) # See "More info"
# Split dataframe into frames of 100 trials each
ds_list <- split(ds, (seq(nrow(ds))-1) %/% 100)
ds_400list <- split(ds, (seq(nrow(ds))-1) %/% 400)
# For debugging
#ds_by_choice_list <- lapply(ds_list, function (df) split(df, f = df$choice))
#lengths <- unname(unlist(lapply(ds_by_choice_list, function (ls) length(ls))))

### Start of pre-processing
# Determine the condition/problem number of each 100-trial block
problem_list <- vector(mode = "list", length(ds_list))
for (ls in 1:length(ds_list)) {
  df <- ds_list[[ls]]
  two <- three <- FALSE
  p_first <- p_second <- -1
  df_sublist <- split(df, f = df$choice)
  if (1 %in% names(df_sublist)) { # Subejct has chosen safe option at one point
    df1 <- df_sublist[["1"]]
    v1 <- trunc(df1$payoff)
    if (all(v1 == 0)) { # Safe outcome = 0
      ## Loss condition
      if (2 %in% names(df_sublist)) {
        two <- TRUE
        df2 <- df_sublist[["2"]]
        # One of the outcomes of the medium-risk option = -1. For the noise condition, a small value is added making the loss
        # less than 1, and when truncated the result is zero, which is wrong, so correct this.
        v2 <- sapply(1:nrow(df2), function (n) ifelse(df2$payoff[n] < 0 && df2$payoff[n] > -1, -1, trunc(df2$payoff[n])))
        p_first <- ifelse (all(v2 %in% c(2, -1)), 2, 1)
      }
      if (3 %in% names(df_sublist)) {
        three <- TRUE
        df3 <- df_sublist[["3"]]
        # One of the outcomes of the risky option = -2. For the noise condition, a small value is added making the loss
        # less than 2, and when truncated the result is -1, which is wrong, so correct this.
        v3 <- sapply(1:nrow(df3), function (n) ifelse(df3$payoff[n] < -1 && df3$payoff[n] > -2, -2, trunc(df3$payoff[n])))
        p_second <- ifelse (all(v3 %in% c(4, -2)), 2, 1)
      }
      if (two && three && p_first != p_second) {
        p <- ifelse (all(v2 %in% c(2, -1)) && all(v3 %in% c(4, -2)), 2, 1)
      } else {
        p <- ifelse(p_first != -1, p_first, p_second)
      }
    } else if (all(v1 == 2)) { # Safe outcome = 2
      two <- three <- FALSE
      p_first <- p_second <- -1
      ## Gain condition
      # No corrections are necessary in the gain condition
      if (2 %in% names(df_sublist)) {
        two <- TRUE
        df2 <- df_sublist[["2"]]
        v2 <- trunc(df2$payoff)
        p_first <- ifelse (all(v2 %in% c(1, 4)), 4, 3)
      }
      if (3 %in% names(df_sublist)) {
        three <- TRUE
        df3 <- df_sublist[["3"]]
        v3 <- trunc(df3$payoff)
        p_second <- ifelse (all(v3 %in% c(0, 6)), 4, 3)
      }
      if (two && three && p_first != p_second) {
        p <- ifelse (all(v2 %in% c(1, 4)) && all(v3 %in% c(0, 6)), 4, 3)
      } else {
        p <- ifelse(p_first != -1, p_first, p_second)
      }
    } else {
      p <- NA
    }
  }
  problem_list[[ls]] <- p
  # In the 103rd trial block (problem X) the subject chose the safe option only.
  # The condition had to be identified manually.
  # Checking the original dataset, the succeeding trial block is gain condition problem 3, and the two before it
  # are loss condition, so this has to be gain condition problem 4.
  problem_list[[103]] <- 4
  # In the 21st trial block, not deducible. Manual. Loss condition.
  # 22nd trial block is loss condition problem 2, so 21st is problem 1
  problem_list[[21]] <- 1
  # The 81st block is problem 3, 82 is correctly identified as problem 4
  problem_list[[81]] <- 3
  # 181st block is problem 4, so fix 182 to be problem 3
  problem_list[[182]] <- 3
}
# Number the list's elements
problem_list <- setNames(problem_list, 1:length(problem_list))
problems <- unlist(unname(problem_list))
# Test if each condition occurs exactly 48 times
p_freq <- rle(sort(problems))
### End of pre-processing

# Split identified problem IDs into groups of 4
problem_sublists <- split(problems, ceiling(seq_along(problems)/4))
option <- LETTERS[1:12]
choice_matrix <- matrix (option, ncol = 3, byrow = TRUE)
condition_map <- c(`1`="Loss", `2`="Loss", `3`="Gain", `4`="Gain")
numeric_condition_map <- c(`1`=1, `2`=1, `3`=2, `4`=2)
# List to store each subject's processed data
psd_list <- vector(mode = "list", length(problem_sublists))

for (sb in 1:length(problem_sublists)) {
  subject <- sb
  # Extract this subject's data (already grouped in the original dataset)
  df <- ds_400list[[sb]]
  problem_v <- problem_sublists[[sb]]
  problem <- rep(problem_v, each= 100)
  condition <- unname(numeric_condition_map[as.character(problem)])
  note1 <- unname(condition_map[as.character(problem)])
  options <- sapply(problem, function (p) paste(choice_matrix[p, ], collapse = "_"))
  trial <- df$trial
  # Safe, Medium, Risky = 1, 2, and 3
  choice <- sapply(1:nrow(df), function (n) choice_matrix[problem[n], df$choice[n]])
  payoff <- df$payoff
  outcome <- paste(choice, payoff, sep = ":")
  response_time <- stage <- sex <- age <- education <- note2 <- NA
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine and save processed data
psd_combined <- do.call("rbind", psd_list)
ds_final <- psd_combined [order(psd_combined$subject, psd_combined$problem, psd_combined$trial), ]
ds_final_continuous <- ds_final[1:9600,]
ds_final_lottery <- ds_final[9601:nrow(ds_final),]
file_name_lottery <- paste0(paper, "_", 1, "_", "data.csv")
file_name_continuous <- paste0(paper, "_", 2, "_", "data.csv")
setwd(data_path)
write.table(ds_final_lottery, file = file_name_lottery, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(ds_final_continuous, file = file_name_continuous, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
