### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Li et. al (2011) How instructed knowledge modulates the neural systems of reward learning

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "LDP2011"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Binary prediction: whether value of cue greater than 5 or not (see supplement PDF)
# There might be a way to model it as static options
option <- c("A", "B", "C", "D", "E", "F", "G", "H")
out_1 <- c(1, 1, 1, 1, 1, 1, 1, -0.5)
pr_1 <- c(0.25, 0.75, 0.50, 0.50, 0.75, 0.25, 1, 1)
out_2 <- c(-0.5, -0.5, -0.5, -0.5, -0.5, -0.5, NA, NA)
pr_2 <- c(0.75, 0.25, 0.50, 0.50, 0.25, 0.75, NA, NA)
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
# Back to raw data directory
setwd(raw_path)
setwd("data")
study <- 1
# Read demographic data
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
file_subjects <- "subjects_demo.xlsx"
dmg <- read_excel(file_subjects, sheet = "Sheet1", skip = 4)
# Read dataset
if (!requireNamespace("R.matlab", quietly = TRUE)) install.packages("R.matlab")
library(R.matlab)
file_data <- "behaviors_scanning.mat"
ds <- readMat(file_data, verbose = FALSE)
ds <- ds$behaviors
problem <- 1
option <- c("A", "B", "C", "D", "E", "F", "G", "H")
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
# Note that the cue options are A, C, E, and G
options_map <- c(`1`="A", `2`="C", `3`="E", `4`="G")
psd_list <- vector(mode = "list", length(ds))

# Note that ds at this stage is a list
for (sb in 1:length(ds)) {
  df <- ds[[sb]] # Dig into nest
  df <- df[[1]]
  df <- df[[1]]
  # Extract data
  subject <- as.numeric(df[[1]])
  sex <- tolower(as.character(dmg[dmg$subjectID == subject, 3]))
  # Process both sessions/conditions
  process_session <- function (dt, session, pos) {
    # Process session data
    if (session == "instructed") {
      note1 <- "Outcomes probabilities described"
      condition <- 2
    } else {
      note1 <- ""
      condition <- 1
    }
    # The second column in the "cue" matrix is the 1-4 visual cues
    cue_raw <- unname(unlist(dt[[3]]))
    # The third column in decision is the choice
    decision_raw <- unname(unlist(dt[[4]]))
    # All columns in the decision/outcome matrix got concatenated, so select the last column's data
    st <- length(decision_raw) - 80 + 1
    decision <- decision_raw[st:length(decision_raw)] # p = right button, q = left
    cue_codes <- as.numeric(cue_raw[81:(st-1)])
    cue_options <- unname(options_map[as.character(cue_codes)]) # not needed
    options <- sapply(1:length(decision), function (n) paste(choice_pairs[cue_codes[n], ], collapse = "_"))
    # "q represent subjects pressed button on the left side of the screen (selecting option on the left side) or
    # p (selecting option on the right side of the screen)"
    # The yokeID (here=pos) tells which side of the screen the stimulus picture was presented for a specific subject.
    if (pos == 0) {
      # the stimulus is on left side of screen
      choice <- sapply(1:length(decision), function (n)
                       ifelse(decision[n] == "q", choice_pairs[cue_codes[n], 2], choice_pairs[cue_codes[n], 1]))
    } else {
      # stimulus on the right side
      choice <- sapply(1:length(decision), function (n)
                       ifelse(decision[n] == "p", choice_pairs[cue_codes[n], 2], choice_pairs[cue_codes[n], 1]))
    }
    trial <- 1:length(choice)
    # Win/loss feedback is given, plus the value of the variable option
    payoff <- unname(unlist(dt[[6]]))
    outcome <-ifelse(is.na(choice), NA, paste(choice, payoff, sep = ":"))
    response_time <- stage <- age <- education <- note2 <- NA
    # Create final dataframe
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  }
  # Function calls
  # unknown = session with feedback
  # pos = yokeID = which side of the screen the stimulus was presented on (0 = right)
  session_fb <- process_session(dt = df[[4]], session = "feedback", pos = as.numeric(df[[2]]))
  session_ins <- process_session(dt = df[[3]], session = "instructed", pos = as.numeric(df[[2]])) # known
  psd_list[[sb]] <- rbind(session_fb, session_ins)
}

# Combine
psd_combined <- do.call("rbind", psd_list)
ds_final <- psd_combined [order(psd_combined$subject, psd_combined$problem, psd_combined$condition, psd_combined$trial), ]
# Save processed data
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
