### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Frey, R., Hertwig, R., & Rieskamp, J. (2014). Fear shapes information acquisition in decisions from experience. Cognition, 132(1), 90-99.
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "FHR2014"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1 only use data in comedy and denstry condition
# A High, B Low
option <- LETTERS[1:8]
out_1 <- c(4, 3, -3, -32, -3, -4, 32, 3)
pr_1 <- c(0.8, 1, 1, 0.1, 1, 0.8, 0.1, 1)
out_2 <- c(0, NA, NA, 0, NA, 0, 0, NA)
pr_2 <- c(0.2, NA, NA, 0.9, NA, 0.2, 0.9, NA)
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

#Study 2
option <- LETTERS[1:18]
out_1 <- c(4, 3, -3, -32, -3, -4, 32, 3, 32, 3, 3, 5, 11, 4, -12, -32, -4, -3)
pr_1 <- c(0.8, 1, 1, 0.1, 1, 0.8, 0.1, 1, 0.025,0.25, 1, 0.55, 0.35, 0.9, 0.25, 0.1, 0.25,0.35)
out_2 <- c(0, NA, NA, 0, NA, 0, 0, NA, 0, 0, NA, 0, 0, 0, 0, 0, 0, 0)
pr_2 <- c(0.2, NA, NA, 0.9, NA, 0.2, 0.9, NA, 0.975, 0.75, NA, 0.45, 0.65, 0.1, 0.75, 0.9, 0.75, 0.65)
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

# study 1
study <-1
# load sampling data
smp<-read.csv('ipad_sampling.csv')
smp<-smp[smp$sample_ind!=0,]
ch <- read.csv('ipad_decisions.csv')
dem <- read.csv('ipad_demogr.csv')
# exclude unuseful rows
is_row_empty <- function(row) {
  all(is.na(row) | row == "")
}
smp <- smp[!apply(smp, 1, is_row_empty), ]
ch <- ch[!apply(ch, 1, is_row_empty), ]
dem <- dem[!apply(dem, 1, is_row_empty), ]

condition_list <- c('comedy', 'dentsurg')
smp <-smp[smp$cond %in% condition_list, ]
ch <-ch[ch$cond %in% condition_list, ]
dem <- dem[dem$cond %in% condition_list, ]
# identify question and subject
problems <- c('G1', 'G3', 'G4', 'G5')
# options
option <- LETTERS[1:8]
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
pd <- data.frame()
sub_id <- 1
for (participant in unique(smp$session)) {
  subject <- sub_id
  sub_id <- sub_id + 1
  smp_s <- smp[smp$session==participant, ]
  ch_s <- ch[ch$session==participant, ]
  dem_s <- dem[dem$session==participant, ]
  # if empty, add NA
  if (nrow(dem_s) == 0) {
    dem_s[1, ] <- NA
  }
  for (p in unique(smp_s$gamble_lab)) {
    smp_p <- smp_s[smp_s$gamble_lab==p, ]
    ch_p <- ch_s[ch_s$gamble_lab==p, ]
    # if empty, add NA
    if (nrow(ch_p) == 0) {
      ch_p[1, ] <- NA
    }
    problem <- match(p, problems)
    options <- option_map[problem]
    feedback <- smp_p$sample_out
    choice <- ifelse(smp_p$sample_opt=='H', choice_pairs[problem, 1], choice_pairs[problem, 2])
    outcome <- paste(choice, feedback, sep = ":")
    trial<- smp_p$sample_ind
    decision <- ifelse(ch_p$opt=='H', choice_pairs[problem, 1], choice_pairs[problem, 2])
    if (length(decision) > 1){
      decision <- decision[1]
    }
    condition <- match(smp_p$cond, condition_list)
    note1 <- smp_p$cond
    note2 <- participant
    sex <- ifelse(is.na(dem_s$sex), NA, ifelse(dem_s$sex=='female', 'f', 'm'))
    age <- dem_s$age
    education <- dem_s$education
    # Rest of variables
    response_time<- stage <- NA
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
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)
study <-2
# load sampling data
load("/Users/yang/Desktop/material/ARC/项目/3_Data/Sampling_Yujia/FHR2014/raw_data/data_prep.Rdata")
condition_list <- c("anger", "fear",  "pos" ,  "sadn")
smp <- subset(sampling_data,cond%in%condition_list)
problems <- c('c1', 'c3', 'c4', 'c5', 'c6', 'n1b', 'n2b', 'n3b', 'n4b')
# options
option <- LETTERS[1:18]
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
pd <- data.frame()
for (participant in unique(smp$subject)) {
  subject <- participant
  smp_s <- smp[smp$subject==participant, ]
  if (subject==477){
    smp_s$sampled.opt <- ifelse(smp_s$sampled.opt==1, 2, 1)
  }
  for (p in unique(smp_s$probl.lab)) {
    smp_p <- smp_s[smp_s$probl.lab==p, ]
    problem <- match(p, problems)
    options <- option_map[problem]
    feedback <- smp_p$sample.out
    choice <- ifelse(smp_p$sampled.opt==1, choice_pairs[problem, 1], choice_pairs[problem, 2])
    outcome <- paste(choice, feedback, sep = ":")
    trial<- smp_p$sample.ind
    decision <- ifelse(smp_p$probl.dec==1, choice_pairs[problem, 1], choice_pairs[problem, 2])
    condition <- match(smp_p$cond, condition_list)
    note1 <- smp_p$cond
    sex <- ifelse(smp_p$sex==1, 'f', 'm')
    age <- smp_p$age
    # Rest of variables
    response_time<- education <- stage <- note2 <- NA
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
