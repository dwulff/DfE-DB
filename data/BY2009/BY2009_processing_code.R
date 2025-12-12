### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Barron & Yechiam (2009) The coexistence of overestimation and underweighting of rare events and the contingent recency effect
# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "BY2009"

raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

##### Create the options sheet

# Study 2
option <- c("A", "B", "C", "D")
out_1 <- c(-1.3, -3, 2.7, 3)
pr_1 <- c(1, 0.15, 1, 0.85)
out_2 <- c(NA, -1, NA, 1)
pr_2 <- c(NA, 0.85, NA, 0.15)
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options
file_name <- paste0(paper, "_", "2", "_", "options.csv")
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

# Clear all variables except path, paper
rm(list=setdiff(ls(), c("path", "paper", "raw_path", "data_path")))
# Back to raw data directory
setwd(raw_path)

study <- 2
files <- list.files()
# Extract subject IDs
subject_ids <- gsub('^.*_\\s*|\\s*.txt.*$', '', files)
# From the file name, 5 = loss condition, and 6 = gain condition
conditions <- gsub('^.*terror1a_\\s*|\\s*_.*$', '', files)
problem_map <- c(`5`=1, `6`=2)
options_map <- c(`5`="A_B", `6`="C_D")
option <- c("A", "B", "C", "D")
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
# List to store processed data
psd_list <- vector(mode = "list", length(files))

for (sb in 1:length(psd_list)) {
  # Read data
  df <- read.csv(files[sb], header = FALSE, skip = 4, stringsAsFactors = FALSE,
                 col.names = c("risky", "payoff", "foregone", "u"))
  df <- df[!is.na(df$payoff), ]
  subject <- subject_ids[sb] # Subject
  problem <- unname(problem_map[conditions[sb]]) # Problem number
  condition <- problem
  options <- unname(options_map[conditions[sb]])
  trial <- 1:400
  choice <- ifelse(df$risky == 0, choice_pairs[problem, 1], choice_pairs[problem, 2])
  foregone_choice <- ifelse(df$risky == 0, choice_pairs[problem, 2], choice_pairs[problem, 1])
  payoff <- df$payoff
  foregone_pay <- df$foregone
  outcome <- paste(paste(choice, payoff, sep = ":"), paste(foregone_choice, foregone_pay, sep = ":"), sep = "_")
  note1 <- ifelse(problem == 1, "Loss", "Gain")
  response_time <- stage <- sex <- age <- education <- note2 <- NA
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine and save data
psd_combined <- do.call("rbind", psd_list)
ds_final <- psd_combined [order(psd_combined$subject, psd_combined$problem, psd_combined$trial), ]
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
