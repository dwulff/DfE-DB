### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Lejarraga, T., Pachur, T., Frey, R., & Hertwig, R. (2016). Decisions from experience: From monetary to medical gambles. Journal of Behavioral Decision Making, 29(1), 67-77.
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "LPFH2016"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1 only use data in experience condition
option <- LETTERS[1:18]
out_1 <- c('Flatulence', 'Hallucinations', 'Fatigue', 'Memory loss', 'Itching', 'Depression', 'Fever','Hallucinations', 'Insomnia', 'Depression', 'Lalopathy', 'Memory loss', 'Fatigue', 'Dizziness', 'Itching', 'Trembling', 'Flatulence', 'Diarrhea')
pr_1 <- c(1, 0.25, 0.9, 0.25, 0.7, 0.25, 0.4, 0.2, 0.55, 0.3, 0.3, 0.2, 0.7, 0.3, 0.6, 0.5, 0.7, 0.4)
out_2 <- rep('Nothing', 18)
pr_2 <- c(NA, 0.75, 0.1, 0.75, 0.3, 0.75, 0.6, 0.8, 0.45, 0.7, 0.3, 0.8, 0.3, 0.7, 0.4, 0.5, 0.3, 0.6)
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
smp <- read.table('FullSamplingDatabase.txt',header=T,sep='\t')
option <- LETTERS[1:18]
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
pd <- data.frame()
for (participant in unique(smp$Subject)) {
  subject <- participant
  smp_s <- smp[smp$Subject==participant, ]
  for (p in unique(smp_s$Gambel_ID)) {
    smp_p <- smp_s[smp_s$Gambel_ID==p, ]
    problem <- p
    options <- option_map[problem]
    feedback <- smp_p$Sampling_Stimuli
    choice <- ifelse(smp_p$Sampling_Response==1, choice_pairs[problem, 1], choice_pairs[problem, 2])
    outcome <- paste(choice, feedback, sep = ":")
    trial<- smp_p$Sampling_Frequency
    decision <- ifelse(smp_p$Decision=='q', choice_pairs[problem, 1], choice_pairs[problem, 2])
    sex<-ifelse(smp_p$Sex=='weiblich', 'f','m')
    age<- smp_p$Age
    condition <- ifelse(smp_p$Condition=='Medical', 1, 2)
    note1<- smp_p$Condition
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
