# clean_daca_sample.R
#
# What this file does:
#
#  - Generates control variables using names from MEP task 2


# --- Libraries ---#
library(vroom)
library(dplyr)
library(janitor)

#--- Command Line Args Unpacking ---# 
args <- commandArgs(trailingOnly = TRUE)

in_file  <- args[1]
out_file <- args[2]

# --- Load Data --- #
df <- vroom(in_file) %>%
        clean_names()

# --- CONTROL VARIABLES --- # 

# Age entered USA
df <- 
    df %>%
    mutate(age_enter_usa = age - yrsusa1) %>%
    # clean up the negative numbers in what we computed
    mutate(age_enter_usa = case_when(
        age_enter_usa == -1 ~ 0,
        age_enter_usa <  -1 ~ NA_real_, 
        TRUE ~ age_enter_usa
    )
    )

# Married
df <-
    df %>%
    mutate(married = if_else(marst <= 2, TRUE, FALSE))

# home language is Spanish 
df <- 
    df %>%
    mutate(home_lang_es = if_else(language == 12, TRUE, FALSE))

# --- Save Data --- # 
vroom_write(df, out_file, ",")
