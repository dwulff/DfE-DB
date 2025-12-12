### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Cooper, J., et al. (2014) Training attention improves decision making in individuals with elevated self-reported depressive symptoms

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "CGDW2014"
study <- 1
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)
########## Generate the options sheet

# Two options, A (suboptimal) and B (optimal)
option <- c("A", "B")
#description <- c("A mean reward of 55 points with a standard deviation of 15 points.",
#                 "A mean reward of 65 points with a standard deviation of 15 points.")
description <- c("N(55, 15^2)", "N(65, 15^2)")

options_table <- data.frame(option, description)

# Save options sheet
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
rm(list=setdiff(ls(), c("path", "paper", "study", "raw_path", "data_path")))
# Back to raw data directory
setwd(raw_path)
# Subject IDs and gender info are stored in a separate spreadsheet
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
fname <- "CABN_Demog_Sex_CooperMaddox.xlsx"
ds_sub <- read_excel(fname, sheet = "Sheet1")
ds_sub <- ds_sub[order(ds_sub$subnum), ] # order by subnum
# Enter sub-directroy where the data files and capture as ordered
setwd("CABN_2014_CooperMaddox/")
if (!requireNamespace("gtools", quietly = TRUE)) install.packages("gtools")
library(gtools)
file_list <- list.files()
file_list <- mixedsort(file_list) # Now the files are sorted by subject numer
# Keep files for subjects that were included in the analysis
included <- ds_sub$`in 2014 paper?` == "yes"
file_list <- file_list[included]
# Extract the subject identifiers from file names
subject_ids <- sort(as.numeric(sub("\\D*(\\d+).*", "\\1", file_list)))
gender <- tolower(ds_sub$gender[included])
# Extract group numbers
temp <- substr(file_list, 1, nchar(file_list) - 4)
group_ids <- substr(temp, nchar(temp) - 1 + 1, nchar(temp))
option <- c("A", "B")
options <- "A_B"
problem <- 1
condition_map <- c(`1`="Elevated depressive positive dot-probe", `2`="Elevated depressive neurtal dot-probe",
                   `3`="Low depressive no dot-probe")

# Read all data files into a data list
data_list <- lapply(file_list,
                    FUN = function(files)
                    {read.table(files, header = FALSE, fill = TRUE,
                                col.names = c("trial", "choice", "points_awarded", "response_time"))})
# Combine all dataframes in data_list
#dataset <- do.call("rbind", data_list)
#num_trials <- 150 # Verified
# List to store each subject's processed data
psd_list <- vector(mode = "list", length(subject_ids))

for (sb in 1:length(subject_ids)) {
  subject <- subject_ids[sb]
  # Subject data
  df <- data_list[[sb]]
  sex <- gender[sb]
  trial <- df$trial
  # Choice 2 is the optimal option
  choice <- ifelse(df$choice == 1, option[1], option[2])
  # Use points_awarded column to make the outcomes
  outcome <- paste(choice, df$points_awarded, sep = ":")
  # Group info in note variable
  condition <- group_ids[sb]
  note1 <- unname(condition_map[as.character(condition)])
  response_time <- round(df$response_time * 1000)
  age <- stage <- education <- note2 <- NA
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine and save processed data
ds_final <- do.call("rbind", psd_list)
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
