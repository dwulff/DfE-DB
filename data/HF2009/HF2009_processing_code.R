### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Hadar, L., & Fox, C. R. (2009). Information asymmetry in decision from description versus decision from experience. Judgment and Decision Making, 4(4), 317-325.
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "HF2009"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1 only have data for problem 3, 5, 6
# A risky, B safe
option <- LETTERS[1:6]
out_1 <- c(-32, -3,  32, 3, 32, 3)
pr_1 <- c(0.1, 1, 0.1, 1, 0.025, 0.25)
out_2 <- c(0, NA, 0, NA, 0, 0)
pr_2 <- c(0.9, NA, 0.9, NA, 0.975, 0.75)
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
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path", "problem_list")))
# Back to raw data directory
setwd(raw_path)

# study 1
study <-1
# load sampling data
smp<-read.csv('Hadar09_raw_114_115.csv')
option <- LETTERS[1:6]
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
pd <- data.frame()
for (participant in unique(smp$Subject)) {
  subject <- participant
  smp_s <- smp[smp$Subject==participant, ]
  for (p in unique(smp_s$Problem)) {
    smp_p <- smp_s[smp_s$Problem==p, ]
    problem <- p
    options <- option_map[problem]
    feedback <- smp_p$outcome
    choice <- ifelse(smp_p$option==1, choice_pairs[problem, 1], choice_pairs[problem, 2])
    outcome <- paste(choice, feedback, sep = ":")
    trial<- smp_p$trial
    decision <- ifelse(smp_p$Choice==1, choice_pairs[problem, 1], choice_pairs[problem, 2])
    sex <- ifelse(smp_p$Gender ==0, 'f', 'm')
    age <- smp_p$Age
    condition <- ifelse(smp_p$ShowCash==0, ifelse(smp_p$ShowAll==0, 1, 2), ifelse(smp_p$ShowAll==0, 3, 4))
    note1 <- ifelse(smp_p$ShowCash==0, 'event sampling', 'outcome sampling')
    note2 <- ifelse(smp_p$ShowAll==0, 'incomplete information', 'complete information')
    # Rest of variables
    response_time<- stage <-education <-NA
    # Create final dataframe
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, decision, response_time, stage, sex, age, education, note1, note2)
    pd <- rbind(pd, psd)
  }
}


# Combine and save processed data
ds_final <- pd[order(pd$subject, pd$condition, pd$problem, pd$trial), ]
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

