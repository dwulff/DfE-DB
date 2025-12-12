### AUTOMATICALLY PROCESSED TO CHANGE ABSOLUTE PATHS TO RELATIVE PATHS ###
# Ludvig & Spetch (2011) Of Black Swans and Tossed Coins: Is the Description-Experience Gap in Risky Choice Limited to Rare Events?

# Identify the root directory - "path" would denote the root directory
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
path <- dirname(rstudioapi::getSourceEditorContext()$path)
paper <- "LS2011"
# Set as working directory the folder that contains the data as sent by the author
raw_path = paste0(path,"/raw/")
data_path = paste0(path,"/processed/")
setwd(raw_path)
### Create the options sheet
# Study 1
# Fixed gain (+20), risky gain (+0 or +40 with 50% probability), fixed loss (-20), or risky loss (-0 or -40 with 50% probability)
option <- c("A", "B", "C", "D")
out_1 <- c(20, 40, -20, -40)
pr_1 <- c(1, 0.5, 1, 0.5)
out_2 <- c(NA, 0, NA, 0)
pr_2 <- c(NA, 0.5, NA, 0.5)
options_table1 <- data.frame(option, out_1, pr_1, out_2, pr_2)

# Save options sheet
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

### Process dataset

# Clear all variables except path, paper, and studies
rm(list=setdiff(ls(), c("path", "paper","data_path","raw_path")))
# Back to raw directory
setwd(raw_path)
study <- 1
# Read data
# Subjects were split into two groups to counterbalance door colors only
file1 <- "HF9_33Subjects.txt"
file2 <- "HF11_28Subjects.txt"
# Specify the tab character as the value separator because spaces are used in the first column
# NB: For participants 6 and 7 in HF9 a bug in the experiment code allowed them to click on the "or"
# symbol and skip that trial
ds1 <- read.table(file1, header = TRUE, stringsAsFactors = FALSE, skip = 1, sep = "\t")
ds2 <- read.table(file2, header = TRUE, stringsAsFactors = FALSE, skip = 1, sep = "\t")

#problem <- 1
# Create choice pairs
option <- c("A", "B", "C", "D")
choice_pairs <- matrix(option, ncol = 2, byrow =  TRUE)
opts_map <- c(`1`="A", `2`="B", `3`="C", `4`="D")
loc_map <- c(`L`=1, `R`=2)
trial_map <- c(`CTProbe`="Catch trial", `GProbeC`="Catch trial", `Forced`="Forced choice", `Gprobe`="Gain", `GProbeLoss`="Loss")
cnd_map <- c(`Experience only`=1, `Outcome probabilities described`=2)


ds1$subject <- ds1$Subject
ds2$subject <- ds2$Subject + 100

df_rawdata = rbind(ds1,ds2)

relevant_StimType <- c("1","2","3","4", # problem 1,2,3,4
                       "103","301", "104", "401", "203","302", "204","402", # problem 5,6,7,8
                       "102","201", "403","304") # problem 9,10
df <- df_rawdata[df_rawdata$StimType %in% relevant_StimType,]
names(df)[names(df) == "Procedure[Trial]"] <- "Procedure"
map_problem <- c("1"=1,"2"=2,"3"=3, "4"=4, # problem 1,2,3,4
                  "103"=5,"301"=5, "104"=6, "401"=6, "203"=7,"302"=7, "204"=8,"402"=8, # problem 5,6,7,8
                  "102"=9,"201"=9, "403"=10, "304"=10) # problem 9,10)
df$problem <- plyr::revalue(df$StimType, map_problem)

df$paper <- "LS2011"
df$study <- 1
df$condition <- 1
df$condition <- 1
df$age <- as.numeric(df$Age)
df$sex <- tolower(as.character(df$Gender))
df$note1 <- NA #ifelse(df$Procedure.trial == "Proc", "Experience only", "Outcome probabilities described")
df$response_time <- round(df$Click.RT)
df$note2 <- sapply(1:length(df$TrialType), function (n)
  ifelse(df$TrialType[n] != "CProbe", trial_map[df$TrialType[n]], ifelse(as.numeric(df$StimType[n]) %in% c(102,201), "Gain", "Loss")))
df$stage <- df$education <- NA

df$trial <- df$Trial

#unique(df[df$subject==1, "problem"])
for (sb in unique(df$subject)){
  df[df$subject==sb, 'trial'] <- 1:nrow(df[df$subject==sb, ])
}


df$options <- NA
map_options <- c(`1`="A", `2`="B", `3`="C", `4`="D",
                 `103`="A_C", `301`="C_A", `104`="A_D", `401`="D_A", 
                 `203`="B_C", `302`="C_B", `204`="B_D", `402`="D_B",
                 `102`="A_B", `201`="B_A", `304`="C_D", `403`="D_C")

df$options <- map_options[df$StimType]
df$choice <- ifelse(df$problem %in% c(1,2,3,4), df$options, 
                    ifelse(df$Click.Location=="L", substr(df$options, 1,1), substr(df$options, 3,3)))
df$outcome <- paste(df$choice, df$RewardAmount,sep = ":")
df$choice <- ifelse(df$options %in% c("A","B","C","D"),"",df$choice)
df[df$response_time == 0, "choice"] <- NA
df[df$response_time == 0, "outcome"] <- NA
df[df$response_time == 0, "response_time"] <- NA


psd_combined <- df[, c("paper","study", "subject", "problem", "condition", 
                   "options", "trial", "choice", "outcome", 
                   "response_time", "stage", "sex", "age", "education", "note1", "note2")]

df_final <- psd_combined [order(psd_combined$subject, psd_combined$problem, psd_combined$condition, psd_combined$trial), ]
file_name <- paste0(paper, "_", "1", "_", "data.csv")
setwd(data_path)
write.table(df_final, file = file_name, row.names = FALSE, quote = FALSE, sep = ",", dec = ".")
