### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Worthy et al. (2008) Ratio and difference comparisons of expected reward in decision-making tasks

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "WMM2008"
studies <- c(1, 2)
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

### Study 1
# Two options (decks), three conditions/problems
# In each problem the rewards differed in amount depending on the trial. In the control condition (AB): 1-10 points
# Difference-preserving (CD): 81-90 points, and ratio-preserving (EF): 10-100
option <- c("A", "B", "C", "D", "E", "F")
description <- c("Deck A gave values that averaged 3 points during the first 30 trials, 4 points over the next 20 trials, and 7 points over the final 30 trials",
                 "Deck B gave values that averaged 8 points over the first 30 trials, 6 points over the next 20 trials, and 3 points over the final 30 trials",
                 "Same as option A except that 80 points were added to each reward",
                 "Same as option B except that 80 points were added to each reward",
                 "Same as option A except that each reward was multiplied by 10",
                 "Same as option B except that each reward was multiplied by 10")
options_table1 <- data.frame(option, description)

### Study 2
# Two options (decks), same constraints as in study 1
# But the reward structure alternated between the two options every 10 trials so that one option's
# average reward is higher, then lower, and so on.
option <- c("A", "B", "C", "D", "E", "F")
description <- c("Deck A gave reward values that averaged 7 points over the first 10 trials, 3 points over trials 11-20. The reward values reversed in this manner every 10 trials throughout the remainder of the experiment",
                 "Deck B gave reward values that averaged 3 points over the first 10 trials, 7 points over trials 11-20. The reward values reversed in this manner every 10 trials throughout the remainder of the experiment",
                 "Same as option A except that 80 points were added to each reward",
                 "Same as option B except that 80 points were added to each reward",
                 "Same as option A except that each reward was multiplied by 10",
                 "Same as option B except that each reward was multiplied by 10")
options_table2 <- data.frame(option, description)

# Save options
file_name1 <- paste0(paper, "_", studies[1], "_", "options.csv")
file_name2 <- paste0(paper, "_", studies[2], "_", "options.csv")
setwd(data_path)
write.table(options_table1, file = file_name1, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")
write.table(options_table2, file = file_name2, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

### Process dataset

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper", "studies","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)
setwd("Worthyetal2008Data")

### Study 1

# Read the data files
data_ex1Control <- "Worthyetal2008Exp1Control.csv"
data_ex1Diff <- "Worthyetal2008Exp1DifferencePreserving.csv"
data_ex1Ratio <- "Worthyetal2008Exp1RatioPreserving.csv"
dsc <- read.csv(data_ex1Control, header = TRUE, stringsAsFactors = FALSE)
dsd <- read.csv(data_ex1Diff, header = TRUE, stringsAsFactors = FALSE)
dsr <- read.csv(data_ex1Ratio, header = TRUE, stringsAsFactors = FALSE)
dataset_options_map <- c(`dsc`=1, `dsd`=2, `dsr`=3, `dsc2`=1, `dsd2`=2, `dsr2`=3)
option <- c("A", "B", "C", "D", "E", "F")
choice_matrix <- matrix(option, ncol = 2, byrow = TRUE)

process_st <- function (ds, st, subject_group) {
  study <- st
  problem <- unname(dataset_options_map[as.character(deparse(substitute(ds)))])
  options <- paste(choice_matrix[problem, ], collapse = "_")
  trial <- ds$trial
  # Subject IDs reset (1-10) for all conditions, so make them consecutive (between-subject design)
  subject_freq <- rle(sort(ds$subjID)) # Subject IDs and frequenies
  if (subject_group == 1) {
    subject <- ds$subjID
    note1 <- "Control"
    condition <- 1
  } else if (subject_group == 2) {
    subIDs <- 11:20
    subject <- rep(subIDs, subject_freq$lengths)
    note1 <- "Difference-preserving"
    condition <- 2
  } else {
    subIDs <- 21:30
    subject <- rep(subIDs, subject_freq$lengths)
    note1 <- "Ratio-preserving"
    condition <- 3
  }
  # Map choices
  choice <- sapply(ds$choice, function(ch) choice_matrix[problem, ch])
  # Subject were given feedback on the points earned
  #cum_totals <- cumsum(as.numeric(ds$outcome))
  outcome <- paste(choice, ds$outcome, sep = ":")
  response_time <- round(as.numeric(ds$rt) * 1000)
  # Rest of variables
  age <- sex <- stage <- education <- note2 <- NA
  # Processed data
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  return(psd)
}

st1control <- process_st (ds = dsc, st = studies[1], subject_group = 1)
st1diff <- process_st (ds = dsd, st = studies[1], subject_group = 2)
st1ratio <- process_st (ds = dsr, st = studies[1], subject_group = 3)
# Combine processed data
ds_st1_final <- rbind(st1control, st1diff, st1ratio)

### Study 2

# Read in the data
data_ex2Control <- "Worthyetal2008Exp2Control.csv"
data_ex2Diff <- "Worthyetal2008Exp2DifferencePreserving.csv"
data_ex2Ratio <- "Worthyetal2008Exp2RatioPreserving.csv"
dsc2 <- read.csv(data_ex2Control, header = TRUE, stringsAsFactors = FALSE)
dsd2 <- read.csv(data_ex2Diff, header = TRUE, stringsAsFactors = FALSE)
dsr2 <- read.csv(data_ex2Ratio, header = TRUE, stringsAsFactors = FALSE)

# Function calls
st2control <- process_st (ds = dsc2, st = studies[2], subject_group = 1)
st2diff <- process_st (ds = dsd2, st = studies[2], subject_group = 2)
st2ratio <- process_st (ds = dsr2, st = studies[2], subject_group = 3)
# Combine processed data
ds_st2_final <- rbind(st2control, st2diff, st2ratio)

# Save processed data
file_name1 <- paste0(paper, "_", studies[1], "_", "data.csv")
file_name2 <- paste0(paper, "_", studies[2], "_", "data.csv")
setwd(data_path)
write.table(ds_st1_final, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(ds_st2_final, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
