#!/bin/bash

log_file="script.log"
error_log="error.log"

script_dir="$(dirname "$(realpath "$0")")"
python_script="$(realpath "$script_dir/../../plant_plots.py")"

if [[ ! -f "$python_script" ]]; then
    echo "error: Python script $python_script not found!" | tee -a "$error_log"
    exit 1
fi

if [[ -n "$1" && -f "$1" ]]; then
    csv_file="$1"
else
    echo "no CSV file provided. Searching for one in Q4..."
    csv_file=$(find "$script_dir" -maxdepth 1 -type f -name "*.csv" | head -n 1)
fi

if [[ ! -f "$csv_file" ]]; then
    echo "error: no CSV file found in Q4" | tee -a "$error_log"
    exit 1
fi

echo "Using CSV file: $csv_file" | tee -a "$log_file"
mkdir -p "$script_dir/Diagrams"

tail -n +2 "$csv_file" | while IFS=',' read -r plant heights leaf_counts dry_weights; do
    plant=$(echo "$plant" | tr -d '"')
    heights=$(echo "$heights" | tr -d '"')
    leaf_counts=$(echo "$leaf_counts" | tr -d '"')
    dry_weights=$(echo "$dry_weights" | tr -d '"')

    plant_dir="$script_dir/Diagrams/$plant"
    mkdir -p "$plant_dir"

    echo "processing plant: $plant" | tee -a "$log_file"

    python3 "$python_script" --plant "$plant" --height $heights --leaf_count $leaf_counts --dry_weight $dry_weights > "$plant_dir/$plant.log" 2>&1

    if [[ $? -ne 0 ]]; then
        echo "error processing $plant, check $plant_dir/$plant.log" | tee -a "$error_log"
    else
        echo "Generated plots for $plant" | tee -a "$log_file"
    fi

    if [[ -f "${plant}_scatter.png" ]]; then mv "${plant}_scatter.png" "$plant_dir/${plant}_scatter.png"; fi
    if [[ -f "${plant}_histogram.png" ]]; then mv "${plant}_histogram.png" "$plant_dir/${plant}_histogram.png"; fi
    if [[ -f "${plant}_line_plot.png" ]]; then mv "${plant}_line_plot.png" "$plant_dir/${plant}_line_plot.png"; fi
done
