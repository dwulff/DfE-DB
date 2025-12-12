### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Speekenbrink & Konstantinidis (2015) Uncertainty and Exploration in a Restless Bandit Problem

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "SK2015"
study <- 1
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

##### Create the options sheets

# Four problems each with 4 options that offer different reward structures
option <- LETTERS[1:prod(4, 4)]
d <- "Reward was drawn from a normal distribution with a mean that varied randomly and independently according to a random walk"
description <- rep(d, length(option))
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
rm(list=setdiff(ls(), c("path", "paper", "study","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)
file_data <- "SpeekenbrinkKonstantinidisData.csv"
ds <- read.csv(file_data, header = TRUE, stringsAsFactors = FALSE)
# 80 subjects, 200 trials each. One subject excluded, so ds has 15800 obs
subject <- ds$id
problem_map <- c(`nts`=1, `ntn`=2, `ts`=3, `tn`=4)
problem <- problem_map[as.character(ds$cond)]
condition <- problem
option <- LETTERS[1:prod(4, 4)]
choice_pairs <- matrix (option, ncol = 4, byrow = TRUE)
options <- apply(choice_pairs[problem,], 1, paste, collapse = "_")
note_map <- c(`nts`="Rewards: stable volatility without trend",
             `ntn`="Rewards: variable volatility without trend",
             `ts`="Rewards: stable volatility with trend",
             `tn`="Rewards: variable volatility with trend")
note1 <- note_map[as.character(ds$cond)]
trial <- ds$trial
age <- ds$age
sex <- ifelse(ds$gender == "female", "f", "m")
response_time <- round(ds$rt)
# Map choices
#choice_map <- c(`1`="A", `2`="B", `3`="C", `4`="D")
choice <- sapply(1:nrow(ds), function(r) choice_pairs[problem[r], as.numeric(ds[r, "deck"])] )
# Outcomes
outcome <- paste(choice, ds$payoff, sep = ":")
# Rest of variables
stage <- education <- note2 <- NA
# Create final dataframe
psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)

# Save data
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(psd, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
