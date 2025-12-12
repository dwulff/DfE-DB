### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Sims et al. (2013) Melioration as rational choice: sequential decision making in uncertain environments

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "SNJG2013"
study <- 1
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheets

# One problem, two options
# A: maximizing option, B: meliorating option
# Reward is either 0 or 2 cents
option <- c("A", "B")
description <- c("Probability of reward (2 cents, otherwise 0) is a function of the number of recent choices made to the maximizing alternative (B)",
                 "Same reward probability function as the maximizing option, plus a constant")
options_table <- data.frame(option, description)

# Save options
file_name <- paste0(paper, "_", study, "_", "options.csv")
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
rm(list=setdiff(ls(), c("path", "paper", "study","data_path","raw_path")))
# Back to raw data directory
setwd(raw_path)
file_data <- "SimsEtAl2012MeliorationData.tsv"
# Read dataset
ds <- read.table(file_data, header = TRUE, stringsAsFactors = FALSE)
# Dataset is already ordered
subject <- ds$SUBJ
problem <- 1
options <- "A_B"
trial <- ds$TRIAL
choice_map <- c(`MAX`="A", `MEL`="B")
choice <- choice_map[as.character(ds$CHOICE)]
outcome <- paste(choice, ds$OUTCOME, sep = ":")
# Rest of variables (no demographic data was collected)
response_time <- stage <- sex <- age <- education <- note1 <- note2 <- condition <- NA
# Create final dataframe
psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)

# Save data
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(psd, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
