### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Lejarraga, T. (2010). When experience is better than description: Time delays and complexity. Journal of Behavioral Decision Making, 23(1), 100-116.
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "L2010"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 2 only use data in experience condition
prob_data <- read_excel('Lejarraga (2010) Exp2.xls')
prob_data$OutcomeA2 <- ifelse(prob_data$ProbA==1, NA, 0)
prob_data$ProbA2 <- ifelse(prob_data$ProbA==1, NA, 1 - prob_data$ProbA)
prob_data$OutcomeB2 <- ifelse(prob_data$ProbB==1, NA, 0)
prob_data$ProbB2 <- ifelse(prob_data$ProbB==1, NA, 1-prob_data$ProbB)

# melt options
name_list <- c('out1', 'out2', 'per1', 'per2', 'problem')
combined_columns <- list()
combined_columns[[name_list[1]]] <- as.vector(rbind(prob_data$OutcomeA, prob_data$OutcomeB))
combined_columns[[name_list[2]]] <- as.vector(rbind(prob_data$OutcomeA2, prob_data$OutcomeB2))
combined_columns[[name_list[3]]] <- as.vector(rbind(prob_data$ProbA, prob_data$ProbB))
combined_columns[[name_list[4]]] <- as.vector(rbind(prob_data$ProbA2, prob_data$ProbB2))
combined_columns[[name_list[5]]] <- as.vector(rbind(prob_data$ProblemId, prob_data$ProblemId))

problems_table <- as.data.frame(combined_columns)

option <- LETTERS[1:14]
out_1 <- problems_table$out1
pr_1 <- problems_table$per1
out_2 <- problems_table$out2
pr_2 <- problems_table$per2
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options
file_name2 <- paste0(paper, "_", "2", "_", "options.csv")

setwd(data_path)
write.table(options_table1, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

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

process_data <- function(smp, ch, study, paper){
  option <- LETTERS[1:14]
  choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
  option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
  condition_list <- c('1 stage', '2 stages', '3 stages')
  pd <- data.frame()
  for (participant in unique(smp$SubjectId)) {
    subject <- participant
    smp_s <- smp[smp$SubjectId==participant, ]
    ch_s <- ch[ch$SubjectId==participant,]
    ch_s <- as.vector(unlist(ch_s[, paste0("Problem", 1:7)]))
    
    for (p in unique(smp_s$ProblemId)) {
      smp_p <- smp_s[smp_s$ProblemId==p, ]
      ch_p <- ch_s[p]
      problem <- p
      options <- option_map[problem]
      feedback <- smp_p$Outcome
      choice <- ifelse(smp_p$Option==1, choice_pairs[problem, 1], choice_pairs[problem, 2])
      outcome <- paste(choice, feedback, sep = ":")
      trial<- smp_p$TrialId
      decision <- ifelse(ch_p=='a', choice_pairs[problem, 1], choice_pairs[problem, 2])
      condition<- smp_p$LotteryType
      note1<- condition_list[condition]
      # Rest of variables
      response_time <-sex<-age<- stage <- note2<-education <-NA
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
  setwd(raw_path)
}

# study 2
# load sampling data
smp<-read.csv('Lejarraga (2010) Exp2 - Sampling.csv',sep = ';')
smp$Outcome <- as.numeric(gsub(",", ".", smp$Outcome))
ch <-read.csv('Lejarraga (2010) Exp2 - Choice.csv',sep = ';')
process_data(smp, ch, 2, paper)

