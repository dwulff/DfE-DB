### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Camilleri, A. R., & Newell, B. R. (2009a). The role of representation in experience-based choice. Judgment and Decision Making, 4, 518–529
# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "CN2009a"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1 experienced condition. description data only have one choice data, not useful.
# A safe, B risky
option <- LETTERS[1:16]
out_1 <- c(3, 4, -2, -50, 14, 17, -3, -32, 1, 14, -9, -12, 4, 25, -8, -9)
pr_1 <- c(1, 0.8, 1, 0.05, 1, 0.9, 1, 0.1, 1, 0.15, 1, 0.85, 1, 0.2, 1, 0.95)
out_2 <- c(NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0)
pr_2 <- c(NA, 0.2, NA, 0.95, NA, 0.1, NA, 0.9, NA, 0.85, NA, 0.15, NA, 0.8, NA, 0.05)
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
d<-read.spss("C&N 2009 JDM.sav")
d<-data.frame(d)
smp<-subset(d,Condition=="Experience") # description version only have one choice data, not useful.
subject_list <- unique(smp$ID)
option <- LETTERS[1:16]
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
out_safe <- c(3, -2, 14, -3, 1, -9, 4, -8)
condition_list <- c('percent_before', 'percent_after', 'safe_before', 'safe_after')
pd <- data.frame()

for (participant in unique(smp$ID)) {
  subject <- participant
  smp_s <- smp[smp$ID==participant, ]
  for (p in unique(smp_s$Problem)) {
    smp_p <- smp_s[smp_s$Problem==p, ]
    problem <- p
    options <- option_map[problem]
    feedback <- smp_p[1, 14:133] 
    feedback <- feedback[!is.na(feedback)]
    choice <- ifelse(feedback==out_safe[problem], choice_pairs[problem, 1], choice_pairs[problem, 2])
    outcome <- paste(choice, feedback, sep = ":")
    trial<- seq(1, length(feedback))
    decision <- smp_p$Choice
    decision <- ifelse(decision == 'Safe', choice_pairs[problem,1], choice_pairs[problem,2])
    condition <- ifelse(smp_p$JudegmentType=='Percent',ifelse(smp_p$JudegmentTime=='Before', 1, 2), ifelse(smp_p$JudegmentTime=='Before', 3, 4))
    note1 <- condition_list[condition]
    sex <- ifelse(smp_p$Gender=='Female', 'f', 'm')
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
