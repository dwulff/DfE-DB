### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Turi et al. (2017) Placebo Intervention Enhances Reward Learning in Healthy Individuals

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "TMPA2017"
study <- 1
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet
# One problem, optimal and suboptimal options, in that order
option <- LETTERS[1:6]
out_1 <- c(1,     1,     1,         1,        1,      1)
pr_1 <- c(0.6,   0.4,  0.7,     0.3,     0.8,   0.2)
out_2 <- c(0,    0,    0,        0,       0,     0)
pr_2 <- c(0.4,   0.6,  0.3,    0.7,    0.2,   0.8 )
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)

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
setwd("2016-placebo-tdcs-study-master/data/export")
# Read datasets (there is also a Rdata file but it loads so many unnecessary variables)
dsl <- read.csv(file = "placebo_tdcs_learn.csv", header = TRUE, stringsAsFactors = FALSE)
dst <- read.csv(file = "placebo_tdcs_transfer.csv", header = TRUE, stringsAsFactors = FALSE)
# All participants were male
sex <- "m"
option <- c("E", "F", "C", "D", "A", "B") # Notice the different order
choice_matrix <- matrix(option, ncol = 2, byrow = TRUE)
condition_map <- c(`N`=1, `A`=2, `B`=3)
condition_name_map <- c(`N`="Baseline/control", `A`="Purportedly low uncertainty", `B`="Purportedly high uncertainty")
options_rewardProbs_map <- c(`A`=0.8, `B`=0.2, `C`=0.7, `D`=0.3, `E`=0.6, `F`=0.4)
subject_freq <- rle(sort(dsl$Participant))
# List to store each subject's processed data
psd_list <- vector(mode = "list", length(subject_freq$values))

for (sb in 1:length(subject_freq$values)) {
  # Subject was assigned to one problem only (good or bad world) under one condition
  subject <- subject_freq$values[sb]
  # Extract this subject's data
  dfl <- dsl[dsl$Participant == subject, ]
  dft <- dst[dst$Participant == subject, ]
  # Split data by condition
  dfl_list <- split(x = dfl, f = dfl$condition)
  dft_list <- split(x = dft, f = dft$condition)
  conditions <- c("N", "A", "B")
  # List to store subject's three conditions
  cnd_list <- vector(mode = "list", length(conditions))
  
  for (cnd in 1:length(conditions)) {
    dfpartL <- dfl_list[[conditions[cnd]]]
    dfpartT <- dft_list[[conditions[cnd]]]
    condition <- condition_map[as.character(conditions[cnd])]
    note1 <- condition_name_map[as.character(conditions[cnd])]
    options_L <- sapply(dfpartL$pair, function (pr) paste(choice_matrix[pr, ], collapse = "_"))
    options_T <- sapply(1:nrow(dfpartT), function (n)
      paste(sort(c(dfpartT$symb1[n], dfpartT$symb2[n])), collapse = "_"))
    options <- c(options_L, options_T)
    trial <- c(1:nrow(dfpartL), 1:nrow(dfpartT))
    # accuracy: 1 correct, 0 incorrect, -1 no response
    selection_L <- ifelse(dfpartL$ACC == 0, 2, dfpartL$ACC)
    choice_L <- sapply(1:nrow(dfpartL), function (n)
      ifelse(selection_L[n] != -1, choice_matrix[dfpartL$pair[n], selection_L[n]], NA))
    choice_T <- dfpartT$choice
    choice <- c(choice_L, choice_T)
    # Feedback in learning trials
    reward_L <- sapply(1:nrow(dfpartL), function (n)
      ifelse(selection_L[n] != -1, paste(choice_L[n], dfpartL$reward[n], sep = ":"), NA))
    # No feedback was given in the second stage (testing)
    reward_T <- choice_T
    outcome <- c(reward_L, reward_T)
    response_time <- round(c(dfpartL$RT, dfpartT$RT) * 1000)
    note2 <- c(rep(c("Learning phase"), nrow(dfpartL)), rep(c("Testing phase"), nrow(dfpartT)))
    problem <- c(rep(c(1), nrow(dfpartL)), rep(c(2), nrow(dfpartT)))
    age <- education <- stage <- NA
    # Create final dataframe
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    cnd_list[[cnd]] <- psd
  }
  cnd_all <- do.call("rbind", cnd_list)
  psd_list[[sb]] <- cnd_all
}

# Combine and save processed data
ds_final <- do.call("rbind", psd_list)
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
