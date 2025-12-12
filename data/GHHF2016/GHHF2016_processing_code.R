### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Glöckner, A., Hilbig, B. E., Henninger, F., & Fiedler, S. (2016). The reversed description-experience gap: Disentangling sources of presentation format effects in risky choice. Journal of Experimental Psychology: General, 145(4), 486.
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
if (!requireNamespace("haven", quietly = TRUE)) install.packages("haven")
library(haven)
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
library(dplyr)
if (!requireNamespace("plyr", quietly = TRUE)) install.packages("plyr")
library(plyr)
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "GHHF2016"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet
#read data and preprocess
d1 <- read.csv('Modelcomparison_forIBL.csv')  #sampling data
d2 <- read_dta('EB_all.dta')  # problem & demography
d1 <- subset(d1, exp%in%c(2,3,4))
d2 <- subset(d2,exp%in%c(2,3,4) & description==0)
d1$g1p1[is.na(d1$g1p2)] <- 1
d1$g2p1[is.na(d1$g2p2)] <- 1
d2$g1p1[is.na(d2$g1p2)] <- 1
d2$g2p1[is.na(d2$g2p2)] <- 1

# create problem table, remove repeated problems, set reverse tag
pro <- unique(d2[,c('exp','g1o1','g1p1','g1o2','g1p2','g2o1','g2p1','g2o2','g2p2','targets')])
pro <- data.frame(pro)
pro$pid <- NA
pro$pid_rev<- NA
for(i in 1:nrow(pro)){
  exp <- pro[i,1]
  p <- unlist(pro[i,-c(1,10:12)])
  pid11 <- paste0(p[1:2],collapse='_')
  pid12 <- paste0(p[3:4],collapse='_')
  pid21 <- paste0(p[5:6],collapse='_')
  pid22 <- paste0(p[7:8],collapse='_')
  if(pid11 > pid12){
    pid1 <- paste0(c(pid11,pid12),collapse='_')
    p1   <- p[1:4]
  } else {
    pid1 <- paste0(c(pid12,pid11),collapse='_')
    p1   <- p[c(3:4,1:2)]
  }
  if(pid21 > pid22){
    pid2 <- paste0(c(pid21,pid22),collapse='_')
    p2   <- p[5:8]
  } else {
    pid2 <- paste0(c(pid22,pid21),collapse='_')
    p2   <- p[c(7:8,5:6)]
  }
  test <- pid1 > pid2
  if(test == TRUE){
    pro$pid[i]     <- paste0(c(pid1,pid2,exp),collapse='_')
    pro$pid_rev[i] <- paste0(c(pid2,pid1,exp),collapse='_')
    pro[i,-c(1,10:12)] <- as.vector(c(p1,p2))
  } else {
    pro$pid[i]     <- paste0(c(pid2,pid1,exp),collapse='_')
    pro$pid_rev[i] <- paste0(c(pid1,pid2,exp),collapse='_')
    pro[i,-c(1,10:12)] <-as.vector(c(p2,p1))    
  }
}


pro <- pro[!duplicated(pro$pid),]
pro <- ddply(pro,.(exp),function(x) data.frame('problem'=1:nrow(x),x))
pro$g1o1[pro$g1p1==0] <- NA
pro$g1p1[pro$g1p1==0] <- NA
pro$g1o2[pro$g1p2==0] <- NA
pro$g1p2[pro$g1p2==0] <- NA
pro$g2o1[pro$g2p1==0] <- NA
pro$g2p1[pro$g2p1==0] <- NA
pro$g2o2[pro$g2p2==0] <- NA
pro$g2p2[pro$g2p2==0] <- NA

# set problem label for both dataframe
set_pro <- function(d){
  pid <- character(nrow(d)) 
  for(i in 1:nrow(d)){
    exp <- d[i,'exp']
    p <- unlist(d[i,c('g1o1','g1p1','g1o2','g1p2','g2o1','g2p1','g2o2','g2p2')])
    pid11 <- paste0(p[1:2],collapse='_')
    pid12 <- paste0(p[3:4],collapse='_')
    pid21 <- paste0(p[5:6],collapse='_')
    pid22 <- paste0(p[7:8],collapse='_')
    pid1 <- ifelse(pid11 > pid12, paste0(c(pid11,pid12),collapse='_'), paste0(c(pid12,pid11),collapse='_'))
    pid2 <- ifelse(pid21 > pid22, paste0(c(pid21,pid22),collapse='_'), paste0(c(pid22,pid21),collapse='_'))
    pid[i] = paste0(c(pid1,pid2,exp),collapse='_')
    
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

d1 <- set_pro(d1)
d2 <- set_pro(d2)


#create problem table
# melt table
name_list <- c('out1', 'out2', 'per1', 'per2', 'problem', 'exp')
combined_columns <- list()
combined_columns[[name_list[1]]] <- as.vector(rbind(pro$g1o1, pro$g2o1))
combined_columns[[name_list[2]]] <- as.vector(rbind(pro$g1o2, pro$g2o2))
combined_columns[[name_list[3]]] <- as.vector(rbind(pro$g1p1, pro$g2p1))
combined_columns[[name_list[4]]] <- as.vector(rbind(pro$g1p2, pro$g2p2))
combined_columns[[name_list[5]]] <- as.vector(rbind(pro$problem, pro$problem))
combined_columns[[name_list[6]]] <- as.vector(rbind(pro$exp, pro$exp))
problems_table_all <- as.data.frame(combined_columns)

# Study 1 only use data in experience condition
option <- c(LETTERS[1:26], paste0('A', LETTERS[1:26]), paste0('B', LETTERS[1:26]), paste0('C', LETTERS[1:26]), paste0('D', LETTERS[1:16]))
problems_table <- problems_table_all[problems_table_all$exp==2,]
out_1 <- problems_table$out1
pr_1 <- problems_table$per1
out_2 <- problems_table$out2
pr_2 <- problems_table$per2
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Study 2
problems_table <- problems_table_all[problems_table_all$exp == 3,]
out_1 <- problems_table$out1
pr_1 <- problems_table$per1
out_2 <- problems_table$out2
pr_2 <- problems_table$per2
options_table2 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Study 3
option <- c(LETTERS[1:26], paste0('A', LETTERS[1:26]), paste0('B', LETTERS[1:26]), paste0('C', LETTERS[1:26]), paste0('D', LETTERS[1:26]), paste0('E', LETTERS[1:26]), paste0('F', LETTERS[1:26]), paste0('G', LETTERS[1:26]), paste0('H', LETTERS[1:26]), paste0('I', LETTERS[1:26]),paste0('J', LETTERS[1:16]))
problems_table <- problems_table_all[problems_table_all$exp == 4,]
out_1 <- problems_table$out1
pr_1 <- problems_table$per1
out_2 <- problems_table$out2
pr_2 <- problems_table$per2
options_table3 <- data.frame(option, out_1, pr_1, out_2, pr_2)


# Save options
file_name1 <- paste0(paper, "_", "1", "_", "options.csv")
file_name2 <- paste0(paper, "_", "2", "_", "options.csv")
file_name3 <- paste0(paper, "_", "3", "_", "options.csv")

setwd(data_path)
write.table(options_table1, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(options_table2, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(options_table3, file = file_name3, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

### Process dataset

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "raw_path","data_path","d1","d2")))
paper_raw <- "GHHF2016"
d1<- d1[!is.na(d1$problem),]
d2<- d2[!is.na(d2$problem),]


process_data <- function(study_raw, d1, d2,option){
  # Back to raw data directory
  setwd(raw_path)
  # load sampling data
  choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
  option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
  smp<-d1[d1$exp==(study_raw+ 1),]
  dem <- d2[d2$exp==(study_raw+1),]
  smp <-smp[!is.na(smp$problem),]
  # problem_list <- sort(unique(smp$problem))
  pd <- data.frame()
  for (participant in unique(smp$matchSubject)) {
    subject_raw <- participant
    smp_s <- smp[smp$matchSubject==participant, ]
    dem_s <- dem[dem$subj==participant, ]
    for (p in unique(smp_s$problem)) {
      smp_p <- smp_s[smp_s$problem==p, ]
      dem_p <- dem_s[dem_s$problem==p, ]
      feedback_list <- unlist(smp_p[1,c('g1o1','g1o2','g2o1','g2o2')])
      feedback <- feedback_list[smp_p$ind]
      problem <- p
      # problem <- match(p,problem_list)
      choice_raw <- ifelse(smp_p$ind %in%c(1, 2), 'L', 'R')
      if(smp_p$reverse[1] == 0){
        choice <- ifelse(choice_raw=='L', choice_pairs[problem, 1], choice_pairs[problem, 2])
        decision <- ifelse(smp_p$decision==1, choice_pairs[problem, 1], choice_pairs[problem, 2])
      }else{
        choice <- ifelse(choice_raw=='R', choice_pairs[problem, 1], choice_pairs[problem, 2])
        decision <- ifelse(smp_p$decision==2, choice_pairs[problem, 1], choice_pairs[problem, 2])
      }
      outcome <- paste(choice, feedback, sep = ":")
      problem <- rep(p,length(choice))
      options <- option_map[problem]
      if(length(feedback)==0){
        feedback=NA
        choice=NA
        outcome=NA
      }
      trial<- seq(1:length(choice))
      if (length(decision) > 1){
        decision <- decision[1]
      }
      age <- ifelse(length(dem)!=0,rep(dem_p$age,length(choice)),NA)
      sex <- ifelse(length(dem)!=0,rep(ifelse(dem_p$female==1, 'f','m'),length(choice)),NA)
      paper <- rep(paper_raw, length(choice))
      study <- rep(study_raw, length(choice))
      subject<-rep(subject_raw, length(choice))
      # Rest of variables
      response_time<- stage <- condition<- note1<-note2<-education <-rep(NA,length(choice))
      # Create final dataframe
      psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, decision, response_time, stage, sex, age, education, note1, note2)
      pd <- rbind(pd, psd)
    }
  }
  # Combine and save processed data
  ds_final <- pd[order(pd$subject, pd$condition, pd$problem, pd$trial), ]
  file_name <- paste0(paper_raw, "_", study_raw, "_", "data.csv")
  setwd(data_path)
  write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
}

#study 1
option <- c(LETTERS[1:26], paste0('A', LETTERS[1:26]), paste0('B', LETTERS[1:26]), paste0('C', LETTERS[1:26]), paste0('D', LETTERS[1:16]))
process_data(1, d1, d2,option)


#study 2
option <- c(LETTERS[1:26], paste0('A', LETTERS[1:26]), paste0('B', LETTERS[1:26]), paste0('C', LETTERS[1:26]), paste0('D', LETTERS[1:16]))
process_data(2, d1, d2, option)

#study 3
option <- c(LETTERS[1:26], paste0('A', LETTERS[1:26]), paste0('B', LETTERS[1:26]), paste0('C', LETTERS[1:26]), paste0('D', LETTERS[1:26]), paste0('E', LETTERS[1:26]), paste0('F', LETTERS[1:26]), paste0('G', LETTERS[1:26]), paste0('H', LETTERS[1:26]), paste0('I', LETTERS[1:26]),paste0('J', LETTERS[1:16]))
process_data(3, d1, d2, option)
