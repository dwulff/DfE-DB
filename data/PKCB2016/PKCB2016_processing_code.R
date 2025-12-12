### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Palminteri et al. (2016) The Computational Development of Reinforcement Learning during Adolescence

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "PKCB2016"

raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet
# One session, two underlying option pairs: reward and punishment, optimal and suboptimal
option <-  LETTERS[1:8]
out_1 <- c(1,   1,   1,   1,   -1,   -1,   -1,    -1)
pr_1 <- c(0.75,   0.25,   0.75,   0.25,   0.25,  0.75,  0.25,  0.75)
out_2 <- rep(c(0,     0,      0,     0), 2)
pr_2 <- c(0.25,   0.75,   0.25,   0.75,   0.75,  0.25,   0.75,  0.25)
# Save to data frame
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options sheet
file_name <- paste0(paper, "_", "1", "_", "options.csv")
setwd(data_path)
write.table(options_table, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

################################################################################################

### Process dataset

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path","option")))
# Back to raw directory
setwd(raw_path)
setwd("Plaminteri_PlosCB_2016")
study <- 1
# Read demographic data
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
file_dmg <- "Demographics.xlsx"
dmg_adolesc <- read_excel(file_dmg, sheet = "Adolescents")
dmg_adults <- read_excel(file_dmg, sheet = "Adults")
dmg_list <- list(dmg_adolesc, dmg_adults)
# Read and process data
if (!requireNamespace("R.matlab", quietly = TRUE)) install.packages("R.matlab")
library(R.matlab)
group <- c("Adolescents", "Adults")
ds_final_list <- vector(mode = "list", length(group))

for (g in 1:2) {
  # Go to data directory
  setwd(group[g])
  note1 <- paste(group[g], "group", sep = " ")
  files <- list.files()
  # Extract subject IDs
  subject_ids <- gsub('^.*Learning\\s*|\\s*_Session.*$', '', files)
  e <- grep("PostTest", subject_ids)[1] - 1
  subject_ids <- subject_ids[1:e]
  # Separate files
  learning_files <- files[1:e]
  test_files <- files[-c(1:e)]
  # (reward/partial, reward/complete, punishment/partial and punishment/complete)
  options_map <- c(`1`="A_B", `2`="A_B", `3`="C_D", `4`="C_D")
  cnd_map <- c(`1`="Reward with partial feedback", `2`="Reward with complete feedback",
               `3`="Punishment with partial feedback", `4`="Punishment with complete feedback")
  psd_list <- vector(mode = "list", length(learning_files))
  
  for (sb in 1:length(learning_files)) {
    subject <- as.numeric(subject_ids[sb])
    # Read data
    dflearn <- readMat(learning_files[sb]) # Data in the "data" structure/list
    dflearn <- as.data.frame(dflearn$data)
    #problem <- 1

    process_df <- function (df) {
      # Create column names for reference
      colnames(df) <- c("u1", "u2", "trial", "stim_pair", "u3", "button_pressed", "choice", "feedback", "foregone", "response_time")
      # problem <- df$stim_pair
      problem <- 1
      # (1: reward/partial, 2: reward/complete, 3: punishment/partial and 4: punishment/complete)
      note2 <- cnd_map[as.character(df$stim_pair)]
      #options <- options_map[as.character(df$stim_pair)]
      options <- paste(option[df$stim_pair*2-1], option[df$stim_pair*2], sep='_')
      trial <- df$trial
      choice <- ifelse(df$choice == 1, option[df$stim_pair*2-1], option[df$stim_pair*2])

      reward_map <- c(`1`="1", `0`="0")
      punish_map <- c(`1`="0", `0`="-1")
      payoff_feedback <- ifelse(df$stim_pair == 1 | df$stim_pair == 2, reward_map[as.character(df$feedback)],
                                punish_map[as.character(df$feedback)])
      ch <- paste(choice, payoff_feedback, sep = ":")
      fg_feedback <- ifelse(df$stim_pair == 1 | df$stim_pair == 2, reward_map[as.character(df$foregone)],
                            punish_map[as.character(df$foregone)])
      fg_choice <- ifelse(df$choice == 1, option[df$stim_pair*2], option[df$stim_pair*2-1])
      fg <- paste(fg_choice,fg_feedback,sep = ":")
      outcome <- sapply(1:nrow(df), function(n)
        ifelse(df$stim_pair[n] == 1 || df$stim_pair[n] == 3, ch[n],
               paste(ch[n], fg[n], sep = "_")))
      response_time <- round(df$response_time)
      # Dempographics
      dmg <- dmg_list[[g]]
      sex <- tolower(as.character(dmg[dmg$Subject == subject, "Gender"]))
      age <- round(as.numeric(dmg[dmg$Subject == subject, "Age"]))
      # DIfferentiate group 2 subject IDs
      if (g == 2) {
        subject <- subject + 100
      }
      stage <- education <- condition <- NA
      # Create final dataframe
      pdf <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
      # Fix trials with no response 
      pdf[pdf$response_time == 0, "choice"] <- NA
      pdf[pdf$response_time == 0, "outcome"] <- NA
      pdf[pdf$response_time == 0, "response_time"] <- NA
      return(pdf)
    }
    # Function call
    psd_list[[sb]] <- process_df(df = dflearn)
  }
  # Combine processed data
  psd_combined <- do.call("rbind", psd_list)
  #psd_combined <- psd_combined [order(psd_combined$subject, psd_combined$problem, psd_combined$trial), ]
  ds_final_list[[g]] <- psd_combined
  setwd("..")
}

# Combine and save processed data
ds_final <- do.call("rbind", ds_final_list)

ds_final$choice <- as.character(ds_final$choice)
ds_final$outcome <- as.character(ds_final$outcome)

file_name <- paste0(paper, "_", "1", "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
