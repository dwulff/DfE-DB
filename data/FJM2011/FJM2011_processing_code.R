### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Fatás, Jiménez, & Morales. (2011) Controlling for initial endowment and experience in binary choice tasks

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "FJM2011"
study <- 1
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Generate the options sheet, include two period: passive and active. stage 1: observe. stage two, choice by themselves
# A single problme but with different starting parameters (initial endowments), safe and risky options, in that order
# Between subject design
option <- c("A", "B")
out_1 <- c(1, 10)
pr_1 <- c(1.0, 0.5)
out_2 <- c(NA, -10)
pr_2 <- c(NA, 0.5)
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options sheet
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
rm(list=setdiff(ls(), c("path", "paper", "raw_path", "data_path", "study")))
# Working directory is in processed/options at this point, so go back to raw_data
setwd(raw_path)
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
option_map <- c(`1`="A", `10`="B", `-10`="B")
choice_map <- c(`0`="A", `1`="B")
cnd_map <- c(`HB+ group`=1, `HB- group`=2, `LB+ group`=3, `LB- group`=4)
subID_counter <<- 1 # Global variable

process_grp <- function (target_dir, note) {
  # Go to subdirectory
  setwd(target_dir)
  files_list <- list.files()
  if(note == "HB+ group" || note == "LB- group") {
    # Read data, remove extraneous columns, rename the remaining columns, and remove introduced NAs after conversion (ignore warning messages)
    ds_stg1_list <- lapply(files_list, function (f) read_excel(f, sheet = "etapa1", col_names = FALSE))
    ds_stg1_list <- lapply(ds_stg1_list, function (df) df[, -c(1,2,4,5,7:ncol(df))])
    ds_stg1_list <- lapply(ds_stg1_list, function (df) setNames(df, c("trial", "payoff")))
    ds_stg1_list <- lapply(ds_stg1_list, function (df) df[!is.na(as.numeric(as.character(df$trial))), ])
    # Also for stage 2 data
    ds_stg2_list <- lapply(files_list, function (f) read_excel(f, sheet = "etapa2", col_names = FALSE))
    ds_stg2_list <- lapply(ds_stg2_list, function (df) df[, -c(1,2,3,5,8:ncol(df))])
    ds_stg2_list <- lapply(ds_stg2_list, function (df) setNames(df, c("trial", "choice", "payoff")))
    ds_stg2_list <- lapply(ds_stg2_list, function (df) df[!is.na(as.numeric(as.character(df$choice))), ])
  } else if(note == "HB- group" || note == "LB+ group") {
    ds_stg1_list <- lapply(files_list, function (f) read_excel(f, sheet = "progr1", col_names = FALSE))
    ds_stg1_list <- lapply(ds_stg1_list, function (df) df[, -c(1,2,4,5,7)])
    ds_stg1_list <- lapply(ds_stg1_list, function (df) setNames(df, c("trial", "payoff")))
    ds_stg1_list <- lapply(ds_stg1_list, function (df) df[!is.na(as.numeric(as.character(df$trial))), ])
    ds_stg2_list <- lapply(files_list, function (f) read_excel(f, sheet = "score-memo", col_names = FALSE))
    ds_stg2_list <- lapply(ds_stg2_list, function (df) df[, -c(4:ncol(df))])
    ds_stg2_list <- lapply(ds_stg2_list, function (df) setNames(df, c("trial", "choice", "payoff")))
    ds_stg2_list <- lapply(ds_stg2_list, function (df) df[!is.na(as.numeric(as.character(df$choice))), ])
  }
  
  ds_processed_List <- vector(mode = "list", length(files_list))
  for (sb in 1:length(files_list)) { # Process subject data, and recombine
    ds_stg1 <- ds_stg1_list[[sb]]
    ds_stg2 <- ds_stg2_list[[sb]]
    problem <- 1
    stage <- 1. # passive stage. Experience but no choice by themselves
    options <- "A_B"
    subject <<- subID_counter # Subject ID
    subID_counter <<- subID_counter + 1
    trial <- ds_stg1$trial[1:75] # Trials stage 1 - 75 trials (subjects only observed the outcomes)
    outcome <- ds_stg1$payoff[1:75]
    choice <- ""
    # Rest of variables
    note1 <- note
    condition <- unname(cnd_map[note])
    response_time <- sex <- age <- education <- note2 <- NA
    # Stage1 dataframe
    psd_stg1 <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    # Stage2 dataframe
    stage <- 2
    trial <- ds_stg2$trial
    choice <- choice_map[as.character(ds_stg2$choice)]
    outcome <- paste(choice, ds_stg2$payoff, sep = ":")
    psd_stg2 <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    # Combine the two stages
    psd <- rbind(psd_stg1, psd_stg2)
    ds_processed_List[[sb]] <- psd
  }
  # Combine all subjects
  psd_all <- do.call("rbind", ds_processed_List)
  # Set working directory back to main (raw_data)

  setwd(raw_path)
  
  return(psd_all)
}
# HB+
psd_hbplus1 <- process_grp (target_dir = "HB+/HB+1", note = "HB+ group")
psd_hbplus2 <- process_grp (target_dir = "HB+/HB+2", note = "HB+ group")
# HB-
psd_hbminus1 <- process_grp (target_dir = "HB-/HB-1", note = "HB- group")
psd_hbminus2 <- process_grp (target_dir = "HB-/HB-2", note = "HB- group")
# LB+
psd_lbplus1 <- process_grp (target_dir = "LB+/LB+1", note = "LB+ group")
psd_lbplus2 <- process_grp (target_dir = "LB+/LB+2", note = "LB+ group")
# LB-
psd_lbminus1 <- process_grp (target_dir = "LB-/LB-1", note = "LB- group")
psd_lbminus2 <- process_grp (target_dir = "LB-/LB-2", note = "LB- group")

ds_final <- rbind(psd_hbplus1, psd_hbplus2, psd_hbminus1, psd_hbminus2, psd_lbplus1, psd_lbplus2, psd_lbminus1, psd_lbminus2)

# Save data
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
