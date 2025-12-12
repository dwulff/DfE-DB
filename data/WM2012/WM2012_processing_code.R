### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Worthy & Maddox (2012) Age-based differences in strategy use in choice tasks

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "WM2012"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# Four cards (yoked pairs) but two underlying options (decks) in each task
# Choice-independent task (ABCD), and choice-dependent task (EFGH)
option <- c("A", "B", "C", "D", "E", "F", "G", "H")
description <- c("Pre-defined/trial - 1-10 points, smaller reward over trials 1-50, larger reward over the final 30 trials",
                 "Pre-defined/trial - 1-10 points, smaller reward over trials 1-50, larger reward over the final 30 trials",
                 "Pre-defined/trial - 1-10 points, larger reward over trials 1-50, smaller reward over the final 30 trials",
                 "Pre-defined/trial - 1-10 points, larger reward over trials 1-50, smaller reward over the final 30 trials",
                 "Pre-defined/trial - 1-10 points, smaller reward initially but reward value increases as more cards are drawn from the deck",
                 "Pre-defined/trial - 1-10 points, smaller reward initially but reward value increases as more cards are drawn from the deck",
                 "Pre-defined/trial - 1-10 points, larger reward initially but reward value decreases as more cards are drawn from the deck",
                 "Pre-defined/trial - 1-10 points, larger reward initially but reward value decreases as more cards are drawn from the deck")
options_table <- data.frame(option, description)

# Save options
file_name <- paste0(paper, "_", "1", "_", "options.csv")
setwd(data_path)
write.table(options_table, file = file_name, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")

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
# Choice-independent task data
setwd("WorthyMaddox2012Frontiers")
fdata_older <- "WorthyMaddox2012FrontiersOlderAdults.txt"
fdata_younger <- "WorthyMaddox2012FrontiersYoungerAdults.txt"
ds_ci_older <- read.table(fdata_older, header = FALSE, stringsAsFactors = FALSE,
                       col.names = c("response_time", "choice", "choice_redund", "reward", "subject"))
ds_ci_younger <- read.table(fdata_younger, header = FALSE, stringsAsFactors = FALSE,
                         col.names = c("response_time", "choice", "choice_redund", "reward", "subject"))
# Choice-dependent task data
setwd("..") # Back to raw_data directory
fdata_older <- "WorthyMaddox2012FrontiersOlderAdultsExplore.txt"
fdata_younger <- "WorthyMaddox2012FrontiersYoungerAdultsExplore.txt"
ds_cd_older <- read.table(fdata_older, header = FALSE, stringsAsFactors = FALSE,
                          col.names = c("response_time", "choice", "choice_redund", "reward", "subject"))
ds_cd_younger <- read.table(fdata_younger, header = FALSE, stringsAsFactors = FALSE,
                            col.names = c("response_time", "choice", "choice_redund", "reward", "subject"))
# length(unique(ds_cd_older$subject)) + length(unique(ds_ci_older$subject)) = 58
# length(unique(ds_cd_younger$subject)) + length(unique(ds_ci_younger$subject)) = 56
option <- c("A", "B", "C", "D", "E", "F", "G", "H")
choice_pairs <- matrix(option, ncol = 4, byrow = TRUE)

process_st <- function (ds, p, subject_id_index) {
  subject_freq <- rle(ds$subject) # Subject IDs and frequencies
  psd_list <- vector(mode = "list", length(subject_freq$values))
  
  for (sb in 1:length(subject_freq$values)) {
    subject <- subject_id_index
    subject_id_index <- subject_id_index + 1
    df <- ds[ds$subject == subject_freq$values[sb], ]
    problem <- p
    condition <- p
    options <- paste(choice_pairs[p, ], collapse = "_")
    trial <- 1:nrow(df)
    # Mentioned in an email that choice codes 1,2 = deck A (will be checked in validation)
    choice <- choice_pairs[p, df$choice]
    outcome <- paste(choice, df$reward, sep = ":")
    response_time <- round(df$response_time * 1000)
    note1 <- ifelse(p == 1, "Choice-independent problem", "Choice-dependent problem")
    stage <- sex <- age <- education <- note2 <- NA
    # Create final dataframe
    psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    psd_list[[sb]] <- psd
  }
  # Combine processed data
  psd_combined <- do.call("rbind", psd_list)
  return(psd_combined)
}

# Function calls
ind = 1
psd_ci_older <- process_st (ds = ds_ci_older, p = 1, subject_id_index = ind)
ind <- length(unique(ds_ci_older$subject)) + 1
psd_ci_younger <- process_st (ds = ds_ci_younger, p = 1, subject_id_index = ind)
ind <- length(unique(ds_ci_older$subject)) + length(unique(ds_ci_younger$subject)) + 1
psd_cd_older <- process_st (ds = ds_cd_older, p = 2, subject_id_index = ind)
ind <- length(unique(ds_ci_older$subject)) + length(unique(ds_ci_younger$subject)) + length(unique(ds_cd_older$subject)) + 1
psd_cd_younger <- process_st (ds = ds_cd_younger, p = 2, subject_id_index = ind)

# Combine and save processed data
ds_final <- rbind(psd_ci_older, psd_ci_younger, psd_cd_older, psd_cd_younger)
file_name <- paste0(paper, "_", "1", "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
