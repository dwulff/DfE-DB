### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
# Erev et al. (2010) A Choice Prediction Competition: Choices from Experience and from Description

# NOTE: The options table produced when generating the options sheet is necessary for processing this dataset

paper <- "EERH2010"
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)
################### study 3 ############################

study <- 3

# Set as working directory the folder that contains the data as sent by the author
setwd(raw_path)

raw_data = read.table("clicking_Est_dat.txt", header = TRUE, sep = "", fill = TRUE,
                      col.names = c("obs", "cohort", "id", "problem", "round", "order", "high",
                                    "phigh", "low", "medium", "choice", "payoff"))

############ Save options info ##################
letter_grid <- expand.grid(LETTERS, LETTERS)
letter_grid$comb <- paste0(letter_grid$Var2, letter_grid$Var1)
# we need 120 options in total (60 problems * 2 options per problem)
option_list <- c(LETTERS, letter_grid$comb[1:94])

option_info <- unique(subset(raw_data[order(raw_data$problem, raw_data$choice),], 
                             select= c(problem, high, phigh, low, medium)))

# Merge the outcomes of "medium option" with "high" in alternating order, store in out_1
out_1 <- c(rbind(option_info$medium, option_info$high))
# Merge the probabilities of "medium option" with "high" in alternating order, store in pr_1
pr_1 <- c(rbind(1.0, option_info$phigh))
# Merge the alternative outcomes of "medium option" = NA, and "high" = values in low, store in out_2
out_2 <- c(rbind(NA, option_info$low))
# Merge the alternative outcomes' probabilities
pr_2 <- c(rbind(NA, round(1 - option_info$phigh, digits = 2)))
# Save to data frame
options_table <- data.frame('option'=option_list, out_1, pr_1, out_2, pr_2)

# Save options
file_name <- paste0(paper, "_", study, "_", "options.csv")
setwd(data_path)
write.table(options_table, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")

######################## Generate main data #####################

subject <- raw_data$id # id
problem <- raw_data$problem # problem
options <- paste(options_table[raw_data$problem*2-1,'option'], options_table[raw_data$problem*2,'option'], sep="_") 
trial <- raw_data$round # round
choice <- vector("character", length(options))

for (i in seq_along(options)) {
  if (nchar(options[i]) == 3) {
    choice[i] <- ifelse(raw_data$choice[i] == 0, substr(options[i], 1, 1), substr(options[i], 3, 3))
  } else {
    choice[i] <- ifelse(raw_data$choice[i] == 0, substr(options[i], 1, 2), substr(options[i], 4, 5))
  }
}

outcome <- paste(choice, raw_data$payoff, sep=":")

condition <- response_time <- stage <- sex <- age <- education <- note1 <- note2 <- NA

ds_final <- data.frame(paper, study, subject, problem, condition, options, trial, choice, outcome, response_time, stage, sex, age, education, note1, note2)



# Save data file
file_name_d <- paste0(paper, "_", study, "_", "data.csv")
setwd(data_path)
write.table(ds_final, file = file_name_d, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
