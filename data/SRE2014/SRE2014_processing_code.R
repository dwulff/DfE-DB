### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Schurr et al. (2014) The effect of unpleasant experiences on evaluation and bsehavior

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "SRE2014"
study <- 1
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# One problem, 3 stages (stages 1 and 3 are coded because stage 2 is just planning)
# The out values represent dots, and each dot equals an agora = 0.01 sheqel
option <- c("A", "B", "C")
out_1 <- c(3, 0, 3)
pr_1 <- c(0.3, 1, 0.3)
out_2 <- c(2, NA, 2)
pr_2 <- c(0.3, NA, 0.3)
out_3 <- c(1, NA, 1)
pr_3 <- c(0.3, NA, 0.3)
out_4 <- c(26, NA, -22)
pr_4 <- c(0.1, NA, 0.1)
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2, out_3, pr_3, out_4, pr_4)

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

### Process datasets

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper", "study","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)

if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
file1 <- "peakFreqData4Mix.sav" # Data without stage 2 outcomes (but with the choices)
ds_choice <- read.spss(file1, to.data.frame = TRUE)

if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
file2 <- "PeakDataRaw4AhmadDawud.xlsx"
ds <- read_excel(file2, sheet = "Sheet1") # Data without stage 2 choices (but with the outcomes)
subject_freq <- rle(sort(ds$ID)) # Subject IDs and frequencies (47 subjects analysed out of 48 in the paper)
psd_list <- vector(mode = "list", length(subject_freq$values))

for (sb in 1:length(subject_freq$values)) {
  df <- ds[ds$ID == subject_freq$values[sb], ] # Get subject data
  df_choice <- ds_choice[ds_choice$ID == subject_freq$values[sb], ]
  # Remove steps 101-103 as these only separate stages 1 and 2
  rm_indices <- which(df$Step %in% c(101,102,103))
  df <- df[-rm_indices, ]
  # Trial numbering, 1-100 two times, or maybe 1-200 ?
  df$Step <- rep(1:100, 2)
  # Get variables to build processed dataframe
  subject <- as.numeric(subject_freq$values[sb])
  problem <- 1
  options <- rep(c("A", "B_C"), each = 100)
  trial <- df$Step
  stage <- rep(c(1, 2), each = 100) # Experiential stage, then choice between safe and risky options
  choice_stg1 <- rep("", 100) # Non-consequential choice in stage 1 (only observe the outcome)
  # B = play safe (observe the outcome), C = play for money (risky)
  choice_stg2 <- ifelse(df_choice$DecisionS2 == 0, "B", "C")
  choice <- c(choice_stg1, choice_stg2)
  # Negative sign added to indicate that red represents a loss
  outcome_stg1 <- paste("A", df$Reds[1:100], sep = ":")
  # Reds (losses) + greens
  outStg2 <- as.numeric(df$Reds[101:200]) * -1 + 4 # +4 greens
  outcome_stg2 <- ifelse(choice_stg2 == "B", paste(paste(choice_stg2, 0, sep = ":"), paste("C", outStg2, sep = ":"), sep = "_"), paste(paste(choice_stg2, outStg2, sep = ":"), paste("B", 0, sep = ":"), sep = "_"))
  outcome <- c(outcome_stg1, outcome_stg2)
  #note_stg1 <- rep("Experiential stage", 100)
  #note_stg2 <- ifelse(choice_stg2 == "B", "Chose to play it safe", "Chose to play for real money")
  #note <- c(note_stg1, note_stg2)
  sex <- df$Gender
  age <- df$Age
  note1 <- rep(c("Observe the outcomes", "Play for money"), each = 100)
  note2 <- ifelse(options == "A", "Observe", ifelse(choice == "B", "Play Safe (not for money)", "Play Risky (for money)"))
  response_time <- education <- condition <- NA
  # Create dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd # Store
}

# Combine and save processed data
ds_final <- do.call("rbind", psd_list)
ds_final$choice <- as.character(ds_final$choice)
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
