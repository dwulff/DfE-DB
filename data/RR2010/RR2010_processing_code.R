### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Rakow, T., & B. Rahim, S. (2010). Developmental insights into experience‐based decision making. Journal of Behavioral Decision Making, 23(1), 69-82.
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
if (!requireNamespace("plyr", quietly = TRUE)) install.packages("plyr")
library(plyr)
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "RR2010"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1 only use data in experience condition
# A is risk, B is safe
prob_data <- read.csv('Rakow10_ProblemTable.csv',header = T)
prob_data$OutcomeA.2 <- ifelse(prob_data$ProbA==1, NA, prob_data$OutcomeA.2)
prob_data$ProbA.2 <- ifelse(prob_data$ProbA==1, NA, prob_data$ProbA.2)
prob_data$OutcomeB.2 <- ifelse(prob_data$ProbB==1, NA, prob_data$OutcomeB.2)
prob_data$ProbB.2 <- ifelse(prob_data$ProbB==1, NA, prob_data$ProbB.2)

# melt options
name_list <- c('out1', 'out2', 'per1', 'per2', 'problem')
combined_columns <- list()
combined_columns[[name_list[1]]] <- as.vector(rbind(prob_data$OutcomeA, prob_data$OutcomeB))
combined_columns[[name_list[2]]] <- as.vector(rbind(prob_data$OutcomeA.2, prob_data$OutcomeB.2))
combined_columns[[name_list[3]]] <- as.vector(rbind(prob_data$ProbA, prob_data$ProbB))
combined_columns[[name_list[4]]] <- as.vector(rbind(prob_data$ProbA.2, prob_data$ProbB.2))

problems_table <- as.data.frame(combined_columns)

option <- LETTERS[1:8]
out_1 <- problems_table$out1
pr_1 <- problems_table$per1
out_2 <- problems_table$out2
pr_2 <- problems_table$per2
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)


# Study 2
# A is risk, B is safe

option <- LETTERS[1:12]
out_1 <- c(20, 1, 10, 9, 20, 3, 10, 8, 8, 6, 10, 3)
pr_1 <- c(0.05, 1, 0.9, 1, 0.15, 1, 0.8, 1, 0.75, 1, 0.3, 1)
out_2 <- c(0, NA, 0, NA, 0, NA, 0, NA, 0, NA, 0, NA)
pr_2 <- c(0.95, NA, 0.1, NA, 0.85, NA, 0.2, NA, 0.25, NA, 0.7, NA)
options_table2 <- data.frame(option, out_1, pr_1, out_2, pr_2)


# Study 3
# A is risk, B is safe

prob_data <- read.csv('Exp3/Rakow10_ProblemTable_130.csv',header = T)

# melt options
name_list <- c('out1', 'out2', 'per1', 'per2', 'problem')
combined_columns <- list()
combined_columns[[name_list[1]]] <- as.vector(rbind(prob_data$OutcomeA, prob_data$OutcomeB))
combined_columns[[name_list[2]]] <- as.vector(rbind(prob_data$OutcomeA.2, prob_data$OutcomeB.2))
combined_columns[[name_list[3]]] <- as.vector(rbind(prob_data$ProbA, prob_data$ProbB))
combined_columns[[name_list[4]]] <- as.vector(rbind(prob_data$ProbA.2, prob_data$ProbB.2))
combined_columns[['out1']][5] <- 8 # in choice data, it's 8

problems_table <- as.data.frame(combined_columns)

option <- LETTERS[1:12]
out_1 <- problems_table$out1
pr_1 <- problems_table$per1
out_2 <- problems_table$out2
pr_2 <- problems_table$per2
options_table3 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options
file_name1 <- paste0(paper, "_", "1", "_", "options.csv")
file_name2 <- paste0(paper, "_", "2", "_", "options.csv")
file_name3 <- paste0(paper, "_", "3", "_", "options.csv")

setwd(data_path)
write.table(options_table1, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(options_table2, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(options_table3, file = file_name3, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

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


# function
process_data <- function(smp, study){
  option <- LETTERS[1:12]
  choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
  option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
  pd <- data.frame()
  for (participant in unique(smp$Participant.Number)) {
    subject <- participant
    smp_s <- smp[smp$Participant.Number==subject, ]
    for (p in unique(smp_s$ProblemNumber)) {
      smp_p <- smp_s[smp_s$ProblemNumber==p, ]
      problem <- ifelse(p>6, p-6, p)
      options <- option_map[problem]
      feedback <- smp_p$PointsSeen
      choice <- ifelse(smp_p$OptionSampled==1, choice_pairs[problem, 1], choice_pairs[problem, 2])
      outcome <- paste(choice, feedback, sep = ":")
      trial<- smp_p$TrialNumber
      decision <- ifelse(smp_p$OptionPicked==1, choice_pairs[problem, 1], choice_pairs[problem, 2])
      if('Ppt.Type' %in% colnames(smp_p)){
        condition <- ifelse(smp_p$Ppt.Type==1,ifelse(smp_p$Condition==1, 1, 2), ifelse(smp_p$Condition==1, 3, 4))
        note1<-ifelse(smp_p$Ppt.Type==1, 'Adult', 'Children')
        note2<-ifelse(smp_p$Condition==1, 'Experience first', 'Description first')
      }else{
        condition <- smp_p$Condition
        note1<-ifelse(smp_p$Condition==1, 'Experience first', 'Description first')
        note2<-NA
      }
      # Rest of variables
      response_time <- sex<-age<- stage <-education <-NA
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
  # Back to raw data directory
  setwd(raw_path)
}


# study 1
study <-1
setwd('Exp1/')
# load sampling data
smp1 <- read.table('Rakow10_sampling_128.0.txt', header = T)
smp2 <- read.table('Rakow10_sampling_128.1.txt', header = T)
ch1 <- read.table('Rakow10_choice_128.0.txt', header = T)
ch2 <- read.table('Rakow10_choice_128.1.txt', header = T)
con <- read.table('Rakow10_demo_128.0.txt', header = T)

smp <- rbind(smp1, smp2)
ch <- rbind(ch1, ch2)

option <- LETTERS[1:8]
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")

pd <- data.frame()
for (participant in unique(smp$subject)) {
  subject <- participant
  smp_s <- smp[smp$subject==participant, ]
  ch_s <- ch[ch$subject==participant,]
  con_s <- con[con$subject==participant,]
  for (p in unique(smp_s$problem)) {
    smp_p <- smp_s[smp_s$problem==p, ]
    ch_p <- ch_s[ch_s$problem==p,]
    problem <- p
    options <- option_map[problem]
    feedback <- smp_p$outcome
    choice <- ifelse(smp_p$option==0, choice_pairs[problem, 1], choice_pairs[problem, 2])
    outcome <- paste(choice, feedback, sep = ":")
    trial<- smp_p$trial
    decision <- ifelse(ch_p$choice==0, choice_pairs[problem, 1], choice_pairs[problem, 2])
    if(length(decision)>1){decision <- decision[1]}
    condition <- ifelse(con_s$age=='Children', 1, 2)[1]
    note1<-con_s$age[1]
    # Rest of variables
    response_time <- sex<-age<- stage <-note2<-education <-NA
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
setwd(raw_path)
setwd('Exp2/')
study <- 2
smp1 <- read.csv('R&R Expt 2 Process Master (ADOLESCENTS).csv', skip = 1)
smp2 <- read.csv('R&R Expt 2 Process Master (CHILDREN).csv', skip = 1)
smp <- rbind(smp1, smp2)
process_data(smp, study)


# study 3
setwd(raw_path)
setwd('Exp3/')
study <- 3
smp <- read.csv('Rakow10_choice_129.2.csv')
process_data(smp, study)
