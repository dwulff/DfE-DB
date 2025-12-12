### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Rakow & Miiler (2009) Doomed to repeat the successes of the past: History is best forgotten for repeated choices with nonstationary payoffs

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "RM2009"
studies <- c(1, 2)
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create options sheets

# Study 1
# Four problems (games 1-4), two conditions: experience-only, and experience plus history info,
# Two options per problem, stationary and non-stationary, in that order
option <- c("A", "B", "C", "D", "E", "F", "G", "H")
description <- c("10 with a probability of 0.7, -20 otherwise",
                 "For trials 1-20, 10 with a probability of 0.9, -20 otherwise. P(10) decreases by 0.1/trial for trials 21-60, and remains at 0.5 for trials 61-100",
                 "10 with a probability of 0.7, -20 otherwise",
                 "For trials 1-40, 10 with a probability of 0.9, -20 otherwise. P(10) decreases by 0.1/trial over trials 41-80, then remains at 0.5 for trials 81-100",
                 "20 with a probability of 0.3, -10 otherwise",
                 "For trials 1-20, 20 with a probability of 0.1, -10 otherwise. P(20) increases gradually by 0.1/trial over trials 21-60, then remains at 0.5 for trials 61-100",
                 "10 with a probability of 0.5, -12 otherwise",
                 "For trials 1-20, 20 with a probability of 0.1, -10 otherwise. P(20) increases gradually by 0.1/trial over trials 21-60, then remains at 0.5 for trials 61-100")
options_table1 <- data.frame(option, description)

# Study 2
# Six problems (games 5-10)
option <- c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L")
description <- c("20 with a probability of 0.6, -10 otherwise",
                 "For trials 1-20, 20 with a probability of 0.8, -10 otherwise. P(20) decreases by 0.1/trial for trials 21-40, and remains at 0.4 for trials 41-60",
                 "20 with a probability of 0.6, -10 otherwise",
                 "For trials 1-20, 20 with a probability of 0.4, -10 otherwise. P(20) increases by 0.1/trial for trials 21-40, and remains at 0.8 for trials 41-60",
                 "20 with a probability of 0.6, -10 otherwise",
                 "For trials 1-30, 20 with a probability of 0.4, -10 otherwise. P(20) increases by 0.1/trial for trials 31-50, and remains at 0.8 for trials 51-60",
                 "36 with a probability of approx. 0.45, -14 otherwise",
                 "For trials 1-20, 20 with a probability of 0.8, -10 otherwise. P(20) decreases by 0.1/trial for trials 21-40, and remains at 0.4 for trials 41-60",
                 "20 with a probability of approx. 0.6, -10 otherwise",
                 "For trials 1-30, 36 with a probability of approx. 0.35, -14 otherwise. P(36) increases by 0.1/trial for trials 31-50, and remains at approx. 0.55 for trials 51-60",
                 "20 with a probability of approx. 0.6, -10 otherwise",
                 "For trials 1-30, 36 with a probability of approx. 0.55, -14 otherwise. P(36) decreases by 0.1/trial for trials 31-50, and remains at approx. 0.35 for trials 51-60")
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

### Process datasets

# Study 1
# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper", "studies","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)
setwd("TR-KM-2009 Data shared 14.08.2017/")
study <- studies[1]
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
file_exp1 <- "Full t-by-t data TR-KM-Expt1 shared copy 14.08.2017.xls"
file_dmg <- "TR-KM-Expt1 demographic data shared 14.08.2017.sav"
ds <- read_excel(file_exp1, sheet = "All data (copy)") # Dataset
dmg <- read.spss(file_dmg, to.data.frame = TRUE) # Demographic data
options_map <- c(`1`="A_B", `2`="C_D", `3`="E_F", `4`="G_H") # Map problem number to options
problem <- ds$Problem
options <- options_map[as.character(problem)]
option <- c("A", "B", "C", "D", "E", "F", "G", "H") # Individual Options
choice_pairs <- matrix (option, ncol = 2, byrow = TRUE) # Used when mapping choices
subject <- ds$PptNumber
condition_map <- c(`Exp_only`="Experience only", `Desc_hist`="Experience with outcome history info")
note1 <- condition_map[as.character(ds$Condition)]
condition <- ifelse(ds$Condition == "Exp_only", 1, 2)
sex <- sapply(ds$PptNumber, function (s) ifelse(as.character(dmg[s,2]) == "female", "f", "m"))
age <- sapply(ds$PptNumber, function (g) as.numeric(dmg[g,3]))
# Map choices and outcomes
# OptionChosen is coded: ‘0’ if the ‘Fixed’ option is chosen, and ‘1’ if the ‘NS’ option is chosen.
choice <- sapply(1:length(problem), function(p)
  ifelse(ds$OptionChosen[p] == 0, choice_pairs[problem[p], 1], choice_pairs[problem[p], 2]))
payoff <- ds$OutcomeObtained
foregone_choice <- sapply(1:length(problem), function(p)
  ifelse(ds$OptionChosen[p] == 0, choice_pairs[problem[p], 2], choice_pairs[problem[p], 1]))
foregone_payoff <- sapply(1:length(problem), function (p)
  ifelse(ds$OptionChosen[p] == 0, ds$OutcomeNS[p], ds$OutcomeFixed[p]))
outcome <- paste(paste(choice, payoff, sep = ":"), paste(foregone_choice, foregone_payoff, sep = ":"),sep = "_")
# Rest of variables
response_time <- stage <- education <- note2 <- NA
trial <- ds$Trial
# Create dataframe
psd_st1 <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
# Save data
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(psd_st1, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

# Study 2
# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper", "studies", "psd_st1","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)
setwd("TR-KM-2009 Data shared 14.08.2017/")
study <- studies[2]
file_exp2 <- "Full t-by-trial data TR-KM-Expt2 shared copy 14.08.2017.xls"
file_dmg <- "TR-KM-Expt2 demographic data shared 14.08.2017.sav"
ds <- read_excel(file_exp2, sheet = "ALL DATA") # Dataset
dmg <- read.spss(file_dmg, to.data.frame = TRUE) # Demographic data
options_map <- c(`1`="A_B", `2`="C_D", `3`="E_F", `4`="G_H", `5`="I_J", `6`="K_L") # Map problem number to options
problem <- ds$Problem
options <- options_map[as.character(problem)]
option <- c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L") # Individual Options
choice_pairs <- matrix (option, ncol = 2, byrow = TRUE) # Used when mapping choices
subject <- ds$PptNumber
condition_map <- c(`exp_only`="Experience only", `desc_hist`="Experience with outcome history info")
note1 <- condition_map[as.character(ds$Condition)]
condition <- ifelse(ds$Condition == "exp_only", 1, 2)
sex <- sapply(ds$PptNumber, function (s) ifelse(as.character(dmg[s,2]) == "female", "f", "m"))
age <- sapply(ds$PptNumber, function (g) as.numeric(dmg[g,3]))
# Map choices and outcomes
# OptionChosen is coded: ‘0’ if the ‘Fixed’ option is chosen, and ‘1’ if the ‘NS’ option is chosen.
choice <- sapply(1:length(problem), function(p)
  ifelse(ds$OptionChosen[p] == 0, choice_pairs[problem[p], 1], choice_pairs[problem[p], 2]))
payoff <- ds$OutcomeObtained
foregone_choice <- sapply(1:length(problem), function(p)
  ifelse(ds$OptionChosen[p] == 0, choice_pairs[problem[p], 2], choice_pairs[problem[p], 1]))
foregone_payoff <- sapply(1:length(problem), function (p)
  ifelse(ds$OptionChosen[p] == 0, ds$OutcomeNS[p], ds$OutcomeFixed[p]))
outcome <- paste(paste(choice, payoff, sep = ":"), paste(foregone_choice, foregone_payoff, sep = ":"),sep = "_")
# Rest of variables
response_time <- stage <- education <- note2 <- NA
trial <- ds$Trial
# Create dataframe
psd_st2 <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
# Save data
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(psd_st2, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

