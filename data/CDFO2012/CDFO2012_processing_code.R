### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Cooper et al. (2012) Human Dorsal Striatum Encodes Prediction Errors during Observational Learning of Instrumental Actions

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "CDFO2012"
study <- 1
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/raw_data_for_meta/data")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

option <- c("A", "B", "C", "D")

# Order of conditions
# 1 Experienced/Observed instrumental (A, B)
# 2 Experienced/Observed/Test noninstrumental (C, D)

description <- c("Left arm of a two armed slot machine - choice is followed by a random delay before a liquid reward (+visual: green square) or neutral outcome (+visual: gray square) with a probability taken from a sine curve whose start and half-period are randomly determined",
                 "Right arm of a two armed slot machine - choice is followed by a random delay before a liquid reward (+visual: green square) or neutral outcome (+visual: gray square) with a probability taken from a sine curve whose start and half-period are randomly determined",
                 "Left arm of a two armed slot machine - choice made by computer with an independent reward probability distribution. The computer selects the side with the higher probability of reward 70% of the time, the choice is presented on screen and the participant has to indicate that the left arm was chosen",
                 "Right arm of a two armed slot machine - choice made by computer with an independent reward probability distribution. The computer selects the side with the higher probability of reward 70% of the time, the choice is presented on screen and the participant has to indicate that the right arm was chosen")

options_table <- data.frame(option, description)

file_name <- paste0(paper, "_", study, "_", "options.csv")
# Save
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
rm(list=setdiff(ls(), c("data_path","raw_path", "paper", "study")))
# Go to data directory
setwd(raw_path)
# # Set problem
# problem_num <- function(input_vector) {
#   output_vector <- rep(NA, length(input_vector))  # create output vector
# 
#   for (i in 1:length(input_vector)) {
#     if (input_vector[i] <= 4) {
#       output_vector[i] <- input_vector[i]
#     } else if (input_vector[i] == 5) {
#       output_vector[i] <- 1
#     } else if (input_vector[i] == 6) {
#       output_vector[i] <- 2
#     } else if (input_vector[i] == 7) {
#       output_vector[i] <- 3
#     } else if (input_vector[i] == 8) {
#       output_vector[i] <- 4
#     } else if (input_vector[i] == 9) {
#       output_vector[i] <- 5
#     } else {
#       output_vector[i] <- 6
#     }
#   }
# 
#   return(output_vector)
# }
# Set note1
condition_means <- function(input_vector) {
  output_vector <- rep(NA, length(input_vector))  # create output vector
  
  for (i in 1:length(input_vector)) {
    if (input_vector[i] == 1) {
      output_vector[i] <- "nonIns_Obs_rew"
    } else if (input_vector[i] == 2) {
      output_vector[i] <- "Ins_Obs_rew"
    } else if (input_vector[i] == 3) {
      output_vector[i] <- "nonIns_Exp_rew"
    } else if (input_vector[i] == 4) {
      output_vector[i] <- "Ins_Exp_rew"
    } else if (input_vector[i] == 5) {
      output_vector[i] <- "nonIns_Obs_neut"
    } else if (input_vector[i] == 6) {
      output_vector[i] <- "Ins_Obs_neut"
    } else if (input_vector[i] == 7) {
      output_vector[i] <- "nonIns_Exp_neut"
    } else if (input_vector[i] == 8) {
      output_vector[i] <- "Ins_Exp_neut"
    } else if (input_vector[i] == 9) {
      output_vector[i] <- "nonIns_Obs_test"
    } else {
      output_vector[i] <- "Ins_Obs_test"
    }
  }
  
  return(output_vector)
}

dirs <- list.files()
psd_list <- vector(mode = "list", length(dirs))
for (sb in 1:length(dirs)) {
  subject <- dirs[sb]
  data = read.table(paste0(dirs[sb],"/cogentResults.res"), header = TRUE, sep = '\t', quote = "")
  stage <- sex <- age <- education <- NA
  # Set Problem
  problem <- data$X.CueCond.
  # Set Condition
  condition <- data$X.CueCond.
  # Set options
  options <- ifelse(condition%%2 == 0, "A_B", "C_D")
  # Set trial
  trial <- data$X.Trial.
  # Set choice
  choice_table <- matrix(c('A','C','B','D'),2,2)
  choice <- ifelse(data$X.Action.=='', NA, ifelse(options=="A_B", choice_table[1,data$X.Action.], choice_table[2,data$X.Action.]))
  # Set outcome
  outcome <- ifelse(is.na(choice), NA,paste(choice, data$X.Out.,sep = ":")) # actual outcome
  # Set RT
  response_time <- ifelse(data$X.ActRT. == 'Inf', NA, data$X.ActRT.)
  # Set note
  note1 <- condition_means(data$X.CueCond.)
  note2 <- ifelse(data$X.CueCond.>8,ifelse(is.numeric(data$X.Correct.), paste("testACT",  data$X.Correct., sep=":"), "testACT NA"), NA) # testACT + correct outcome
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine and save processed data
ds_final <- do.call("rbind", psd_list)
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
