### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Noguchi, T., & Hills, T. T. (2016). Experience‐based decisions favor riskier alternatives in large sets. Journal of Behavioral Decision Making, 29(5), 489-498.
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("RSQLite", quietly = TRUE)) install.packages("RSQLite")
library(RSQLite)
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
library(dplyr)
if (!requireNamespace("lme4", quietly = TRUE)) install.packages("lme4")
library(lme4)
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
if (!requireNamespace("plyr", quietly = TRUE)) install.packages("plyr")
library(plyr)
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
library(dplyr)
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "NH2016"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1 A safer, B riskier
option <- c(rep('A',16), rep('B',16))
description <- c(rep('safer alternative with a non-zero payoff v and a zero payoff, v~U(0.5, 1) or v~U(-1,-0.5). P(v)~U(0.8, 0.995), EV=a', 16), rep('riskier alternative with a non-zero payoff v and a zero payoff, P(v)~U(0.005, 0.2, EV=0.9a',16))
options_table1 <- data.frame(option,description)

# Study 2 A safe, B risky
description <- c(rep('safer alternative with a non-zero payoff v and a zero payoff, v~U(0.5, 1) or v~U(-1,-0.5). P(v)~U(0.8, 0.995), EV=a', 16), rep('riskier alternative with a non-zero payoff v and a zero payoff, P(v)~U(0.005, 0.2, EV=1.1a',16))
options_table2 <- data.frame(option,description)

# Save options
file_name1 <- paste0(paper, "_", "1", "_", "options.csv")
file_name2 <- paste0(paper, "_", "2", "_", "options.csv")
setwd(data_path)
write.table(options_table1, file = file_name1, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")
write.table(options_table2, file = file_name2, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")

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

#function
lexMatch<-function(x,lexicon){
  if(length(lexicon[,1])!=length(unique(lexicon[,1]))) stop("lexicon entries not unique")
  return(apply(as.matrix(x),1,function(z) lexicon[lexicon[,1]==z[1] ,ncol(lexicon)]))
}

process_data <- function(smp, ch, study){
  pd <- data.frame()
  for (participant in unique(smp$participant_id)) {
    subject <- participant
    smp_s <- smp[smp$participant_id==participant, ]
    ch_s <- ch[ch$participant_id==participant, ]
    par_s <- participants[participants$participant_id==participant,]
    con_s <- conditions[conditions$participant_id==participant,]
    for (p in unique(smp_s$problem)) {
      smp_p <- smp_s[smp_s$problem==p, ]
      ch_p <- ch_s[ch_s$problem==p,]
      problem <- p
      alternatives <- alternative[alternative$problem==p,]
      condition<- ifelse(con_s$setsize[1]==2, 1, 2)
      options <- option_map[condition]
      feedback <- smp_p$payoff
      choice <- ifelse(grepl("^safe", smp_p$alternative_id), 'A', 'B')
      outcome <- paste(choice, feedback, sep = ":")
      trial<- smp_p$time
      decision <- ifelse(grepl("^safe", ch_p$alternative_id), 'A', 'B')
      response_time <- smp_p$response_time
      note1<-smp_p$alternative_id
      sex<-ifelse(par_s$gender=='female', 'f', 'm')
      age<-par_s$age
      note2<-con_s$paradigm[1]
      # Rest of variables
      stage <- education <-NA
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
}

option <- c(rep('A',16), rep('B',16))
option_map <- c('A_B', paste(option, collapse = "_"))

# study 1
study <-1
#read data
database <-'data_exp1.sqlite3'
conn <- dbConnect(dbDriver("SQLite"), database)
dbListTables(conn)

response = dbReadTable(conn,'response')
conditions = dbReadTable(conn,'condition')
participants = dbReadTable(conn,'participant')
alternative = dbReadTable(conn,'alternative')
dbDisconnect(conn)
response$problem <- substr(sub(".*_", "", response$alternative_id), 1, 5)
alternative$problem <- substr(sub(".*_", "", alternative$alternative_id), 1, 5)
alternative <- alternative %>%
  select(problem, everything())

smp = subset(response, action == 'sample')
ch = subset(response, action == 'choice')
# process
process_data(smp, ch, study)

# study 2
study <-2
#read data
setwd(raw_path)
database <-'data_exp2.sqlite3'
conn <- dbConnect(dbDriver("SQLite"), database)
dbListTables(conn)

response = dbReadTable(conn,'response')
conditions = dbReadTable(conn,'condition')
participants = dbReadTable(conn,'participant')
alternative = dbReadTable(conn,'alternative')
dbDisconnect(conn)
response$problem <- substr(sub(".*_", "", response$alternative_id), 1, 5)
alternative$problem <- substr(sub(".*_", "", alternative$alternative_id), 1, 5)
alternative <- alternative %>%
  select(problem, everything())

smp = subset(response, action == 'sample')
ch = subset(response, action == 'choice')
# process
process_data(smp, ch, study)
