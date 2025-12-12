### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Shin et. al (2014) Neural correlates of social perception on response bias

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "SKH2014"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Study 1
# YES and NO options - 3 problems: yeasayer, naysayer, and neutral, each with Y and N options in that order
option <- c("A", "B", "C", "D", "E", "F")
out_1 <- c(1,   1,     1,    1,   1,   1)
pr_1 <- c(0.8,  0.2,   0.2,  0.8, 0.5, 0.5)
out_2 <- c(0,   0,     0,    0,   0,   0)
pr_2 <- c(0.2,  0.8,   0.8,  0.2, 0.5, 0.5)
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Study 2
options_table2 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options sheet
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
exp1_file <- "ShinKimHan2014_Exp1.csv"
exp2_file <- "ShinKimHan2014_Exp2.csv"
ds1 <- read.csv(exp1_file, stringsAsFactors = FALSE)
ds2 <- read.csv(exp2_file, stringsAsFactors = FALSE)
problem <- 1
option <- c("A", "B", "C", "D", "E", "F")
choice_pairs <- matrix(option, nrow = 3, ncol = 2, byrow = TRUE)
condition_map <- c(`Yeasayer`=1, `Naysayer`=2, `Neutral`=3)
options_map <- c(`1`="A_B", `2`="C_D", `3`="E_F")
response_map <- c(`Y`=1, `N`=2) # To map to choice matrix

process_st <- function (ds, st) {
  
  study <- st
  subject_freq <- rle(sort(ds$Subject))
  psd_list <- vector(mode = "list", length(subject_freq$values))
  
  for (sb in 1:length(subject_freq$values)) {
    subject <- subject_freq$values[sb]
    df <- ds[ds$Subject == subject, ] # Subject's data
    cnd <- unname(condition_map[df$Condition])
    # problem <- cnd
    problem <- 1
    options <- unname(options_map[as.character(cnd)])
    trial <- 1:length(df$Trial) # Collapse all blocks
    response_code <- unname(response_map[as.character(df$Response)])
    choice <- sapply(1:length(response_code), function (r) choice_pairs[cnd[r], response_code[r]])
    result_code <- unname(response_map[as.character(df$Outcome)])
    result <- sapply(1:length(result_code), function (r) choice_pairs[cnd[r], result_code[r]])
    outcome <- ifelse(result == choice, paste(choice, "1", sep = ":"), paste(choice, "0", sep = ":"))
    if (st == 1) {
      sex <- age <- NA
    } else {
      sex <- tolower(df$SubjSex)
      age <- df$SubjAge
    }
    response_time <- ifelse(df$RT == "NaN", NA, round(df$RT))
    stage <- education <- note1 <- note2 <- condition <- NA
    # Create final dataframe
    pdf <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    psd_list[[sb]] <- pdf
  }
  # Combine
  psd_combined <- do.call("rbind", psd_list)
  return(psd_combined)
}

# Function calls
ds_st1_final <- process_st(ds = ds1, st = 1)
ds_st2_final <- process_st(ds = ds2, st = 2)
# Save data
file_name1 <- paste0(paper, "_", "1", "_", "data.csv")
file_name2 <- paste0(paper, "_", "2", "_", "data.csv")
setwd(data_path)
write.table(ds_st1_final, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(ds_st2_final, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
