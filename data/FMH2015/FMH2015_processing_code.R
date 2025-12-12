### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Frey, R., Mata, R., & Hertwig, R. (2015). The role of cognitive abilities in decisions from experience: Age differences emerge as a function of choice set size. Cognition, 142, 60-80.
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "FMH2015"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1 only use data in comedy and denstry condition
# A High, B Low
option <- LETTERS[1:24]
out_1 <- c(4, 3, -3, -4, 4, 3, -3, -4, 32, 3, -3, -32, 32, 3, -3, -32, 6, 0.5, -0.5, -6, 13, 0.9, -0.9, -13)
pr_1 <- c(0.8, 1, 1, 0.8, 0.2, 0.25, 0.25, 0.2, 0.1, 1, 0.1, 0.1, 0.025, 0.25, 0.25, 0.025, 0.15, 0.75, 0.75, 0.15, 0.15, 0.7, 0.7, 0.15)
out_2 <- c(0, NA, NA, 0, 0, 0, 0, 0, 0, NA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
pr_2 <- c(0.2, NA, NA, 0.2, 0.8, 0.75, 0.75, 0.8, 0.9, NA, 0.9, 0.9, 0.975, 0.75, 0.75, 0.975, 0.85, 0.25, 0.25, 0.85, 0.85, 0.3, 0.3, 0.85)
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Study 2, read options from different table
option_H <- read.csv('problems_h.csv')
option_L <- read.csv('problems_l.csv')
data <- read.csv('Exp2.csv')
problem_list <- unique(data$problem)

option_H$cat <- 'H'
option_L$cat <- 'L'
problems_table <- rbind(option_H, option_L)
problem_list1 <- unique(data$gamble_lab)
problems_table <- problems_table[problems_table$problem %in% problem_list1, ]
problems_table <- problems_table[order(problems_table$problem, problems_table$cat), ]
problem_list <- unique(problems_table$problem)
option <- c(LETTERS[1:26], paste0('A', LETTERS[1:26]), paste0('B', LETTERS[1:26]), paste0('C', LETTERS[1:26]), paste0('D', LETTERS[1:26]), paste0('E', LETTERS[1:26]), paste0('F', LETTERS[1:26]), paste0('G', LETTERS[1:26]), paste0('H', LETTERS[1:26]),  paste0('I', LETTERS[1:26]),  paste0('J', LETTERS[1:4]))
out_1 <- problems_table$x1
pr_1 <- problems_table$p1
out_2 <- problems_table$x2
pr_2 <- problems_table$p2
out_3 <- problems_table$x3
pr_3 <- problems_table$p3
options_table2 <- data.frame(option, out_1, pr_1, out_2, pr_2, out_3, pr_3)

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
smp<-read.csv('DfE_Aging_Labstudy.csv')
option <- LETTERS[1:24]
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
pd <- data.frame()
for (participant in unique(smp$Subject)) {
  subject <- participant
  smp_s <- smp[smp$Subject==participant, ]
  for (p in unique(smp_s$Problem)) {
    smp_p <- smp_s[smp_s$Problem==p, ]
    ch_p <- smp_p[is.na(smp_p$Observed), ]
    smp_p <- smp_p[!is.na(smp_p$Observed), ]
    problem <- p
    options <- option_map[problem]
    feedback <- smp_p$Observed
    choice <- ifelse(smp_p$OptionSampled=='q', choice_pairs[problem, 1], choice_pairs[problem, 2])
    outcome <- paste(choice, feedback, sep = ":")
    trial<- smp_p$Sample
    decision <- ifelse(ch_p$Choice=='q', choice_pairs[problem, 1], choice_pairs[problem, 2])
    if (length(decision) > 1){
      decision <- decision[1]
    }
    # Rest of variables
    response_time<- stage <- condition<- note1<-note2<-sex<-age<-education <-NA
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
smp2 <- read.csv('Exp2.csv')
smp2 <- smp2[smp2$sample_ind!=0,]
condition_list <- c("old", "yng")
# options
option <- c(LETTERS[1:26], paste0('A', LETTERS[1:26]), paste0('B', LETTERS[1:26]), paste0('C', LETTERS[1:26]), paste0('D', LETTERS[1:26]), paste0('E', LETTERS[1:26]), paste0('F', LETTERS[1:26]), paste0('G', LETTERS[1:26]), paste0('H', LETTERS[1:26]),  paste0('I', LETTERS[1:26]),  paste0('J', LETTERS[1:4]))
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
pd <- data.frame()
for (participant in unique(smp2$partid)) {
  subject <- participant
  smp_s <- smp2[smp2$partid==participant, ]
  for (p in unique(smp_s$gamble_lab)) {
    smp_p <- smp_s[smp_s$gamble_lab==p, ]
    problem <- match(p, problem_list)
    options <- option_map[problem]
    feedback <- smp_p$sample_out
    choice <- ifelse(smp_p$sample_opt=='H', choice_pairs[problem, 1], choice_pairs[problem, 2])
    outcome <- paste(choice, feedback, sep = ":")
    trial<- smp_p$sample_ind
    decision <- ifelse(smp_p$decision=='H', choice_pairs[problem, 1], choice_pairs[problem, 2])
    condition <- match(smp_p$group, condition_list)
    note1 <- smp_p$group
    # Rest of variables
    response_time<- sex<-age<-education <- stage <- note2 <- NA
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
