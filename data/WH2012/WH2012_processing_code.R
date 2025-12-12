### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Unpublished raw data
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
paper <- "WH2012"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1
# create problem table, remove repeated problems, set reverse tag
ch <- read.csv('rounds.csv')
ch <- ch[ch$experiment==0,]
pro <- unique(ch[,c('options1a', 'options1b', 'options2a', 'options2b')])
pro <- data.frame(pro)
pro$pid <- NA
pro$pid_rev<- NA
for(i in 1:nrow(pro)){
  p <- unlist(pro[i,])
  pid1 <- paste0(p[1:2],collapse='_')
  pid2 <- paste0(p[3:4],collapse='_')
  p1 <- p[1:2]
  p2 <- p[3:4]
  test <- pid1 > pid2
  if(test == TRUE){
    pro$pid[i]     <- paste0(c(pid1,pid2),collapse='_')
    pro$pid_rev[i] <- paste0(c(pid2,pid1),collapse='_')
    pro[i,c(1:4)] <- as.vector(c(p1,p2))
  } else {
    pro$pid[i]     <- paste0(c(pid2,pid1),collapse='_')
    pro$pid_rev[i] <- paste0(c(pid1,pid2),collapse='_')
    pro[i,c(1:4)] <-as.vector(c(p2,p1))    
  }
}

pro <- pro[!duplicated(pro$pid),]
pro$problem <- 1:nrow(pro)
pro[, 1:4] <- lapply(pro[, 1:4], as.numeric)
pro$options1c <- ifelse(pro$options1b==1, NA, 0)
pro$options1d <- ifelse(pro$options1b==1, NA, 1-pro$options1b)
pro$options2c <- ifelse(pro$options2b==1, NA, 0)
pro$options2d <- ifelse(pro$options2b==1, NA, 1-pro$options2b)

#create problem table
# melt table
name_list <- c('out1', 'out2', 'per1', 'per2', 'problem')
combined_columns <- list()
combined_columns[[name_list[1]]] <- as.vector(rbind(pro$options1a, pro$options2a))
combined_columns[[name_list[2]]] <- as.vector(rbind(pro$options1c, pro$options2c))
combined_columns[[name_list[3]]] <- as.vector(rbind(pro$options1b, pro$options2b))
combined_columns[[name_list[4]]] <- as.vector(rbind(pro$options1d, pro$options2d))
combined_columns[[name_list[5]]] <- as.vector(rbind(pro$problem, pro$problem))
problems_table <- as.data.frame(combined_columns)


option <- LETTERS[1:12]
# out_1 <- c(32, 3, 3, 4, -3, -32, 3, 4, 2, 3, -3, -4)
# pr_1 <- c(0.1, 1, 0.25, 0.2, 1, 0.1, 1, 0.8, 0.025, 0.25, 1, 0.8)
# out_2 <- c(0, NA, 0, 0, NA, 0, NA, 0, 0, 0, NA, 0)
# pr_2 <- c(0.9, NA, 0.75, 0.8, NA, 0.9, NA, 0.2, 0.975, 0.75, NA, 0.8)
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
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path", "pro")))
# Back to raw data directory
setwd(raw_path)


# function
process_data <- function(smp, ch, dem, study){
  option <- LETTERS[1:12]
  choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
  option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
  condition_list <- unique(smp$condition)
  pd <- data.frame()
  for (participant in unique(smp$round.person_id)) {
    subject <- participant
    smp_s <- smp[smp$round.person_id==participant, ]
    ch_s <- ch[ch$person_id==participant,]
    dem_s <- dem[dem$id==participant,]
    for (p in unique(smp_s$problem)) {
      smp_p <- smp_s[smp_s$problem==p, ]
      ch_p <- ch_s[ch_s$problem==p,]
      problem <- p
      options <- option_map[problem]
      feedback <- smp_p$number
      choice <- ifelse(smp_p$reverse==0, ifelse(smp_p$urn==0, choice_pairs[problem, 1], choice_pairs[problem, 2]),ifelse(smp_p$urn==1, choice_pairs[problem, 1], choice_pairs[problem, 2]))
      outcome <- paste(choice, feedback, sep = ":")
      trial<- seq(length(choice))
      decision <- ifelse(ch_p$reverse==0, ifelse(ch_p$choice==0, choice_pairs[problem, 1], choice_pairs[problem, 2]),ifelse(ch_p$choice==1, choice_pairs[problem, 1], choice_pairs[problem, 2]))
      sex<- ifelse(dem_s$gender==0, 'f', 'm')
      age<- dem_s$age
      education <- dem_s$education
      # Rest of variables
      condition <-response_time <- stage <- note1<-note2<-NA
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
smp <- read.csv('samples.csv')
if (any(is.na(smp))) {
  colnames(smp) <- colnames(read.csv("samples.csv", header = TRUE))[-1]
}
ch <- read.csv('rounds.csv')
ch <- ch[ch$experiment==0,]
dem <- read.csv('people.csv')
#add problem number
# set problem label for both dataframe
set_pro <- function(d){
  pid <- character(nrow(d)) 
  for(i in 1:nrow(d)){
    if ("options1a" %in% names(d)) {
      p <- unlist(d[i,c('options1a', 'options1b', 'options2a', 'options2b')])
    }else{
      p <- unlist(d[i,c('round.options1a', 'round.options1b', 'round.options2a', 'round.options2b')])
    }
    pid1 <- paste0(p[1:2],collapse='_')
    pid2 <- paste0(p[3:4],collapse='_')
    pid[i] <- paste0(c(pid1,pid2),collapse='_')
  }
  d$pid <- pid
  # set problem var
  p1 = pro$problem[match(d$pid,pro$pid)]
  p2 = pro$problem[match(d$pid,pro$pid_rev)]
  # reversed or not
  d$reverse <- ifelse(!is.na(p1),0,1)
  d$problem <- ifelse(!is.na(p1),p1,p2)
  return(d)
}

smp<-set_pro(smp)
ch<-set_pro(ch)


process_data(smp, ch, dem, study)

