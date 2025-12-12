### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Wulff, D. U., Hills, T. T., & Hertwig, R. (2015). How short-and long-run aspirations impact search and choice in decisions from experience. Cognition, 144, 29-37.
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
if (!requireNamespace("haven", quietly = TRUE)) install.packages("haven")
library(haven)
if (!requireNamespace("plyr", quietly = TRUE)) install.packages("plyr")
library(plyr)
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
library(dplyr)

path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "WHH2015b"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1
pro <- read.table('Problems.txt', header = T)
pro$outA2 <- ifelse(pro$probA1==1, NA, pro$outA2)
pro$probA2 <- ifelse(pro$probA1==1, NA, pro$probA2)
pro$outB2 <- ifelse(pro$probB1==1, NA, pro$outB2)
pro$probB2 <- ifelse(pro$probB1==1, NA, pro$probB2)
#create problem table
# melt table
name_list <- c('out1', 'out2', 'per1', 'per2','problem')
combined_columns <- list()
combined_columns[[name_list[1]]] <- as.vector(rbind(pro$outA1, pro$outB1))
combined_columns[[name_list[2]]] <- as.vector(rbind(pro$outA2, pro$outB2))
combined_columns[[name_list[3]]] <- as.vector(rbind(pro$probA1, pro$probB1))
combined_columns[[name_list[4]]] <- as.vector(rbind(pro$probA2, pro$probB2))
combined_columns[[name_list[5]]] <- as.vector(rbind(pro$problem, pro$problem))
problems_table <- as.data.frame(combined_columns)


option <- c(LETTERS[1:26], paste0('A',LETTERS[1:6]))
out_1 <- problems_table$out1
pr_1 <- problems_table$per1
out_2 <- problems_table$out2
pr_2 <- problems_table$per2
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)


# Study 1 standard condition
out_1 <- out_1 * 6
out_2 <- out_2 * 6
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
  option <- c(LETTERS[1:26], paste0('A',LETTERS[1:6]))
  choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
  option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
  pd <- data.frame()
  for (participant in unique(smp$subject)) {
    subject <- participant
    smp_s <- smp[smp$subject==participant, ]
    for (p in unique(smp_s$problem)) {
      smp_p <- smp_s[smp_s$problem==p, ]
      problem <- p
      options <- option_map[problem]
      feedback <- smp_p$outcome
      choice <- ifelse(smp_p$option==1, choice_pairs[problem, 1], choice_pairs[problem, 2])
      outcome <- ifelse(is.na(feedback), NA, paste(choice, feedback, sep = ":"))
      trial<- seq(length(choice))
      decision <- ifelse(smp_p$choice==1, choice_pairs[problem, 1], choice_pairs[problem, 2])
      sex<- ifelse(smp_p$sex=='female', 'f', 'm')
      age<- smp_p$age
      condition <-smp_p$condition
      # Rest of variables
      response_time <- stage <-education <- note1<-note2<-NA
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
smp <- read.table('Full DfE table.txt',header = T)
smp1 <- smp[smp$condition!=1,]
process_data(smp1,study)

#study 2 (study 1 sdandard condition)
study <- 2
smp2 <- smp[smp$condition==1,]
process_data(smp2,study)