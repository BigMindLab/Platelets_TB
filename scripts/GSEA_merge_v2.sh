#!/bin/bash

# Author: Daniel Garbozo and Daniel Guevara
# dan.garbozo.urp@gmail.com
# February 20, 2025

# Use this script to merge and rename GSEA results data for each comparison.

# ------------- #
# Define routes #
# ------------- #
main_dir="/media/david/bm2/Platelets_TB/GSEA/Collections"
destination_dir="/media/david/bm2/Platelets_TB/GSEA/all_tsv"

# Create the destination directory if it doesn't exist
mkdir -p "$destination_dir"

# Iterate over each subdirectory (collection) in the main directory
for collection_dir in "$main_dir"/*/; do
  collection_name=$(basename "$collection_dir")  # e.g., c1, c2.cgp, etc.
  echo "Processing collection: $collection_name"

  # Iterate over each comparison subdirectory
  for comparison_dir in "${collection_dir}"*/; do
    raw_comparison_name=$(basename "$comparison_dir")
    # Example raw_comparison_name: c1_TB_Control.Gsea.1740033310298

    # 1) Remove the prefix "<collection_name>_" if present
    # 2) Remove ".Gsea.<numbers>" at the end
    comparison_name_clean=$(echo "$raw_comparison_name" \
      | sed "s/^${collection_name}_//" \
      | sed 's/\.Gsea\.[0-9]\+//')

    echo "  -> Processing comparison: $raw_comparison_name"
    echo "     Clean name: $comparison_name_clean"

    # Define the final merged file path in all_Tsv
    # e.g. /media/david/bm2/Platelets_TB/GSEA/all_Tsv/c1_TB_Control_merged.tsv
    output_file="$destination_dir/${collection_name}_${comparison_name_clean}_merged.tsv"

    # Initialize a flag for the header
    header_included=false

    # Merge all gsea_report_for*.tsv files in that comparison directory
    for file in "${comparison_dir}"gsea_report_for*.tsv; do
      if [ -f "$file" ]; then
        if [ "$header_included" = false ]; then
          cat "$file" >> "$output_file"
          header_included=true
        else
          tail -n +2 "$file" >> "$output_file"
        fi
      fi
    done

    # Check if we created the merged file
    if [ -f "$output_file" ]; then
      echo "    -> Merged files from $comparison_dir into $output_file"
    else
      echo "    -> No matching TSV files found in $comparison_dir"
    fi
  done
done

echo "All collections and comparisons processed. Merged TSV files are in $destination_dir."
