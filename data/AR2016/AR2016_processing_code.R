### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Ashby & Rakow (2016) Eyes on the Prize? Evidence of Diminishing Attention to Experienced and Foregone Outcomes in Repeated Experiential Choice

if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
# Identify the root directory
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "AR2016"

raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet
# Study 1 - Problems 1-14, two options each
# This reflects the table in the paper. The choice pairs in the dataset are sorted differently, but
# will be mapped to the correct pair here
# Gains only (O-pairs 1–6), mixed outcomes (O-pairs 7–10), and losses only (O-pairs 11–14)
option <- c(paste('',LETTERS,sep=""), paste('A',LETTERS,sep="")[1:2])
out_1 <- c(3.85, 2,    3.85, 2,   1.5, 2,   1.5, 16,  1.5,  2,    1.5,  16,    1.5,  1.5,   1.8,   1.8,  1.8,  1.8,  1.5,  1.5,  -16, -1.5, -2,  -1.5, -3.85, -2,    -3.85, -2)
pr_1 <- c( 0.8,  0.8,  0.5,  0.5, 1,   0.8, 1,   0.1, 0.25, 0.2,  0.25, 0.03,  0.9,  0.7,   0.74,  0.5,  0.5,  0.26, 0.3,  0.1,  0.1, 1,    0.8, 1,    0.5,   0.5,   0.8, 0.8)
out_2 <- c(0.10, 1.60, 0.10, 1.6, NA,  0,   NA,  0,   0,    0,    0,    0,    -1.5, -1.5,  -1.8,  -1.8, -1.8, -1.8, -1.5, -1.5,  0,   NA,   0,   NA,   -0.1,  -1.6,  -0.1, -1.6)
pr_2 <- c( 0.2,  0.2,  0.5,  0.5, NA,  0.2, NA,  0.9, 0.75, 0.8,  0.75, 0.97,  0.1,  0.3,   0.26,  0.5,  0.5,  0.74, 0.7,  0.9,  0.9, NA,   0.2, NA,   0.5,   0.5,   0.2, 0.2 )
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options sheets
file_name1 <- paste0(paper, "_", "1", "_", "options.csv")
setwd(data_path)
write.table(options_table1, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

### Process study 1

# Clear all variables except path and paper
rm(list=setdiff(ls(), c("path", "paper", "raw_path", "data_path")))

# Back to raw directory
setwd(raw_path)
study <- 1
ds <- read.csv(file = "AshbyRakow.S1.csv", header = TRUE, stringsAsFactors = FALSE)
# Subject identifiers and frequencies
subject_freq <- rle(sort(ds$subject))
# Make choice pairs matrix
option <- c(paste('',LETTERS,sep=""), paste('A',LETTERS,sep="")[1:2])
choice_pairs <- matrix(option, nrow = 14, ncol = 2, byrow = TRUE)
# Map pair numbers to problem numbers as in the paper
problem_map <- c(`1`=10, `2`=9, `3`=7, `4`=8, `5`=2, `6`=13, `7`=1, `8`=14, `9`=3,
                 `10`=5, `11`=11, `12`=12, `13`=4, `14`=6)
# List to store each subject's processed data
psd_list <- vector(mode = "list", length(subject_freq$values))

for (sb in 1:length(subject_freq$values)) {
  subject <- as.numeric(subject_freq$values[sb])
  # Extract this subject's data
  df <- ds[ds$subject == subject, ]
  # Sort by problem
  df <- df [order(df$pair), ]
  problem <- unname(problem_map[as.character(df$pair)])
  df$pair <- problem
  options <- sapply(problem, function (p) paste(choice_pairs[p, ], collapse = "_"))
  trial <- 1:40
  # Full feedback is given in all trials
  choice <- sapply(1:nrow(df), function (n)
    ifelse(df$picked[n] == 1, choice_pairs[problem[n], 1], choice_pairs[problem[n], 2]))
  fg_choice <- sapply(1:nrow(df), function (n)
    ifelse(df$picked[n] == 1, choice_pairs[problem[n], 2], choice_pairs[problem[n], 1]))
  fb_choice <- round(x = df$outcome, digits = 2)
  fg_fb <- round(x = df$foutcome, digits = 2)
  outcome <- paste(paste(choice, fb_choice, sep = ":"), paste(fg_choice, fg_fb, sep = ":"), sep = "_")
  sex <- ifelse(df$gender == 0, "m", "f")
  age <- df$age
  response_time <- round(df$rtpick)
  # This may look like a condition but it is just a categorisation of the problems
  note1 <- ifelse(problem %in% c(1:6), "Gains only", ifelse(problem %in% c(7:10), "Mixed", "Losses only"))
  stage <- education <- condition <- note2 <- NA
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine processed data
psd_combined <- do.call("rbind", psd_list)
ds_st1_final <- psd_combined[order(psd_combined$subject, psd_combined$problem), ]

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################


# Save all processed data files
file_name1 <- paste0(paper, "_", "1", "_", "data.csv")
setwd(data_path)
write.table(ds_st1_final, file = file_name1, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
