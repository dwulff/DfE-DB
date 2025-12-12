### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Yechiam, Druyan, & Ert (2008) Observing others’ behavior and risk taking in decisions from experience

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "YDE2008"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheets

# Study 1
# Two problems, 1/20 (AB) and 1/2 (CD), safe and risky choices, in that order
option <- c("A", "B", "C", "D")
out_1 <- c(-2, -30, -2, -4)
pr_1 <- c(1, 0.05, 1, 0.5)
out_2 <- c(NA, -1, NA, -1)
pr_2 <- c(NA, 0.95, NA, 0.5)
# Save to data frame
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Study 2
option <- c("A", "B")
out_1 <- c(-2, -30)
pr_1 <- c(1, 0.05)
out_2 <- c(NA, -1)
pr_2 <- c(NA, 0.95)
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
rm(list=setdiff(ls(), c("path", "paper", "studies","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)

### Study 1

study <- 1
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
# Read the data file
file_data <- "experiment1_data.xls"
ds_st1.20s <- read_excel(file_data, sheet = "social 1.20", skip = 6) # 1/20 problem (AB), social exposure
ds_st1.20ns <- read_excel(file_data, sheet = "no social 1.20", skip = 6) # 1/20 problem (AB), no social exposure
ds_st1.2s <- read_excel(file_data, sheet = "social 1.2", skip = 6) # 1/2 problem (CD), social exposure
ds_st1.2ns <- read_excel(file_data, sheet = "no social 1.2", skip = 6) # 1/2 problem (CD), no social exposure
# Remove columns that contain only NAs
ds_st1.20ns <- ds_st1.20ns[, colSums(is.na(ds_st1.20ns)) < nrow(ds_st1.20ns)]
ds_st1.2ns <- ds_st1.2ns[, colSums(is.na(ds_st1.2ns)) < nrow(ds_st1.2ns)]

split_df <- function (ds, sep_indices) {
  # Separate the dataframe into 5-column blocks at the indices given
  sd <- lapply(sep_indices, function(ind) ds[, c(ind, ind+1, ind+2, ind+3)])
  return (sd)
}
# Split dataframe into a list of per subject dataframes
ds_st1.20s_list <- split_df (ds = ds_st1.20s, sep_indices = grep('data', names(ds_st1.20s))) # seq(1, ncol(ds_st1.20s), 5)
ds_st1.20ns_list <- split_df (ds = ds_st1.20ns, sep_indices = grep('data', names(ds_st1.20ns)))
ds_st1.2s_list <- split_df (ds = ds_st1.2s, sep_indices = grep('data', names(ds_st1.2s)))
ds_st1.2ns_list <- split_df (ds = ds_st1.2ns, sep_indices = grep('data', names(ds_st1.2ns)))

paired_opts <- c("A_B", "C_D")
response_time <- stage <- sex <- age <- education <- NA
social_txt <- "Can observe partner / is observed"
nosocial_txt <- "No partner"
option <- c("A", "B", "C", "D")
choice_pairs <- matrix (option, ncol = 2, byrow = TRUE)
subjectID_poolList <- list(`1.20ns`=c(1:30), `1.20s`=c(31:50), `1.2ns`=c(51:80), `1.2s`=c(81:100))
note1 <- "Outcome probabilities described"

process_st1 <- function (dslist, p, note2, sid_pool) {
  
  condition <- ifelse(note2 == nosocial_txt, 1, 2)
  processedList <- vector(mode = "list", length(dslist))
  
  for (sb in 1:length(dslist)) {
    ds <- dslist[[sb]] # Current subject data
    num_trials <- 400
    subject <- sid_pool[sb] # Get the first item
    trial <- 1:num_trials
    problem <- p
    options <- paired_opts[p]
    # Map choices and outcomes to options (buttons fixed: 0 = risky, 1 = safe)
    choice_raw <- unlist(ds[1:num_trials, 2])
    choice <- ifelse(choice_raw == 1, choice_pairs[p, 1], choice_pairs[p, 2])
    payoffs <- unlist(ds[1:num_trials, 3])
    outcome <- paste(choice, payoffs, sep = ":")
    # Create final dataframe
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    processedList[[sb]] <- psd
  }
  df_processed <- do.call("rbind", processedList)
  return(df_processed)
}

# Function calls
df_1.20ns <- process_st1(ds_st1.20ns_list, p = 1, note2 = nosocial_txt, sid_pool = subjectID_poolList$`1.20ns`)
df_1.20s <- process_st1(ds_st1.20s_list, p = 1, note2 = social_txt, sid_pool = subjectID_poolList$`1.20s`)
df_1.2ns <- process_st1(ds_st1.2ns_list, p = 2, note2 = nosocial_txt, sid_pool = subjectID_poolList$`1.2ns`)
df_1.2s <- process_st1(ds_st1.2s_list, p = 2, note2 = social_txt, sid_pool = subjectID_poolList$`1.2s`)
# Recombine and save data
ds_st1_final <- rbind(df_1.20ns, df_1.20s, df_1.2ns, df_1.2s)
file_name1 <- paste0(paper, "_", "1", "_", "data.csv")
setwd(data_path)
write.table(ds_st1_final, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")


### Study 2

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper", "split_df","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)
study <- 2
# Function again
split_df <- function (ds, sep_indices) {
  # Separate the dataframe into 5-column blocks at the indices given
  sd <- lapply(sep_indices, function(ind) ds[, c(ind, ind+1, ind+2, ind+3)])
  return (sd)
}

file_data <- "experiment2_data.xls"
ds_st1.20_src <- read_excel(file_data, sheet = "1.20 not seeing", skip = 6)
ds_st1.20_obs <- read_excel(file_data, sheet = "1.20 seeing", skip = 6) # 1/20 problem (AB), social exposure
# Split dataframe into a list of per subject dataframes
ds_st1.20_srclist <- split_df (ds = ds_st1.20_src, sep_indices = grep('data', names(ds_st1.20_src)))
ds_st1.20_obslist <- split_df (ds = ds_st1.20_obs, sep_indices = grep('data', names(ds_st1.20_obs)))
# Variables to process the data
problem <- 1
options <- c("A_B")
option <- c("A", "B")
response_time <- stage <- sex <- age <- education <- NA
subjectID_poolList <- list(`1.20obs`=c(1:16), `1.20src`=c(17:32))
note1 <- "Outcome probabilities described"
ob_text <- "Can observe / is not observed"
src_text <- "Cannot observe / is observed"

process_st2 <- function (dslist, note2, sid_pool) {
  
  condition <- ifelse(note2 == ob_text, 1, 2)
  # New list
  processedList <- vector(mode = "list", length(dslist))
  
  for (sb in 1:length(dslist)) {
    ds <- dslist[[sb]] # Current subject data
    num_trials <- 400
    subject <- sid_pool[sb]
    trial <- 1:num_trials
    # Map choices and outcomes to options (buttons fixed: 0 = risky, 1 = safe)
    choice_raw <- unlist(ds[1:num_trials, 2])
    choice <- ifelse(choice_raw == 1, option[1], option[2])
    payoffs <- unlist(ds[1:num_trials, 3])
    outcome <- paste(choice, payoffs, sep = ":")
    # Create final dataframe
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    processedList[[sb]] <- psd
  }
  df_processed <- do.call("rbind", processedList)
  return(df_processed)
}

# Function calls
df_1.20obs <- process_st2(ds_st1.20_obslist, note2 = ob_text, sid_pool = subjectID_poolList$`1.20obs`)
df_1.20src <- process_st2(ds_st1.20_srclist, note2 = src_text, sid_pool = subjectID_poolList$`1.20src`)
# Recombine and save data
ds_st2_final <- rbind(df_1.20obs, df_1.20src)
file_name2 <- paste0(paper, "_", "2", "_", "data.csv")
setwd(data_path)
write.table(ds_st2_final, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
