### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Avrahami & Kareev (2011) The Role of Impulses in Shaping Decisions

if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "AK2011"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")

setwd(raw_path)

##### Create the options sheet

### Study 1
# Optimal and suboptial options (probability of coin in box), A and B will not get a 1 at the same time
option <- c("A", "B")
out_1 <- c(1, 1)
pr_1 <- c(0.6, 0.4)
out_2 <- c(0, 0)
pr_2 <- c(0.4, 0.6)
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

## Study 2
# Optimal and suboptimal
options_table2 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options
file_name1 <- paste0(paper, "_", "1", "_", "options.csv")
file_name2 <- paste0(paper, "_", "2", "_", "options.csv")
setwd(data_path)
write.table(options_table1, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(options_table2, file = file_name2, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")

################################################################################################
################################################################################################

### Process dataset

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("raw_path","data_path","path", "paper")))
# Back to raw directory
setwd(raw_path)
# Read dataset
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
file_data <- "Hats for Berlin.xlsx"
ds <- read_excel(file_data, sheet = "Sheet1")
ds_st1 <- ds[ds$likelihoodBoth == 0, ] # Study 1
ds_st2 <- ds[ds$likelihoodBoth != 0, ] # Study 2
problem <- 1
opts <- c("A", "B")
options <- paste(opts, collapse = "_")

process_st <- function(ds, st) {
  # Function to process dataset
  study <- st
  subject_freq <- rle(sort(ds$sn)) # Subject identifiers and frequencies
  psd_list <- vector(mode = "list", length(subject_freq$values))
  for (sb in 1:length(subject_freq$values)) {
    subject <- subject_freq$values[sb] # Subject identifier
    df <- ds[ds$sn == subject, ] # Subject data
    trial <- df$round
    # Determine the box with the highest probability
    optimal_box <- ifelse(df$likelihoodLeft > df$likelihoodRight, "L", "R")
    choice <- ifelse(df$choice_L_R == optimal_box, opts[1], opts[2])
    choice_fg <- ifelse(df$choice_L_R == optimal_box, opts[2], opts[1])
    # Coin found or not
    result <- ifelse(df$choice_L_R == "L", df$outInLeft, df$outInRight)
    result_fg <- ifelse(df$choice_L_R == "R", df$outInLeft, df$outInRight)
    # Subjects can only know the outcome of the box they chose, not the other option
    outcome <- paste(paste(choice, result, sep = ":"), paste(choice_fg, result_fg, sep = ":"), sep = "_")
    response_time <- stage <- sex <- age <- education <- note1 <- note2 <- condition <- NA
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

# Save processed data
file_name1 <- paste0(paper, "_", "1", "_", "data.csv")
file_name2 <- paste0(paper, "_", "2", "_", "data.csv")
setwd(data_path)
write.table(ds_st1_final, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(ds_st2_final, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
