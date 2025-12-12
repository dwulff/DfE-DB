### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Phillips, N. D., Hertwig, R., Kareev, Y., & Avrahami, J. (2014). Rivals in the dark: How competition influences search in decisions under uncertainty. Cognition, 133(1), 104-119.
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
if (!requireNamespace("plyr", quietly = TRUE)) install.packages("plyr")
library(plyr)
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
library(dplyr)
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "PHKA2014"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1 A safe, B risky
prob_data <- read.table('Phillips et al 2014 Gambles.txt')
prob_data$str <- paste(prob_data$Option.0.x1,prob_data$Option.0.px1, prob_data$Option.0.x2,prob_data$Option.0.px2, prob_data$Option.1.x1,prob_data$Option.1.px1, prob_data$Option.1.x2,prob_data$Option.1.px2, sep = '_')
prob_data <- prob_data[!duplicated(prob_data$str),]
prob_data$problem <- seq(1:nrow(prob_data))

# melt options
name_list <- c('out1', 'out2', 'per1', 'per2', 'problem','exp')
combined_columns <- list()
combined_columns[[name_list[1]]] <- as.vector(rbind(prob_data$Option.0.x1, prob_data$Option.1.x1))
combined_columns[[name_list[2]]] <- as.vector(rbind(prob_data$Option.0.x2, prob_data$Option.1.x2))
combined_columns[[name_list[3]]] <- as.vector(rbind(prob_data$Option.0.px1, prob_data$Option.1.px1))
combined_columns[[name_list[4]]] <- as.vector(rbind(prob_data$Option.0.px2, prob_data$Option.1.px2))
combined_columns[[name_list[5]]] <- as.vector(rbind(prob_data$problem, prob_data$problem))
combined_columns[[name_list[6]]] <- as.vector(rbind(prob_data$Experiment, prob_data$Experiment))

problems_table <- as.data.frame(combined_columns)
problems_table <- problems_table[order(problems_table$problem),]
problem_list <- unique(problems_table$problem)
option <- c(LETTERS[1:26], paste0('A', LETTERS[1:14]))
out_1 <- problems_table$out1
pr_1 <- problems_table$per1
out_2 <- problems_table$out2
pr_2 <- problems_table$per2
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
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path", 'prob_data')))
# Back to raw data directory
setwd(raw_path)

# study 1
study <-1
option <- c(LETTERS[1:26], paste0('A', LETTERS[1:26]), paste0('B', LETTERS[1:26]), paste0('C', LETTERS[1:26]), paste0('D', LETTERS[1:16]))
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
# read data
smp1 <- read.table('Phillips et al 2014 Solitary Trial Data.txt',header = T)
smp1$subject <- smp1$SessionID
smp1$Choice <- smp1$Choice.First
smp2 <- read.table('Phillips et al 2014 Competition Trial Data.txt', header = T)
smp2$subject <- paste(smp2$SessionID,smp2$PlayerID.Session,sep = '_')

process_data <- function(smp,con, study){
  pd <- data.frame()
  smp$str <- paste(smp$Urn.0.x1,smp$Urn.0.px1, smp$Urn.0.x2, smp$Urn.0.px2, smp$Urn.1.x1, smp$Urn.1.px1, smp$Urn.1.x2, smp$Urn.1.p.x2, sep = '_')
  smp$problem <- prob_data$problem[match(smp$str, prob_data$str)]
  for (participant in unique(smp$subject)) {
    subject <- participant
    smp_s <- smp[smp$subject==participant, ]
    for (p in unique(smp_s$problem)) {
      smp_p <- smp_s[smp_s$problem==p, ]
      ch_p <- smp_p[smp_p$Inspect.Option==-99,]
      smp_p <- smp_p[smp_p$Inspect.Option!=-99,]
      problem <- p
      options <- option_map[problem]
      feedback <- smp_p$Inspect.Value
      choice <- ifelse(smp_p$Inspect.Option==0, choice_pairs[problem, 1], choice_pairs[problem, 2])
      outcome <- paste(choice, feedback, sep = ":")
      trial<- seq(length(feedback))
      decision <- ifelse(ch_p$Choice==0, choice_pairs[problem, 1], choice_pairs[problem, 2])
      if(length(decision)>1){decision=decision[1]}
      condition<- con
      note1<-ifelse(con==1, 'solitary', 'competition')
      # Rest of variables
      response_time <- stage <-note2<-sex<-age<-education <-NA
      # Create final dataframe
      psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, decision, response_time, stage, sex, age, education, note1, note2)
      pd <- rbind(pd, psd)
    }
  } 
  return(pd)
}

# process data
pd1 <- process_data(smp1, 1, study)
pd2 <- process_data(smp2, 2, study)
pd <- rbind(pd1, pd2)

# Combine and save processed data
ds_final <- pd[order(pd$subject, pd$condition, pd$problem, pd$trial), ]
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
