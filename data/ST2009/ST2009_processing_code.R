### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Stillwell & Tunney (2009) Melioration behaviour in the Harvard game is reduced by simplifying decision outcomes

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "ST2009"
study <- 1
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheets

# A meliorating option (button A), and a maxmizing option (button B), choose A leads to lower game trials
option <- c("A", "B")
out_1 <- c(5, 2.5)
pr_1 <- c(1, 1)
options_table <- data.frame(option, out_1, pr_1)

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
setwd("Data copied for Ahmad Dawud/")
data_files <- list.files()
subject_IDs <- sort(as.numeric(gsub("[^[:digit:]]", "" ,data_files))) # 21 subjects
data_files <- paste(as.character(subject_IDs), "csv", sep = ".")
psd_list <- vector(mode = "list", length(data_files)) # Processed datasets

for (d in 1:length(data_files)) {
  # Read data for this subject
  dfile <- data_files[[d]]
  ds <- read.csv(dfile, header = TRUE, stringsAsFactors = FALSE)
  subject <- subject_IDs[d]
  problem <- 1
  options <- "A_B"
  # Trial numbering resets to mark a new session
  trial <- ds$Trial
  # Identify the different sequences in trial
  sInd <- cumsum(trial == 1)
  sInds <- rle(sInd)
  note1 <- unlist(lapply(1:length(sInds$values), function (n)
    rep(paste("Session", sInds$values[n], sep = " "), sInds$lengths[n])))
  choice <- ifelse(ds$Choice == 0, "A", "B")
  payoff <- ds$PayOff
  cumulative_pay <- ds$winnings
  outcome <- paste(choice, payoff, sep = ":")
  note2 <- paste("Cumulative earnings =", cumulative_pay, sep = " ")
  # Rest of variables
  response_time <- stage <- sex <- age <- education <- condition <- NA
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[d]] <- psd # Store
}

# Combine and save processed data
ds_final <- do.call("rbind", psd_list)
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
