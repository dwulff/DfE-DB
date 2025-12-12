### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Kellen, D., Pachur, T., & Hertwig, R. (2016). How (in) variant are subjective representations of described and experienced risk and rewards?. Cognition, 157, 126-138.
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
if (!requireNamespace("plyr", quietly = TRUE)) install.packages("plyr")
library(plyr)
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "KPH2016"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1 only use data in experience condition
prob_data <- read.table('problems.txt')
prob_data$OutA2 <- ifelse(prob_data$PrbA1==1, NA, prob_data$OutA2)
prob_data$PrbA2 <- ifelse(prob_data$PrbA1==1, NA, prob_data$PrbA2)
prob_data$OutB2 <- ifelse(prob_data$PrbB1==1, NA, prob_data$OutB2)
prob_data$PrbB2 <- ifelse(prob_data$PrbB1==1, NA, prob_data$PrbB2)
prob_data$problem <- seq_len(nrow(prob_data))

# melt options
name_list <- c('out1', 'out2', 'per1', 'per2', 'problem')
combined_columns <- list()
combined_columns[[name_list[1]]] <- as.vector(rbind(prob_data$OutA1, prob_data$OutB1))
combined_columns[[name_list[2]]] <- as.vector(rbind(prob_data$OutA2, prob_data$OutB2))
combined_columns[[name_list[3]]] <- as.vector(rbind(prob_data$PrbA1, prob_data$PrbB1))
combined_columns[[name_list[4]]] <- as.vector(rbind(prob_data$PrbA2, prob_data$PrbB2))
combined_columns[[name_list[5]]] <- as.vector(rbind(prob_data$problem, prob_data$problem))

problems_table <- as.data.frame(combined_columns)

option <- c(LETTERS[1:26], paste0('A', LETTERS[1:26]),  paste0('B', LETTERS[1:26]),  paste0('C', LETTERS[1:26]),  paste0('D', LETTERS[1:26]),  paste0('E', LETTERS[1:26]),  paste0('F', LETTERS[1:26]),  paste0('G', LETTERS[1:26]),  paste0('H', LETTERS[1:20]))
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
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path", "problem_list")))
# Back to raw data directory
setwd(raw_path)

# study 1
study <-1
# load sampling data
files <- list.files(,full.names = T)
dfes <- files[grepl('decFromExp',files)]
smps <- dfes[grepl('res',dfes)]

smp <- lapply(smps, read.table, sep='\t', header=T)
smp <- do.call(rbind,smp)
smp$subject <- sapply(strsplit(as.character(smp$participant), "_"), `[`, 1)

option <- c(LETTERS[1:26], paste0('A', LETTERS[1:26]),  paste0('B', LETTERS[1:26]),  paste0('C', LETTERS[1:26]),  paste0('D', LETTERS[1:26]),  paste0('E', LETTERS[1:26]),  paste0('F', LETTERS[1:26]),  paste0('G', LETTERS[1:26]),  paste0('H', LETTERS[1:20]))
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
pd <- data.frame()
for (participant in unique(smp$subject)) {
  subject <- participant
  smp_s <- smp[smp$subject==participant, ]
  for (p in unique(smp_s$problem)) {
    smp_p <- smp_s[smp_s$problem==p, ]
    ch_p <- smp_p[smp_p$response != -99,]
    smp_p <- smp_p[smp_p$response == -99, ]
    problem <- p
    options <- option_map[problem]
    feedback <- ifelse(grepl("^A", smp_p$SampVal), ifelse(smp_p$SampVal=='A1', smp_p$outcomeA1, smp_p$outcomeA2), ifelse(smp_p$SampVal=='B1', smp_p$outcomeB1, smp_p$outcomeB2))
    choice <- ifelse(grepl("^A", smp_p$SampVal), choice_pairs[problem, 1], choice_pairs[problem, 2])
    outcome <- paste(choice, feedback, sep = ":")
    trial<- seq(nrow(smp_p))
    decision <- ifelse(ch_p$response=='A', choice_pairs[problem, 1], choice_pairs[problem, 2])
    # Rest of variables
    response_time <- sex<-age<- stage <- condition<- note1<-note2<-education <-NA
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
