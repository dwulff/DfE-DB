### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Lejarraga et. al (2014) Decisions from experience: How groups and individuals adapt to change

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "LLG2014"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Six problems, two options each (stationary and non-stationary, in that order)
# 6 games/problems times 2 options
option <- LETTERS[1:12]
description <- c("P(10) = p, and P(-20) = 1 - p",
                 "P(10) = q and P(-20) = 1 - q for t trials, then q decreases gradually per trial until it plateaus again",
                 "P(8) = p, and P(-16) = 1 - p",
                 "P(8) = q and P(-16) = 1 - q for t trials, then q decreases gradually per trial until it plateaus again",
                 "P(20) = p, and P(-10) = 1 - p",
                 "P(20) = q and P(-10) = 1 - q for t trials, then q increases gradually per trial until it plateaus again",
                 "P(12) = p, and P(-18) = 1 - p",
                 "P(12) = q and P(-18) = 1 - q for t trials, then without gradation q changes to a smaller value and is fixed for the remaining trials",
                 "P(7) = p, and P(-5) = 1 - p",
                 "P(7) = q and P(-5) = 1 - q for t trials, then without gradation q changes to a smaller value and is fixed for the remaining trials",
                 "P(18) = p, and P(-12) = 1 - p",
                 "P(18) = q and P(-12) = 1 - q for t trials, then without gradation q changes to a larger value and is fixed for the remaining trials")
options_table <- data.frame(option, description)

# Save options sheet
file_name <- paste0(paper, "_", "1", "_", "options.csv")
setwd(data_path)
write.table(options_table, file = file_name, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

### Process dataset

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper","data_path","raw_path")))
# Back to raw data directory
setwd(raw_path)
study <- 1
# Read the data
file_data <- "RawData.txt"
ds_main <- read.table(file_data, header = TRUE, stringsAsFactors = FALSE)
option <- LETTERS[1:12]
opt_pairs <- matrix(option, ncol = 2, byrow = TRUE)
cnd_map <- c(`1`="Individual decision-making", `2`="Group decision-making")
ds_final_list <- vector(mode = "list", length(cnd_map))

for (cond in 1:2) {
  condition <- cond
  note1 <- unname(cnd_map[as.character(cond)])
  
  if (cond == 1) {
    ds <- ds_main[ds_main$condition == "Individual", ]
  } else {
    ds <- ds_main[ds_main$condition == "Team", ]
  }
  subject_freq <- rle(ds$Subject) # Subject IDs and frequencies
  psd_list <- vector(mode = "list", length(subject_freq$values))
  for (sb in 1:length(subject_freq$values)) {
    subject <- subject_freq$values[sb]
    df <- ds[ds$Subject == subject, ]
    problem <- df$GambleNumber # The column problem number seems to include game order
    options <- paste(opt_pairs[problem,1], opt_pairs[problem,2], sep = "_")
    trial <- df$Trial
    # Map choices and outcomes
    choice <- ifelse(df$choice == 1, opt_pairs[df$GambleNumber, 2], opt_pairs[df$GambleNumber, 1])
    payoff <- df$obtainedPayoff
    foregone_option <- ifelse(df$choice == 1, opt_pairs[df$GambleNumber, 1], opt_pairs[df$GambleNumber, 2])
    foregone_payoff <- df$foregonePayoff
    outcome_c <- paste(choice,payoff,sep = ":")
    outcone_f <- paste(foregone_option,foregone_payoff,sep = ":")
    outcome <- paste(outcome_c,outcone_f, sep = "_")
    response_time <- stage <- sex <- age <- education <- note2 <- NA
    # Create final dataframe
    pdf <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    psd_list[[sb]] <- pdf
  }
  # Combine all and sort
  psd_combined <- do.call("rbind", psd_list)
  psd_combined <- psd_combined [order(psd_combined$subject, psd_combined$problem, psd_combined$condition, psd_combined$trial), ]
  ds_final_list[[cond]] <- psd_combined
}

# Combine processed conditions
ds_final <- do.call("rbind", ds_final_list)
# Save
file_name <- paste0(paper, "_", "1", "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
