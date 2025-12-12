### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Silberberg et al. (2013) Human risky choice in a repeated-gambles procedure

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "SPAF2013"
study <- 1
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# One problem, safe (A) and risky (B) choices
# Two conditions, losses or gains (framing)
# The Nickels vs Candy reward distinction is added to note2
option <- LETTERS[1:8]
out_1 <- c(rep(c(2, 3), 4))
pr_1 <- c(rep(c(1, 0.5), 4))
out_2 <- c(rep(c(NA, 1), 4))
pr_2 <- c(rep(c(NA, 0.5), 4))
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options
file_name <- paste0(paper, "_", study, "_", "options.csv")
setwd(data_path)
write.table(options_table, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

################################################################################################
### Process dataset

# Clear all variables except path, paper, and study
rm(list=setdiff(ls(), c("path", "paper", "study","data_path","raw_path")))
# Back to raw data directory
setwd(raw_path)
setwd("raw/")

# Read all subjects' data into list (these were coded based on paper sheets)
file_list <- list.files()
ds_all <- lapply(file_list,
                 function (f){data.frame(read.table(f, header = TRUE, stringsAsFactors = FALSE,
                                         sep = "", strip.white = TRUE))})

# convert the list into dataframe
df_raw <- data.frame()
for (i in 1:length(ds_all)){
  ds_all[[i]]
  df_raw <- rbind(df_raw, ds_all[[i]])
}

allocate_problem <- function (x){
  return_problem = 0
  if (x$RewardType=="Nickels" && x$Condition=="Losses") {return_problem <- 1} 
  else if (x$RewardType=="Nickels" && x$Condition=="Gains") {return_problem <- 2} 
  else if (x$RewardType=="Candy" && x$Condition=="Losses") {return_problem <- 3} 
  else if (x$RewardType=="Candy" && x$Condition=="Gains") {return_problem <- 4}
  return(return_problem)
}

option <- LETTERS[1:8]
problem <- options <- subject <- trial <- choice <- outcome <- vector()
response_time <- stage <- sex <- age <- education <- note1 <- note2 <- NA
condition <- 1
trial<-rep(1:60, 21*2)

for (r in 1:nrow(df_raw)){
  subject <- c(subject, df_raw[r,]$Subject)
  r_problem <- allocate_problem(df_raw[r,])
  problem <- c(problem, r_problem)
  options <- c(options, paste(option[r_problem*2-1], option[r_problem*2], sep="_"))
  r_choice <- ifelse(df_raw[r,]$Reward==2, option[r_problem*2-1], option[r_problem*2])
  choice <- c(choice, r_choice)
  outcome <- c(outcome, paste(r_choice, df_raw[r,]$Reward, sep=":"))
}

ds_final <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)

# Combine and save processed data
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
