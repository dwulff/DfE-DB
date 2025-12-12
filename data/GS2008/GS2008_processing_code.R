### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Gaissmaier & Schooler (2008) The smart potential behind probability matching

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "GS2008"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

##### Create the options sheet
# Predict a red square on top, or a green square in the bottom
# Study 1
option <- c("A", "B")
out_1 <- c(1, 1)
pr_1 <- c(0.67, 0.33)
out_2 <- c(0, 0)
pr_2 <- c(0.33, 0.67)
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Study 2
option <- c("A", "B")
out_1 <- c(1, 1)
pr_1 <- c(0.67, 0.33)
out_2 <- c(0, 0)
pr_2 <- c(0.33, 0.67)
options_table2 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options
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

### Study 1
# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper", "raw_path", "data_path")))
# Back to raw data directory
setwd(raw_path)
study <- 1
library(foreign)
library(readxl)
# Read data
file_data <- "Gaissmaier_Schooler_2008_Exp1_Choice_Data.xlsx"
ds_resp <- read_excel(file_data, sheet = "RESP")
ds_resp <- ds_resp[-c(1:8), -2] # Remove extraneous rows/columns
ds_resp <- ds_resp[, -c(2:11)] # Remove training trials
ds_cresp <- read_excel(file_data, sheet = "CRESP")
ds_cresp <- ds_cresp[-c(1:9), -2]
ds_cresp <- ds_cresp[, -c(2:11)]
ds_acc <- read_excel(file_data, sheet = "ACC")
ds_acc <- ds_acc[-c(1:9), -2]
ds_acc <- ds_acc[, -c(2:11)]
# Read demographic data
file_dmg <- "Gaissmaier_Schooler_2008_Exp1_Demographics.sav"
ds_dmg <- read.spss(file_dmg, to.data.frame = TRUE)
# Sort by experiment and subject numbers
ds_dmg <- ds_dmg [order(ds_dmg$Subject), ]
subject_ids <- as.numeric(unname(unlist((ds_acc[2:nrow(ds_acc), 1])))) # Subject ids
problem <- 1
options <- "A_B"
option <- c("A", "B")
trial <- as.numeric(unname(unlist(ds_resp[2, 2:ncol(ds_resp)])))
condition <- as.numeric(unname(unlist(ds_resp[1, 2:ncol(ds_resp)])))
trial <-ifelse(condition==3, trial + 288, trial)
# Remove trial number row
ds_resp <- ds_resp[-c(1:2), ]
ds_cresp <- ds_cresp[-1, ]
ds_acc <- ds_acc[-1, ]
# To store processed data
psd_list <- vector(mode = "list", length(subject_ids))

for (sb in 1:length(subject_ids)) {
  subject <- subject_ids[sb]
  # Check condition to map optimal and suboptimal options
  if (as.character(as.vector(ds_dmg[ds_dmg$Subject == subject, 2])) %in% c("Pats_Prob_red_green", "Prob_Pats_red_green")) {
    choice <- ifelse(
      as.numeric(unname(unlist(ds_resp[subject, 2:ncol(ds_resp)]))) == 1,
      option[1],
      option[2]
    )
  } else {
    choice <- ifelse(
      as.numeric(unname(unlist(ds_resp[subject, 2:ncol(ds_resp)]))) == 0,
      option[1],
      option[2]
    )
  }
  choice <-ifelse((choice==option[1]) & (condition==3),option[2],ifelse((choice==option[2]) & (condition==3),option[1],choice))
  outcome <- ifelse(as.numeric(unname(unlist(ds_acc[subject, 2:ncol(ds_acc)]))) == 1,
                    paste(choice, "1", sep = ":"), paste(choice, "0", sep = ":"))
  sex <- ifelse(as.character(as.vector(ds_dmg[ds_dmg$Subject == subject, 4])) == "male", "m", "f")
  age <- as.numeric(as.vector(ds_dmg[ds_dmg$Subject == subject, 5]))
  if(as.character(as.vector(ds_dmg[ds_dmg$Subject == subject, 3])) == 'Patterns first'){ condition_2 <- ifelse(condition==2, 2, 1)
  }else{condition_2 <-ifelse(condition==2,1,2)}
  note1<- ifelse(condition_2==1, 'random', 'pattern')
  response_time <- stage <- education <-note2 <- NA
  condition <- condition_2
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine and save processed data
ds_st1_final <- do.call("rbind", psd_list)
file_name <- paste0(paper, "_", "1", "_", "data.csv")
setwd(data_path)
write.table(ds_st1_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

### Study 2
# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper","raw_path", "data_path")))
# Back to raw data directory
setwd(raw_path)
study <- 2
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
library(readxl)
# Read data
file_data <- "Gaissmaier_Schooler_2008_Exp2_Choice_Data.xlsx"
ds_resp <- read_excel(file_data, sheet = "RESP")
ds_resp <- ds_resp[-c(1:8), -2] # Remove extraneous rows/columns
ds_resp <- ds_resp[, -c(2:11)] # Remove training trials
ds_cresp <- read_excel(file_data, sheet = "CRESP")
ds_cresp <- ds_cresp[-c(1:9), -2]
ds_cresp <- ds_cresp[, -c(2:11)]
ds_acc <- read_excel(file_data, sheet = "ACC")
ds_acc <- ds_acc[-c(1:9), -2]
ds_acc <- ds_acc[, -c(2:11)]
# Read demographic data
file_dmg <- "Gaissmaier_Schooler_2008_Exp2_Demographics.sav"
ds_dmg <- read.spss(file_dmg, to.data.frame = TRUE)
# Sort by experiment and subject numbers
ds_dmg <- ds_dmg [order(ds_dmg$Subject), ]
subject_ids <- as.numeric(unname(unlist((ds_acc[2:nrow(ds_acc), 1])))) # Subject ids
problem <- 1
options <- "A_B"
option <- c("A", "B")
trial <- as.numeric(unname(unlist(ds_resp[2, 2:ncol(ds_resp)])))
condition <- as.numeric(unname(unlist(ds_resp[1, 2:ncol(ds_resp)]))) - 1
trial <-ifelse(condition==2, trial + 288, trial)
# Remove trial number row
ds_resp <- ds_resp[-c(1,2), ]
ds_cresp <- ds_cresp[-1, ]
ds_acc <- ds_acc[-1, ]
# To store processed data
psd_list <- vector(mode = "list", length(subject_ids))
# don't have subject 20, only 139 participants in total
for (sb in 1:length(subject_ids)) {
  subject <- subject_ids[sb]
  if (as.character(as.vector(ds_dmg[ds_dmg$Subject == subject, 2])) == "Prob_Pats_red_green") {
    choice <- ifelse(
      as.numeric(unname(unlist(ds_resp[sb, 2:ncol(ds_resp)]))) == 1,
      option[1],
      option[2]
    )
  } else {
    choice <- ifelse(
      as.numeric(unname(unlist(ds_resp[sb, 2:ncol(ds_resp)]))) == 0,
      option[1],
      option[2]
    )
  }
  choice <-ifelse((choice==option[1]) & (condition==2),option[2],ifelse((choice==option[2]) & (condition==2),option[1],choice))
  outcome <- ifelse(as.numeric(unname(unlist(ds_acc[sb, 2:ncol(ds_acc)]))) == 1,
                    paste(choice, "1", sep = ":"), paste(choice, "0", sep = ":"))
  sex <- ifelse(as.character(as.vector(ds_dmg[ds_dmg$Subject == subject, 5])) == "male", "m", "f")
  age <- as.numeric(as.vector(ds_dmg[ds_dmg$Subject == subject, 4]))
  note1<- ifelse(condition==1, 'random', 'pattern')
  response_time <- stage <- education <-  note2 <- NA
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine and save processed data
ds_st2_final <- do.call("rbind", psd_list)
file_name <- paste0(paper, "_", "2", "_", "data.csv")
setwd(data_path)
write.table(ds_st2_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
