### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Dombrovski, A, Y., et al. (2015) Corticostriatothalamic Reward Prediction Error Signals and Executive Control in Late-Life Depression

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "DSCA2015"
study <- 1
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet
# Study 1
option <- c("A", "B")
description <- c("Starts with a high reward probability range [0.80-0.87] and alternates between high and low reward probability range [0.13-0.20] every 25 trials",
                 "Starts with a low reward probability range [0.13-0.20] and alternates between low and high reward probability range [0.80-0.87] every 25 trials")
options_table <- data.frame(option, description)

# Save options sheet
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
rm(list=setdiff(ls(), c("path", "paper", "study", "raw_path", "data_path")))
# Back to raw data directory
setwd(raw_path)
# Read demographic data
if (!requireNamespace("foreign", quietly = TRUE)) install.packages("foreign")
library(foreign)
# Read subjects file
# 47 participants (31 with major depressive disorder (MDD) and 16 psychiatrically healthy controls)
dmg <- read.spss("reversal_N=53_for_Dawud_2017.sav", to.data.frame = TRUE)
# Read data
if (!requireNamespace("R.matlab", quietly = TRUE)) install.packages("R.matlab")
library(R.matlab)
ds <- readMat("pall.mat")
ds <- ds[["pall"]]
# These are the fields in the main Matlab struct
# {'parmswinlossalphafMRI'}
# {'summary'              }
# {'reversal'             }
# {'beh'                  }
# {'e1'                   }
# {'prob1'                }
# {'behav'                }
# {'timeseries'           }
# {'timeseriesregs'       }
# {'variables'            }
# {'dirname'              }
# This is a matrix of summary statistics, including the subject ID for reference in dmg (7th element)
dt_summ <- as.data.frame(ds[[7]])
# Add variable names to summary matrix
dt_summVars <- unname(unlist(ds[[10]]))
colnames(dt_summ) <- dt_summVars
# The trial by trial data is in the "beh" struct (4th element)
# These are the variables in "beh"
# {'persev'    }
# {'pswitch'   }
# {'sswitch'   }
# {'pstay'     }
# {'switch'    }
# {'switchnext'}
# {'NumRight'  }
# {'feed'      }
# {'RT'        }
# {'onset'     }
data <- ds[[4]]
# All vectors in the "beh" matrix got listed (order row-wise) altogether, so make groups of subject-specific variables
data_list <- split(data, rep(1:ceiling(length(data)/10), each=10)[1:length(data)])
option <- c("A", "B")
problem <- 1
options <- c("A_B")
trial <- 1:300
# List to store each subject's processed data
psd_list <- vector(mode = "list", length(data_list))

# switch func
switch0 <- function(choice0){
  if(choice0=="A"){
    choice0 <- "B"
  }else{
    choice0 <-"A"
  }
  return(choice0)
}

# mean for every 25 trials
choice_check <- function(df){
  averages_A <- c()
  averages_B <- c()
  group_size <- 25
  num_groups <- ceiling(nrow(df) / group_size)
  # calculate average for each 25 trials
  for (i in 1:num_groups) {
    # raw number
    start_row <- (i - 1) * group_size + 1
    end_row <- min(i * group_size, nrow(df))
    # select A/B trials
    group_data <- df[start_row:end_row, ]
    selected_rows_A <- group_data[group_data$choice == "A", ]
    selected_rows_B <- group_data[group_data$choice == "B", ]
    avg_A <- mean(selected_rows_A$outcome, na.rm = TRUE)
    avg_B <- mean(selected_rows_B$outcome, na.rm = TRUE)
    averages_A <- c(averages_A, avg_A)
    averages_B <- c(averages_B, avg_B)
  }
  
  # calculate average in odd-even rounds
  final_average_high_A <- mean(averages_A[seq(1, length(averages_A), by = 2)], na.rm = TRUE)
  final_average_low_A <- mean(averages_A[seq(2, length(averages_A), by = 2)], na.rm = TRUE)
  final_average_high_B <- mean(averages_B[seq(2, length(averages_B), by = 2)], na.rm = TRUE)
  final_average_low_B <- mean(averages_B[seq(1, length(averages_B), by = 2)], na.rm = TRUE)
  #print(paste("A_high",final_average_high_A))
  #print(paste("A_low",final_average_low_A))
  #print(paste("B_high",final_average_high_B))
  #print(paste("B_low",final_average_low_B))
  
  # check whether they start with A
  if (final_average_high_A - final_average_low_A <= -0.05 & final_average_high_B-final_average_low_B <= -0.05){
    choices <- ifelse(df$choice == "A", "B", "A")
  }else{
    choices <- df$choice
  }
  return(choices)
}

for (sb in 1:length(data_list)) {
  subject <- dt_summ$id[sb]
  # Decide whether subject is included in demographics sheet or data can be processed
  ID_match_index <- match(subject, dmg$ID)
  if (!is.na(ID_match_index)) {
    # Extract this subject's trial data
    df_list <- data_list[[sb]]
    # Cast matrices into vectors and set names
    df_list <- lapply(df_list, function (m) as.vector(m))
    df_list <- setNames(df_list,
                        c("persev", "pswitch", "sswitch", "pstay", "switch", "switchnext", "NumRight", "feed", "RT", "onset"))
    response_time <- round(df_list[["RT"]])
    if (length(response_time) == 300) {
      note1 <- ifelse(as.numeric(dmg[dmg$ID == subject, 2]) == 1, "Major depression", "Healthy control")
      # Get demographic data
      sex <- tolower(trimws(as.character(dmg[dmg$ID == subject, "Gender"])))
      age <- as.numeric(dmg[dmg$ID == subject, 7])
      education <- paste(as.character(dmg[dmg$ID == subject, 11]), "years", sep = " ")
      # Assume everyone begin with A
      choice0 <- "A"
      choice <- vector("character", length(df_list[["switch"]]))
      for (i in seq_along(df_list[["switch"]])){
        if(df_list[["switch"]][i] == 0){
          choice[i] <- choice0
        }else {
          choice0 <- switch0(choice0)
          choice[i] <- choice0
        }
      }
      #outcome
      outcome <- df_list[["feed"]]
      df <- data.frame(choice, outcome)
      choice <- choice_check(df)
      outcome <- paste(choice,df_list[["feed"]],sep = ":")

      stage <- condition <- note2 <- NA
      # Create final dataframe
      psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
      # For rows with RT=0 set choice and outcome as NA
      #psd[psd$response_time == 0, "choice"] <- NA
      psd[psd$response_time == 0, "outcome"] <- NA
      psd[psd$response_time == 0, "response_time"] <- NA
      psd_list[[sb]] <- psd
    }
  }
}

psd_list_ftr <- psd_list[-which(sapply(psd_list, is.null))]
# Combine and save the processed data
psd_combined <- do.call("rbind", psd_list_ftr)
ds_final <- psd_combined [order(psd_combined$subject, psd_combined$problem, psd_combined$trial), ]
file_name <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
