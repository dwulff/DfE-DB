### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Gershman & Niv (2015) Novelty and Inductive Generalization in Human Reinforcement Learning

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "GN2015"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

### Study 1 prediction task, rate the probability of reward. NO binary choices
study <- 1
file_exp1 <- "data_exp1.csv"
file2_exp1 <- "data_exp1_choice.csv"
dsexp1 <- read.csv(file_exp1, header = TRUE, stringsAsFactors = FALSE)
dsexp1_choice <- read.csv(file2_exp1, header = TRUE, stringsAsFactors = FALSE)
subject_freq <- rle(dsexp1$subject) # Subject IDs and frequencies
# Create the options
cues <- sort(unique(dsexp1$cue)) # Crops or options
g <- expand.grid(LETTERS, LETTERS)
g$Comb <- with(g, paste0(Var2, Var1))
remaining <- length(cues) - length(LETTERS)
options_v <- c(LETTERS, g$Comb[1:remaining]) # These would be the options corresponding to the cues
# Create options table for options sheet
option <- options_v
description <- rep("For each planet, a variable b was drawn from a Beta(1.5,1.5) distribution, and then a crop-specific reward probability was drawn from a Beta(pb, p(1 - b)) distribution, with p = 5",
                   length(option))
options_table <- data.frame(option, description)
psd_list <- vector(mode = "list", length(subject_freq$values))

# Process data
for (sb in 1:length(subject_freq$values)) {
  subject <- subject_freq$values[sb]
  df <- dsexp1[dsexp1$subject == subject_freq$values[sb], ] # Prediction data
  block_freq <- rle(df$block) # Get trials per block info
  df_choice <- dsexp1_choice[dsexp1_choice$subject == subject_freq$values[sb], ] # Choice data
  
  # Fastest way is to create lists and interleave choices with predictions
  psd_block_list <- vector(mode = "list", length(block_freq$values))
  for (b in 1:length(block_freq$values)) {
    df_block <- df[df$block == block_freq$values[b], ]
    df_block_choice <- df_choice[df_choice$block == block_freq$values[b], ]
    problem <- unique(df_block$block)[1]
    # Split prediction trials into groups of 10
    options_prd_list <- split(options_v[df_block$cue], ceiling(seq_along(df_block$cue)/10))
    choice_raw <- rep("", nrow(df_block)) # Only observe outcomes (after predictions)
    choice_prd_list <- split(choice_raw, ceiling(seq_along(choice_raw)/10))
    outcome_prd_list <- split(df_block$reward, ceiling(seq_along(df_block$reward)/10))
    note_raw <- rep("Rate and observe", nrow(df_block))
    note_prd_list <- split(note_raw, ceiling(seq_along(note_raw)/10))
    # Split choice trials into groups of 1
    options_ch_list <- as.list(paste(options_v[df_block_choice$cue1], options_v[df_block_choice$cue2], sep = "_"))
    choice_ch_list <- as.list(ifelse(df_block_choice$action == 1, as.character(options_v[df_block_choice$cue1]), as.character(options_v[df_block_choice$cue2])))
    outcome_ch_list <- as.list(paste(unlist(choice_ch_list), df_block_choice$reward, sep = ":"))
    note_ch_list <- as.list(rep("Choice trial", nrow(df_block_choice)))
    # Interleave choice list elements with prediction list elements
    opidx <- order(c(seq_along(options_prd_list), seq_along(options_ch_list)))
    options <- unname(unlist(c(options_prd_list, options_ch_list)[opidx]))
    trial <- seq_len(length(options))
    chidx <- order(c(seq_along(choice_prd_list), seq_along(choice_ch_list)))
    choice <- unname(unlist(c(choice_prd_list, choice_ch_list)[chidx]))
    outidx <- order(c(seq_along(outcome_prd_list), seq_along(outcome_ch_list)))
    outcome <- unname(unlist(c(outcome_prd_list, outcome_ch_list)[outidx]))
    noteidx <- order(c(seq_along(note_prd_list), seq_along(note_ch_list)))
    note1 <- unname(unlist(c(note_prd_list, note_ch_list)[noteidx]))
    # Rest of variables
    response_time <- stage <- sex <- age <- education <- condition <- note2 <- NA
    # Create prediction dataframe (block column will be removed in the end)
    psd_block <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
    psd_block_list[[b]] <- psd_block
  }
  # Combine blocks
  psd_combined <- do.call("rbind", psd_block_list)
  # Store final frame
  psd_list[[sb]] <- psd_combined
}

# Combine and save processed data
ds_st1_final <- do.call("rbind", psd_list)
file_opts <- paste0(paper, "_", study, "_", "options.csv")
setwd(data_path)
write.table(options_table, file = file_opts, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")
file_dt <- paste0(paper, "_", study, "_", "data.csv")
write.table(ds_st1_final, file = file_dt, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

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
setwd(raw_path) # Back to data directory
study <- 2
file_exp2 <- "data_exp2.csv"
dsexp2 <- read.csv(file_exp2, header = TRUE, stringsAsFactors = FALSE)
subject_freq <- rle(dsexp2$subject) # Subject IDs and frequencies
crops <- unique(dsexp2$cue) # Options
options_v <- LETTERS[crops]
reference_opt <- "Z" # this is the reference crop
# Create the options tablw for the option sheet
option <- c(reference_opt, options_v)
description <- c("P(reward) = 0.5 across all 12 planets",
                 "P(reward) = 0.25 on infertile planets (6 out of 12), while P(reward) = 0.75 on fertile planets.",
                 "P(reward) = 0.25 on infertile planets (6 out of 12), while P(reward) = 0.75 on fertile planets.",
                 "P(reward) = 0.25 on infertile planets (6 out of 12), while P(reward) = 0.75 on fertile planets.",
                 "P(reward) = 0.25 on infertile planets (6 out of 12), while P(reward) = 0.75 on fertile planets.",
                 "P(reward) = 0.25 on infertile planets (6 out of 12), while P(reward) = 0.75 on fertile planets.",
                 "P(reward) = 0.25 on infertile planets (6 out of 12), while P(reward) = 0.75 on fertile planets.",
                 "P(reward) = 0.25 on infertile planets (6 out of 12), while P(reward) = 0.75 on fertile planets.",
                 "P(reward) = 0.25 on infertile planets (6 out of 12), while P(reward) = 0.75 on fertile planets.",
                 "P(reward) = 0.25 on infertile planets (6 out of 12), while P(reward) = 0.75 on fertile planets.")
options_table <- data.frame(option, description)

psd_list <- vector(mode = "list", length(subject_freq$values))

# Process data
for (sb in 1:length(subject_freq$values)) {
  df <- dsexp2[dsexp2$subject == subject_freq$values[sb], ] # Subject's data
  subject <- subject_freq$values[sb]
  problem <- df$cue
  # Participants were shown two crops from the same planet and were asked to choose the crop with
  # the greater probability of reward. One of the two crops was a reference crop that delivered
  # reward with probability 1/2 across all planets.
  # Note: when action=1, this is the "reference" option that always delivers reward with probability 0.5.
  # So "cue" indicates the alternative (action=2) - see Moreinfo.txt
  # Map options and choices
  options <- paste(reference_opt, options_v[df$cue], sep = "_")
  choice <- sapply(1:nrow(df), function (p)
    ifelse(df$action[p] == 0, NA, ifelse(df$action[p] == 1, reference_opt, options_v[as.numeric(df$cue[p])])))
  outcome <- paste(choice, df$reward, sep = ":")
  trial <- 1:nrow(df)
  # Rest of variables
  response_time <- stage <- sex <- age <- education <- condition <- note1 <- note2 <- NA
  # Create final dataframe
  psd <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- psd
}

# Combine and save options and processed data
ds_st2_final <- do.call("rbind", psd_list)
file_opts <- paste0(paper, "_", study, "_", "options.csv")
setwd(data_path)
write.table(options_table, file = file_opts, row.names = FALSE, quote = TRUE, sep = ",", dec = ".")
file_dt <- paste0(paper, "_", study, "_", "data.csv")
write.table(ds_st2_final, file = file_dt, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
