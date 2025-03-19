#!/usr/bin/env Rscript
# Merge COLLECTION GSEA DATA into a single .tsv file
## Author: Daniel Garbozo
## After run GSEA_all.sh, move the .tsv files to a single directory and run this script

# Load required libraries
library(dplyr)
library(purrr)
library(readr)
library(tidyr)

# Read command-line arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
  stop("Usage: preprocess_GSEA.R <input_directory> [output_file]\n")
}
input_directory <- args[1]
# If a second argument is provided, use it as the output file; otherwise, save the file in the input directory.
output_file <- ifelse(length(args) >= 2, args[2], file.path(input_directory, "merged_all_gsea_data.tsv"))

# Validate input directory and check for TSV files
if (!dir.exists(input_directory)) {
  stop("The specified directory does not exist: ", input_directory)
}
files <- list.files(path = input_directory, pattern = "\\.tsv$", full.names = TRUE)
if (length(files) == 0) {
  stop("No TSV files found in ", input_directory)
}

# Function to read each file and add a column with the modified file name
read_file <- function(file) {
  data <- read_tsv(file)
  file_name <- basename(file)
  file_name <- sub("_TB_CONTROL.tsv$", "", file_name)  # Change the pattern if necessary
  # Convert all numeric columns explicitly
  numeric_cols <- c("SIZE", "ES", "NES", "NOM p-val", "FDR q-val", "FWER p-val", "RANK AT MAX")
  data <- data %>%
    mutate(across(all_of(numeric_cols), as.numeric))
  data$COLLECTION <- file_name
  return(data)
}

# Read and combine all TSV files into a single data frame

gsea_data <- lapply(files, read_file) %>% bind_rows()

gsea_data <- gsea_data %>%
  select(-`...12`)

# Define numeric columns
numeric_cols <- c("SIZE", "ES", "NES", "NOM p-val", "FDR q-val", "FWER p-val", "RANK AT MAX")

# Find problematic values in numeric columns
gsea_data %>%
  filter(if_any(all_of(numeric_cols), ~ !grepl("^-?[0-9.]+$", .))) %>%
  print()

# Data processing: selection, separation, mutation, and renaming of columns
gsea_data <- gsea_data %>%
  select(-"GS<br> follow link to MSigDB", -"GS DETAILS") %>%  #, -"...12"
  separate(col = `LEADING EDGE`, into = c("tags", "list", "signal"), sep = ",", remove = FALSE) %>%
  mutate(
    tags = 0.01 * as.numeric(sub("%", "", sub("tags=", "", tags))),
    list = 0.01 * as.numeric(sub("%", "", sub("list=", "", list))),
    signal = 0.01 * as.numeric(sub("%", "", sub("signal=", "", signal))),
    `FDR q-val` = ifelse(`FDR q-val` == 0, 0.001, `FDR q-val`),
    `Log10FDR` = -log10(`FDR q-val`)
  ) %>%
  relocate(`Log10FDR`, .after = `FWER p-val`) %>%
  rename(FDR = `FDR q-val`) # QUit "COMPARISON = Comparison," because it is not necessary

# Save the processed data to a TSV file
write_tsv(gsea_data, output_file)

cat("GSEA data saved to:", output_file, "\n")
