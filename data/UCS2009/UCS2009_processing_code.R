### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Ungemach, C., Chater, N., & Stewart, N. (2009). Are probabilities overweighted or underweighted when rare outcomes are experienced (rarely)?. Psychological Science, 20(4), 473-479.
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
if (!requireNamespace("plyr", quietly = TRUE)) install.packages("plyr")
library(plyr)
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "UCS2009"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1 only use data in experience condition
option <- LETTERS[1:12]
out_1 <- c(4, 3, 4, 3, -3, -32, -3, -4, 32, 3, 32, 3)
pr_1 <- c(0.8, 1, 0.2, 0.25, 1, 0.1, 1, 0.8, 0.1, 1, 0.025, 0.25)
out_2 <- c(0, NA, 0, 0, NA, 0, NA, 0, 0, NA, 0, 0)
pr_2 <- c(0.2, NA, 0.8, 0.75, NA, 0.9, NA, 0.2, 0.9, NA, 0.975, 0.75)
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Study 2
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
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)


# function
process_data <- function(smp, study){
  option <- LETTERS[1:12]
  choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
  option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
  condition_list <- unique(smp$condition)
  pd <- data.frame()
  for (participant in unique(smp$sub_nr)) {
    subject <- participant
    smp_s <- smp[smp$sub_nr==participant, ]
    for (p in unique(smp_s$problem_nr)) {
      smp_p <- smp_s[smp_s$problem_nr==p, ]
      problem <- p
      options <- option_map[problem]
      feedback <- unlist(strsplit(smp_p$outcomes, split = ','))
      choice_list <- unlist(strsplit(smp_p$buttons, split = ','))
      if(length(feedback)>80){
        feedback <- feedback[1:80]
        choice_list <- choice_list[1:80]}
      if(smp_p$rev==0){
        choice <- ifelse(choice_list=='A', choice_pairs[problem, 1], choice_pairs[problem, 2])
        decision <- ifelse(smp_p$choice=='A', choice_pairs[problem, 1], choice_pairs[problem, 2])
      } else{
        choice <- ifelse(choice_list=='B', choice_pairs[problem, 1], choice_pairs[problem, 2])
        decision <- ifelse(smp_p$choice=='B', choice_pairs[problem, 1], choice_pairs[problem, 2])
      }
      outcome <- paste(choice, feedback, sep = ":")
      trial<- seq(length(choice))
      condition <- match(smp_p$condition, condition_list)
      note1<-smp_p$condition
      sex<- ifelse(smp_p$sex=='female', 'f', 'm')
      age<- smp_p$age
      # Rest of variables
      response_time <- stage <-note2<-education <-NA
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
# study 1
study <-1
# load sampling data
smp <- read.csv('data_exp1_n.csv')
process_data(smp, study)

#study 2
study <-2
# load sampling data
smp <- read.csv('data_exp2.csv')
names(smp)[names(smp) == "id"] <- "sub_nr"
process_data(smp, study)
