#!/bin/bash

log_file="script.log"
error_log="error.log"

script_dir="$(dirname "$(realpath "$0")")"
python_script="$(realpath "$script_dir/../../plant_plots.py")"

if [ ! -d "$script_dir/venv" ]; then
    python3 -m venv "$script_dir/venv"
    source "$script_dir/venv/bin/activate"
    if [ -f "$script_dir/requirements.txt" ]; then
        pip install -r "$script_dir/requirements.txt"
    fi
else
    source "$script_dir/venv/bin/activate"
fi

csv_file=""
plant_name=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -p|--path) csv_file="$2"; shift ;;
        --plant) plant_name="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [[ -z "$csv_file" ]]; then
    csv_file=$(find "$script_dir/../Q3" -maxdepth 1 -type f -name "*.csv" | head -n 1)
fi

if [[ ! -f "$csv_file" ]]; then
    echo "error: no CSV file found" | tee -a "$error_log"
    exit 1
fi

echo "Using CSV file: $csv_file" | tee -a "$log_file"
mkdir -p "$script_dir/Diagrams"

tail -n +2 "$csv_file" | while IFS=',' read -r plant heights leaf_counts dry_weights; do
    plant=$(echo "$plant" | tr -d '"')
    heights=$(echo "$heights" | tr -d '"')
    leaf_counts=$(echo "$leaf_counts" | tr -d '"')
    dry_weights=$(echo "$dry_weights" | tr -d '"')

    if [[ -n "$plant_name" && "$plant" != "$plant_name" ]]; then
        continue
    fi

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
