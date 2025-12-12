### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Hills, T. T., Noguchi, T., & Gibbert, M. (2013). Information overload or search-amplified risk? Set size and order effects on decisions from experience. Psychonomic Bulletin & Review, 20, 1023-1031.
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "HNG2013"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1 problem 1-5, has options 2, 4, 8, 16, 32.
# A-Z, probablity, low-high
setwd('Hills13_problemtables')
p1 <- read.table('Hills13.Problem.set.2.txt')
p2 <- read.table('Hills13.Problem.set.4.txt')
p3 <- read.table('Hills13.Problem.set.8.txt')
p4 <- read.table('Hills13.Problem.set.16.txt')
p5 <- read.table('Hills13.Problem.set.32.txt')
cols <- colnames(p5)
p5 <- p5[, c(setdiff(cols, c("A", "B", "C", "D", "E", "F")), c("A", "B", "C", "D", "E", "F"))]


option <- c(LETTERS[1:26], paste0('A', LETTERS[1:26]), paste0('B', LETTERS[1:10]))
out_1 <- as.vector(unlist(c(p1['Payoff',], p2['Payoff',], p3['Payoff',], p4['Payoff',], p5['Payoff',])))
pr_1 <- as.vector(unlist(c(p1['P(Payoff)',], p2['P(Payoff)',], p3['P(Payoff)',], p4['P(Payoff)',], p5['P(Payoff)',])))
out_2 <- as.vector(unlist(c(p1['Zero',], p2['Zero',], p3['Zero',], p4['Zero',], p5['Zero',])))
pr_2 <- as.vector(unlist(c(p1['P(0)',], p2['P(0)',], p3['P(0)',], p4['P(0)',], p5['P(0)',])))
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

# study 1
study <-1
# load sampling data
smp<-read.table('Hills13_s1_133_raw.txt')
# create choice matrix
option <- c(LETTERS[1:26], paste0('A', LETTERS[1:26]), paste0('B', LETTERS[1:10]))
option_num <- c(2, 4, 8, 16, 32)
ends <- cumsum(option_num)
starts <- c(1, head(ends, -1) + 1)
sub_vectors <- mapply(function(start, end) option[start:end], starts, ends, SIMPLIFY = FALSE)
choice_pairs <- do.call(rbind, lapply(sub_vectors, function(x) c(x, rep(NA, max(option_num) - length(x)))))
# option map
option_map <- apply(choice_pairs, 1, function(row) {
  row <- row[!is.na(row)]
  paste(row, collapse = "_")
})
choice_label_list <- c(letters[1:26], LETTERS[1:6])
pd <- data.frame()
for (participant in unique(smp$subj)) {
  subject <- participant
  smp_s <- smp[smp$subj==participant, ]
  for (p in unique(smp_s$n_options)) {
    smp_p <- smp_s[smp_s$n_options==p, ]
    ch_p <- smp_p[smp_p$realgame==1,]
    smp_p <- smp_p[smp_p$realgame!=1,]
    problem <- match(p, option_num)
    options <- option_map[problem]
    feedback <- smp_p$payoff
    choice_raw <- match(smp_p$choice_label, choice_label_list)
    choice <- choice_pairs[problem, choice_raw]
    outcome <-ifelse(is.na(feedback),NA, paste(choice, feedback, sep = ":"))
    trial<- smp_p$round+1
    decision_raw <- match(ch_p$choice_label, choice_label_list)
    decision <- choice_pairs[problem, decision_raw]
    condition <- smp_p$condition
    note1 <- ifelse(condition==1, 'many to few', 'few to many')
    # Rest of variables
    response_time<- stage <- sex<- age<-note2<-education <-NA
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
