#' download_data.R
#'
#' contributors: @lachlandeer
#'
#' Downloads data from NickCHK's GH repo
#'

#--- Command Line Args Unpacking ---# 
args <- commandArgs(trailingOnly = TRUE)

in_url  <- args[1]
out_data <- args[2]

#--- download it! --- #
download.file(in_url, out_data)