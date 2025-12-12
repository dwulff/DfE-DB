### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Wulff, D. U., Hills, T. T., & Hertwig, R. (2015). Online product reviews and the description–experience gap. Journal of Behavioral Decision Making, 28(3), 214-223.
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
paper <- "WHH2015a"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1
pro <- read.table('problems.txt', header = T)

#create problem table
# melt table
name_list <- c('out1', 'out2', 'out3', 'out4', 'out5', 'out6', 'out7', 'out8', 'out9', 'out10', 'per1', 'per2', 'per3', 'per4', 'per5', 'per6', 'per7', 'per8', 'per9', 'per10','problem')
combined_columns <- list()
combined_columns[[name_list[1]]] <- rep(1, each = 20)
combined_columns[[name_list[2]]] <- rep(2, each = 20)
combined_columns[[name_list[3]]] <- rep(3, each = 20)
combined_columns[[name_list[4]]] <- rep(4, each = 20)
combined_columns[[name_list[5]]] <- rep(5, each = 20)
combined_columns[[name_list[6]]] <- rep(6, each = 20)
combined_columns[[name_list[7]]] <- rep(7, each = 20)
combined_columns[[name_list[8]]] <- rep(8, each = 20)
combined_columns[[name_list[9]]] <- rep(9, each = 20)
combined_columns[[name_list[10]]] <- rep(10, each = 20)
combined_columns[[name_list[11]]] <- as.vector(rbind(pro$probA1, pro$probB1))
combined_columns[[name_list[12]]] <- as.vector(rbind(pro$probA2, pro$probB2))
combined_columns[[name_list[13]]] <- as.vector(rbind(pro$probA3, pro$probB3))
combined_columns[[name_list[14]]] <- as.vector(rbind(pro$probA4, pro$probB4))
combined_columns[[name_list[15]]] <- as.vector(rbind(pro$probA5, pro$probB5))
combined_columns[[name_list[16]]] <- as.vector(rbind(pro$probA6, pro$probB6))
combined_columns[[name_list[17]]] <- as.vector(rbind(pro$probA7, pro$probB7))
combined_columns[[name_list[18]]] <- as.vector(rbind(pro$probA8, pro$probB8))
combined_columns[[name_list[19]]] <- as.vector(rbind(pro$probA9, pro$probB9))
combined_columns[[name_list[20]]] <- as.vector(rbind(pro$probA10, pro$probB10))
combined_columns[[name_list[21]]] <- as.vector(rbind(pro$problem, pro$problem))
problems_table <- as.data.frame(combined_columns)


option <- LETTERS[1:20]
pt <- problems_table

# change perx=0 to nan
for (i in 1:10) {
  per_col <- paste0("per", i)
  out_col <- paste0("out", i)
  
  zero_idx <- pt[[per_col]] == 0
  
  pt[[per_col]][zero_idx] <- NaN
  pt[[out_col]][zero_idx] <- NaN
}

cols_list <- list()
for (i in 1:10) {
  cols_list[[paste0("out_", i)]] <- pt[[paste0("out", i)]]
  cols_list[[paste0("pr_",  i)]] <- pt[[paste0("per", i)]]
}

# create data.frame
options_table1 <- data.frame(option, cols_list, check.names = FALSE)
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


# function
process_data <- function(smp, ch, dem, study){
  option <- LETTERS[1:20]
  choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
  option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
  pd <- data.frame()
  for (participant in unique(smp$subject)) {
    subject <- participant
    smp_s <- smp[smp$subject==participant, ]
    ch_s <- ch[ch$subject==participant,]
    dem_s <- dem[dem$subject==participant,]
    for (p in unique(smp_s$problem)) {
      smp_p <- smp_s[smp_s$problem==p, ]
      ch_p <- ch_s[ch_s$problem==p,]
      problem <- p
      options <- option_map[problem]
      feedback <- smp_p$outcome
      choice <- ifelse(smp_p$option==0, choice_pairs[problem, 1], choice_pairs[problem, 2])
      outcome <- paste(choice, feedback, sep = ":")
      trial<- seq(length(choice))
      decision <- ifelse(ch_p$dfe.choice==0, choice_pairs[problem, 1], choice_pairs[problem, 2])
      sex<- ifelse(dem_s$sex=='female', 'f', 'm')
      age<- dem_s$age
      # Rest of variables
      condition <-response_time <- stage <-education <- note1<-note2<-NA
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
smp <- read.table('sampling.txt',header = T)
ch <- read.table('choices.txt',header = T)
dem <- read.table('demographics.txt', header = T)

process_data(smp, ch, dem, study)

