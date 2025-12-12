### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Glöckner, A., Fiedler, S., Hochman, G., Ayal, S., & Hilbig, B. E. (2012). Processing differences between descriptions and experience: A comparative analysis using eye-tracking and physiological measures. Frontiers in psychology, 3, 173.
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
install.packages("dplyr")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
library(dplyr)
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "GFHA2012"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1 only use data in comedy and denstry condition
data <- read.csv('EB1 choices + sampling.csv')
prob_data <- data[data$subj==3,]
prob_data <- prob_data[order(prob_data$shuffled_trial),]
lefteur <- prob_data$lefteur1

problem_list <- unique(prob_data$shuffled_trial)

# melt table
name_list <- c('eur1', 'eur2', 'per1', 'per2', 'problem')
combined_columns <- list()
combined_columns[[name_list[1]]] <- as.vector(rbind(prob_data$lefteur1, prob_data$righteur1))
combined_columns[[name_list[2]]] <- as.vector(rbind(prob_data$lefteur2, prob_data$righteur2))
combined_columns[[name_list[3]]] <- as.vector(rbind(prob_data$leftper1, prob_data$rightper1))
combined_columns[[name_list[4]]] <- as.vector(rbind(prob_data$leftper2, prob_data$rightper2))
combined_columns[[name_list[5]]] <- as.vector(rbind(prob_data$shuffled_trial, prob_data$shuffled_trial))

problems_table <- as.data.frame(combined_columns)

option <- c(LETTERS[1:26], paste0('A', LETTERS[1:26]), paste0('B', LETTERS[1:26]), paste0('C', LETTERS[1:26]), paste0('D', LETTERS[1:14]))
out_1 <- problems_table$eur1
pr_1 <- problems_table$per1
out_2 <- problems_table$eur2
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
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path", "lefteur")))
# Back to raw data directory
setwd(raw_path)

# study 1
study <-1
# load sampling data
smp<-read.csv('EB1 choices + sampling.csv')
dem <- read.csv('EB1 choices + demographics.csv')
option <- c(LETTERS[1:26], paste0('A', LETTERS[1:26]), paste0('B', LETTERS[1:26]), paste0('C', LETTERS[1:26]), paste0('D', LETTERS[1:14]))
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
pd <- data.frame()
for (participant in unique(smp$subj)) {
  subject <- participant
  smp_s <- smp[smp$subj==participant, ]
  dem_s <- dem[dem$subj==participant, ]
  for (p in unique(smp_s$shuffled_trial)) {
    smp_p <- smp_s[smp_s$shuffled_trial==p, ]
    prob_id <- smp_p$trial
    dem_p <- dem_s[dem_s$trial==prob_id, ]
    problem <- ifelse(p>37, p-1, p)
    options <- option_map[problem]
    feedback <- smp_p %>%
      select(starts_with("w")) %>%
      unlist() %>%
      na.exclude() %>%
      as.vector()
    choice_raw <- smp_p %>%
      select(starts_with("i")) %>%
      unlist() %>%
      na.exclude() %>%
      as.vector() %>%
      grep("^[A-Za-z][0-9]", ., value = TRUE) %>% # exclude only "L" in raw data
      substr(1, 1)
    choice_raw <- choice_raw[choice_raw != ""]
    if(smp_p$lefteur1==lefteur[problem]){
      choice <- ifelse(choice_raw=='L', choice_pairs[problem, 1], choice_pairs[problem, 2])
      decision <- ifelse(smp_p$decision==1, choice_pairs[problem, 1], choice_pairs[problem, 2])
    }else{
      choice <- ifelse(choice_raw=='R', choice_pairs[problem, 1], choice_pairs[problem, 2])
      decision <- ifelse(smp_p$decision==2, choice_pairs[problem, 1], choice_pairs[problem, 2])
    }
    outcome <- paste(choice, feedback, sep = ":")
    if(length(feedback)==0){
      feedback=NA
      choice=NA
      outcome=NA
    }
    trial<- seq(1:length(choice))
    if (length(decision) > 1){
      decision <- decision[1]
    }
    age <- dem_p$age
    sex <- ifelse(dem_p$female==1, 'f','m')
    # Rest of variables
    response_time<- stage <- condition<- note1<-note2<-education <-NA
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
