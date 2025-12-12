### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Moustafa et. al (2015) The Role of Informative and Ambiguous Feedback in Avoidance Behavior: Empirical and Computational Findings

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "MSM2015"
study <- 1
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Each stimulus is made to associate with different outcomes for A and B
# Although in the paper they are A and B and  with different outcome probabilities

option <- c("A",    "B",     "C",     "D",     "E",     "F",     "G",     "H")
out_1 <- c(25,     25,       25,       25,      0,       0,        0,       0)
pr_1 <- c(0.80,    0.20,     0.20,     0.80,    0.80,    0.20,     0.20,    0.80)
out_2 <- c(0,      0,         0,       0,       -25,     -25,      -25,     -25)
pr_2 <- c(0.20,    0.80,      0.80,    0.20,     0.20,    0.80,     0.80,    0.20)
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
setwd("1617340/Moustafa2015_data")
# Read demographic dat
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
file_dmg <- "Moustafa2015_demog.xls"
ds_dmgNF <- read_excel(file_dmg, sheet = "Moustafa2015_nofeedback")
ds_dmgF <- read_excel(file_dmg, sheet = "Moustafa2015_feedback")
# Read datasets from the two folders (one file per subject)
# Note: the study talks about two feedback conditions, but that refers to informing the subject
# which option would have possibly given feedback (not the feedback/outcome itself) - on skipped trials only.
if (!requireNamespace("readtext", quietly = TRUE)) install.packages("readtext")
library(readtext)
setwd("Moustafa2015_NoFeedback") ### First folder
files <- list.files()
# Change .doc extensions to .txt (on disc)
invisible(file.rename(files, gsub("doc", "txt", files)))
files <- gsub("doc", "txt", files) # Fix file list
# Note that gsub here separates the entries of the 2nd column
ds_NFBList <- lapply(files, FUN =
    function(f) read.table(textConnection(gsub(",", "\t", readLines(f))), header = FALSE, fill = TRUE))
setwd("../Moustafa2015_Feedback") ### Second folder
files <- NA
files <- list.files()
# Change .doc extensions to .txt (on disc)
invisible(file.rename(files, gsub("doc", "txt", files)))
files <- gsub("doc", "txt", files) # Fix file list
ds_FBList <- lapply(files, FUN =
    function(f) read.table(textConnection(gsub(",", "\t", readLines(f))), header = FALSE, fill = TRUE))

# Remove leading zeros from subject IDs
ds_dmgNF$`SUBJECT ID` <- c(1:nrow(ds_dmgNF))
ds_dmgF$`SUBJECT ID` <- c(1:nrow(ds_dmgF))
# Prepare mapping vectors
options_map <- c(`StimA`="A_B", `StimB`="C_D", `StimC`="E_F", `StimD`="G_H")
category_map <- c(`StimA`=1, `StimB`=2, `StimC`=3, `StimD`=4)
choice_map <- c(`A`=1, `B`=2)
option <- c("A", "B", "C", "D", "E", "F", "G", "H")
outcomes <- matrix(c(25, 25,0,0, 0,0,-25,-25),nrow=2, ncol = 4 , byrow = TRUE)
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE) # Used when mapping choices

process_sd <- function (ds_list, ds_dm, part) {
  # List to store processed subjects' data
  processed_list <- vector(mode = "list", length(ds_list))
  # Loop through all data, build a dataframe for each subject, and rbind everything at the end
  for (sb in 1:length(ds_list)) {
    age <- as.numeric(ds_dm[ds_dm$`SUBJECT ID` == sb, "AGE"])
    sex <- tolower(as.character(ds_dm[ds_dm$`SUBJECT ID` == sb, "Gender"]))
    ds <- ds_list[[sb]] # Data for this specific subject
    # For part 2 dataset add 100 to sb
    subject <- ifelse (part == 2, sb + 100, sb)
    trial <- ds$V1
    # Get response times (RTs in column V11 if choice was made, column V9 if trial was skipped)
    response_time <- sapply(1:nrow(ds), function(r)
      ifelse(as.character(ds[r, "V7"]) == "s", as.numeric(ds[r, "V9"]), as.numeric(ds[r, "V11"])))
    # Here 60 ticks = 1 second, so convert to milliseconds
    response_time <- round((response_time / 60) * 1000)
    # Map to options and choices
    options <- as.character(options_map[as.character(ds$V3)])
    category <- as.numeric(category_map[as.character(ds$V3)])
    # Extract choices
    choice <- sapply(1:nrow(ds), function (n)
      ifelse(as.character(ds[n, "V7"]) == "s", NA,
             choice_pairs[category[n], as.numeric(choice_map[as.character(ds[n, "V7"])])]))
    note1 <- ifelse(is.na(choice), "Trial skipped", "") # Make note of skipped trials
    result <- ds$V8 # Skipped trials have RT here (because of the data organisation)
    outcome <- ifelse(result=="RT",NA,ifelse(result == 1, outcomes[1, category],outcomes[2, category])) # 1 success (rewarded or punishment avoided), 0 otherwise
    outcome <- ifelse(is.na(outcome), NA,paste(choice, outcome,sep=":"))
    problem <- category
    # Rest of variables
    condition <-  ifelse(part==1, 1, 2)
    note2 <- ifelse(part==1, 'no feedback', 'feedback')
    stage <- education <- NA
    # Create dataframe
    sdf <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    processed_list[[sb]] <- sdf
  }
  return(processed_list)
}

# Process the two datasets
pdnf <- process_sd(ds_NFBList, ds_dm = ds_dmgNF, part = 1)
pdf <- process_sd(ds_FBList, ds_dm = ds_dmgF, part = 2)
ds_all <- c(pdnf, pdf) # Combine both lists
ds_combined <- do.call("rbind", ds_all) # Join all processed datasets
ds_final <- ds_combined [order(ds_combined$subject, ds_combined$problem, ds_combined$condition), ]

# exclude participants with uncomplete data
ds_final <- ds_final[ds_final$subject != 182,]

# Save processed data
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
