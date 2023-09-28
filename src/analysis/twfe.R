# twfe.R
#
# What this file does:
#   - TWFE estimation for a DiD study


# --- Libraries ---#
library(vroom)
library(dplyr)
library(fixest)
library(rjson)
library(rlist)

# --- Command Line Unpacking --- # 
args <- commandArgs(trailingOnly = TRUE)

in_data        <- args[1]
model_base     <- args[2]
model_controls <- args[3]
model_fixedeff <- args[4]
out_file       <- args[5]

# --- Load Data --- # 
message("Loading Data")
df <- vroom(in_data) 

# --- Load Model --- #
message("Loading Regression Model")
base     <- fromJSON(file = model_base) 
controls <- fromJSON(file = model_controls)
fixedeff <- fromJSON(file = model_fixedeff) 


# --- Construct Regression Formula --- # 
# Base Regression Formula
depvar <- base$DEPVAR 
exog   <- base$DID

reg_fmla <- paste(depvar, " ~ ", exog, sep="")

# Fixed Effects
fe <- fixedeff$VARS
reg_fmla <- paste(reg_fmla, " | ", fe, sep = "")

# Controls 
if (controls$VARS != "NULL") {
  ctrls <- controls$VARS
  reg_fmla <- paste(reg_fmla, " + ", ctrls, sep = "")
}

# --- Estimation --- #
message("the regression formula is:")
print(reg_fmla)

out_model <- feols(as.formula(reg_fmla), 
                  cluster =~ statefip + year,
                  data = df
                )

print("Model Output:")
summary(out_model)

# --- Export Model --- # 
list.save(out_model, out_file)
