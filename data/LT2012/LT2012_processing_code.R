### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Lee & Tomblin (2012) Reinforcement learning in young adults with developmental language impairment

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "LT2012"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

##### Create the options sheet

option <- c("A", "B", "C", "D", "E", "F")
out_1 <- c(1, 1, 1, 1, 1, 1)
pr_1 <- c(0.8, 0.2, 0.7, 0.3, 0.6, 0.4)
out_2 <- c(0, 0, 0, 0, 0, 0)
pr_2 <- c(0.2, 0.8, 0.3, 0.7, 0.4, 0.6)
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options
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
# Back to raw data directory
setwd(raw_path)
study <- 1
# Read datasets
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
file_data <- "RL_Lee.xlsx"
ds <- read_excel(file_data, sheet = "RL.csv", skip = 1,
                 col_names = c("subject", "trial", "block", "stimulus_pair", "response_training", "response_accuracy", "response_testing"))
subject_freq <- rle(ds$subject) # Subject ID values and frequencies
length(unique(ds$subject))
length(subject_freq)
#reinf_map <- c(`A`=0.8, `C`=0.7, `E`=0.6, `F`=0.4, `D`=0.3, `B`=0.2)
# Remove subjects with not enough data (check if less than 400 trials)
indices <- which(subject_freq$lengths >= 400)
psd_list <- vector(mode = "list", length(indices))
for (sb in 1:length(indices)) {
  subject <- subject_freq$values[indices[sb]]
  df <- ds[ds$subject == subject, ] # Subject data
  
  options <- gsub(pattern = ".BMP", replacement = "", x = df$stimulus_pair) # Remove .bmp
  options <- paste(substr(options, 1, 1), substr(options, 2, 2), sep="_")
  trial <- df$trial
  choice <- c(df$response_training, df$response_testing)
  choice <- choice[!is.na(choice)] # Remove the NAs
  choice[choice == "NO_RESPONSE"] <- NA # If no response, insert NA
  outcome <- ifelse(is.na(choice),NA, ifelse(is.na(df$response_accuracy), choice, paste(choice, df$response_accuracy,sep = ":"))) # No feedback during testing
  note1 <- ifelse(grepl("C", subject), "Control condition", "DLI condition")
  condition <- ifelse(grepl("C", subject), 1, 2)
  response_time <- stage <- sex <- age <- education <- NA
  # Create final dataframe
  note2 <- df$block
  problem <- ifelse(df$block == 'TestBlock', 2, 1)
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine and save processed data
ds_final <- do.call("rbind", psd_list)

length(unique(ds_final$subject))

file_name <- paste0(paper, "_", "1", "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
