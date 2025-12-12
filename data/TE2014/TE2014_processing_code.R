### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Teoderescu & Erev (2014) Learned Helplessness and Learned Prevalence: Exploring the Causal Relations Among Perceived Controllability, Reward Prevalence, and Exploration

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "TE2014"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)
##### Create the options sheet

# Three problems (different p(reward), low, medium, or high), two underlying options: explore or not (in that order)
# Study 1 (Independent group)
option <- c("A", "B", "C", "D", "E", "F")
out_1 <- c(10, 0, 10, 0, 10, 0)
pr_1 <- c(0.1, 1, 0.2, 1, 1, 1)
out_2 <- c(-1, NA, -1, NA, NA, NA)
pr_2 <- c(0.9, NA, 0.8, NA, NA, NA)

options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Study 2, yoked group
option <- c("A", "B", "C", "D", "E", "F")
description <- c("for the first 50 trials, 10 if the matched participant chose to explore and got a reward, -1 if matched participants didn't explore or got no reward in exploration. The last 50 trials is the same as Study 1",
                 "for the first 50 trials, 11 if the matched participant chose to explore and got a reward, 0 if matched participants didn't explore or got no reward in exploration. The last 50 trials is the same as Study 1",
                 "for the first 50 trials, 10 if the matched participant chose to explore and got a reward, -1 if matched participants didn't explore or got no reward in exploration. The last 50 trials is the same as Study 1",
                 "for the first 50 trials, 11 if the matched participant chose to explore and got a reward, 0 if matched participants didn't explore or got no reward in exploration. The last 50 trials is the same as Study 1",
                 "for the first 50 trials, 10 if the matched participant chose to explore and got a reward, -1 if matched participants didn't explore or got no reward in exploration. The last 50 trials is the same as Study 1",
                 "for the first 50 trials, 11 if the matched participant chose to explore and got a reward, 0 if matched participants didn't explore or got no reward in exploration. The last 50 trials is the same as Study 1"
)

options_table2 <- data.frame(option, description)

# Save options
file_name1 <- paste0(paper, "_", "1", "_", "options.csv")
file_name2 <- paste0(paper, "_", "2", "_", "options.csv")

setwd(data_path)
write.table(options_table1, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
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
study = 1
# Back to raw data directory
setwd(raw_path)
# Get column names stored in separate txt file
column_names <- colnames(read.table(file = "variables titles.txt", header = TRUE, stringsAsFactors = FALSE))
data_files <- list.files(pattern = "[[:digit:]].txt")
subject_ids <- gsub(pattern = ".txt", replacement = "", x = data_files)
# Option number code
option <- c("A", "B", "C", "D", "E", "F")
choice_matrix <- matrix(option, ncol = 2, byrow = TRUE)
problem_map <- c(`0.1`=1, `0.2`=2, `1`=3)
# List to store processed data
psd_list <- vector(mode = "list", length(data_files))

for (sb in 1:length(data_files)) {
  subject <- as.numeric(subject_ids[sb])
  df <- read.csv(file = data_files[sb], header = FALSE, stringsAsFactors = FALSE, col.names = column_names)
  # exclude duplicate trials
  if (subject == 2){
    df <- df[-(1:77), ]
  }else if (subject == 45){
    df <- df[-(1:16), ]
  }
  # Gender code: 1 for male and 0 for female, as indicated by the author
  sex <- ifelse(df$gender == 1, "m", "f")
  age <- df$age
  response_time <- round(df$RT)
  problem <- problem_map[as.character(df$Phigh)]
  options <- sapply(1:nrow(df), function (n) paste(choice_matrix[problem[n], ], collapse = "_"))
  trial <- df$t
  condition <- sapply(1:nrow(df), function (n) ifelse(df$control[n] == 1, 1, 2))
  note1 <- ifelse(df$control[1] == 1, "Independent", "Yoked")
  choice <- sapply(1:nrow(df), function (n)
    ifelse(df$explore[n] == 1, choice_matrix[problem[n], 1], choice_matrix[problem[n], 2]))
  payoff <- df$FinalPay
  outcome <- paste(choice, payoff, sep = ":")
  stage <- education <- note2 <- NA
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine and save processed data
psd_combined <- do.call("rbind", psd_list)
ds_final <- psd_combined [order(psd_combined$subject, psd_combined$problem, psd_combined$trial), ]
# Study 1
ds_final1 <- ds_final[ds_final$note1 == "Independent",]
file_name1 <- paste0(paper, "_", "1", "_", "data.csv")
# Study 2
ds_final2 <- ds_final[ds_final$note1 == "Yoked",]
ds_final2$study <- 2
file_name2 <- paste0(paper, "_", "2", "_", "data.csv")

setwd(data_path)
write.table(ds_final1, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(ds_final2, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
