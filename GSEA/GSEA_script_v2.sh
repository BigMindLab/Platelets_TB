#!/bin/bash

############################################
# Script to run GSEA on multiple GMT files
# from the Human_sets_symbols folder.
# Author: Daniel Garbozo
############################################

# ===========================
#       PARAMETERS
# ===========================

# Main directories (adjust according to your environment)
working_dir="/media/david/bm2/Platelets_TB/GSEA"
matrix_dir="$working_dir/Human_sets_symbols"
chip_annotations="$working_dir/Human_Annotations"

# Main files (adjust according to your environment)
expression_data="$working_dir/expression_data_TB.txt"
phenotype_info="$working_dir/phenotype_TB.cls"

# Comparisons and labels (adjust as needed)
comparisons=('TB_versus_Control')
labels=('TB_Control')

# Common GSEA parameters
nperm=10000
rnd_seed=149

# ================
#   GET GMT FILES
# ================
# Retrieve all .gmt files from the Human_sets_symbols folder
gmt_files=("$matrix_dir"/*.gmt)

NUM_COLLECTIONS=${#gmt_files[@]} # Get total number of collections

echo "Found ${#gmt_files[@]} GMT files in '$matrix_dir'."
echo "Processing up to $NUM_COLLECTIONS of them (or fewer if there are less)."
echo

# Counter for processed GMT files
count=0

# Global start time
global_start_time=$(date)

# ===============================================
#  MAIN LOOP THROUGH GMT FILES IN THE DIRECTORY
# ===============================================
for gmt_file in "${gmt_files[@]}"; do

  # Get the base filename, without path
  base_name="$(basename "$gmt_file")"
  # Remove extension .v2023.2.Hs.symbols.gmt
  collection_name="$(echo "$base_name" | sed 's/\.v2023\.2\.Hs\.symbols\.gmt//')"
  # Remove the word "all" if present
  collection_name="$(echo "$collection_name" | sed 's/\.all//g' | sed 's/all//g')"

  # Define output directory based on collection name
  output_dir="$working_dir/${collection_name}"
  mkdir -p "$output_dir"

  echo "-------------------------------------"
  echo "Processing GMT #$((count+1)): $base_name"
  echo "Collection: $collection_name"
  echo "Output directory: $output_dir"
  echo "-------------------------------------"

  # Internal loop through comparisons and labels
  for i in "${!comparisons[@]}"; do
    comparison="${comparisons[$i]}"
    label="${labels[$i]}"

    # Create a full label combining the collection name and comparison label
    full_label="${collection_name}_${label}"

    echo "  -> Running GSEA for comparison: $comparison (label: $full_label)"

    # Run GSEA (in the background using &)
    gsea-cli.sh GSEA \
      -res "$expression_data" \
      -cls "${phenotype_info}#${comparison}" \
      -gmx "$gmt_file" \
      -collapse No_Collapse \
      -mode Max_probe \
      -norm meandiv \
      -nperm $nperm \
      -permute gene_set \
      -rnd_seed $rnd_seed \
      -rnd_type no_balance \
      -scoring_scheme weighted \
      -rpt_label "$full_label" \
      -metric Signal2Noise \
      -sort abs \
      -order descending \
      -chip "$chip_annotations/Human_Ensembl_Gene_ID_MSigDB.v2023.2.Hs.chip" \
      -create_gcts false \
      -create_svgs false \
      -include_only_symbols true \
      -make_sets true \
      -median false \
      -num 100 \
      -plot_top_x 100 \
      -save_rnd_lists false \
      -set_max 500 \
      -set_min 15 \
      -zip_report false \
      -out "$output_dir" &

  done

  # Optional: If you want to complete all comparisons before moving to the next collection, add a wait here.
  wait

  # Increment the processed collections counter
  ((count++))

done

# Wait for all background processes to finish (in case any are still running)
wait

global_end_time=$(date)
echo
echo "---------------------------------------------"
echo "All GSEA runs have completed."
echo "Started at: $global_start_time"
echo "Finished at: $global_end_time"
echo "---------------------------------------------"
