### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Camilleri, A. R., & Newell, B. R. (2011a). Description- and experience-based choice: Does equivalent information equal
# equivalent choice?☆
# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "CN2011a"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1 experienced condition. description data only have one choice data, not useful. Study 1 and 2 use the same problem set.
# A safe, B risky
option <- LETTERS[1:20]
out_1 <- c(3, 4, -3, -4, 3, 32, -3, -32, 9, 10, -9, -10, 3, 16, 1, 11, 2, 14, 4, 28)
pr_1 <- c(1, 0.8, 1, 0.8, 1, 0.1, 1, 0.1, 1, 0.9, 1, 0.9, 1, 0.2, 1, 0.1, 1, 0.15, 1, 0.15)
out_2 <- c(NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0)
pr_2 <- c(NA, 0.2, NA, 0.2, NA, 0.9, NA, 0.9, NA, 0.1, NA, 0.1, NA, 0.8, NA, 0.9, NA, 0.85, NA, 0.85)
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options
file_name1 <- paste0(paper, "_", "1", "_", "options.csv")
file_name2 <- paste0(paper, "_", "2", "_", "options.csv")
setwd(data_path)
write.table(options_table, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(options_table, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

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
d<-read.csv("C&N 2011 Acta_MAX_exp.csv")
d<-data.frame(d)
option <- LETTERS[1:20]
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
out_safe <- c(3, -3, 3, -3, 9, -9, 3, 1, 2, 4)
condition_list <- c('random draw', 'sudo random','free choice' )

# study 1
study <-1
smp1 <- d[d$Condition %in% c(2, 3), ]
pd <- data.frame()
for (participant in unique(smp1$ID)) {
  subject <- participant
  smp_s <- smp1[smp1$ID==participant, ]
  for (p in unique(smp_s$Problem)) {
    smp_p <- smp_s[smp_s$Problem==p, ]
    problem <- p
    options <- option_map[problem]
    feedback <- smp_p$option
    choice <- ifelse(feedback==out_safe[problem], choice_pairs[problem, 1], choice_pairs[problem, 2])
    outcome <- paste(choice, feedback, sep = ":")
    trial<- smp_p$trial
    decision <- ifelse(smp_p$Choice == 0, choice_pairs[problem, 1], choice_pairs[problem, 2])
    condition <- smp_p$Condition
    note1 <- condition_list[smp_p$Condition-1]
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
ds_final1 <- pd [order(pd$subject), ]
file_name1 <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final1, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

# Study 2
study <-2
smp2 <- d[d$Condition==4, ]
pd2 <- data.frame()
for (participant in unique(smp2$ID)) {
  subject <- participant
  smp_s <- smp2[smp2$ID==participant, ]
  for (p in unique(smp_s$Problem)) {
    smp_p <- smp_s[smp_s$Problem==p, ]
    smp_p <- head(smp_p,20)
    problem <- p
    options <- option_map[problem]
    feedback <- smp_p$option
    choice <- ifelse(feedback==out_safe[problem], choice_pairs[problem, 1], choice_pairs[problem, 2])
    outcome <- paste(choice, feedback, sep = ":")
    trial<- smp_p$trial
    decision <- ifelse(smp_p$Choice == 0, choice_pairs[problem, 1], choice_pairs[problem, 2])
    condition <- smp_p$Condition
    note1 <- condition_list[smp_p$Condition-1]
    sex <- ifelse(smp_p$Gender==0, 'f', 'm')
    age <- smp_p$Age
    # Rest of variables
    response_time<- stage <- education<- note2<- NA
    # Create final dataframe
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, decision, response_time, stage, sex, age, education, note1, note2)
    pd2 <- rbind(pd2, psd)
  }
}

# Combine and save processed data
ds_final2 <- pd2 [order(pd2$subject), ]
file_name2 <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final2, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
