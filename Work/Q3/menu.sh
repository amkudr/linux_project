#!/bin/bash

CSV_FILE="plants.csv"

create_csv() {
    echo ""
    read -p "Enter new CSV filename: " input_file
    CSV_FILE=${input_file:-plants.csv}
    touch "$CSV_FILE"
    echo "CSV file '$CSV_FILE' has been created and set as the current file."
    echo ""
}

choose_csv() {
    echo ""
    read -p "Enter the CSV file name to work with: " input_file
    if [ -f "$input_file" ]; then
        CSV_FILE="$input_file"
        echo "Now working with: $CSV_FILE"
    else
        echo "File not found. Using default: $CSV_FILE"
    fi
    echo ""
}

display_csv() {
    echo ""
    if [ -f "$CSV_FILE" ]; then
        column -t -s, "$CSV_FILE" | less -FX
    else
        echo "CSV file not found. Create or select a file first."
    fi
    echo ""
}

add_new_plant() {
    echo ""
    read -p "Enter plant name: " plant
    read -p "Enter heights (space-separated): " -a heights_arr
    read -p "Enter leaf counts (space-separated): " -a leaf_counts_arr
    read -p "Enter dry weights (space-separated): " -a dry_weights_arr

    max_length=${#heights_arr[@]}
    (( ${#leaf_counts_arr[@]} > max_length )) && max_length=${#leaf_counts_arr[@]}
    (( ${#dry_weights_arr[@]} > max_length )) && max_length=${#dry_weights_arr[@]}

    while [ ${#heights_arr[@]} -lt $max_length ]; do heights_arr+=("${heights_arr[-1]}"); done
    while [ ${#leaf_counts_arr[@]} -lt $max_length ]; do leaf_counts_arr+=("${leaf_counts_arr[-1]}"); done
    while [ ${#dry_weights_arr[@]} -lt $max_length ]; do dry_weights_arr+=("${dry_weights_arr[-1]}"); done

    height_fixed=$(IFS=" "; echo "${heights_arr[*]}")
    leaf_count_fixed=$(IFS=" "; echo "${leaf_counts_arr[*]}")
    dry_weight_fixed=$(IFS=" "; echo "${dry_weights_arr[*]}")

    echo "$plant,\"$height_fixed\",\"$leaf_count_fixed\",\"$dry_weight_fixed\"" >> "$CSV_FILE"
    echo "New plant added: $plant"
    echo ""
}

run_python_script() {
    echo ""
    if [ -f "$CSV_FILE" ]; then
        python3 analyze_plants.py "$CSV_FILE"
    else
        echo "CSV file not found. Create or select a file first."
    fi
    echo ""
}

update_plant() {
    echo ""
    read -p "Enter plant name to update: " plant
    if grep -q "^$plant," "$CSV_FILE"; then
        read -p "Enter new heights (space-separated): " new_height
        read -p "Enter new leaf counts (space-separated): " new_leaf_count
        read -p "Enter new dry weights (space-separated): " new_dry_weight
        sed -i "/^$plant,/c\\$plant,\"$new_height\",\"$new_leaf_count\",\"$new_dry_weight\"" "$CSV_FILE"
        echo "Updated plant: $plant"
    else
        echo "Plant not found in CSV."
    fi
    echo ""
}

delete_row() {
    echo ""
    echo "Enter row number to delete or press Enter to delete by plant name:"
    read line
    if [[ -n "$line" ]]; then
        sed -i "${line}d" "$CSV_FILE"
        echo "Deleted row number: $line"
    else
        read -p "Enter plant name to delete: " plant
        sed -i "/^$plant,/d" "$CSV_FILE"
        echo "Deleted plant: $plant"
    fi
    echo ""
}

print_highest_leaf_avg() {
    echo ""
    if [ -f "$CSV_FILE" ]; then
        awk -F',' 'NR>1 { split($3, a, " "); sum=0; for(i in a) sum+=a[i]; avg=sum/length(a); if(avg>max) { max=avg; plant=$1 } } END { print "Plant with highest average leaf count: " plant }' "$CSV_FILE"
    else
        echo "CSV file not found. Create or select a file first."
    fi
    echo ""
}

while true; do
    echo ""
    echo ""
    echo "================= PLANT CSV MENU ================="
    echo "1 Create and set a new CSV file as the current one"
    echo "2 Choose an existing CSV file"
    echo "3 Display the current CSV file"
    echo "4 Add a new row for a plant"
    echo "5 Run Python script with parameters for a specific plant"
    echo "6 Update values in a specific row by plant name"
    echo "7 Delete a row by index or by plant name"
    echo "8 Print the plant with the highest average leaf count"
    echo "9 Exit"
    echo "================================================="
    read -p "Enter your choice: " choice
    echo ""
    echo ""

    case $choice in
        1) create_csv; echo "" ;;
        2) choose_csv; echo "" ;;
        3) display_csv; echo "" ;;
        4) add_new_plant; echo "" ;;
        5) run_python_script; echo "" ;;
        6) update_plant; echo "" ;;
        7) delete_row; echo "" ;;
        8) print_highest_leaf_avg; echo "" ;;
        9) echo "Exiting..."; echo ""; break ;;
        *) echo "Invalid option. Please try again."; echo "" ;;
    esac
done
