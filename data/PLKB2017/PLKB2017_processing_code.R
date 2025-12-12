### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Palminteri et al. (2017) Confirmation bias in human reinforcement learning: Evidence from counterfactual feedback processing

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "PLKB2017"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1 (partial feedback)
# Two underlying option pairs
# reward and punishment, optimal and suboptimal
option <- LETTERS[1:16]
out_1 <- rep(c(1, 1, 1, 1, 1, 1, 1, 1),2)
pr_1 <- rep(c(0.5, 0.5, 0.75, 0.25, 0.75, 0.25, "0.83 for trials 1-12 and 0.17 afterwards", "0.17 for trials 1-12 and 0.83 afterwards"),2)
out_2 <- rep(c(-1, -1, -1, -1, -1, -1, -1, -1),2)
pr_2 <- rep(c(0.5, 0.5, 0.25, 0.75, 0.25, 0.75, "0.17 for trials 1-12 and 0.83 afterwards", "0.83 for trials 1-12 and 0.17 afterwards"),2)
# Save to data frame
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)
# Study 2 (full feedback)
options_table2 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options sheet
file_name1 <- paste0(paper, "_", "1", "_", "options.csv")
file_name2 <- paste0(paper, "_", "2", "_", "options.csv")
setwd(data_path)
write.table(options_table1, file = file_name1, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")
write.table(options_table2, file = file_name2, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")

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
# Back to raw directory
setwd(raw_path) # Where demographic info is
# Read demographic data
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
dmg1 <- read_excel("demographic_e1.xlsx", sheet = "Feuil1")
dmg2 <- read_excel("demographic_e2.xlsx", sheet = "Feuil1")
# Read data
setwd("Online Scripts/data")
if (!requireNamespace("R.matlab", quietly = TRUE)) install.packages("R.matlab")
library(R.matlab)
files <- list.files()
# Extract subject IDs
subject_ids <- gsub('^.*Test\\s*|\\s*_Session.*$', '', files)
subject_ids_list <- split(subject_ids, ceiling(seq_along(subject_ids)/2))
files_list <- split(files, ceiling(seq_along(files)/2))
study_v <- unname(sapply(subject_ids_list, function(v) ifelse(as.numeric(v[1]) <= 20, 1, 2)))
options_map1 <- c(`1`="A_B", `2`="C_D", `3`="E_F", `4`="G_H")
options_map2 <- c(`1`="I_J", `2`="K_L", `3`="M_N", `4`="O_P")

psd_list <- vector(mode = "list", length(files_list))

for (sb in 1:length(files_list)) {
  subject <<- as.numeric(subject_ids_list[[sb]][1])
  study <<- study_v[sb]
  problem <<- 1
  # Read data
  data_v <- files_list[[sb]]
  df_s1 <- readMat(data_v[1])
  df_s1 <- as.data.frame(df_s1$data)
  df_s2 <- readMat(data_v[2])
  df_s2 <- as.data.frame(df_s2$data)
  
  process_df <- function (df) {
    # Create column names for reference
    if (study == 1) {
      colnames(df) <- c("subject", "session", "trial", "stim_pair", "u1", "choice", "response_time", "feedback", "u2", "u3", "u4")
      sex <- ifelse(as.numeric(dmg1[dmg1$SubID == subject, "Gender"]) == 0, "f", "m")
      age <- as.numeric(dmg1[dmg1$SubID == subject, "Age"])
    } else {
      colnames(df) <- c("subject", "session", "trial", "stim_pair", "u1", "choice", "response_time", "feedback", "foregone", "u2", "u3", "u4")
      sex <- ifelse(as.numeric(dmg2[dmg2$SubID == subject, "Gender"]) == 0, "f", "m")
      age <- as.numeric(dmg2[dmg2$SubID == subject, "Age"])
      foregone_fb <- ifelse(df$foregone == 1, 1, -1)
    }
    opts <- LETTERS[1:16]
    choice_pairs <- matrix(opts, ncol = 2, nrow = 8, byrow =  TRUE) # Create choice matrix
    # (1: reward/partial, 2: reward/complete, 3: punishment/partial and 4: punishment/complete)
    options <- ifelse(df$session == 1, unname(options_map1[as.character(df$stim_pair)]), unname(options_map2[as.character(df$stim_pair)]))
    trial <- df$trial
    # Map choices in the , then the reversal condition, otherwise NA (symmetric)
    choice <- vector(mode = "character", length = nrow(df))
    choice_fg <- vector(mode = "character", length = nrow(df))
    for (n in 1:nrow(df)) {
      context <- as.numeric(df$stim_pair[n])
      context <- ifelse(df$session[n] == 1, context, context + 4)
      if (context %in% c(1,2,3,5, 6, 7)) {
        choice[n] <-ifelse(df$choice[n] == 1, choice_pairs[context,1],
                            choice_pairs[context,2])
        choice_fg[n] <- ifelse(df$choice[n] != 1, choice_pairs[context,1], choice_pairs[context,2])
      } else if (context %in% c(4,8)) {
        if (df$trial[n] <= 12) {
          choice[n] <- ifelse(df$choice[n] == 1, choice_pairs[context,1],
                              choice_pairs[context,2])
          choice_fg[n] <- ifelse(df$choice[n] != 1, choice_pairs[context,1],
                                 choice_pairs[context,2])
        } else {
          choice[n] <- ifelse(df$choice[n] == 1, choice_pairs[context,2],
                              choice_pairs[context,1])
          choice_fg[n] <- ifelse(df$choice[n] == 1, choice_pairs[context,1],
                                 choice_pairs[context,2])
        }
      }
    }
    payoff_fb <- ifelse(df$feedback == 1, 1, -1)
    if (study == 1) {
      outcome <- sapply(1:nrow(df), function(n) paste(choice[n], payoff_fb[n], sep = ":"))
    } else {
      outcome <- sapply(1:nrow(df), function(n) paste(paste(choice[n], payoff_fb[n],sep = ":"), paste(choice_fg[n], foregone_fb[n], sep = ":"), sep = "_"))
    }
    note1 <- paste("Session", df$session, sep = " ")
    response_time <- round(df$response_time)
    stage <- education <- note2 <- condition <- NA
    # Create final dataframe
    pdf <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    return(pdf)
  }
  # Function call
  psd_list[[sb]] <- rbind(process_df(df = df_s1), process_df(df = df_s2))
}

# Combine and save processed data
psd_combined <- do.call("rbind", psd_list)
psd_combined <- psd_combined [order(psd_combined$study, psd_combined$subject), ]
ds_st1_final <- psd_combined[psd_combined$study == 1, ]
ds_st2_final <- psd_combined[psd_combined$study == 2, ]

file_name1 <- paste0(paper, "_", "1", "_", "data.csv")
file_name2 <- paste0(paper, "_", "2", "_", "data.csv")
setwd(data_path)
write.table(ds_st1_final, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(ds_st2_final, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
