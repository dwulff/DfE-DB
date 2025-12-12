### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Worthy & Maddox (2014) A comparison model of reinforcement-learning and win-stay-lose-shift decision-making processes: A tribute to W.K. Estes

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "WM2014"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1
# Advantageous and disadvantageous options, in that order
option <- c("A", "B")
out_1 <- c(3, 3)
pr_1 <- c(0.7, 0.3)
out_2 <- c(1, 1)
pr_2 <- c(0.3, 0.7)
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Study 2
# Continuous
option <- c("A", "B")
description <- c("N(65, 10^2)",
                 "N(55, 10^2)")
options_table2 <- data.frame(option, description)

# Study 3
# Increasing (advantageous) and decreasing (disadvantageous) options, in that order
option <- c("A", "B")
description <- c("Pre-defined/trial - 1-100 points, initially smaller reward but changes (increases) as a function of the number of times the option is chosen in the previos ten trials",
                 "Pre-defined/trial - 1-100 points, initially larger reward but changes (decreases) as a function of the number of times the option is chosen in the previos ten trials")
options_table3 <- data.frame(option, description)

# Save options
file_name1 <- paste0(paper, "_", "1", "_", "options.csv")
file_name2 <- paste0(paper, "_", "2", "_", "options.csv")
file_name3 <- paste0(paper, "_", "3", "_", "options.csv")
setwd(data_path)
write.table(options_table1, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(options_table2, file = file_name2, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")
write.table(options_table3, file = file_name3, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")

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
setwd("MathPsychEstes2014")
# Read datasets
file_st1 <- "WorthyMaddox2014MathPsychExp1Data_Header.txt"
file_st2 <- "WorthyMaddox2014MathPsychExp2DataHeader.txt"
file_st3 <- "WorthyMaddox2014MathPsychExp3Data.txt"
ds_st1 <- read.table(file_st1, header = TRUE, stringsAsFactors = FALSE)
ds_st2 <- read.table(file_st2, header = TRUE, stringsAsFactors = FALSE)
ds_st3 <- read.table(file_st3, header = TRUE, stringsAsFactors = FALSE)

process_st <- function (ds, st) {
  study <- st
  subject_freq <- rle(ds$subjID) # Subject IDs and frequencies
  psd_list <- vector(mode = "list", length(subject_freq$values))
  for (sb in 1:length(subject_freq$values)) {
    subject <- subject_freq$values[sb]
    df <- ds[ds$subjID == subject, ] # Subject data
    problem <- 1
    options <- "A_B"
    trial <- 1:nrow(df)
    if (st == 1) {
      # 1 is optimal p=.7, and 2 is suboptimal p=.3
      choice <- ifelse(df$choice == 1, "A", "B")
      response_time <- NA
    } else if (st == 2) {
      # option 2 has a mean reward of 65 (C), compared to 55 (D) for option 1
      choice <- ifelse(df$choice == 2, "A", "B")
      response_time <- round(df$RT * 1000)
    } else {
      # option 1 is the increasing option
      choice <- ifelse(df$choice == 1, "A", "B")
      response_time <- round(df$RT * 1000)
    }
    outcome <- paste(choice, df$outcome, sep = ":")
    stage <- sex <- age <- education <- note1 <- note2 <- condition <- NA
    # Create final dataframe
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    psd_list[[sb]] <- psd
  }
  # Combine processed data
  psd_combined <- do.call("rbind", psd_list)
  return(psd_combined)
}

# Function calls
ds_st1_final <- process_st(ds = ds_st1, st = 1)
ds_st2_final <- process_st(ds = ds_st2, st = 2)
ds_st3_final <- process_st(ds = ds_st3, st = 3)
# Save processed data
file_name1 <- paste0(paper, "_", "1", "_", "data.csv")
file_name2 <- paste0(paper, "_", "2", "_", "data.csv")
file_name3 <- paste0(paper, "_", "3", "_", "data.csv")
setwd(data_path)
write.table(ds_st1_final, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(ds_st2_final, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(ds_st3_final, file = file_name3, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
