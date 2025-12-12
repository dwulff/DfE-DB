### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Yechiam & Busemeyer (2006) The effect of foregone payoffs on underweighting small probability events

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "YB2006"
study <- 1
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)
### Create the options sheet

# Page 8 - "1/200" problem (AB), and the "1/20" problem (CD)
# Note: The paper on Yechiam's site has a typo in the Procedure and Apparatus section on page 13 where 30 was written as 300.
# This was fixed in the journal's edition
option <- c("A", "B", "C", "D")
out_2 <- c(-8, -300, -8, -30)
pr_2 <- c(0.005, 0.005, 0.005, 0.05)
out_1 <- c(-2, -1, -2, -1)
pr_1 <- c(0.995, 0.995, 0.995, 0.95)
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

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper", "study","data_path","raw_path")))
# Back to raw data directory
setwd(raw_path)
file_foregone <- "forg_fd.csv" # In the Foregone-1 condition, foregone outcome was presented once every two trials starting from trial 1. 
file_noforegone <- "forg_pd.csv" # Partial disclosure (no feedback on foregone payoffs)
# It looks like the data is sorted by problem, 1/200 then 1/20
ds_forg <- read.csv(file_foregone, header = FALSE) # With feedback on foregone payoffs
ds_noforg <- read.csv(file_noforegone, header = FALSE)
# Give some names to the columns for readability
colnames(ds_noforg)[1] <- "subject"
colnames(ds_forg)[1] <- "subject"
colnames(ds_noforg)[4] <- "trial"
colnames(ds_forg)[4] <- "trial"
colnames(ds_noforg)[8] <- "payoff"
colnames(ds_forg)[8] <- "payoff"
colnames(ds_noforg)[9] <- "foregone"
colnames(ds_forg)[9] <- "foregone"
colnames(ds_noforg)[5] <- "pressed" # 1 is safe, 2 is risky choice (lower loss but small prob of much higher loss)
colnames(ds_forg)[5] <- "pressed"
condition_map <- c(`1`="No feedback on foregone", `2`="With feedback on foregone every other trial")
option <- c("A", "B", "C", "D")
choice_matrix <- matrix(option, ncol = 2, byrow = TRUE)

process_st <- function (ds, cnd) {
  
  # Condition 1 = no foregone feedback, 2 = with foregone feedback every other trial
  subject_freq <- rle(sort(ds$subject))
  # First 20 subjects faced problem 1, last 20 subjects faced problem 2
  problems <- rep(c(1, 2), each = 20)
  psd_list <- vector(mode = "list", length(subject_freq$values))
  
  for (sb in 1:length(subject_freq$values)) {
    subject <- as.numeric(subject_freq$values[sb])
    # Extract this subject's data
    df <- ds[ds$subject == subject, ]
    problem <- problems[sb]
    condition <- cnd
    note1 <- unname(condition_map[as.character(cnd)])
    options <- paste(choice_matrix[problem, ], collapse = "_")
    trial <- df$trial
    choice <- ifelse(df$pressed == 2, choice_matrix[problem, 2], choice_matrix[problem, 1])
    payoff <- df$payoff
    outcome <- paste(choice, payoff, sep = ":")
    # Foregone feedback: in this condition, feedback on the foregone option was given once every two trials
    if (cnd == 2) {
      foregone_payoff <- df$foregone
      foregone_option <- ifelse(df$pressed == 2, choice_matrix[problem, 1], choice_matrix[problem, 2])
      outcome_mod <- sapply(1:length(outcome), function (n)
        ifelse(n %% 2 != 0, paste(outcome[n], paste(foregone_option[n], foregone_payoff[n], sep = ":"), sep = "_"), outcome[n]))
      outcome <- outcome_mod
    }
    response_time <- stage <- sex <- age <- education <- note2 <- NA
    # Create final dataframe
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    psd_list[[sb]] <- psd
  }
  psd_combined <- do.call("rbind", psd_list)
  return(psd_combined)
}

# Combine and save processed data
ds_final <- rbind(process_st(ds = ds_noforg, cnd = 1), process_st(ds = ds_forg, cnd = 2))
ds_final <- ds_final [order(ds_final$subject, ds_final$condition, ds_final$problem), ]
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
