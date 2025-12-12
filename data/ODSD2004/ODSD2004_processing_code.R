### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# O'Doherty et. al (2004) Dissociable Roles of Ventral and Dorsal Striatum in Instrumental Conditioning

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "ODSD2004"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)

### Create the options sheet

# AB juice reward, and CD affectively neutral solution (optimal and suboptimal options)
option <- c("A", "B", "C", "D")
out_1 <- c(1, 1, 1, 1)
pr_1 <- c(0.6, 0.3, 0.6, 0.3)
out_2 <- c(0, 0, 0, 0)
pr_2 <- c(0.4, 0.7, 0.4, 0.7)
options_table <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options sheet
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
setwd("PavvsInst")
study <- 1
files <- list.files()
# Remove pavlovian task files
files <- files[!grepl("Pav", files)]
# Extract gender and age from file name
males <- grep("MALE", files)
age_v <- as.numeric(substr(x = files, start = nchar(files) - 5, stop = nchar(files) - 4))
#problem <- 1
option <- c("A", "B", "C", "D")
choice_pairs <- matrix(option, ncol = 2, byrow = TRUE)
psd_list <- vector(mode = "list", length(files))

for (sb in 1:length(files)) {
  subject <- sb
  # Read subject data
  ds <- read.table(files[sb], header = FALSE, stringsAsFactors = FALSE, fill = TRUE, skip = 13)
  # Clean the dataframe
  ds <- ds[-which(ds$V4 == "Byte"), ]
  ds <- ds[-which(ds$V4 == "High"), ]
  ds <- ds[-which(ds$V4 == "Low"), ]
  ds <- ds[-which(ds$V5 == "STOP"), ]
  code <- ds$V4
  # Map variables
  options <- choice <- reward <- note1 <- c()
  for (d in 1:length(code)) {
    opts <- ifelse(substr(x = code[d], start = 3, stop = 3) == "+", "A_B", "C_D")
    t <- ifelse(substr(x = code[d], start = 3, stop = 3) == "+", 1, 2)
    cnd <- ifelse(substr(x = code[d], start = 3, stop = 3) == "+", "Juice reward condition", "Neutral solution reward condition")
    ch <- ifelse(substr(x = code[d], start = 4, stop = 5) == "HP", choice_pairs[t,1], choice_pairs[t,2]) 
    r <- ifelse(substr(x = code[d], start = 7, stop = 7) == "p", "1", "0") 
    options <- c(options, opts)
    choice <- c(choice, ch)
    reward <- c(reward, r)
    note1 <- c(note1, cnd)
  }
  trial <- 1:nrow(ds)
  outcome <- paste(choice, reward, sep = ":")
  sex <- ifelse(sb %in% males, "m", "f")
  age <- age_v[sb]
  response_time <- stage <- education <- note2 <- condition <- NA
  # problem <- ifelse(options=='A_B', 1, 2)
  problem <- 1
  # Create final dataframe
  pdf <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)
  psd_list[[sb]] <- pdf
}

# Combine and save processed dat
psd_combined <- do.call("rbind", psd_list)
ds_final <- psd_combined [order(psd_combined$subject), ]
file_name <- paste0(paper, "_", "1", "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
