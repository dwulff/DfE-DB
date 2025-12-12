### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Lefebvre et al. (2017) Behavioural and neural characterization of optimistic reinforcement learning

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "LLMB2017"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet
# Study 1
# Optimal and suboptimal
# (25/25%, 25/75%, 75/25% and 75/75%)
option <- c("A", "B", "C", "D", "E", "F", "G", "H")
out_1 <- c(0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5)
pr_1 <- c(0.25, 0.25, 0.25, 0.75, 0.75, 0.25, 0.75, 0.75)
out_2 <- c(0, 0, 0, 0, 0, 0, 0, 0)
pr_2 <- c(0.75, 0.75, 0.75, 0.25, 0.25, 0.75, 0.25, 0.25)
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Study 2
# Same but with a possible loss instead of a possible zero outcome
option <- c("A", "B", "C", "D", "E", "F", "G", "H")
out_1 <- c(0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5)
pr_1 <- c(0.25, 0.25, 0.25, 0.75, 0.75, 0.25, 0.75, 0.75)
out_2 <- c(-0.5, -0.5, -0.5, -0.5, -0.5, -0.5, -0.5, -0.5)
pr_2 <- c(0.75, 0.75, 0.75, 0.25, 0.25, 0.75, 0.25, 0.25)
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

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path")))
if (!requireNamespace("R.matlab", quietly = TRUE)) install.packages("R.matlab")
library(R.matlab)
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
# Back to raw directory
setwd(raw_path)
setwd("demographic_data/Replication")
# Read demographic data (won't be used, could not make sense of it)
dmg2 <- read_excel("donneesQuest.xlsx", sheet = "Feuil1")
setwd("../../BehavioralData")
# Read and process data
experiment <- c("data_exp1", "data_exp2")
studies <- c(1, 2)
# List to store processed experiments
ds_final_list <- vector(mode = "list", length(experiment))
problem <- 1
for (exp in studies) {
  study <- studies[exp]
  # Go to data directory
  setwd(experiment[exp])
  files <- list.files()
  # Extract subject IDs only for mapping to gender (but the actual subject IDs are the "sub" variable in the matlab file)
  # (25/25%, 25/75%, 75/25% and 75/75%)
  options_map <- c(`1`="A_B", `2`="C_D", `3`="E_F", `4`="G_H")
  psd_list <- vector(mode = "list", length(files)) # Store processed data
  for (sb in 1:length(files)) {
    # Read data
    ds <- readMat(files[sb]) # Data in the "data" structure/list
    df_s <- as.data.frame(ds$data)
    subject <- as.numeric(ds$sub)
    
    process_df <- function (df) {
      # Create column names for reference
      if (exp == 1) {
        colnames(df) <- c("u1", "trial", "stim_pair", "u2", "u3", "u4", "button_pressed", "choice", "response_time")
        payoff <- ifelse(df$choice == 1, 0.5, 0) # 0.5 or nothing
      } else {
        colnames(df) <- c("u1", "trial", "stim_pair", "u2", "button_pressed", "choice", "response_time", "feedback")
        payoff <- ifelse(df$choice == 1, 0.5, -0.5) # 0.5 or -0.5
      }
      # problem <- df$stim_pair
      option <- c("A", "B", "C", "D", "E", "F", "G", "H")
      choice_pairs <- matrix(option, ncol = 2, byrow =  TRUE) # Create matrix
      options <- unname(options_map[as.character(df$stim_pair)])
      trial <- df$trial
      # Use this to code all choices
      choice <- sapply(1:nrow(df), function (n)
        ifelse(df$button_pressed[n] == 1, choice_pairs[df$stim_pair[n], 1], choice_pairs[df$stim_pair[n], 2]))
      outcome <- ifelse(is.na(choice),NA,paste(choice, payoff, sep = ":"))
      response_time <- round(df$response_time)
      note1 <- sapply(1:nrow(df), function(n)
        ifelse(df$stim_pair[n] == 1 | df$stim_pair[n] == 4, "Symmetric options", "Asymmetric options"))
      # Age and gender won't be mapped using the dmg dataset. Although there is a pattern, it may not be accurate.
      stage <- education <- condition <- sex <- age <- note2 <- NA
      # Create final dataframe
      pdf <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
      # Set as NA trials with no response
      pdf[pdf$response_time == 0, "choice"] <- NA
      pdf[pdf$response_time == 0, "outcome"] <- NA
      pdf[pdf$response_time == 0, "response_time"] <- NA
      return(pdf)
    }
    # Function call
    psd_list[[sb]] <- process_df(df = df_s)
  }
  # Combine processed data
  psd_combined <- do.call("rbind", psd_list)
  psd_combined <- psd_combined [order(psd_combined$subject), ]
  ds_final_list[[exp]] <- psd_combined
  setwd("..")
}

ds_st1_final <- ds_final_list[[1]]
ds_st2_final <- ds_final_list[[2]]


ds_st1_final$choice <- as.character(ds_st1_final$choice)
ds_st1_final$outcome <- as.character(ds_st1_final$outcome)

ds_st2_final$choice <- as.character(ds_st2_final$choice)
ds_st2_final$outcome <- as.character(ds_st2_final$outcome)

# Save
file_name1 <- paste0(paper, "_", "1", "_", "data.csv")
file_name2 <- paste0(paper, "_", "2", "_", "data.csv")

setwd(data_path)
write.table(ds_st1_final, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(ds_st2_final, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
