### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Yechiam, Barron, & Erev (2005) The Role of Personal Experience in Contributing to Different Patterns of Response to Rare Terrorist Attacks

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "YBE2005"
# Set as working directory the folder that contains the data as sent by the author
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

option <- c("A", "B")
out_2 <- c(-1, -2)
pr_2 <- c(0.995, 0.995)
out_1 <- c(-200, -8)
pr_1 <- c(0.005, 0.005)

# Save to data frame
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options sheet
file_name <- paste0(paper, "_", "1", "_", "options.csv")
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
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path")))
study <- 1
# Back to raw data directory
setwd(raw_path)
setwd("results")
# List all data files in working directory (raw_data)
#file_list_test <- list.files()
batch_1 = paste("terror_raw_400_1_", c(9, 10, 15:22, 31, 32), ".txt", sep = "")
batch_2 = paste("terror_raw_400_2_", c(1:8, 11:14), ".txt", sep = "")
file_list <- c(batch_2[1:8], batch_1[1:2], batch_2[9:12], batch_1[3:10], batch_1[11:12])

# Read all data files into a data list
data_list <- lapply(file_list,
                    FUN = function(files)
                    {read.table(files, header = FALSE, skip = 4, sep = ",", stringsAsFactors = FALSE,
                                fill = TRUE,
                                col.names = c("subject", "choice", "outcome"))})

# Check if read data sets have equal dimensions
test_data <- read.table(file_list[1], header = FALSE, skip = 4, sep = ",", fill = TRUE,
                  col.names = c("subject", "choice", "outcome"), stringsAsFactors = FALSE)
test_dim <- dim(test_data)
data_all <- do.call("rbind", data_list)
data_dim <- dim(data_all)
test_dim[1] <- test_dim[1] * length(file_list)
if (identical(data_dim, test_dim)) {
  print("All data sets have equal dimensions")
} else {
  print("Data sets do not have equal dimensions")
}

problem <- 1
options <- c("A_B")
# List of processed data sets
psd_list <- vector(mode = "list", length = length(data_list))

for (d in 1:length(file_list)) {
  df <- data_list[[d]]
  # In the files, some rows contain non-data, which were read as NAs, so they can be discarded
  # Clean out all rows with any NA values
  df <- na.omit(df)
  trial <- 1:nrow(df)
  note1 <- "Experience only"
  # Replace choices with the appropriate options
  # choice = 0 = risky = A, and choice = 1 = safe = B
  choice <- ifelse(df$choice == 0, "A", "B")
  df$choice <- choice
  # In the study, option A has two outcomes (-200 or -1), and option B (-8, -2)
  outcome <- paste(as.character(choice), as.character(df$outcome), sep = ":")
  df$outcome <- outcome
  response_time <- stage <- sex <- age <- education <- condition <- note2 <- NA
  # Add remaining variables to data set
  df <- cbind(df, paper, study, problem, options, trial, condition, response_time, stage, sex, age, education, note1, note2)
  # Re-arrange data set variables
  # Required order of variables: paper, study, subject, problem, options, trial, choice, outcome
  ds_processed <- df[, c("paper", "study", "subject", "problem", "condition", "options", "trial", "choice", "outcome", "response_time", "stage", "sex", "age", "education", "note1", "note2")]
  # Store processed data set in the list
  psd_list[[d]] <- ds_processed
}

# Combine and save processed data
ds_final <- do.call("rbind", psd_list)
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
