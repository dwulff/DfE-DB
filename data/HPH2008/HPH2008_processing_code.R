### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Hau, R., Pleskac, T. J., Kiefer, J., & Hertwig, R. (2008). The description–experience gap in risky choice: The role of sample size and experienced probabilities. Journal of Behavioral Decision Making, 21(5), 493-518.
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "HPH2008"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1 only use data in experience condition
prob_data <- read.table('Hau08.ProblemTable_117.0.txt')

# melt options
name_list <- c('out1', 'out2', 'per1', 'per2', 'problem')
combined_columns <- list()
combined_columns[[name_list[1]]] <- as.vector(rbind(prob_data$outA1, prob_data$outB1))
combined_columns[[name_list[2]]] <- as.vector(rbind(prob_data$outA2, prob_data$outB2))
combined_columns[[name_list[3]]] <- as.vector(rbind(prob_data$probA1, prob_data$probB1))
combined_columns[[name_list[4]]] <- as.vector(rbind(prob_data$probA2, prob_data$probB2))
combined_columns[[name_list[5]]] <- as.vector(rbind(prob_data$problem, prob_data$problem))

problems_table <- as.data.frame(combined_columns)

option <- LETTERS[1:12]
out_1 <- problems_table$out1
pr_1 <- problems_table$per1
out_2 <- problems_table$out2
pr_2 <- problems_table$per2
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options
file_name1 <- paste0(paper, "_", "1", "_", "options.csv")
file_name2 <- paste0(paper, "_", "2", "_", "options.csv")
file_name3 <- paste0(paper, "_", "3", "_", "options.csv")

setwd(data_path)
write.table(options_table1, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(options_table1, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(options_table1, file = file_name3, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

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

process_data <- function(smp, ch, study, paper){
  option <- LETTERS[1:12]
  choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
  option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
  pd <- data.frame()
  for (participant in unique(smp$subject)) {
    subject <- participant
    smp_s <- smp[smp$subject==participant, ]
    ch_s <- ch[ch$subject==participant,]
    for (p in unique(smp_s$problem)) {
      smp_p <- smp_s[smp_s$problem==p, ]
      ch_p <- ch_s[ch_s$problem==p,]
      problem <- p
      if(study==2 & subject==4 & problem==6){
        smp_p$option  <- 1-smp_p$option
        ch_p$choice <- 1-ch_p$choice
      }
      options <- option_map[problem]
      feedback <- smp_p$outcome
      choice <- ifelse(smp_p$option==0, choice_pairs[problem, 1], choice_pairs[problem, 2])
      outcome <- paste(choice, feedback, sep = ":")
      trial<- smp_p$trial
      decision <- ifelse(ch_p$choice==0, choice_pairs[problem, 1], choice_pairs[problem, 2])
      # Rest of variables
      response_time <-sex<-age<- stage <- condition<- note1<-note2<-education <-NA
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
# load sampling data
smp<-read.table('Hau08_s1.sampling_117.0.txt')
ch <-read.table('Hau08_s1.choices_117.0.txt')
process_data(smp, ch, 1, paper)

# study 2
# load sampling data
smp<-read.table('Hau08_s2.sampling_118.0.txt')
ch <-read.table('Hau08_s2.choices_118.0.txt')
process_data(smp, ch, 2, paper)

# study 3
# load sampling data
smp<-read.table('Hau08_s3.sampling_119.0.txt')
ch <-read.table('Hau08_s3.choices_119.0.txt')
process_data(smp, ch, 3, paper)
