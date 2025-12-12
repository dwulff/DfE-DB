### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Ratcliff & Frank (2012) Reinforcement-Based Decision Making in Corticostriatal Circuits: Mutual Constraints by Neurocomputational and Diffusion Models

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "RF2012"
study <- 1
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# One problem, 6 non-stationary letters/options whose success probability (being the "correct" choice) depends on the other option available for choice
option <- c("A", "B", "C", "D", "E", "F")
description <- c("A success probability of 0.8 when paired with B, 0.7 when paired with C, 0.7 when paired with E, 0.9 when paired with F, and 0.7 when paired with D",
                 "A success probability of 0.2 when paired with A, 0.4 when paired with D, 0.4 when paired with F, 0.4 when paired with E, and 0.3 when paired with C",
                 "A success probability of 0.7 when paired with D, 0.3 when paired with A, 0.6 when paired with E, and 0.7 when paired with B",
                 "A success probability of 0.3 when paired with C, 0.6 when paired with B, 0.4 when paired with F, and 0.3 when paired with A",
                 "A success probability of 0.6 when paired with F, 0.3 when paired with A, 0.4 when paired with C, and 0.6 when paired with B",
                 "A success probability of 0.4 when paired with E, 0.1 when paired with A, 0.6 when paired with B, and 0.6 when paired with D")
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
file_data <- "dt23cy.out"
# Read dataset - see "Moreinfo"
ds <- read.table(file_data, header = FALSE, stringsAsFactors = FALSE,
                 col.names = c("subject", "block", "trial_num", "stimulus", "keycode_correct", "keycode_response", "response_time") )
subject_freq <- rle(ds$subject) # Subject IDs and frequencies
# Stimulus-related data
setwd("dt23c") # Stimulus pairings are in the subfolder "dt23c"
map_file <- "subject_stimulus_map.txt" # The mapping between subject number and stimulus list
ssmap <- read.table(map_file, header = FALSE, stringsAsFactors = FALSE)
# Read the stimulus lists as text (line by line. Note: leading and trailing white lines are omitted)
stim_text_list <- lapply(subject_freq$values, function(m) readLines(as.character(ssmap[ssmap$V2 == m, "V4"])))
# Remove first 4 lines, and lines containing string txt1 and all lines that follow mod1
stim_text_list <- lapply(stim_text_list, function(text) text[-c(1:4)])
txt1 <- "EXPERIMENT IS NOW OVER"
stim_text_list <- lapply(stim_text_list, function(text) text[-c(grep(txt1, text):length(text))])
# Replace every $, /, comma, and # with a white space
stim_text_list <- lapply(stim_text_list, function(text) trimws(gsub(pattern = "([$/#,])", replacement = " ", x = text)))
# Write clean stimulus lists
for (f in 1:length(stim_text_list)) {
  fileConn <- file(paste(f, ".txt", sep = "")) # Use subject ID as file name
  writeLines(stim_text_list[[f]], fileConn)
  close(fileConn)
}
# Now read data from the new stimulus lists
stim_ds_list <- lapply(subject_freq$values, function(sb)
  read.table(paste(as.character(sb), ".txt", sep = ""), header = FALSE, fill = TRUE, stringsAsFactors = FALSE))
stim_ds_list <- lapply(stim_ds_list, function (df) df[, -c(8:ncol(df))]) # Remove extraneous columns
# Change column names for reference
stim_ds_list <- lapply(stim_ds_list, function (df) setNames(df, c("option1", "option2", "u1", "u2", "S", "stimulus_code", "pressed")))
# Prepare variables and map stimulus codes to options
psd_list <- vector(mode = "list", length(stim_ds_list)) # List of processed datasets
for (sb in subject_freq$values) {
  subject_df <- ds[ds$subject == sb, ] # Current subject's data
  stim_df <- stim_ds_list[[sb]] # Stimulus data for this subject
  subject <- sb
  problem <- 1
  # There are discrepancies between the trials available in the subject and stimulus data
  # Because trial 1 is omitted, trials with RTs faster than 280 ms were excluded
  # Trials with RTs slower than 5000 ms were excluded
  # Invalid keycodes were excluded
  # So create trial and block numbers for the stimulus dataset to map to the main dataset
  block_indices <- which(stim_df$option1 == "To") # Positions where the next block begins (+1)
  block_IDs <- 1:length(block_indices)
  block <- trialn <- vector() # To store block and trial numbers
  for (b in 1:length(block_indices)) {
    b_start <- block_indices[b] + 1
    if (b == length(block_indices)) {
      b_end <- nrow(stim_df) # If last index
    } else {
      b_end <- block_indices[b+1] - 1
    }
    lg <- b_end - b_start + 1
    bids <- rep(block_IDs[[b]], lg) # Create block ID vector
    block <- c(block, bids)
    trialn <- c(trialn, 1:lg)
  }
  # Before Binding the new block and trial columns to stimulus dataframe
  # Remove the "Next Block" rows
  stim_df <- stim_df[stim_df$option1 != "To", ]
  stim_df <- cbind(stim_df, block, trialn) # Bind (note that trials include both training and test)
  # Now for the trials that are in the data (subject_df), get the needed info from stim_df
  block_unq <- unique(subject_df$block)
  # Split both dataframes into lists by blocks
  subject_df_list <- lapply(block_unq, function (b) subject_df[subject_df$block == b, ])
  stim_df_list <- lapply(block_unq, function (b) stim_df[stim_df$block == b, ])
  # Do the mapping
  # Choices and options are in the original letters Q,F,N,B,X,T, so create a map to A,B,C,D,E,F
  option_map <- c(`Q`="A", `F`="B", `N`="C", `B`="D", `X`="E", `T`="F")
  options <- outcome <- choice <- response_time <- vector()
  trial_count <- 0
  for (d in 1:length(subject_df_list)) {
    subdf <- subject_df_list[[d]]
    tr <- subdf$trial_num
    stimdf <- stim_df_list[[d]]
    response_time <- c(response_time, subdf$response_time)
    # Keep a count of trials
    trial_count <- trial_count + length(tr)
    options_new <- sapply(tr, function (t)
      paste(option_map[as.character(stimdf[stimdf$trialn == t, "option1"])],
            option_map[as.character(stimdf[stimdf$trialn == t, "option2"])], sep = "_"))
    options <- c(options, options_new)
    # Depending on subject's keycode response, get corresponding option (1=left, 2=right)
    choice_new <- sapply(tr, function (t)
      ifelse(as.numeric(subdf[subdf$trial_num == t, "keycode_response"]) == 1,
             as.character(stimdf[stimdf$trialn == t, "option1"]), as.character(stimdf[stimdf$trialn == t, "option2"])))
    choice_mapped <- option_map[choice_new] # Map to options
    choice <- c(choice, choice_mapped)
    # Success if response equals correct choice (correct feedback given)
    outcome_new <- sapply(1:nrow(subdf), function (t)
      ifelse(as.character(subdf[t, "keycode_response"]) == as.character(subdf[t, "keycode_correct"]), "1", "0"))
    outcome <- c(outcome, outcome_new)
  }
  # Reset trial numbering and make it consecutive
  trial <- 1:trial_count
  # Rest of variables
  outcome <- paste(choice, outcome,sep = ":")
  age <- sex <- stage <- education <- note1<- note2<- NA
  condition <- 1
  # Processed data
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}
# Combine all dataframes in the list
ds_final <- do.call("rbind", psd_list)

# Save processed data
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
