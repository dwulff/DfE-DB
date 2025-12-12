### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Navarro et. al (2016) Learning and choosing in an uncertain world: An investigation of the explore–exploit dilemma in static and dynamic environments

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "NNS2016"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)


# Outcome sequences
v1_g1 <- c(0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,1,0,1,1,0,0,0)
v1_g2 <- c(0,0,0,0,1,0,1,0,1,1,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,1,0,0,0,0,0,0,1,0,0,0,0,1,1,1,0)
v1_g3 <- c(1,1,1,1,1,0,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,1,1,1,0,1,1,1,1,0,1,0,1,1,0,0,0,1,1,0,1,1,1,1,0,1,1)
v1_g4 <- c(0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,0,0,1,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,1,1,0,0,0,0,0,0)
v1_g5 <- c(1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,0,1,1,0,1,1,1,1,1,1,0,1,1,0,0,1,1,1,0,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,0)
v2_g1 <- c(0,0,0,0,0,0,0,1,1,0,0,1,0,0,0,1,0,1,1,0,0,0,0,0,1,0,0,0,0,0,0,1,1,0,1,0,0,0,0,1,0,0,1,0,0,1,0,0,0,0)
v2_g2 <- c(0,0,0,0,1,0,1,0,0,1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,1,1,0,0,1,0,1,1,0,0,0,1,0,0,0,0,1,1,0,0,0)
v2_g3 <- c(0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,1,0,0,1,0,1,0,1,0,1,1,1,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0)
v2_g4 <- c(0,1,0,1,0,1,1,0,1,0,1,1,0,0,1,1,1,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1)
v2_g5 <- c(1,0,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,1,1,0,1,1,1,1,1,1,0,1,0,0,0,1,1,1,1,1,0,1,1,1,1,1)
v3_g1 <- c(0,1,1,1,0,1,0,1,0,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,0,1,1,1,0,1,1,1,1,1,0,1,1,1,1)
v3_g2 <- c(1,1,1,0,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,0,1,0,1,1,1,0,1,1,0,1,1,1,1,0,0,1,1,1,1,1)
v3_g3 <- c(0,0,0,0,0,0,0,0,1,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0)
v3_g4 <- c(1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,0,0,0,1,1,1,1,1,1,1,0,1,1,1,0,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1)
v3_g5 <- c(1,1,1,1,0,0,1,0,0,1,1,1,1,1,1,0,1,0,0,1,0,1,1,0,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,0,0,1,1,1,1,0,1,1,1,1)
outcome_list_stat <- list(list(v1_g1, v1_g2, v1_g3, v1_g4, v1_g5),
                          list(v2_g1, v2_g2, v2_g3, v2_g4, v2_g5),
                          list(v3_g1, v3_g2, v3_g3, v3_g4, v3_g5))
v1_g1 <- c(0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,1,0,1,1,0,0,0)
v1_g2 <- c(0,0,0,0,1,0,1,0,1,1,0,0,0,0,0,0,1,1,0,1,1,0,1,1,1,1,1,0,1,1,1,1,1,0,0,1,1,1,1,1,1,0,1,1,1,1,0,0,0,1)
v1_g3 <- c(1,1,1,1,1,0,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,1,0,0,1,0,0,0,0,1,0,1,0,0,1,1,1,0,0,1,0,0,0,0,1,0,0)
v1_g4 <- c(0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,0,0,1,0,0,1,1,1,1,0,0,0,1,1,1,1,1,1,1,1,1,1,0,1,0,1,0,0,1,1,1,1,1,1)
v1_g5 <- c(1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,0,1,1,0,1,1,0,0,0,0,1,0,0,1,1,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1)
v2_g1 <- c(0,0,0,0,0,0,0,1,1,0,0,1,0,0,0,1,0,1,1,0,0,0,0,0,1,0,0,0,0,0,0,1,1,0,0,1,1,1,1,0,1,1,0,1,1,0,1,1,1,1)
v2_g2 <- c(0,0,0,0,1,0,1,0,0,1,1,0,0,0,0,1,1,0,1,1,1,1,1,1,1,1,0,1,1,0,0,1,1,0,1,0,0,1,1,1,0,1,1,1,1,0,0,1,1,1)
v2_g3 <- c(0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,1,0,0,1,0,1,0,1,0,1,1,1,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0)
v2_g4 <- c(0,1,0,1,0,1,1,0,1,0,1,1,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0)
v2_g5 <- c(1,0,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,0,0,0,0,1,0,0,0,0,0,0,1,0,1,1,1,0,0,0,0,0,1,0,0,0,0,0)
v3_g1 <- c(0,1,1,1,0,1,0,1,0,1,1,1,1,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,1,0,0,0,0,0,1,0,0,0,0)
v3_g2 <- c(1,1,1,0,1,1,1,1,1,0,1,1,1,1,1,1,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,1,0,0,0,1,0,0,1,0,0,0,0,1,1,0,0,0,0,0)
v3_g3 <- c(0,0,0,0,0,0,0,0,1,1,0,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,0,1,0,1,1,1,1,1,1,1)
v3_g4 <- c(1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,0,1,1,0,1,1,1,0,0,0,0,0,0,0,1,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0)
v3_g5 <- c(1,1,1,1,0,0,1,0,0,1,1,1,1,1,1,0,1,0,0,1,0,1,1,0,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,0,0,1,1,1,1,0,1,1,1,1)
outcome_list_dyn <- list(list(v1_g1, v1_g2, v1_g3, v1_g4, v1_g5),
                         list(v2_g1, v2_g2, v2_g3, v2_g4, v2_g5),
                         list(v3_g1, v3_g2, v3_g3, v3_g4, v3_g5))
outcome_lists <- list(outcome_list_stat, outcome_list_dyn)

### Create the options sheet

# Study 1
# 5 games X 3 versions X 2 conditions X 2 options (blue, red, with the possibility
# to just observe the outcome) = 60
# Generate letters for options
g <- expand.grid(LETTERS, LETTERS) # Combine
g$Comb <- with(g, paste0(Var2, Var1))
option <- c(LETTERS, g$Comb[1:34]) # 60 options
description <- rep(c("Blue", "Red"), 30)
options_table1 <- data.frame(option, description)

# Study 2
# Optimal and suboptimal options
option <- c("A", "B")
 out_1 <- c(0.1, 0.1)
 pr_1 <- c(0.7, 0.3)
 out_2 <- c(-0.1, -0.1)
 pr_2 <- c(0.3, 0.7)
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

### Process dataset

## Study 1
# Clear all variables except path, paper, and studies
 rm(list=setdiff(ls(), c("path", "paper", "study","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)
setwd("observeorbet-master/data")
study <- 1
ds_train <- load("trainingData.Rdata")
ds_st1 <- load("experiment1.Rdata")
subject_freq <- rle(sort(all$subject))
# List of options
g <- expand.grid(LETTERS, LETTERS) # Combine
g$Comb <- with(g, paste0(Var2, Var1))
option <- c(LETTERS,  g$Comb[1:34])
# Split into list of games/versions
option_list <- split(option, ceiling(seq_along(option)/2))
option_sublists <- split(option_list, rep(1:ceiling(length(option_list)/2), each=5)[1:length(option_list)])
option_lists <- list(option_sublists[1:3], option_sublists[4:6]) # Static and dynamic
# List of problems
pnums <- 1:length(option_list)
problem_sublists <- split(pnums, rep(1:ceiling(length(pnums)/2), each=5)[1:length(pnums)])
problem_lists <- list(problem_sublists[1:3], problem_sublists[4:6])
psd_list <- vector(mode = "list", length(subject_freq$values))

for (sb in 1:length(subject_freq$values)) {
  subject <- as.numeric(subject_freq$values[sb])
  df <- all[all$subject == subject, ] # Extract subject data
  cond <- as.character(unique(df$condition))
  cnd <- ifelse(cond == "static", 1, 2)
  problem <- sapply(1:nrow(df), function(n) as.numeric(problem_lists[[cnd]][[df$version[n]]][df$game[n]]))
  options <- sapply(1:nrow(df), function(n)
    paste(option_lists[[cnd]][[df$version[n]]][[df$game[n]]], collapse = "_"))
  trial <- df$trial
  # Guess blue, guess red, or observe
  choice_list <- sapply(1:nrow(df), function(n)
    option_lists[[cnd]][[df$version[n]]][[df$game[n]]][as.numeric(df$action[n])])
  choice_list[lapply(choice_list, length) == 0] <- ""
  choice <- unlist(unname(choice_list))
  # Get actual outcomes from outcome sequences, add 1 to make 1,2 instead of 0,1
  outcome_raw <- sapply(1:nrow(df), function(n)
    outcome_lists[[cnd]][[df$version[n]]][[df$game[n]]][as.numeric(df$trial[n])] + 1)
  # Compare to choice to decide on success
  outcome_mapped <- sapply(1:nrow(df), function(n)
    ifelse(df$action[n] == 0, NA,
           ifelse(df$action[n] == outcome_raw[n], 1, 0)))
  # Show feedback or the outcome only if "observe" only was chosen (choice=0)
  outcome <- sapply(1:nrow(df), function(n)
    ifelse(choice[n] != "", paste(choice[n], outcome_mapped[n], sep = ":"),
           paste(option_lists[[cnd]][[df$version[n]]][[df$game[n]]][outcome_raw[n]],outcome_raw[n]-1, sep = ":")))
  condition <- cnd
  note1 <- cond
  response_time <- stage <- sex <- age <- education <- note2 <- NA
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}
# Combine and save processed data
ds_st1_final <- do.call("rbind", psd_list)
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

## Study 2
# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)
setwd("observeorbet-master/data")
study <- 2
ds <- load("experiment2.Rdata")
subject_freq <- rle(sort(responses$subj))
problem <- 1
options <- "A_B"
psd_list <- vector(mode = "list", length(subject_freq$values))

for (sb in 1:length(subject_freq$values)) {
  subject <- as.numeric(subject_freq$values[sb])
  df <- responses[responses$subj == subject, ] # Extract subject data
  age <- as.numeric(demographics[demographics$PID == subject, "Age"])
  gender <- as.character(demographics[demographics$PID == subject, "Gender"])
  sex <- ifelse(gender == "male", "m", "f")
  trial <- df$trial
  # Determine the initially optimal option
  optimal_option <- ifelse(sum(df$outcome == 1) > sum(df$outcome == 2), 1, 2)
  choice <- sapply(1:nrow(df), function(n)
    ifelse(df$choice[n] == 0, "", ifelse(df$choice[n] == optimal_option, "A", "B")))
  payoff <- df$payoff
  payoff[payoff == ""] <- "0" # To be able to map to empty string
  payoff_mapped <- c(`$0.10`=0.1, `-$0.10`=-0.1, `0`=NA)
  # Subjects had to guess the color of that card without being shown what it was
  outcome <- sapply(1:nrow(df), function(n)
    ifelse(df$choice[n] == 0, NA, paste(choice[n], payoff_mapped[as.character(payoff[n])], sep = ":")))
  response_time <- stage <- education <- note1 <- note2 <- condition <- NA
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}
# Combine and save processed data
ds_st2_final <- do.call("rbind", psd_list)
file_name <- paste0(paper, "_", "2", "_", "data.csv")
setwd(path(data_path))
write.table(ds_st2_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
