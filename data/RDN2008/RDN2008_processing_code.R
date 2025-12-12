### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Rakow, T., Demes, K. A., & Newell, B. R. (2008). Biased samples not mode of presentation: Re-examining the apparent underweighting of rare events in experience-based choice. Organizational Behavior and Human Decision Processes, 106(2), 168-179.
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
if (!requireNamespace("plyr", quietly = TRUE)) install.packages("plyr")
library(plyr)
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
library(dplyr)
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "RDN2008"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1 A risky, B safe
# Study 1 only use data in experience condition
prob_data <- read.csv('Rakow08_ProblemTable.csv')
prob_data$OutcomeA2 <- ifelse(prob_data$ProbA==1, NA, 0)
prob_data$ProbA2 <- ifelse(prob_data$ProbA==1, NA, 1-prob_data$ProbA)
prob_data$OutcomeB2 <- ifelse(prob_data$ProbB==1, NA, 0)
prob_data$ProbB2 <- ifelse(prob_data$ProbB==1, NA, 1-prob_data$ProbB)

# melt options
name_list <- c('out1', 'out2', 'per1', 'per2', 'problem')
combined_columns <- list()
combined_columns[[name_list[1]]] <- as.vector(rbind(prob_data$OutcomeA, prob_data$OutcomeB))
combined_columns[[name_list[2]]] <- as.vector(rbind(prob_data$OutcomeA2, prob_data$OutcomeB2))
combined_columns[[name_list[3]]] <- as.vector(rbind(prob_data$ProbA, prob_data$ProbB))
combined_columns[[name_list[4]]] <- as.vector(rbind(prob_data$ProbA2, prob_data$ProbB2))
combined_columns[[name_list[5]]] <- as.vector(rbind(prob_data$ProblemID, prob_data$ProblemID))

problems_table <- as.data.frame(combined_columns)

option <- LETTERS[1:24]
out_1 <- problems_table$out1
pr_1 <- problems_table$per1
out_2 <- problems_table$out2
pr_2 <- problems_table$per2
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options
file_name1 <- paste0(paper, "_", "1", "_", "options.csv")
setwd(data_path)
write.table(options_table1, file = file_name1, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")

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

#function
process_data <- function(smp, dem, study){
  pd <- data.frame()
  for (participant in unique(smp$Participant.Number.)) {
    subject <- participant
    smp_s <- smp[smp$Participant.Number.==participant, ]
    dem_s <- dem[dem$No....1==participant,]
    for (p in unique(smp_s$ProblemNumber)) {
      smp_p <- smp_s[smp_s$ProblemNumber==p, ]
      problem <- p
      options <- option_map[problem]
      feedback <- smp_p$PointsSeen
      choice <- ifelse(smp_p$OptionSampled==1, choice_pairs[problem, 1], choice_pairs[problem, 2])
      outcome <- paste(choice, feedback, sep = ":")
      trial<- smp_p$TrialNumber
      decision <- ifelse(smp_p$OptionPicked==1, choice_pairs[problem, 1], choice_pairs[problem, 2])
      sex<-ifelse(dem_s$Sex=='F', 'f', 'm')
      age<-dem_s$Age
      # Rest of variables
      note1<-note2<-response_time <- condition<- stage <- education <-NA
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
}

# study 1
study <-1
#read data
smp <- read.table('Rakow08_raw_131.txt', header = T)
dem <- read_excel('Rakow et al (2008) Process Copy for Dirk Wulff/Rakow-Demes-Newell (2008) ppt demography.xls')
option <- LETTERS[1:24]
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
# process
process_data(smp, dem, study)
