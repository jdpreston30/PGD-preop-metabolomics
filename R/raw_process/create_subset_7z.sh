#!/bin/bash

# Script to create subsetted 7z archives from filtered mzXML files
# Author: Generated for PGD metabolomics project
# Date: November 3, 2025

set -e  # Exit on any error

# Define paths
BASE_DIR="/Users/JoshsMacbook2015/Library/CloudStorage/OneDrive-EmoryUniversity/Research/MS_raw_data/Chan_studies_MS_raw/PGD_studies/Chan_PGD_9_2025/raw_zips"
SUBSET_DIR="$BASE_DIR/subsets/AJT"
C18_CSV="$SUBSET_DIR/mzxml_filtered_AJT_c18.csv"
HILICPOS_CSV="$SUBSET_DIR/mzxml_filtered_AJT_hilicpos.csv"

echo "=== PGD Metabolomics 7z Subset Creation Script ==="
echo "Base directory: $BASE_DIR"
echo "Subset directory: $SUBSET_DIR"

# Change to the base directory
cd "$BASE_DIR"

# Check if required files exist
if [[ ! -f "c18neg.7z" ]]; then
    echo "ERROR: c18neg.7z not found in $BASE_DIR"
    exit 1
fi

if [[ ! -f "hilicpos.7z" ]]; then
    echo "ERROR: hilicpos.7z not found in $BASE_DIR"
    exit 1
fi

if [[ ! -f "$C18_CSV" ]]; then
    echo "ERROR: $C18_CSV not found"
    exit 1
fi

if [[ ! -f "$HILICPOS_CSV" ]]; then
    echo "ERROR: $HILICPOS_CSV not found"
    exit 1
fi

echo "✓ All required files found"

# Create file lists
echo "Creating file lists..."

# Extract c18neg file names (skip header, get column 4, remove quotes)
awk -F',' 'NR>1 {print $4}' "$C18_CSV" | sed 's/"//g' > c18neg_files_to_extract.txt
echo "✓ Created c18neg file list ($(wc -l < c18neg_files_to_extract.txt) files)"

# Extract hilicpos file names (skip header, get column 4, remove quotes)
awk -F',' 'NR>1 {print $4}' "$HILICPOS_CSV" | sed 's/"//g' > hilicpos_files_to_extract.txt
echo "✓ Created hilicpos file list ($(wc -l < hilicpos_files_to_extract.txt) files)"

# Add proper folder prefixes for 7z paths
sed 's/^/c18neg\//' c18neg_files_to_extract.txt > c18neg_files_with_path.txt
sed 's/^/hilicpos\//' hilicpos_files_to_extract.txt > hilicpos_files_with_path.txt

echo "✓ Added folder prefixes to file paths"

# Create temporary extraction directories
mkdir -p "$SUBSET_DIR/c18neg_temp"
mkdir -p "$SUBSET_DIR/hilicpos_temp"

echo "✓ Created temporary directories"

# Check if c18neg subset already exists OR temp directory has files
if [[ -f "$SUBSET_DIR/c18neg_subset.7z" ]]; then
    echo "⚠️  c18neg_subset.7z already exists - skipping c18neg extraction"
    SKIP_C18=true
elif [[ -d "$SUBSET_DIR/c18neg_temp/c18neg" && $(ls -A "$SUBSET_DIR/c18neg_temp/c18neg" 2>/dev/null | wc -l) -gt 0 ]]; then
    echo "⚠️  c18neg files already extracted - skipping extraction, will create archive"
    SKIP_C18_EXTRACT=true
    SKIP_C18=false
else
    SKIP_C18=false
    SKIP_C18_EXTRACT=false
fi

# Check if hilicpos subset already exists OR temp directory has files
if [[ -f "$SUBSET_DIR/hilicpos_subset.7z" ]]; then
    echo "⚠️  hilicpos_subset.7z already exists - skipping hilicpos extraction"
    SKIP_HILICPOS=true
elif [[ -d "$SUBSET_DIR/hilicpos_temp/hilicpos" && $(ls -A "$SUBSET_DIR/hilicpos_temp/hilicpos" 2>/dev/null | wc -l) -gt 0 ]]; then
    echo "⚠️  hilicpos files already extracted - skipping extraction, will create archive"
    SKIP_HILICPOS_EXTRACT=true
    SKIP_HILICPOS=false
else
    SKIP_HILICPOS=false
    SKIP_HILICPOS_EXTRACT=false
fi

# Extract c18neg files
if [[ "$SKIP_C18" == false && "$SKIP_C18_EXTRACT" == false ]]; then
    echo "Extracting c18neg files... (this may take a while)"
    7z x c18neg.7z @c18neg_files_with_path.txt -o"$SUBSET_DIR/c18neg_temp/" -y

    if [[ $? -eq 0 ]]; then
        echo "✓ Successfully extracted c18neg files"
    else
        echo "ERROR: Failed to extract c18neg files"
        exit 1
    fi
elif [[ "$SKIP_C18_EXTRACT" == true ]]; then
    echo "⏭️  Skipped c18neg extraction (files already extracted)"
else
    echo "⏭️  Skipped c18neg extraction (archive already exists)"
fi

# Extract hilicpos files
if [[ "$SKIP_HILICPOS" == false && "$SKIP_HILICPOS_EXTRACT" == false ]]; then
    echo "Extracting hilicpos files... (this may take a while)"
    7z x hilicpos.7z @hilicpos_files_with_path.txt -o"$SUBSET_DIR/hilicpos_temp/" -y

    if [[ $? -eq 0 ]]; then
        echo "✓ Successfully extracted hilicpos files"
    else
        echo "ERROR: Failed to extract hilicpos files"
        exit 1
    fi
elif [[ "$SKIP_HILICPOS_EXTRACT" == true ]]; then
    echo "⏭️  Skipped hilicpos extraction (files already extracted)"
else
    echo "⏭️  Skipped hilicpos extraction (archive already exists)"
fi

# Create new subset 7z archives
if [[ "$SKIP_C18" == false ]]; then
    echo "Creating subset c18neg.7z archive..."
    cd "$SUBSET_DIR/c18neg_temp"
    7z a "../c18neg_subset.7z" c18neg/ -mx=5

    if [[ $? -eq 0 ]]; then
        echo "✓ Successfully created c18neg_subset.7z"
    else
        echo "ERROR: Failed to create c18neg_subset.7z"
        exit 1
    fi

    cd "$BASE_DIR"
else
    echo "⏭️  Skipped creating c18neg_subset.7z (already exists)"
fi

if [[ "$SKIP_HILICPOS" == false ]]; then
    echo "Creating subset hilicpos.7z archive..."
    cd "$SUBSET_DIR/hilicpos_temp"
    7z a "../hilicpos_subset.7z" hilicpos/ -mx=5

    if [[ $? -eq 0 ]]; then
        echo "✓ Successfully created hilicpos_subset.7z"
    else
        echo "ERROR: Failed to create hilicpos_subset.7z"
        exit 1
    fi

    cd "$BASE_DIR"
else
    echo "⏭️  Skipped creating hilicpos_subset.7z (already exists)"
fi

# Clean up temporary files and directories
echo "Cleaning up temporary files..."
rm -f c18neg_files_to_extract.txt c18neg_files_with_path.txt
rm -f hilicpos_files_to_extract.txt hilicpos_files_with_path.txt
rm -rf "$SUBSET_DIR/c18neg_temp"
rm -rf "$SUBSET_DIR/hilicpos_temp"

echo "✓ Cleaned up temporary files"

# Display final results
echo ""
echo "=== SUBSET CREATION COMPLETE ==="
echo "Created files:"
echo "  - $SUBSET_DIR/c18neg_subset.7z"
echo "  - $SUBSET_DIR/hilicpos_subset.7z"
echo ""
echo "File sizes:"
ls -lh "$SUBSET_DIR/c18neg_subset.7z" "$SUBSET_DIR/hilicpos_subset.7z" 2>/dev/null || echo "Note: Use 'ls -lh' to check file sizes"
echo ""
echo "Original archive sizes for comparison:"
ls -lh c18neg.7z hilicpos.7z
echo ""
echo "Script completed successfully!"