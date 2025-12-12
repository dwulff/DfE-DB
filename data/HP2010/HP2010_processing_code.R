### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Hertwig, R., & Pleskac, T. J. (2010). Decisions from experience: Why small samples?. Cognition, 115(2), 225-237.
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "HP2010"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1 only use data in experience condition
prob_data <- read.csv('Hertwig & Pleskac (2010).csv',sep = ';')
prob_data$OutcomeH2 <- ifelse(prob_data$probH==1, NA, 0)
prob_data$probH2 <- ifelse(prob_data$probH==1, NA, 1-prob_data$probH)
prob_data$OutcomeL2 <- ifelse(prob_data$probL==1, NA, 0)
prob_data$probL2 <- ifelse(prob_data$probL==1, NA, 1-prob_data$probL)
outcomeh <- prob_data$OutcomeH
# melt options
name_list <- c('out1', 'out2', 'per1', 'per2', 'problem')
combined_columns <- list()
combined_columns[[name_list[1]]] <- as.vector(rbind(prob_data$OutcomeH, prob_data$OutcomeL))
combined_columns[[name_list[2]]] <- as.vector(rbind(prob_data$OutcomeH2, prob_data$OutcomeL2))
combined_columns[[name_list[3]]] <- as.vector(rbind(prob_data$probH, prob_data$probL))
combined_columns[[name_list[4]]] <- as.vector(rbind(prob_data$probH2, prob_data$probL2))
combined_columns[[name_list[5]]] <- as.vector(rbind(prob_data$Problem, prob_data$Problem))

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
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path", "outcomeh")))
# Back to raw data directory
setwd(raw_path)

# study 1
study <-1
# load sampling data
smp<-read.table('Hertwig.Pleskac10_s1.raw.txt', header = TRUE, sep = '\t', fill = TRUE)
names(smp)[names(smp) == "ChoiceResp..q...Choose.A..p...choose.B."] <- "ChoiceResp"
option <- LETTERS[1:24]
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
pd <- data.frame()
for (participant in unique(smp$Subject)) {
  subject <- participant
  smp_s <- smp[smp$Subject==participant, ]
  for (p in unique(smp_s$MoneyList)) {
    smp_p <- smp_s[smp_s$MoneyList==p, ]
    smp_p <- smp_p[smp_p$SamplingMoney.RESP != '{SPACE}', ]
    problem <- p
    smp_p$reverse <- ifelse(smp_p$OutcomeA1 %in% outcomeh, 0, 1)
    options <- option_map[problem]
    feedback <- smp_p$Stim
    choice <- ifelse(smp_p$reverse==0, ifelse(smp_p$SamplingMoney.RESP=='q', choice_pairs[problem, 1], choice_pairs[problem, 2]),ifelse(smp_p$SamplingMoney.RESP=='q', choice_pairs[problem, 2], choice_pairs[problem, 1]))
    outcome <- paste(choice, feedback, sep = ":")
    trial<- smp_p$Trial
    decision <- ifelse(smp_p$reverse==0, ifelse(smp_p$ChoiceResp=='q', choice_pairs[problem, 1], choice_pairs[problem, 2]),ifelse(smp_p$ChoiceResp=='q', choice_pairs[problem, 2], choice_pairs[problem, 1]))
    response_time <- smp_p$SamplingMoney.RT
    # Rest of variables
    sex<-age<- stage <- condition<- note1<-note2<-education <-NA
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
