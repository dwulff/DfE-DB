### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Nevo & Erev (2012) On surprise, change, and the effect of recent outcomes

if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "NE2012"
studies <- c(1, 2)
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Study 1: options and data processing

# Two problems, safe and risky choice in this order
option <- c("A", "B", "C", "D")
out_1 <- c(0, 10, 0, 1)
pr_1 <- c(1.0, 0.1, 1.0, 0.9)
out_2 <- c(NA, -1, NA, -10)
pr_2 <- c(NA, 0.9, NA, 0.1)
# Save to data frame
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)
# Save options sheets
file_name1 <- paste0(paper, "_", studies[1], "_", "options.csv")

setwd(data_path)
write.table(options_table1, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

# Back to raw data directory

setwd(raw_path)
file_data <- "NevoErev2012.txt"
ds <- read.table(file_data, skip = 8, header = TRUE, stringsAsFactors = FALSE)
subject <- ds$id
options_map <- c(`4`="A_B", `1`="C_D") #cond = 4 corresponds to problem 1 in the paper
options <- as.character(options_map[as.character(ds$cond)])
problem <- ifelse(ds$cond == 1, 2, 1) #cond = 1 corresponds to problem 2 in the paper
trial <- ds$t
option <- c("A", "B", "C", "D")
choice_pairs <- matrix (option, ncol = 2, byrow = TRUE) # Used when mapping choices
choice_row_map <- c(`10`=1, `-10`=2)
choice_index <- as.numeric(choice_row_map[as.character(ds$rl)]) # rl = 10 or -10
choice <- sapply(1:nrow(ds),
                 function (p) ifelse(as.numeric(ds[p, "v"]) == 0, choice_pairs[choice_index[p], 1], choice_pairs[choice_index[p], 2]))
choice_fg <- sapply(1:nrow(ds),
                 function (p) ifelse(as.numeric(ds[p, "v"]) == 0, choice_pairs[choice_index[p], 2], choice_pairs[choice_index[p], 1]))
outcomes_raw <- ds$v
outcomes_fg_raw <- ds$f
outcome <- ifelse(is.na(choice),NA,paste(paste(choice, outcomes_raw, sep = ":"), paste(choice_fg, outcomes_fg_raw, sep = ":"), sep = "_"))
# Rest of variables
study <- studies[1]
response_time <- stage <- sex <- age <- education <- note1 <- note2 <- condition <- NA
# Create final dataframe
psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
ds_st1_final <- psd[order(psd$subject, psd$problem, psd$trial), ]
# Save data
file_name1 <- paste0(paper, "_", studies[1], "_", "data.csv")

setwd(data_path)
write.table(ds_st1_final, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################


### Study 2: Options and data processing

### Options: 12 problems, safe and risky choices, in this order
#rm(list=setdiff(ls(), c("path", "paper", "studies")))
setwd(raw_path)

file_data <- "Nevo Erev compforg.txt"
ds <- read.table(textConnection(gsub("_", "\t", readLines(file_data))), skip = 3, header = TRUE, stringsAsFactors = FALSE,
                 col.names = c("obs", "subject", "problem", "trial", "order", "rh", "prh", "rl", "s", "risky_selected", "obtained", "foregone"))
#option <- LETTERS[seq(from = 1, to = 24)]
option <- LETTERS[1:24]
# Select only certain columns and reduce the rows to the unique problems and their info
ds_problem_unq <- unique(subset(ds, select = c(problem, s, rh, prh, rl)))
out_1 <- c(rbind(ds_problem_unq$s, ds_problem_unq$rh))
pr_1 <- c(rbind(1.0, ds_problem_unq$prh))
out_2 <- c(rbind(NA, ds_problem_unq$rl))
pr_2 <- c(rbind(NA, round(1 - ds_problem_unq$prh, digits = 2)))
options_table2 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options sheets
file_name2 <- paste0(paper, "_", studies[2], "_", "options.csv")
setwd(data_path)
write.table(options_table2, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")


# Back to data processing
setwd(raw_path)

# Options and choices
choice_pairs <- matrix (option, ncol = 2, byrow = TRUE)
options <- sapply(1:nrow(ds), function(p) paste(choice_pairs[ds$problem[[p]], 1], choice_pairs[ds$problem[[p]], 2], sep = "_"))
choice <- sapply(1:nrow(ds), function(e)
  ifelse(ds$risky_selected[[e]] == 0, choice_pairs[ds$problem[[e]], 1], choice_pairs[ds$problem[[e]], 2]))
choice_fg <- sapply(1:nrow(ds), function(e)
  ifelse(ds$risky_selected[[e]] == 0, choice_pairs[ds$problem[[e]], 2], choice_pairs[ds$problem[[e]], 1]))
# Outcomes
outcome <- paste(paste(choice, ds$obtained, sep = ":"),paste(choice_fg, ds$foregone, sep = ":"),sep = "_")
# Rest of variables
study <- studies[2]
response_time <- sex <- age <- stage <- education <- note1 <- note2 <- condition <- NA
# Bind new variables
ds <- cbind(ds, paper, study, options, condition, choice, outcome, response_time, sex, age, stage, education, note1, note2)
# Required order of variables: paper, study, subject, problem, options, trial, choice, outcome
ds_st2_final <- ds[, c("paper", "study", "subject", "problem", "condition", "options", "trial", "choice", "outcome", "response_time", "stage", "sex", "age", "education", "note1", "note2")]

# Save data
file_name2 <- paste0(paper, "_", studies[2], "_", "data.csv")
setwd(data_path)
write.table(ds_st2_final, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
