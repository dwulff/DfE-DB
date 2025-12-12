### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Worthy et al. (2018) A Case of Divergent Predictions Made by Delta and Decay Rule Learning Models

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "WOCD2018"
study <- 1
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

##### Create the options sheet

option <- c("A", "B", "C", "D")
out_1 <- c(1, 1, 1, 1)
pr_1 <- c(0.65, 0.35, 0.75, 0.25)
out_2 <- c(0, 0, 0, 0)
pr_2 <- c(0.35, 0.65, 0.25, 0.75)
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options
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
rm(list=setdiff(ls(), c("path", "paper", "study","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)
setwd("osfstorage-archive")
# Read dataset
ds <- read.table("CogSciDeltaDecayAllDataHeader.txt", header = TRUE, stringsAsFactors = FALSE)
# Split dataset into groups of 250 trials (150 training and 100 test trials)
num_subjects <- 33
problem <- 1
ds_list <- split(ds, rep(1:num_subjects, each = 250))
# Option number code
option <- c("A", "B", "C", "D")
choice_matrix <- matrix(option, ncol = 2, byrow = TRUE)
choice_map <- c(`1`="A", `2`="B", `3`="C", `4`="D")
options_map <- c(`1`="A_B", `2`="C_D", `3`="A_C", `4`="B_C", `5`="A_D", `6`="B_D")
# List to store processed data
psd_list <- vector(mode = "list", num_subjects)

for (sb in 1:num_subjects) {
  subject <- sb
  df <- ds_list[[sb]]
  # problem <- df$trialtype
  options <- unname(options_map[as.character(df$trialtype)])
  trial <- c(c(1:150), c(1:100))
  #trial <- 1:250
  note1 <- c(rep(c("Learning phase"), 150), rep(c("Testing phase"), 100))
  problem <- c(rep(c(1), 150), rep(c(2), 100))
  choice <- unname(choice_map[as.character(df$choice)])
  fb <- df$outcome
  # Subjectd received feedback during the learning and test phases
  outcome <- paste(choice, fb, sep = ":")
  response_time <- round(df$RT * 1000)
  stage <- sex <- age <- education <- note2 <- NA
  condition <- 1
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine and save processed data
ds_final <- do.call("rbind", psd_list)
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
