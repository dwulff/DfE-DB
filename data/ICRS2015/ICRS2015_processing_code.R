### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Itthipuripat et al. (2014) Value-based attentional capture influences context-dependent decision-making

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "ICRS2015"
# Set as working directory the folder that contains the data as sent by the author
raw_path1 = paste0("/Users/yang/Desktop/material/ARC/项目/3_Data/Final_Yujia/",paper,"/raw/itthipuripat2015_value/behExp1/data")
raw_path2 = paste0("/Users/yang/Desktop/material/ARC/项目/3_Data/Final_Yujia/",paper,"/raw/itthipuripat2015_value/behExp2/data")
data_path = paste0(path,"/processed/")
setwd(data_path)

##### Create the options sheet

### Study 1
# A refers to red bottom, B refers to green, C refers to blue. Overall, they looks the same, but in different mini-blocks, each color always refers to one outcome. 
study <- 1
option <- c("A", "B", "C")
description <- rep("when on left/right position, P(0)=0.5, P(1)=1/6, P(5)=1/6, P(9)=1/6; when on centre position, P(0)=1",3)
options_table <- data.frame(option, description)

# Save options
file_name <- paste0(paper, "_", study, "_", "options.csv")
write.table(options_table, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

### Study 2
study <- 2
# Save options
file_name <- paste0(paper, "_", study, "_", "options.csv")
write.table(options_table, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

### Process dataset

# Clear all variables except path, paper
rm(list=setdiff(ls(), c("path", "paper", "raw_path1", "raw_path2", "data_path")))

### Study 1
# Back to raw data directory
setwd(raw_path1)
# Read dataset
study <- problem <- 1
# subject
sb <- unique(read.csv('subNum.csv')$fieldData)
subject <- rep(sb, each = 1944)
# options
option_left_color = read.csv('stimcolor_tgleft.csv')
option_right_color = read.csv('stimcolor_tgright.csv')
option_left = ifelse(option_left_color$fieldData1 != 0, 'A', ifelse(option_left_color$fieldData2 != 0, 'B', 'C'))
option_right = ifelse(option_right_color$fieldData1 != 0, 'A', ifelse(option_right_color$fieldData2 != 0, 'B', 'C'))
options <- paste(option_left, option_right, sep = "_")
#trials
trial <- rep(1:1944, times=28)
#choice
choice_data = read.csv('resp.csv')$fieldData
choice <- vector('character', length = length(choice_data))
for (i in 1:length(choice_data)){
  choice[i] = ifelse (choice_data[i] == 1, option_left[i], ifelse(choice_data[i] == 2, option_right[i], NA))
}
#outcome
outcome_data = read.csv('feedback.csv')$fieldData
outcome <- ifelse(is.nan(outcome_data), NA, paste(choice,outcome_data,sep = ":"))
#response_time
rt_data = read.csv('RT.csv')$fieldData
response_time <- ifelse(is.nan(rt_data), NA, round(rt_data * 1000))
# else
condition <- stage <- sex <- age <- education <- note1 <- note2 <- NA
# Create final dataframe
ds_st1 <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)

# Save
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_st1, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

### Study 2
# Back to raw data directory
setwd(raw_path2)
# Read dataset
study <- 2 
problem <- 1
# subject
sb <- unique(read.csv('subNum.csv')$fieldData)
sb1 <- rep(1:5, each=1944)
sb2 <- rep(6, each=1728)
sb3 <- rep(sb[!(sb %in% c(1:6))], each=1944)
subject <- c(sb1, sb2, sb3)
# options
option_left_color = read.csv('stimcolor_tgleft.csv')
option_right_color = read.csv('stimcolor_tgright.csv')
option_left <- ifelse(option_left_color$fieldData1 != 0, 'A', ifelse(option_left_color$fieldData2 != 0, 'B', 'C'))
option_right <- ifelse(option_right_color$fieldData1 != 0, 'A', ifelse(option_right_color$fieldData2 != 0, 'B', 'C'))
options <- paste(option_left, option_right, sep = "_")
#trials
trial1 <- rep(1:1944, times=5)
trial21 <- rep(109:972, times=1)
trial22 <- rep(1081:1944, times=1)
trial3 <- rep(1:1944, times=20)
trial = c(trial1, trial21, trial22, trial3)
#choice
choice_data <- read.csv('resp.csv')$fieldData
choice <- vector('character', length = length(choice_data))
for (i in 1:length(choice_data)){
  choice[i] = ifelse (choice_data[i] == 1, option_left[i], ifelse(choice_data[i] == 2, option_right[i], NA))
}
#outcome
outcome_data <- read.csv('feedback.csv')$fieldData
outcome <- ifelse(is.nan(outcome_data), NA, paste(choice,outcome_data,sep = ":"))
#response_time
rt_data = read.csv('RT.csv')$fieldData
response_time = ifelse(is.nan(rt_data), NA, round(rt_data * 1000))
# else
condition <- stage <- sex <- age <- education <- note1 <- note2 <- NA
# Create final dataframe
ds_st2 <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)

# Save
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_st2, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

