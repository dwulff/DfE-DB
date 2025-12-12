### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Morris et al. (2014) Action-value comparisons in the dorsolateral prefrontal cortex control choice between goal-directed actions

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "MDGB2014"
study <- 1
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet
###c("P(reward) = {0.25, 0.05, 0.05, 0.125, 0.08, 0.05} in blocks {1, 2, 3, 4, 5, 6}, and repeated twice",
###"P(reward) = {0.05, 0.25, 0.125, 0.05, 0.05, 0.08} in blocks {1, 2, 3, 4, 5, 6}, and repeated twice")
option <- LETTERS[1:12]
out_1 <- c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
pr_1 <- c(0.25, 0.05, 0.05, 0.25, 0.05, 0.125, 0.125, 0.05,0.08,0.05,0.05,0.08)
out_2 <- c(0,0,0,0,0,0,0,0,0,0,0,0)
pr_2 <- c(0.75, 0.95, 0.95, 0.75, 0.95, 0.875, 0.875, 0.95,0.92,0.95,0.95,0.92)
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)
# The note variable tells whether the chosen option was the high or low contingency one

# Save
file_name <- paste0(paper, "_", study, "_", "options.csv")
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
rm(list=setdiff(ls(), c("path", "paper", "study","raw_path","data_path")))
# Back to raw data directory
setwd(raw_path)
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
file_dmg <- "DM Study_141113.sav" # File with demographic data
dt_dmg <- read.spss(file = file_dmg, to.data.frame = TRUE)
setwd("Eventslog csv") # Go to experimental data folder
file_list <- list.files() # 21 subjects
rm_indices <- which(grepl(".mat", file_list))
file_list <- file_list[-rm_indices] # Remove .mat files from list
# Extract subject identifiers
subject_ids <- substr(file_list, 1, 5)
# Also extract subject identifiers from dmg, and fix the pattern to use as indices later
dmg_ids <- gsub(pattern = "_", replacement = "", x = dt_dmg$TaskID)
dmg_ids <- substr(dmg_ids, 1, 5)
cont_map <- c(`1`="0.25 CONT, SHAPES", `2`="0.25 CONT, M&MS", `3`="0.125 CONT, SHAPES", `4`="0.125 CONT, M&MS", `5`="0.08 CONT, SHAPES", `6`="0.08 CONT, M&MS")
opt_code_map <- c(`1`="High contingency option chosen but no reward won", `2`="Low contingency option chosen but no reward won",
                  `3`="High contingency option chosen and reward won", `4`="Low contingency option chosen and reward won")
# Process data
psd_list <- vector(mode = "list", length(file_list))
options_map <- c(`1`="A_B", `2`="C_D", `3`="E_F", `4`="G_H", `5` = "I_J", `6` = "K_L")
choice_list <- matrix(LETTERS[1:12], nrow = 6, ncol = 2, byrow = TRUE) 

for (sb in 1:length(file_list)) {
  subject <- subject_ids[sb]
  df <- read.csv(file_list[sb], header = TRUE, stringsAsFactors = FALSE) # Subject data
  df_dmg <- dt_dmg[as.numeric(which(dmg_ids == subject)), ] # Demographic data
  age <- df_dmg$Age
  sex <- ifelse(df_dmg$Gender == "Male", "m", "f")
  education <- paste(df_dmg$Education, "years", sep = " ")
  trial <- 1:nrow(df)
  options <- options_map[as.character(df$TRIAL)]
  choice <- ifelse(df$KEY.PRESSED == 26, choice_list[df$TRIAL, 1], choice_list[df$TRIAL, 2])
  problem <- df$TRIAL
  # No feedback was provided in the absence of a win. 
  outcome <- paste(choice, df$REWARDED, sep = ":")
  note1 <- opt_code_map[as.character(df$CODE)]
  note2 <- cont_map[as.character(df$TRIAL)]
  response_time <- stage <- condition <- NA
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine and save processed data
psd_combined <- do.call("rbind", psd_list)
ds_final <- psd_combined [order(psd_combined$subject, psd_combined$problem, psd_combined$condition, psd_combined$trial), ]
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")
