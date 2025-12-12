### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Teoderescu et al. (2013) The experience-description gap and the role of the inter decision interval

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "TAE2013"
studies <- c(1, 2, 3)
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

### Study 1
# Two problems, safe and risky choices in each (+ full descriptions)
# Problem 1: AB (rare treasures), Problem 2: CD (rare disaster)
option <-  LETTERS[1:8]
out_1 <- c(rep(c(0, 10, 0, -10), 2))
pr_1 <- c(rep(c(1, 0.1, 1, 0.1), 2))
out_2 <- c(rep(c(NA, -1, NA, 1), 2))
pr_2 <- c(rep(c(NA, 0.9, NA, 0.9), 2))
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)
### Study 2
### Study 3
# Same

# Save options
file_name1 <- paste0(paper, "_", studies[1], "_", "options.csv")
file_name2 <- paste0(paper, "_", studies[2], "_", "options.csv")
file_name3 <- paste0(paper, "_", studies[3], "_", "options.csv")
setwd(data_path)
write.table(options_table, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(options_table, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(options_table, file = file_name3, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

################################################################################################

### Process dataset

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper", "studies","raw_path","data_path","option")))
# Back to raw data directory
setwd(raw_path)
file_data <- "Teodorescu et al 2013.txt"
ds <- read.table(file_data, header = TRUE, stringsAsFactors = FALSE)
st_freq <- rle(ds$study)
# So study="delay_with_description" is study 1 (description-based repeated choice)
# study="delay_no_description" is study 2 (experience only)
# study="distruction_no_description" is study 3
df1 <- ds[ds$study == st_freq$values[2], ] # Study 1's data (index 2)
df2 <- ds[ds$study == st_freq$values[1], ] # Study 2
df3 <- ds[ds$study == st_freq$values[3], ] # Study 3

process_st <- function (df, st) {
  study <- st
  #subject_freq <- rle(df$id)
  subject <- df$id
  sex <- ifelse(df$male == 1, "m", "f")
  # Problem 1: A_B (rare treasures), Problem 2: C_D (rare disaster)
  #problem_map <- c(`10`="1", `-10`="2")
  #problem <- as.character(problem_map[as.character(df$rare)])
  #problem <- ifelse(df$)
  #options_map <- c(`10`="A_B", `-10`="C_D")
  #options <- as.character(options_map[as.character(df$rare)])
  trial <- df$t
  # Get subject choices for each problem, then assign appropriate options
  # condition <- 1
  if (st == 1) {
    condition <- ifelse(df$delay == 0, 1, 2)
    note1 <- ifelse(df$delay == 0, "Full description of payoff distribution", "Full description + 7.8 s of inter-trial delay")
    problem <- sapply(1:nrow(df), function (x) 
      ifelse(df$description[x]==1 & df$delay[x]==0 & df$distruction[x]==0, 
             ifelse(df$rare[x]==10, 1, 2), ifelse(df$rare[x]==10, 3, 4)))  
  } else if (st == 2) {
    condition <- ifelse(df$delay == 1, 2, 1)
    note1 <- ifelse(df$delay == 1, "Experience with an inter-trial delay", "Experience only")
    problem <- sapply(1:nrow(df), function (x) 
      ifelse(df$description[x]==0 & df$delay[x]==0 & df$distruction[x]==0, 
             ifelse(df$rare[x]==10, 1, 2), ifelse(df$rare[x]==10, 3, 4)))  
  } else { # Study 3
    condition <- ifelse(df$distruction == 1, 2, 1)
    note1 <- ifelse(df$distruction == 1, "Eperience with an inter-trial memory task", "Experience only") # distruction = distraction
    problem <- sapply(1:nrow(df), function (x) 
      ifelse(df$description[x]==0 & df$delay[x]==0 & df$distruction[x]==0, 
             ifelse(df$rare[x]==10, 1, 2), ifelse(df$rare[x]==10, 3, 4)))  
  }
  #choice <- sapply(1:nrow(df), function (p)
    #ifelse(problem[p] == 1, ifelse(df$risk[p] == 0, "AA", "AB"), ifelse(df$risk[p] == 0, "AC", "AD")))
  options <- paste(option[problem*2-1], option[problem*2], sep='_')
  choice <- ifelse(df$obtained==0, substring(options, 1,1), substring(options, 3,3))
  choice_fg <- ifelse(df$obtained==0, substring(options, 3,3), substring(options, 1,1))
  outcome <- paste(paste(choice, as.character(df$obtained),sep = ":"), paste(choice_fg, as.character(df$foregone), sep = ":"), sep = "_")
  # Rest of variables
  response_time <- age <- stage <- education <- note2 <- NA
  # Processed data
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd <- psd [order(psd$subject, psd$problem), ] # Order the dataset
  return(psd)
}

# Function calls
ds_st1 <- process_st(df1, studies[1])
ds_st2 <- process_st(df2, studies[2])
ds_st3 <- process_st(df3, studies[3])
# Save processed data
file_name1 <- paste0(paper, "_", studies[1], "_", "data.csv")
file_name2 <- paste0(paper, "_", studies[2], "_", "data.csv")
file_name3 <- paste0(paper, "_", studies[3], "_", "data.csv")
setwd(data_path)
write.table(ds_st1, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(ds_st2, file = file_name2, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
write.table(ds_st3, file = file_name3, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
