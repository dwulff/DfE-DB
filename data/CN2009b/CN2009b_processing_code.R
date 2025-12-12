### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Camilleri, A. R., & Newell, B. R. (2009b). Within-subject Preference Reversals in Description- and Experience-based Choice
# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "CN2009b"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1 experienced condition. description data only have one choice data, not useful.
# A safe, B risky
option <- LETTERS[1:20]
out_1 <- c(3, 4, -3, -4, 3, 32, -3, -32, 9, 10, -9, -10, 3, 16, 1, 11, 2, 14, 4, 28)
pr_1 <- c(1, 0.8, 1, 0.8, 1, 0.1, 1, 0.1, 1, 0.9, 1, 0.9, 1, 0.2, 1, 0.1, 1, 0.15, 1, 0.15)
out_2 <- c(NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0)
pr_2 <- c(NA, 0.2, NA, 0.2, NA, 0.9, NA, 0.9, NA, 0.1, NA, 0.1, NA, 0.8, NA, 0.9, NA, 0.85, NA, 0.85)
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options
file_name1 <- paste0(paper, "_", "1", "_", "options.csv")
setwd(data_path)
write.table(options_table1, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

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
study <-1
d<-read.csv("Camilleri09_101_raw.csv")
d<-data.frame(d)
option <- LETTERS[1:20]
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
out_safe <- c(3, -3, 3, -3, 9, -9, 3, 1, 2, 4)
condition_list <- c('description first', 'experience first')
pd <- data.frame()
d$EChoice <- ifelse(d$Problem %in% c(1, 4, 5), d$EChoice, 1-d$EChoice ) # except for problem 1, 4, 5, in other problem, safe option is on the right wihch is inconsist with our problen table. Therefore, switch it.
for (participant in unique(d$ID)) {
  subject <- participant
  smp_s <- d[d$ID==participant, ]
  for (p in unique(smp_s$Problem)) {
    smp_p <- smp_s[smp_s$Problem==p, ]
    problem <- p
    options <- option_map[problem]
    feedback <- smp_p$sampling
    choice <- ifelse(feedback==out_safe[problem], choice_pairs[problem, 1], choice_pairs[problem, 2])
    outcome <- paste(choice, feedback, sep = ":")
    trial<- smp_p$trial
    decision <- ifelse(smp_p$EChoice == 0, choice_pairs[problem, 1], choice_pairs[problem, 2])
    condition <- smp_p$Order
    note1 <- condition_list[smp_p$Order]
    sex <- ifelse(smp_p$Gender==0, 'f', 'm')
    age <- smp_p$Age
    # Rest of variables
    response_time<- stage <- education<- note2<- NA
    # Create final dataframe
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, decision, response_time, stage, sex, age, education, note1, note2)
    pd <- rbind(pd, psd)
  }
}

# Combine and save processed data
ds_final <- pd [order(pd$subject), ]
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
