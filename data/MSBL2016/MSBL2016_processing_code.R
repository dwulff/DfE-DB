### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Myers et. al (2016) Probabilistic reward- and punishment-based learning in opioid addiction: Experimental and computational data

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "MSBL2016"
study <- 1
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Each stimulus is made to associate with different outcomes for A and B
# Although in the paper they are A and B and  with different outcome probabilities

option <- c("A", "B", "C", "D", "E", "F", "G", "H")
out_1 <- c(25, 25, 25, 25, 0, 0, 0, 0)
pr_1 <- c(0.80, 0.20, 0.20, 0.80, 0.80, 0.20, 0.20, 0.80)
out_2 <- c(0, 0, 0, 0, -25, -25, -25, -25)
pr_2 <- c(0.20, 0.80, 0.80, 0.20, 0.20, 0.80, 0.80, 0.20)
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
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
# The file "Opiods data with published parameters.sav" can't be opened
# Read datasets from the two folders (one file per subject)
setwd("AU Quarters/patients") ### Opioid-addicted patients
files <- list.files()
# Change .doc extensions to .txt (on disc)
invisible(file.rename(files, gsub("doc", "txt", files)))
files <- gsub("doc", "txt", files) # Fix file list
# Note that gsub here separates the entries of the 2nd column
ds_patients <- lapply(files, FUN =
    function(f) read.table(textConnection(gsub(",", "\t", readLines(f))), skip = 13, header = FALSE, fill = TRUE))
setwd("../../AU Quarters/controls") ### Healthy controls
files <- NA
files <- list.files()
# Change .doc extensions to .txt (on disc)
invisible(file.rename(files, gsub("doc", "txt", files)))
files <- gsub("doc", "txt", files) # Fix file list
# Remove first file from list because it is incomplete
files <- files[-1]
ds_controls <- lapply(files, FUN =
    function(f) read.table(textConnection(gsub(",", "\t", readLines(f))), skip = 13, header = FALSE, fill = TRUE))

# Remove leading zeros from subject IDs
#ds_dmgNF$`SUBJECT ID` <- c(1:nrow(ds_dmgNF))
#ds_dmgF$`SUBJECT ID` <- c(1:nrow(ds_dmgF))
# Prepare mapping vectors
num_trials <- 160
options_map <- c(`StimA`="A_B", `StimB`="C_D", `StimC`="E_F", `StimD`="G_H")
category_map <- c(`StimA`=1, `StimB`=2, `StimC`=3, `StimD`=4)
option <- c("A", "B", "C", "D", "E", "F", "G", "H")
outcomes <- matrix(c(25, 25,0,0, 0,0,-25,-25),nrow=2, ncol = 4 , byrow = TRUE)
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE) # Used when mapping choices

process_sd <- function (ds_list, part) {
  # List to store processed subjects' data
  processed_list <- vector(mode = "list", length(ds_list))
  # Loop through all data, build a dataframe for each subject, and rbind everything at the end
  for (sb in 1:length(ds_list)) {
    ds <- ds_list[[sb]][1:num_trials, ] # Data for this specific subject
    subject <- sb
    trial <- ds$V1
    response_time <- ds$V11
    # Here 60 ticks = 1 second, so convert to milliseconds
    response_time <- round((response_time / 60) * 1000)
    # Map to options and choices
    options <- as.character(options_map[as.character(ds$V3)])
    category <- as.numeric(category_map[as.character(ds$V3)])
    choice_index <- ifelse(as.character(ds$V7) == "A", 1, 2)
    choice <- sapply(1:nrow(ds), function (n) choice_pairs[category[n], choice_index[n]])
    outcome <- ifelse(is.na(ds$V8),NA,ifelse(ds$V8 == 1, outcomes[1, category],outcomes[2, category])) # 1 success (rewarded or punishment avoided), 0 otherwise
    outcome <- ifelse(is.na(outcome), NA,paste(choice, outcome,sep=":"))
    # Rest of variables
    condition <- part
    note1 <- ifelse(part == 1, "Opioid-addicted patient", "Healthy control")
    problem <- category
    stage <- education <- age <- sex <- note2 <- NA
    # Create dataframe
    sdf <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    processed_list[[sb]] <- sdf
  }
  return(processed_list)
}

# Process the two datasets
p1 <- process_sd(ds_list = ds_patients, part = 1)
p2 <- process_sd(ds_list = ds_controls, part = 2)
# Fix subject IDs in p2
start_index <- length(p1) + 1
for (s in 1:length(p2)) {
  temp <- p2[[s]]
  temp$subject <- start_index
  p2[[s]] <- temp
  start_index <- start_index + 1
}
ds_all <- c(p1, p2) # Combine both lists
ds_combined <- do.call("rbind", ds_all) # Join all processed datasets
ds_final <- ds_combined [order(ds_combined$subject, ds_combined$problem, ds_combined$condition, ds_combined$trial), ]


# Save processed data
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
