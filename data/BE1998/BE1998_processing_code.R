### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Bereby-Meyer & Erev (1998) On Learning To Become a Successful Loser: A Comparison of Alternative Abstractions of Learning Processes in the Loss Domain

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "BE1998"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)
study <- 1
# Set as working directory the folder that contains the data as sent by the author
setwd(raw_path)

##### Generate the options sheet
# Two options - Blue or Red
# Conditions (4,0), (2,-2), and (0,-4)
option <- c("A", "B", "C", "D", "E", "F")
out_1 <- c(4, 4, 2, 2, 0, 0)
pr_1 <- c(0.7, 0.3, 0.7, 0.3, 0.7, 0.3)
out_2 <- c(0, 0, -2, -2, -4, -4)
pr_2 <- c(0.3, 0.7, 0.3, 0.7, 0.3, 0.7)
#description <- c("For each participant, either A or B is correct/rewarded in 70% of the trials")
#options_table <- data.frame(option, description)
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options
file_name <- paste0(paper, "_", study, "_", "options.csv")
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
rm(list=setdiff(ls(), c("path", "paper", "study", "data_path", "raw_path")))
# Back to raw data directory
setwd(raw_path)
data_file <- "PM5 Erev BerebyMeyer Roth.dat"
ds <- read.table(data_file, header = TRUE, stringsAsFactors = FALSE)
# The 1998 conditions are the ones with good = 0, 2 and 4
# Conditions (4,0), (2,-2), and (0,-4) - 42 participants * 500 trials = 21,000 obs
dsp4 <- ds[ds$good == 4, ] # Problem 1
dsp2 <- ds[ds$good == 2, ] # Problem 2
dsp0 <- ds[ds$good == 0, ] # Problem 3
problem_map <- c(`4`=1, `2`=2, `0`=3) # Condition to problem map
opts_map <- c(`4`="AB", `2`="CD", `0`="EF") # Condition to options map
options_map <- c(`4`="A_B", `2`="C_D", `0`="E_F")

process_st <- function (df, cnd) {
  subject_freq <- rle(df$id)
  problem <- as.numeric(problem_map[as.character(cnd)])
  condition <- problem
  options <- unname(options_map[as.character(cnd)])
  # Separate options
  opts_raw <- unname(opts_map[as.character(cnd)])
  opts <- sapply(1:nchar(options), function (p) substr(opts_raw, p, p))
  psd_list <- vector(mode = "list", length(subject_freq$values))
  
  for (sb in 1:length(subject_freq$values)) {
    subject <- subject_freq$values[sb]
    df_sb <- df[df$id == subject, ] # Subject data
    trial <- df_sb$t
    # Since the color or option was not recorded during data collection, assume the high reward prob option is A,C,E
    # state = 1 means the maximising option occurred, d = 1 means it was chosen/predicted
    choice <- sapply(1:nrow(df_sb), function (n) {
      if (df_sb$state[n] == 1) {
        if (df_sb$d[n] == 1) {
          return(opts[1])
        } else {
          return(opts[2])
        }
      } else { # state = 0
        if (df_sb$d[n] == 1) {
          return(opts[1])
        } else {
          return(opts[2])
        }
      }
    })
    payoff <- sapply(1:nrow(df_sb), function (n) {
      if (df_sb$state[n] == 1) {
        if (df_sb$d[n] == 1) {
          return(cnd)
        } else {
          return(cnd - 4)
        }
      } else { # state = 0
        if (df_sb$d[n] == 1) {
          return(cnd - 4)
        } else {
          return(cnd)
        }
      }
    })
    outcome <- paste(choice, payoff, sep = ":")
    response_time <- stage <- sex <- age <- education <- note1 <- note2 <- NA
    # Create final dataframe
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    psd_list[[sb]] <- psd
  }
  psd_combined <- do.call("rbind", psd_list)
  return(psd_combined)
}

psd4 <- process_st(df = dsp4, cnd = 4)
psd2 <- process_st(df = dsp2, cnd = 2)
psd0 <- process_st(df = dsp0, cnd = 0)
ds_final <- rbind(psd4, psd2, psd0)
# Save processed data
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
