### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Rakow et al. (2010) The role of working memory in information acquisition and decision making: Lessons from the binary prediction task

if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
# Identify the root directory
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "RNZ2010"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet
# Study 1 - games 1-6 (problems), optimal and suboptimal
option <- LETTERS[1:12]
out_1 <- c(3,     3,      3,     3,     3,     3,      3,     3,      3,      3,      3,     3)
pr_1 <- c(0.55,   0.45,   0.60,  0.40,  0.65,  0.35,   0.70,  0.30,   0.75,   0.25,   0.80,  0.20)
out_2 <- c(-3,    -3,     -3,    -3,   -3,     -3,    -3,     -3,    -3,      -3,     -3,   -3)
pr_2 <- c(0.45,   0.55,   0.40,  0.60,  0.35,  0.65,   0.30,  0.70,   0.25,   0.75,   0.20,  0.80)
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Study 2 - same options
options_table2 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options sheets
file_name1 <- paste0(paper, "_", "1", "_", "options.csv")
file_name2 <- paste0(paper, "_", "2", "_", "options.csv")
setwd(data_path)
write.table(options_table1, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(options_table2, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

### Process study 1

# Clear all variables except path and paper
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path")))
# # Experiment 1 directory
setwd(raw_path)
setwd("BP1 QJEP1 Data copy for Ahmad_Dawud/")
study <- 1
# List all folders, each contains data from one participant
dirs <- sort(list.files())
# Vector to map probability of optimal option (lightbulb) to problem number
problem_map <- c(`0.55`=1, `0.6`=2, `0.65`=3, `0.7`=4, `0.75`=5, `0.8`=6)
option <- LETTERS[1:12]
# Options organised into a matrix
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
gender_map <- c(`male`="m", `female`="f")
# List to store each subject's processed data
psd_list <- vector(mode = "list", length(dirs))

for (sb in 1:length(dirs)) {
  # Open subject folder
  setwd(dirs[sb])
  # Each problem's data is in a separate file
  data_files <- list.files(pattern = ".txt")
  # To store processed problems' data
  pr_list <- vector(mode = "list", length(data_files))
  
  for (p in 1:length(data_files)) {
    # Read the data line by line
    conn <- file(data_files[p], open="r")
    lines <- readLines(conn)
    close(conn)
    subject <- as.numeric(gsub(pattern = "Ppt ", replacement = "", x = lines[3]))
    sex <- unname(gender_map[as.character(lines[4])])
    age <- as.numeric(gsub(pattern = "yrs", replacement = "", x = lines[5]))
    problem <- unname(problem_map[as.character(gsub(pattern = "Probability = ", replacement = "", x = lines[8]))])
    options <- paste(choice_pairs[problem, ], collapse = "_")
    # Read the data into a dataframe
    ds <- read.csv(file = data_files[p], header = TRUE, skip = 8, stringsAsFactors = FALSE)
    trial <- ds$trial
    # pickbetter: 0 = observe; 1 = maximising option picked*; -1 = minority option picked
    choice <- ifelse(ds$pick == 0, "",
                     ifelse(ds$pickbetter == 1, choice_pairs[problem, 1], choice_pairs[problem, 2]))
    outcome <- ifelse(ds$pick == 0, "", paste(choice,ds$trialearnings,sep = ":"))
    #outcome <- sapply(1:nrow(ds), function (n) ifelse(ds$pickbetter[n] == 0, ds$trialearnings[n], ""))
    # Determine optimal choice code (1 or -1, in case this was not fixed in all problems/subjects)
    #lights <- rle(sort(ds$whichlight))
    #optimal_code <- lights$values[which(lights$lengths == max(lights$lengths))]
    # Observe is coded with a zero, and choice is either optimal or suboptimal
    #choice <- sapply(1:nrow(ds), function (n) ifelse(ds$pick[n] == 0, "0",
    #                 ifelse(ds$pick[n] == optimal_code, choice_pairs[problem, 1], choice_pairs[problem, 2])))
    #observed <- ifelse(ds$whichlight == optimal_code, choice_pairs[problem, 1], choice_pairs[problem, 2])
    # Outcomes = either feedback on observe trials or no feedback on prediction trials
    #outcome <- sapply(1:nrow(ds), function (n)
    #  ifelse(ds$pickbetter[n] == 0, paste(observed[n], ds$trialearnings[n], sep = ""), ""))
    note1 <- sapply(1:nrow(ds), function (n)
      ifelse(ds$pickbetter[n] == 0, "Observation", "Prediction"))
    response_time <- round(ds$trialtime * 1000)
    stage <- education <- note2 <- condition <- NA
    # Create final dataframe
    pdf <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    # And store in list
    pr_list[[p]] <- pdf
  }
  
  # Combine processed problems into one dataframe
  pr_combined <- do.call("rbind", pr_list)
  pr_combined <- pr_combined [order(pr_combined$problem), ]
  psd_list[[sb]] <- pr_combined
  # Return to main directory in order to process the next participant's data
  setwd("..")
}

# Combine (for subjects) and save processed data
ds_st1_final <- do.call("rbind", psd_list)
file_name <- paste0(paper, "_", "1", "_", "data.csv")
setwd(data_path)
write.table(ds_st1_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

### Process study 2

# Clear all variables except path and paper
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path")))
# Go to Experiment 2 directory
setwd(raw_path)
setwd("BP6 QJEP2 Data copy for Ahmad_Dawud/")
study <- 2
data_files <- list.files(pattern = ".txt")
# Vector to map probability of optimal option (lightbulb) to problem number
problem_map <- c(`0.55`=1, `0.6`=2, `0.65`=3, `0.7`=4, `0.75`=5, `0.8`=6)
option <- LETTERS[1:12]
# Options organised into a matrix
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
gender_map <- c(`male`="m", `female`="f")
# Condition determined from first number of subject identifier
condition_map <- c(`7`="Memory load condition", `8`="Distractor condition", `9`="No load condition")
condition_number_map <- c(`7`=1, `8`=2, `9`=3)
# List to store each subject's processed data
psd_list <- vector(mode = "list", length(data_files))

for (sb in 1:length(data_files)) {
  # Read the data line by line
  conn <- file(data_files[sb], open="r")
  lines <- readLines(conn)
  close(conn)
  # Get subjet number, extract first 3 characters, convert to numeric
  subject <- as.numeric(substring(gsub(pattern = "Ppt ", replacement = "", x = lines[3]), 1, 3))
  cnd <- substring(text = subject, first = 1, last = 1) # First number gives condition
  condition <- condition_number_map[as.character(cnd)]
  note1 <- condition_map[as.character(cnd)]
  sex <- unname(gender_map[as.character(lines[4])])
  age <- as.numeric(gsub(pattern = "yrs", replacement = "", x = lines[5]))
  problem <- unname(problem_map[as.character(gsub(pattern = "Probability = ", replacement = "", x = lines[8]))])
  options <- paste(choice_pairs[problem, ], collapse = "_")
  # Read the data into a dataframe
  lines_toSkip <- as.numeric(grep(pattern = "trial", x = lines)) - 1
  #lines_toSkip <- ifelse(substring(as.character(subject), 1, 1) == "7", 10, 8)
  ds <- read.csv(file = data_files[sb], header = TRUE, skip = lines_toSkip, stringsAsFactors = FALSE)
  trial <- ds$trial
  # pickbetter: 0 = observe; 1 = maximising option picked*; -1 = minority option picked
  choice <- ifelse(ds$pickbetter == 0, "",
                   ifelse(ds$pickbetter == 1, choice_pairs[problem, 1], choice_pairs[problem, 2]))
  outcome <- ifelse(ds$pick == 0, "", paste(choice,ds$trialearnings,sep = ":"))
  #outcome <- sapply(1:nrow(ds), function (n) ifelse(ds$pickbetter[n] == 0, ds$trialearnings[n], ""))
  # Determine optimal choice code (1 or -1, in case this was not fixed in all problems/subjects)
  #lights <- rle(sort(ds$whichlight))
  #optimal_code <- lights$values[which(lights$lengths == max(lights$lengths))]
  # Observe is coded with a zero, and choice is either optimal or suboptimal
  #choice <- sapply(1:nrow(ds), function (n) ifelse(ds$pick[n] == 0), "0",
  #                 ifelse(ds$pick[n] == optimal_code, choice_pairs[problem, 1], choice_pairs[problem, 2]))
  #observed <- ifelse(ds$whichlight == optimal_code, choice_pairs[problem, 1], choice_pairs[problem, 2])
  # Outcomes = either feedback on observe trials or no feedback on prediction trials
  #outcome <- sapply(1:nrow(ds), function (n)
  #  ifelse(ds$pick[n] == 0, paste(observed, ds$trialearnings, sep = ""), ""))
  note2 <- sapply(1:nrow(ds), function (n)
    ifelse(ds$pickbetter[n] == 0, "Observation", "Prediction"))
  response_time <- round(ds$trialtime * 1000)
  stage <- education <- NA
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  # And store in list
  psd_list[[sb]] <- psd
}

# Combine and sort processed data
psd_combined <- do.call("rbind", psd_list)
ds_st2_final <- psd_combined [order(psd_combined$subject, psd_combined$problem), ]
# Save
file_name <- paste0(paper, "_", "2", "_", "data.csv")
setwd(data_path)
write.table(ds_st2_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
