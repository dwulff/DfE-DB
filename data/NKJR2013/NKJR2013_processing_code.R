### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Newell et. al (2013) Probability matching in risky choice: The interplay of feedback and strategy availability

if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "NKJR2013"
study <- 2
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

### Study 2 - One problem (die roll, dominate color is counterbalanced, the dominate one is A)
option <- c("A", "B")
out_1 <- c(1, 1)
pr_1 <- c(0.7, 0.3)
out_2 <- c(0, 0)
pr_2 <- c(0.3, 0.7)
# Save to data frame
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options sheets
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

# Clear all variables except path, paper, and study
rm(list=setdiff(ls(), c("path", "paper", "study","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)
setwd("MCR Exp2. Data")
files <- list.files()
ds_list <- lapply(files, FUN =
                       function(f) read.table(f, header = FALSE, fill = TRUE, stringsAsFactors = FALSE))
problem <- 1
options <- "A_B"
psd_list <- vector(mode = "list", length(ds_list))

# For each subject build a dataframe and then rbind them all
for (sb in 1:length(ds_list)) {
  ds <- ds_list[[sb]] # Dataset
  subject <- sb # subject id
  # Extract info on education
  text_item <- "" # Some control variables to help extract education data
  row_num <- as.numeric(which(ds$V1 == "Degree"))
  still_text <- TRUE
  education <- ""
  while(still_text) {
    ed_item <- trimws(paste(ds[row_num, 1:ncol(ds)], collapse = " "))
    education <- trimws(paste(education, ed_item, sep = " "))
    row_num <- row_num + 1
    if (ds[[row_num, 1]] == "Highest") {
      still_text <- FALSE
    }
  }
  # Delete unwanted rows
  lim <- nrow(ds) - 9
  ds <- ds[c(1:lim), ]
  # Get age and gender info
  age <- as.numeric(ds[[which(ds$V6 == "Age") + 1, "V6"]])
  sex <- ifelse(ds[[which(ds$V7 == "Gender") + 1, "V7"]] == "Female", "f", "m")
  feedback <- ifelse(ds[[which(ds$V3 == "Feedback") + 1, "V3"]] == "F", "Feedback", "No feedback") # Feedback or not
  hint <- ifelse(ds[[which(ds$V2 == "Hint") + 1, "V2"]] == "H", "Hint", "No hint") # Hint or not
  trial <- 1:300
  choice <- ds$V2 # Contains all entries in the column with the choices
  choice <- choice[which(choice %in% c("Red", "RED", "Green", "GREEN"))] # Keep "red" or "green"
  dominate <- ifelse(ds[[which(ds$V4 == "CB") + 1, "V4"]] == "70G", "GREEN", "RED")
  choice <- ifelse(
    toupper(choice) == "GREEN",
    ifelse(dominate == "GREEN", "A", "B"),
    ifelse(dominate == "GREEN", "B", "A")) # A is dominate
  if (feedback == "Feedback") {
    # With feedback, so code outcomes
    outcome_raw <- ds$V6
    outcome_raw <- outcome_raw[which(outcome_raw %in% c("0", "1"))]
    outcome <- paste(choice, outcome_raw, sep = ":")
  } else {
    outcome <- choice
  }
  response_time <- stage <- note2 <- NA
  note1 <- paste(feedback, " and ", hint, sep = " ")
  condition <- ifelse(feedback=="Feedback", ifelse(hint=="Hint", 1, 2),  ifelse(hint=="Hint", 3, 4))
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine and save processed data
ds_st2_final <- do.call("rbind", psd_list)
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_st2_final, file = file_name, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")
