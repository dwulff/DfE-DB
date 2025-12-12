### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Mehlhorn, K., Ben‐Asher, N., Dutt, V., & Gonzalez, C. (2014). Observed variability and values matter: Toward a better understanding of information search and decisions from experience. Journal of Behavioral Decision Making, 27(4), 328-339.
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
if (!requireNamespace("plyr", quietly = TRUE)) install.packages("plyr")
library(plyr)
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
library(dplyr)
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "MBDG2014"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1 A safe, B risky
smp <- read.csv('prepared_Exp3.csv')
prob_data <- smp %>%
  distinct(problem, .keep_all = TRUE)

prob_data$PrbA1 <- rep(1, nrow(prob_data))
prob_data$OutA2 <- rep(NA, nrow(prob_data))
prob_data$PrbA2 <- rep(NA, nrow(prob_data))
prob_data$OutB2 <- ifelse(prob_data$pH==1, NA, 0)
prob_data$PrbB2 <- ifelse(prob_data$pH==1, NA, 1-prob_data$pH)

# melt options
name_list <- c('out1', 'out2', 'per1', 'per2', 'problem')
combined_columns <- list()
combined_columns[[name_list[1]]] <- as.vector(rbind(prob_data$PayoffSafe, prob_data$PayoffRisky))
combined_columns[[name_list[2]]] <- as.vector(rbind(prob_data$OutA2, prob_data$OutB2))
combined_columns[[name_list[3]]] <- as.vector(rbind(prob_data$PrbA1, prob_data$pH))
combined_columns[[name_list[4]]] <- as.vector(rbind(prob_data$PrbA2, prob_data$PrbB2))
combined_columns[[name_list[5]]] <- as.vector(rbind(prob_data$problem, prob_data$problem))

problems_table <- as.data.frame(combined_columns)
problems_table <- problems_table[order(problems_table$problem),]
problem_list <- unique(problems_table$problem)
option <- c(LETTERS[1:26], paste0('A', LETTERS[1:6]))
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
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path", "problem_list", "smp")))
# Back to raw data directory
setwd(raw_path)

# study 1
study <-1
option <- c(LETTERS[1:26], paste0('A', LETTERS[1:6]))
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
pd <- data.frame()
for (participant in unique(smp$Subject)) {
  subject <- participant
  smp_s <- smp[smp$Subject==participant, ]
  for (p in unique(smp_s$problem)) {
    smp_p <- smp_s[smp_s$problem==p, ]
    ch_p <- smp_p[smp_p$phase=='d',]
    smp_p <- smp_p[smp_p$phase=='s', ]
    problem <- match(p, problem_list)
    options <- option_map[problem]
    feedback <- smp_p$PayoffObserved
    choice <- ifelse(smp_p$RiskyChoice==0, choice_pairs[problem, 1], choice_pairs[problem, 2])
    outcome <- paste(choice, feedback, sep = ":")
    trial<- smp_p$Sample
    decision <- ifelse(ch_p$RiskyChoice==0, choice_pairs[problem, 1], choice_pairs[problem, 2])
    sex<-ifelse(smp_p$gender=='F','f','m')
    age<- smp_p$age
    # Rest of variables
    response_time <- stage <- condition<- note1<-note2<-education <-NA
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
