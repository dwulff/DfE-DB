### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Skvortsova et al. (2014) Learning To Minimize Efforts versus Maximizing Rewards: Computational Principles and Neural Correlates

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "SPP2014"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

##### Create the options sheets, for effort, low effort is gain, code as 1, high effort is loss, code as 0
# optimal and non-optimal
option <- LETTERS[1:24]
out_1 <- rep(c(20, 20, 10, 10, 1, 1, 0, 0), 3)
pr_1 <- rep(c(0.75, 0.25),12)
out_2 <- rep(c(10, 10, 20, 20, 0, 0,  1, 1),3)
pr_2 <- rep(c(0.25, 0.75),12)
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)

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
setwd("data_Skvortsova2014/")
study <- 1
if (!requireNamespace("R.matlab", quietly = TRUE)) install.packages("R.matlab")
library(R.matlab)
files <- list.files()
# Remove script file from list
files <- files[-which(files == "BMCNtestComment.m")]
# Extract subject IDs
subject_ids <- gsub('^.*BMCNtestSub\\s*|\\s*ses.*$', '', files)
# Arrange into lists for parallel access (divided by 3 for 3 sessions)
subject_ids_list <- split(subject_ids, ceiling(seq_along(subject_ids)/3))
files_list <- split(files, ceiling(seq_along(files)/3))
option <- LETTERS[1:24]
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
option_map <- paste(choice_pairs[,1], choice_pairs[,2],sep = "_")
psd_list <- vector(mode = "list", length(files_list))

for (sb in 1:length(files_list)) {
  subject <- as.numeric(subject_ids_list[[sb]][1])
  
  process_session <- function(ds) {
    # Function to process session data
    df <- as.data.frame(ds$data)
    colnames(df) <- c("session", "trial", "condition", "u1", "u2", "u3", "u4", "u5", "u6", "u7", "choice", "choice_rt", "squeeze_rt", "gain", "effort", "u9", "u10")
    note1 <- paste("Session", df$session, sep = " ")
    condition <- df$condition # 1 = high gain high effort, 2 = low gain low effort, 3 = high gain low effort, 4 = low gain high effort
    problem <- df$problem <- 4 * (df$session-1) + condition
    trial <- df$trial
    options <- option_map[problem]
    choice <- ifelse(df$choice == 1, choice_pairs[df$problem,1], choice_pairs[df$problem,2])
    # Gain on this trial (coded 0.4 for big and 0.2 for small reward)
    # Effort on this trial (coded 0.2 and 0.8 for low and high efforts)
    gain <- ifelse(df$gain == 0.4, 20, 10)
    effort <- ifelse(df$effort==0.2, 1, 0)
    response_time <- round(df$choice_rt)
    outcome <- ifelse(condition %in% c(1, 2),
                      paste(choice, gain, sep=":"),
                      paste(choice, effort, sep=":"))
    note2 <- ifelse(condition %in% c(1, 2),ifelse(df$effort == 0.2, "Small effort", "Big effort"), ifelse(df$gain == 0.4, "20 payment", "10 payment"))
    # Rest of variables
    problem <- 1
    stage <- sex <- age <- education <- NA
    # Create final dataframe
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    return(psd)
  }
  # Function calls to process the sessions and recombine
  psd_s1 <- process_session(ds = readMat(files_list[[sb]][1]))
  psd_s2 <- process_session(ds = readMat(files_list[[sb]][2]))
  psd_s3 <- process_session(ds = readMat(files_list[[sb]][3]))
  psd <- rbind(psd_s1, psd_s2, psd_s3)
  psd_list[[sb]] <- psd # Store
}

# Combine and save processed data
psd_combined <- do.call("rbind", psd_list)
ds_final <- psd_combined [order(psd_combined$subject), ]
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
