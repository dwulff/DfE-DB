### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Lejarraga & Gonzalez (2011) Effects of feedback and complexity on repeated decisions from description

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "LG2011"
study <- 1
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Two problems, two options each (safe and risky, in that order)
# There were multiple ways in which the two problems were presented.
# For the Description-Eperience condition, the "note" varilable would specify that the options were fully described.

option <- c("A", "B", "C", "D")
out_1 <- c(3, 4, 3, 64)
pr_1 <- c(1, 0.8, 1, 0.05)
out_2 <- c(NA, 0, NA, 0)
pr_2 <- c(NA, 0.2, NA, 0.95)
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
rm(list=setdiff(ls(), c("path", "paper", "study","raw_path","data_path")))
# Back to raw data directory

setwd(raw_path)
# Read data file (excel sheet)
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
file_data <- "Lejarraga & Gonzalez (2011)_data.xlsx"
ds <- read_excel(file_data, sheet = "Results")
# Remove the non-repeated-choice description conditions (DS and DC)
cond_remove <- c("DS", "DC")
ds <- ds[-which(ds$Condition %in% cond_remove), ]
# Participants were randomly assigned to the remaining conditions, so each subject must have a unique number
ds <- ds[order(ds$Condition, ds$Subject, ds$Problem), ]
subject <- ds$Subject
cond <- unique(ds$Condition) # Get the unique condition names in order
condition_map <- c(`DFC`=1, `DFS`=2, `F`=3)
condition <- unname(condition_map[as.character(ds$Condition)])
# Uncomment and run this block in case you need to reset subject IDs at every condition
option <- c("A", "B", "C", "D")
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
# Map to options from problem number
options_map <- c(`1` = "A_B", `2` = "C_D")
options <- as.character(options_map[as.character(ds$Problem)])
## Map choices and outcomes
# If RiskyChoice = 1 then risky option was chosen
choice <- sapply(1:nrow(ds), function (n)
  ifelse(ds$RiskyChoice[n] == 0, choice_pairs[ds$Problem[n], 1], choice_pairs[ds$Problem[n], 2]))
choice_fg <- sapply(1:nrow(ds), function (n)
  ifelse(ds$RiskyChoice[n] == 0, choice_pairs[ds$Problem[n], 2], choice_pairs[ds$Problem[n], 1]))
outcome <- ifelse(is.na(choice),NA,paste(paste(choice, ds$ScoreObtained, sep = ":"), paste(choice_fg, ds$ForegoneScore, sep = ":"), sep = "_"))
# Change other column names
colnames(ds)[which(names(ds) == "Subject")] <- "subject"
colnames(ds)[which(names(ds) == "Trial")] <- "trial"
colnames(ds)[which(names(ds) == "Problem")] <- "problem"
colnames(ds)[which(names(ds) == "Condition")] <- "note1"
# Fix condition names in "note1"
ds[which(ds$note1 == "F"), "note1"] <- "Experience-based Standard"
ds[which(ds$note1 == "DFS"), "note1"] <- "Description-Experience Simple Problem Description"
ds[which(ds$note1 == "DFC"), "note1"] <- "Description-Experience Complex Problem Description"
# Rest of variables
response_time <- stage <- sex <- age <- education <- note2 <- NA
# Bind new variables
ds <- cbind (ds, paper, study, options, condition, choice, outcome, response_time, stage, sex, age, education, note2)
# Rearrange as required
ds_final <- ds[, c("paper", "study", "subject", "problem", "condition", "options", "trial", "choice", "outcome", "response_time", "stage", "sex", "age", "education", "note1", "note2")]

# Save processed data
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
