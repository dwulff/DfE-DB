### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Selbing et al. (2014) Demonstrator skill modulates observational aversive learning

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "SLO2014"
study <- 1
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheets

# One problem - optimality refers to the lower probability of receiving a shock (code as 1) is lower
# A,C: non-optimal choice, B,D: optimal choice. AB for stage1 CD for stage 2

option <- c("A", "B", "C","D")
out_1 <- c(0, 0, 0, 0)
pr_1 <- c(0.8, 0.2,0.8, 0.2)
out_2 <- c(1, 1, 1, 1)
pr_2 <- c(0.2, 0.8, 0.2, 0.8)
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
file_data <- "Data_Selbing_Cognition2014.R"
# Read dataset (saved R dataframe)
load(file_data) # Variable name is "d"
problem <- 1
subject_freq <- rle(sort(d$Subject)) # Values and frequencies
# Repeat each subject ID sequence two times (two stages)
subject <- unname(unlist(lapply(1:length(subject_freq$values), function (sb)
  rep(sb, prod(as.numeric(subject_freq$lengths[sb]), 2)))))
sex <- unname(unlist(lapply(1:length(subject_freq$values), function (sb)
  rep(as.character(d[d$Subject == sb, "Sex"]), 2)))) # Same for sex
# Create two instances of each trial because there are two stages within a trial
trial <- unname(unlist(lapply(subject_freq$lengths, function (t) rep(1:t, each = 2))))
stage <- unname(unlist(lapply(subject_freq$lengths, function (t) rep(1:2, t))))
# Get the stimulus pairs and create options

# A choice between optimal vs non-optimal options
options <- "A_B"
# Code and map choices, outcomes, and response times
### Stage 1
options_stg1 <- "A_B"
rt_stg1 <- d$ButtonPress.Demonstrator.Go.RT.ms # Reaction time in stage 1 (demonstrator)
# Note that what happens in stage 1 depends on observation condition
note1_stg1 <- ifelse(d$ButtonPress.Demonstrator.Go == 1, "Observe demonstrator", "No response to observe")
obs_map <- c(`No.Obs`="No observation is possible", `Choice.Obs`="Obervation of choice but not outcome",
             `Choice.Consequence.Obs`="Observation of choice and outcome")
con_map <- c(`No.Obs`=1, `Choice.Obs`=2, `Choice.Consequence.Obs`=3)
con_stg1 <- con_map[as.character(d$OL.Condition)]
note2_stg1 <- obs_map[as.character(d$OL.Condition)]
# Choice by demonstrator and outcome (optimal or not, 1 or 0)
#choice_stg1 <- ifelse(d$Demonstrator.OptimalChoice == 1, "B", "A")
choice_stg1 <- "" # Code as "" because the subject is not making the choice
# Code outcomes - this has been expanded to clarify what's happening
outcome_stg1 <- sapply(1:nrow(d), function (j) {
  if (d$ButtonPress.Demonstrator.Go[j] == 1 && d$OL.Condition[j] == "No.Obs") {
    return ("") # No outcome condition
  } else if (d$ButtonPress.Demonstrator.Go[j] == 1 && d$OL.Condition[j] == "Choice.Obs") {
    ch <- ifelse(d$Demonstrator.OptimalChoice[j] == 1, "B", "A")
    return(ch) # Choice only
  } else if (d$ButtonPress.Demonstrator.Go[j] == 1 && d$OL.Condition[j] == "Choice.Consequence.Obs") {
    ch <- ifelse(d$Demonstrator.OptimalChoice[j] == 1, "B", "A")
    out <- ifelse(d$Demonstrator.Shock[j] == 1, "0", "1") # If no shock, then success
    return(paste(ch, out, sep = ":")) # Choice and success (no shock) or failure
  } else { # Subject did not choose to observe demonstrator
    return("")
  }
  })
outcome_stg1 <- ifelse(is.na(rt_stg1), NA, outcome_stg1)
choice_stg1 <- ifelse(is.na(rt_stg1), NA, choice_stg1)
### Stage 2
options_stg2 <- "C_D"
rt_stg2 <- d$Subject.Choice.RT.ms # Reaction time in stage 2 (subject)
choice_stg2 <- sapply(d$Subject.OptimalChoice, function(j) ifelse(j == 1, "D", ifelse(j == 0, "C", "0")))
# If the participant did not make a choice during the action stage the risk of a shock was 0.5
shock <- ifelse(d$Subject.Shock == 1, "0", "1") # Success if no shock received
outcome_stg2 <- paste(choice_stg2, shock, sep = ":")
note1_stg2 <- "Subject's choice"
note2_stg2 <- "" # Condition
outcome_stg2 <- ifelse(is.na(rt_stg2), NA, outcome_stg2)
choice_stg2 <- ifelse(is.na(rt_stg2), NA, choice_stg2)
# Merge stage 1 and stage 2 variables (in alternating order)
response_time <- c(rbind(rt_stg1, rt_stg2))
note1 <- c(rbind(note1_stg1, note1_stg2))
note2 <- c(rbind(note2_stg1, note2_stg2))
choice <- c(rbind(choice_stg1, choice_stg2))
outcome <- c(rbind(outcome_stg1, outcome_stg2))
options <- c(rbind(options_stg1, options_stg2))
condition <- rep(con_stg1, each=2)
age <- education <- NA
# Create final dataframe
psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)

# Save data
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(psd, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
