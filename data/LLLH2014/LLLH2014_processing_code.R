### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Li et. al (2014) Inferring reward prediction errors in patients with schizophrenia: a dynamic reward task for reinforcement learning

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "LLLH2014"
study <- 1
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet
# Two problems (sequences of reward probabilities) in two decks of cards
# AB = sequence 1, CD = sequence 2
option <- c("A", "B", "C", "D")
description <- c("P(success/reward) = 0.45 in trial-block1, 0.0857 in trial-block2, 0.45 in trial-block3, 0.0857 in trial-block4, 0.5143 in trial-block5, and 0.15 in trial-block6",
                 "P(success/reward) = 0.15 in trial-block1, 0.5143 in trial-block2, 0.15 in trial-block3, 0.5143 in trial-block4, 0.0857 in trial-block5, and 0.45 in trial-block6",
                 "P(success/reward) = 0.45 in trial-block1, 0.0857 in trial-block2, 0.5143 in trial-block3, 0.15 in trial-block4, 0.5143 in trial-block5, and 0.15 in trial-block6",
                 "P(success/reward) = 0.15 in trial-block1, 0.5143 in trial-block2, 0.0857 in trial-block3, 0.45 in trial-block4, 0.0857 in trial-block5, and 0.45 in trial-block6")
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

### Process the dataset

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper", "study","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
file_data <- "2014 RPE paper- raw data.xlsx"
ds_dmg <- read_excel(file_data, sheet = "demographic info ")
ds <- read_excel(file_data, sheet = "all data")
# Order datasets by group then subject number
ds <- ds [order(ds$Group, ds$`Subject number`), ]
ds_dmg <- ds_dmg [order(ds_dmg$group, ds_dmg$`subject number`), ]
# Remove any white space characters in column entries
ds_dmg$age <- gsub('\\s+', '', ds_dmg$age)
subjec_freq <- rle(sort(ds$`Subject number`))
# Some subjects in different groups have the same ID, giving them 960 trials (see subject_freq)
# So we'll split the ordered dataset into blocks of 480 trials and assign new IDs
# Split dataset into blocks of 480 trials
ds_list <-split(ds, rep(1:ceiling(nrow(ds)/480), each=480)[1:nrow(ds)])
option <- c("A", "B", "C", "D")
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
# Reward probabilities in problem/sequence 1
# Note that for sequence 2, the reward probabilities for decks A and B are the reverse of those in the paper
# So for sequence 2/problem 2, A is B and B is A
sequence1 <- c(0.45, 0.0857, 0.45, 0.0857, 0.5143, 0.15, 0.15, 0.5143, 0.15, 0.5143, 0.0857, 0.45)
sequence2 <- c(0.45, 0.0857, 0.5143, 0.15, 0.5143, 0.15, 0.15, 0.5143, 0.0857, 0.45, 0.0857, 0.45)
# List to store processed data
psd_list <- vector(mode = "list", length(ds_list))

for (sb in 1:length(psd_list)) {
  # Assign new ID
  subject <- sb
  # Subject's data
  df <- ds_list[[sb]]
  # Use old ID to get sex and age
  old_ID <- unique(df$`Subject number`)
  group <- unique(df$Group)
  sex <- ifelse(as.character(ds_dmg[ds_dmg$`subject number` == old_ID & ds_dmg$group == group, "gender"]) == "Male", "m", "f")
  age <- as.numeric(ds_dmg[ds_dmg$`subject number` == old_ID & ds_dmg$group == group, "age"])
  yrs <- as.numeric(ds_dmg[ds_dmg$`subject number` == old_ID & ds_dmg$group == group, "education"])
  education <- paste(yrs, "years of formal education", sep = " ")
  trial <- df$Trial
  response_time <- round(df$RT)
  # Consider that condition 1 = psychosis (low or high), and cnd = 2 = control
  condition <- ifelse(group %in% c("L", "H"), 1, 2)
  note1 <- ifelse(group == "L", "Low Psychosis", ifelse(group == "H", "High Psychosis", "Healthy Control"))
  # Determine the sequence (problem) to which the subject was assigned
  # First split dataframe into 6 blocks
  blocks_list <- split(x = df, f = df$Block)
  probsA <- unname(unlist(lapply(blocks_list, function (d) unique(d$ProbA))))
  probsB <- unname(unlist(lapply(blocks_list, function (d) unique(d$ProbB))))
  problem <- ifelse(identical(c(probsA, probsB), sequence1) || identical(c(probsB, probsA), sequence1), 1, 2)
  options <- paste(choice_pairs[problem, ], collapse = "_")
  # In a given problem, the reward probabilities of deckA for subject1 are those of deckB for subject2
  # Make sure they all map to the sequences defined in the paper
  if (problem == 1) {
    if(identical(c(probsA, probsB), sequence1)) {
      choice_code <- ifelse(df$Choice == "A", 1, 2)
    } else { # Reward probabilities reversed
      choice_code <- ifelse(df$Choice == "A", 2, 1)
    }
  } else { # problem 2
    if(identical(c(probsA, probsB), sequence2)) {
      choice_code <- ifelse(df$Choice == "A", 1, 2)
    } else {
      # Reward probabilities reversed
      choice_code <- ifelse(df$Choice == "A", 2, 1)
    }
  }
  choice <- sapply(1:nrow(df), function (n) choice_pairs[problem, choice_code[n]])
  result <- df$Outcome
  outcome <- ifelse(is.na(choice),NA,paste(choice, result, sep = ":"))
  stage <- note2 <- NA
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine and save processed data
ds_final <- do.call("rbind", psd_list)
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
