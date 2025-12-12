### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Niv et. al (2015) Reinforcement Learning in Multidimensional Environments Relies on Attention Mechanisms

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "NDGG2015"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

option <- c("A", "B", "C")
description <- c("P(success) in trial t is determined by one of three dimensions (color, shape, or texture, with each having 3 possible features)",
                 "P(success) in trial t is determined by one of three dimensions (color, shape, or texture, with each having 3 possible features)",
                 "P(success) in trial t is determined by one of three dimensions (color, shape, or texture, with each having 3 possible features)")
options_table <- data.frame(option, description)

# Save options sheet
file_name <- paste0(paper, "_", "1", "_", "options.csv")
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
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)
study <- 1
if (!requireNamespace("R.matlab", quietly = TRUE)) install.packages("R.matlab")
library(R.matlab)
file_data <- "BehavioralDataOnline.mat"
# 22 participants (rest were discarded, originally 34 reported in paper)
ds <- readMat(file_data)
ds <- ds$DimTaskData
choice_raw <- ds[[1]] # choices
outcome_raw <- ds[[2]] # outcomes
stimuli <- ds[[3]] # the first dimension is colors, then shapes, then textures
rt <- round(ds[[6]] * 1000) # response times
problem <- 1
options <- "A_B_C"
option <- c("A", "B", "C")
num_subjects <- 22 # included in the analysis, out of 34
shape_map <- c(`1`="Square", `2`="Triangle", `3`="Circle")
color_map <- c(`1`="Red", `2`="Green", `3`="Yellow")
texture_map <- c(`1`="Plaid", `2`="Dots", `3`="Waves")
# List of processed data
psd_list <- vector(mode = "list", num_subjects)

for (sb in 1:num_subjects) {
  subject <- as.numeric(sb)
  # In datastructure, column number correspond to subject number
  trial <- 1:800
  # Options: 800X3X22, just take the shape dimension as defining which choice was made
  # square, triangle, or circle
  choices_shape <- choice_raw[, 2, subject]
  choice <- option[choices_shape]
  outcome <- sapply(1:nrow(outcome_raw), function (n) paste(choice[n], outcome_raw[n, subject], sep = ":"))
  outcome <- ifelse(is.na(choice),NA,outcome)
  response_time <- rt[, subject]
  stimulus_raw <- stimuli[, , , subject]
  stm <- apply(stimulus_raw, MARGIN = 1, function (v)
    c(color_map[as.character(v[1])], shape_map[as.character(v[2])], texture_map[as.character(v[3])]))
  stm <- t(stm)
  note1 <- sapply(1:nrow(stm), function (n) paste(stm[n, ], collapse = " "))
  # Rest of variables
  stage <- sex <- age <- education <- condition <- note2 <- NA
  # Processed data
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine data
ds_final <- do.call("rbind", psd_list)
# Save processed data
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

