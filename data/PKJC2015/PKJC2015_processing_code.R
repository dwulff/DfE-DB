### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Palminteri et al. (2015) Contextual modulation of value signals in reward and punishment learning

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "PKJC2015"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)


### Create the options sheet
# Four experimental sessions, each proposing 4 new stimulus pairs
# But two underlying option pairs: reward and punishment, with partial and complete feedback conditions
option <- c(LETTERS, paste0('A', LETTERS[1:6])) # 32
out_1 <- rep(c(0.5,    0.5,    0.5,    0.5,    -0.5,     -0.5,    -0.5,     -0.5), 2)
pr_1 <- rep(c(0.75,    0.25,   0.75,    0.25,  0.25,     0.75,  0.25,     0.75), 2)
out_2 <- rep(c(0,      0,     0,      0,  0,      0,     0,        0), 2)
pr_2 <- rep(c(0.25,    0.75,  0.25,    0.75,     0.75,     0.25, 0.75,     0.25), 2)
# Save to data frame
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options sheet
file_name <- paste0(paper, "_", "1", "_", "options.csv")
setwd(data_path)
write.table(options_table, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

###############################################################################################
### Process dataset

if (!requireNamespace("R.matlab", quietly = TRUE)) install.packages("R.matlab")
library(R.matlab)


# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper","raw_path","data_path")))

# Go to data directory
setwd(raw_path)
setwd("PalminteriNatureCommunications/DataN28")
study <- 1
files <- list.files()

# Extract subject IDs and split into a list of 3-element vectors
subject_ids <- gsub('^.*TestSub\\s*|\\s*_Session.*$', '', files)
subject_ids_list <- split(subject_ids, ceiling(seq_along(subject_ids)/4))

# Split files into a list of 4-element vectors (4 sessions)
files_list <- split(files, ceiling(seq_along(files)/4))
#option <- c("AA", "AB", "AC", "AD")
# (reward/partial, reward/complete, punishment/partial and punishment/complete)

options_map1 <- c(`1`="A_B", `2`="C_D", `3`="E_F", `4`="G_H")
options_map2 <- c(`1`="I_J", `2`="K_L", `3`="M_N", `4`="O_P")
options_map3 <- c(`1`="Q_R", `2`="S_T", `3`="U_V", `4`="W_X")
options_map4 <- c(`1`="Y_Z", `2`="AA_AB", `3`="AC_AD", `4`="AE_AF")
cnd_map <- c(`1`="Reward with partial feedback", `2`="Reward with complete feedback",
              `3`="Punishment with partial feedback", `4`="Punishment with complete feedback")

psd_list <- vector(mode = "list", length(files_list))

option_matrix1 <- matrix(LETTERS[1:8], nrow=4, ncol=2, byrow=TRUE)
option_matrix2 <- matrix(LETTERS[9:16], nrow=4, ncol=2, byrow=TRUE)
option_matrix3 <- matrix(LETTERS[17:24], nrow=4, ncol=2, byrow=TRUE)
option_matrix4 <- matrix(c(LETTERS[25:26],paste0('A', LETTERS[1:6])), nrow=4, ncol=2, byrow=TRUE)

for (sb in 1:length(files_list)) {
  # Read data
  data_v <- files_list[[sb]]
  ds1 <- readMat(data_v[1]) # Data in the "data" structure/list
  ds2 <- readMat(data_v[2])
  ds3 <- readMat(data_v[3])
  ds4 <- readMat(data_v[4])
  df_s1 <- as.data.frame(ds1$data)
  df_s2 <- as.data.frame(ds2$data)
  df_s3 <- as.data.frame(ds3$data)
  df_s4 <- as.data.frame(ds4$data)
  
  subject <- as.numeric(subject_ids_list[[sb]][1])
  
  process_df <- function (df, s) {
    # (1: reward/partial, 2: reward/complete, 3: punishment/partial and 4: punishment/complete)
    # Create column names for reference
    colnames(df) <- c("u1", "u2", "trial", "stim_pair", "u3", "u4", "button_pressed", "choice", "feedback", "foregone", "response_time1", "response_time2", "u6")
    
    note1 <- paste("Session", s, sep = " ") # Session number
    note2 <- cnd_map[as.character(df$stim_pair)]
    trial <- df$trial
    
    if (s==1){
      problem <- df$stim_pair
      opts <- c("A", "B", "C", "D", "E", "F", "G", "H")
      options_map <- options_map1
    }
    else if (s==2){
      problem <- df$stim_pair+4
      opts <- c("I", "J", "K", "L", "M", "N", "O", "P")
      options_map <- options_map2
    }
    else if (s==3){
      problem <- df$stim_pair+8
      opts <- c("Q", "R", "S", "T", "U", "V", "W", "X")
      options_map <- options_map3
    }
    else if (s==4){
      problem <- df$stim_pair+12
      opts <- c("Y", "Z", "AA", "AB", "AC", "AD", "AE", "AF")
      options_map <- options_map4
    }
    problem <- 1
    choice_pairs <- matrix(opts, ncol = 2, nrow = 4, byrow =  TRUE) # Create matrix
    options <- options_map[as.character(df$stim_pair)]
    # 1 stands for the optimal choice (more likely reward or no loss)
    choice <- ifelse(df$choice == 1, choice_pairs[df$stim_pair,1], choice_pairs[df$stim_pair,2])
    reward_map <- c(`1`="0.5", `0`="0")
    punish_map <- c(`1`="0", `0`="-0.5")
    payoff_feedback <- ifelse(df$stim_pair == 1 | df$stim_pair == 2, reward_map[as.character(df$feedback)],
                              punish_map[as.character(df$feedback)])
    ch <- paste(choice, payoff_feedback,sep = ":")
    #foregone <- ifelse(df$feedback == 1, 0, 1) # Foregone payoffs
    fg_choice <- ifelse(df$choice != 1, choice_pairs[df$stim_pair,1], choice_pairs[df$stim_pair,2])
    fg_feedback <- ifelse(df$stim_pair == 1 | df$stim_pair == 2, reward_map[as.character(df$foregone)],
                          punish_map[as.character(df$foregone)])
    fg <- paste(fg_choice,fg_feedback,sep = ":")
    outcome <- sapply(1:nrow(df), function(n)
      ifelse(df$stim_pair[n] == 1 || df$stim_pair[n] == 3, ch[n],
             paste(ch[n],fg[n], sep = "_")))
    
    response_time <- round(df$response_time1) # same as response_time2
    stage <- sex <- age <- education <- condition <- NA
    
    # Create final dataframe
    pdf <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    return(pdf)
  }
  # Function calls
  psd <- rbind(process_df (df = df_s1, s=1), process_df (df = df_s2, s=2),
               process_df (df = df_s3, s=3), process_df (df = df_s4, s=4))
  psd_list[[sb]] <- psd
}
setwd(raw_path)
setwd("PalminteriNatureCommunications/DataN28")

# Combine and save processed data
psd_combined <- do.call("rbind", psd_list)
ds_final <- psd_combined [order(psd_combined$subject), ]
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
