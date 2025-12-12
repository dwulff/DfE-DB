### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Hertwig, R., Barron, G., Weber, E. U., & Erev, I. (2004). Decisions from experience and the effect of rare events in risky choice. Psychological science, 15(8), 534-539.

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("plyr", quietly = TRUE)) install.packages("plyr")
library(plyr)
if (!requireNamespace("reshape", quietly = TRUE)) install.packages("reshape")
library(reshape)
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "HBWE2004"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

##### Create the options sheets
d<- read.csv('Hertwig et al. (2004) - classic DfE.csv', sep=";",skip=1)
d<-d[,c(1,2,3,5,6)]
option <- LETTERS[1:12]
out_1 <- c(rbind(d$OutcomeH, d$OutcomeL))
pr_1 <- c(rbind(d$probH, d$probL))
out_2 <- rep(c(0),each=12)
pr_2 <- 1-pr_1
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)
options_table$out_2[options_table$pr_1 == 1] <- NA
options_table$pr_2[options_table$pr_1 == 1] <- NA

# Save options
file_name <- paste0(paper, "_", "1", "_", "options.csv")
setwd(data_path)
write.table(options_table, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")


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
study <- 1

#0's and 1's are inverted, problem and subjects are plus 600
c<- read.table("Hertwig04.s1_choices_122.txt",header=T)
s<- read.table("Hertwig04.s1_sampling_122.txt",header=T)

c$subject<-c$subject-600; c$problem<-c$problem-600
c$choice<-mapvalues(c$choice, c(1,0),c(0,1))

head(s)
s$subject<-s$subject-600; s$problem<-s$problem-600
s$option<-mapvalues(s$option, c(1,0),c(0,1))

# Arrange into lists for parallel access (divided by 3 for 3 sessions)
subject_ids_list <- unique(c$subject)
option <- LETTERS[1:12]
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
pd <- data.frame()

for (sb in subject_ids_list) {
  ds <- s[s$subject==sb,]
  for (prob in unique(ds$problem)){
    df <- ds[ds$problem==prob,]
    subject <- sb
    trial <- df$trial
    problem <- df$problem
    options <- option_map[problem]
    choice <- ifelse(df$option == 0, choice_pairs[df$problem,1], choice_pairs[df$problem,2])
    outcome <- paste(choice, df$outcome, sep = ":")
    decision <- c[(c$subject == sb & c$problem == prob), ]$choice
    decision <- ifelse(decision == 0, choice_pairs[prob,1], choice_pairs[prob,2])
    # Rest of variables
    response_time<-condition<- stage <- sex <- age <- education<- note1<- note2<- NA
    # Create final dataframe
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, decision, response_time, stage, sex, age, education, note1, note2)
    pd <- rbind(pd, psd)
  }
}

# Combine and save processed data
ds_final <- pd [order(pd$subject), ]
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
