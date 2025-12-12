### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Gonzalez, C., & Mehlhorn, K. (2016). Framing from experience: Cognitive processes and predictions of risky choice. Cognitive science, 40(5), 1163-1191.
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "GM2016"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1 only use data in comedy and denstry condition
# A Safe, B Risky
option <- LETTERS[1:4]
out_1 <- c(200, 600, -400, 0)
pr_1 <- c(1, 0.333, 1, 0.333)
out_2 <- c(NA, 0, NA, -600)
pr_2 <- c(NA, 0.667, NA, 0.667)
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Study 2, read options from different table
# A Safe, B Risky
option <- LETTERS[1:8]
out_1 <- c(200, 600, -400, 0, 100, 600, -500, 0)
pr_1 <- c(1, 0.333, 1, 0.333, 1, 0.167, 1, 0.167)
out_2 <- c(NA, 0, NA, -600, NA, 0, NA, -600)
pr_2 <- c(NA, 0.667, NA, 0.667, NA, 0.833, NA, 0.833)
options_table2 <- data.frame(option, out_1, pr_1, out_2, pr_2)
# Save options
file_name1 <- paste0(paper, "_", "1", "_", "options.csv")
file_name2 <- paste0(paper, "_", "2", "_", "options.csv")
setwd(data_path)
write.table(options_table1, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(options_table2, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

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
smp<-read.csv('DFE_Framing.csv')
option <- LETTERS[1:4]
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
pd <- data.frame()
for (participant in unique(smp$pp)) {
  subject <- participant
  smp_s <- smp[smp$pp==participant, ]
  for (p in unique(smp_s$Domain)) {
    smp_p <- smp_s[smp_s$Domain==p, ]
    problem <- ifelse(p=='G',1,2)
    condition<- ifelse(p=='G',1,2)
    note1<- ifelse(p=='G', 'Gain', 'Loss')
    options <- option_map[problem]
    feedback <- smp_p$SampleOutcome
    choice <- ifelse(smp_p$RiskySamplestring=='S', choice_pairs[problem, 1], choice_pairs[problem, 2])
    outcome <- paste(choice, feedback, sep = ":")
    trial<- smp_p$trialNum
    decision <- ifelse(smp_p$Riskychoicestring=='S', choice_pairs[problem, 1], choice_pairs[problem, 2])
    sex <- ifelse(smp_p$GENDER =='F', 'f', 'm')
    age <- smp_p$AGE
    # Rest of variables
    response_time<- stage <- note2<-education <-NA
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



# study 2
# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path", "problem_list")))
# Back to raw data directory
setwd(raw_path)
study <-2
# load sampling data
smp2 <- read.csv('Exp2_Framing.csv')
condition_list <- c('HighP Gains 100', 'HighP Gains 5', 'HighP Losses 100', 'HighP Losses 5', 'LowP Gains 100','LowP Gains 5', 'LowP Losses 100', 'LowP Losses 5' )
smp2$problem <- ifelse(smp2$condition %in%condition_list[1:4], ifelse(smp2$condition %in% condition_list[1:2], 1, 2), ifelse(smp2$condition %in% condition_list[5:6], 3, 4))
# options
option <- LETTERS[1:8]
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
pd <- data.frame()
for (participant in unique(smp2$pp)) {
  subject <- participant
  smp_s <- smp2[smp2$pp==participant, ]
  for (p in unique(smp_s$problem)) {
    smp_p <- smp_s[smp_s$problem==p, ]
    problem <- p
    options <- option_map[problem]
    feedback <- smp_p$SampleOutcome
    choice <- ifelse(smp_p$RiskySamplestring=='S', choice_pairs[problem, 1], choice_pairs[problem, 2])
    outcome <- paste(choice, feedback, sep = ":")
    trial<- smp_p$trialNum
    decision <- ifelse(smp_p$Riskychoicestring=='S', choice_pairs[problem, 1], choice_pairs[problem, 2])
    condition <- match(smp_p$condition, condition_list)
    note1 <- smp_p$condition
    sex <- ifelse(smp_p$sex =='female', 'f', 'm')
    age <- smp_p$age
    # Rest of variables
    response_time<-education <- stage <- note2 <- NA
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
