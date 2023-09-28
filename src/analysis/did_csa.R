# did_csa.R
#
# What this file does:
#

# --- Libraries ---#
library(vroom)
library(dplyr)
library(did)
library(rjson)
library(readr)

# --- Command Line Unpacking --- # 
args <- commandArgs(trailingOnly = TRUE)

in_data        <- args[1]
model_base     <- args[2]
model_controls <- args[3]
out_file       <- args[4]

# --- Load Data --- # 
message("Loading Data")
df <- vroom(in_data) 

# --- Load Model --- #
message("Loading Regression Model")
base     <- fromJSON(file = model_base) 
controls <- fromJSON(file = model_controls)

# --- Estimation --- #
message("Running Callaway & Sant'Anna's DiD Strategy")
# reformat data for did package structure
df <-
    df %>%
    tibble::rownames_to_column() %>%
    mutate(treatment = as.numeric(as.logical(eligible)),
           rowname = as.numeric(rowname),
           after_2013 = as.numeric(after),
           after = 2013 * treatment
           )

# run the model
out_model <-
    att_gt(
        yname = base$DEPVAR,
        tname = base$T,
        idname = base$UNITID,
        gname = base$AFTER,
        data = df ,
        panel = FALSE, 
        xformla = as.formula(controls$VARS)#, 
        #anticipation = as.numeric(anticip$ANTICIP)
    )

message("Model Output:")
summary(out_model)

message("Simple ATT")
aggte(out_model, type = "simple", na.rm = TRUE)
message("Dynamic ATT")
aggte(out_model, type = "dynamic", na.rm = TRUE)
message("Calendar Time ATT")
aggte(out_model, type = "calendar", na.rm = TRUE)

# # --- Export Model --- # 
write_rds(out_model, out_file)