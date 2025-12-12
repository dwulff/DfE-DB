### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Fleischhut, N., Artinger, F., Olschewski, S., Volz, K. G., & Hertwig, R. (2014). Sampling of social information: Decisions from experience in bargaining. In 36th Annual Meeting of the Cognitive Science Society (pp. 1048-1053). Cognitive Science Society.
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "FAOV2014"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1 experienced condition. description data only have one choice data, not useful.
# A safe, B risky
option <- LETTERS[1:24]
out_1 <- c(50, 55, 40, 80, 40, 70, 60, 80, 50, 80, 20, 40, 35, 70, 55, 65, 25, 50, 25, 60, 30, 110, 25, 120)
pr_1 <- c(1, 0.8, 1, 0.8, 1, 0.8, 1, 0.8, 0.9, 0.55, 0.9, 0.75, 0.9, 0.7, 0.9, 0.7, 0.95, 0.55, 0.95, 0.25, 0.95, 0.25, 0.95, 0.2)
out_2 <- c(NA, 0, NA, 0, NA, 0, NA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
pr_2 <- c(NA, 0.2, NA, 0.2, NA, 0.2, NA, 0.2, 0.1, 0.45, 0.1, 0.25, 0.1, 0.3, 0.1, 0.3, 0.05, 0.45, 0.05, 0.75, 0.05, 0.75, 0.05, 0.8)
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
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)
study <-1
# load sampling data
smp_f<-read.csv('sampling.Lottery.freesampling.csv')
smp_m <- read.csv('sampling.Lottery.matchedsampling.csv')
# identify question
choice.IDs <- c(2, 3, 5, 13, 14, 15, 16, 17, 18, 21, 23, 25)
problems_ID <- c(5, 6, 7, 8, 1, 9, 10, 11, 12, 2, 3, 4)
new_problem_f <- rep(NA, nrow(smp_f))
match_indices_f <- match(smp_f$choice.ID, choice.IDs)
new_problem_f[!is.na(match_indices_f)] <- problems_ID[match_indices_f[!is.na(match_indices_f)]]
smp_f$problem <- new_problem_f
new_problem_m <- rep(NA, nrow(smp_m))
match_indices_m <- match(smp_m$choice.ID, choice.IDs)
new_problem_m[!is.na(match_indices_m)] <- problems_ID[match_indices_m[!is.na(match_indices_m)]]
smp_m$problem <- new_problem_m
# rerange the choice index
smp_f$choice.ID <- match(smp_f$choice.ID, c(2, 3, 5, 13, 14, 15, 16, 17, 18, 21, 23, 25))
smp_m$choice.ID <- match(smp_m$choice.ID, c(2, 3, 5, 13, 14, 15, 16, 17, 18, 21, 23, 25))
# load choice data
ch_f <- read.csv('lottery.freesampling.csv')
ch_m <- read.csv('lottery.matchedsampling.csv')
option <- LETTERS[1:24]
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
out_safe <- c(50, 40, 40, 60, 50, 20, 35, 55, 25, 25, 30, 25)
condition_list <- c('free sampling', 'match sampling')

# for free sampling
process_data <- function(d, ch, pd, con){
  for (participant in unique(d$subject.cons)) {
    subject <- ifelse(con==1, participant, paste0(10, participant))
    smp_s <- d[d$subject.cons==participant, ]
    ch_s <- ch[ch$subject.cons==participant, ]
    ch_s_list <- as.vector(unlist(ch_s[, paste0("propose.", 1:12, ".")]))
    for (p in unique(smp_s$problem)) {
      smp_p <- smp_s[smp_s$problem==p, ]
      ch_p <- ch_s_list[smp_p$choice.ID[1]]
      problem <- p
      options <- option_map[problem]
      feedback <- smp_p$V4
      choice <- ifelse(smp_p$V1==out_safe[problem], choice_pairs[problem, 1], choice_pairs[problem, 2])
      outcome <- paste(choice, feedback, sep = ":")
      trial<- seq_len(nrow(smp_p))
      decision <- ifelse(ch_p==2, choice_pairs[problem, 1], choice_pairs[problem, 2])
      condition <- con
      note1 <- condition_list[condition]
      # Rest of variables
      sex <- age<-response_time<- stage <- education<- note2<- NA
      # Create final dataframe
      psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, decision, response_time, stage, sex, age, education, note1, note2)
      pd <- rbind(pd, psd)
    }
  }
  return(pd)
}

# process one by one
pd_f <- data.frame()
pd_m <- data.frame()
pd_f <- process_data(smp_f, ch_f, pd_f, 1)
pd_m <- process_data(smp_m, ch_m, pd_m, 2)
pd <- rbind(pd_f, pd_m)


# Combine and save processed data
ds_final <- pd[order(pd$subject), ]
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
