#!/bin/bash

# File to store description and code information
data_file="sa_cheats.csv"

# Delimiter
delim="#"

# Time in seconds to wait before entering codes
wait_time="5"

# Check if data file exists
if [ ! -f "$data_file" ]; then
    # Create empty data file
    touch "$data_file"
fi

# Add a new description and code
add_data() {
    read -p "Enter description: " local description
    read -p "Enter code: " local code

    # Add data to file
    echo "$description$delim$code" >>"$data_file"
}

read_data() {
    line_count=1
    if [ ${#delim} -gt 1 ]; then
        # Multi character delimiter
        while read -r line; do
            local description=$(echo "$line" | awk -F "$delim" '{print $1}')
            local code=$(echo "$line" | awk -F "$delim" '{print $2}')
            printf "%d. %-20s %s\n" "$line_count" "$description" "$code"
            line_count=$((line_count + 1))
        done <"$data_file"
    else
        # Single character delimiter
        while IFS="$delim" read -r description code; do
            echo -e "$(printf "\033[33m%d. \033[32m%-20s \033[34m%s\033[0m\n" "$line_count" "$description" "$code")"
            line_count=$((line_count + 1))
        done <"$data_file"
    fi
}

# Display data as a Table
display_table() {
    # Print data as table
    echo -e "\033[32m$(printf "   %-20s %s\n" "Description" "\033[34mCode")\033[0m"
    # printf "$(tput setaf 3)%-20s $(tput setaf 4)%s$(tput sgr0)\n" "Code" "Description"
    read_data
}

get_cheat() {
    if [ ${#delim} -gt 1 ]; then
        # Multi character delimiter
        local code=$(sed -n "$1p" "$data_file" | awk -F"$delim" '{print $1}')
    else
        # Single character delimiter
        local code=$(sed -n "$1p" "$data_file" | cut -d"$delim" -f2)
    fi
    echo $code
}

# Select a code or codes
select_code() {
    # Prompt user to select numbers
    while :; do
        read -p "Enter numbers or range (n to create a new entry, t to show table): " nums

        # Check if input is "n"
        if [ "$nums" = "n" ]; then
            add_data
            return 1
        fi

        # Check if input is "t"
        if [ "$nums" = "t" ]; then
            display_table
            return 1
        fi

        # Check if input is a single number or a range
        if [[ "$nums" =~ ^[0-9]+$ ]]; then
            # Check if number is valid
            if [ "$nums" -gt 0 ] && [ "$nums" -le "$line_count" ]; then
                :
            else
                echo  -e "\033[31mInvalid input. Please try again.\033[0m"
                continue
            fi
        elif [[ "$nums" =~ ^[0-9]+-[0-9]+$ ]]; then
            # Check if range is valid
            start=$(echo "$nums" | cut -d- -f1)
            end=$(echo "$nums" | cut -d- -f2)
            if [ "$start" -le "$end" ] && [ "$end" -le "$line_count" ]; then
                :
            else
                echo  -e "\033[31mInvalid input. Please try again.\033[0m"
                continue
            fi
        # Check if input is a selection of numbers
        elif [[ "$nums" =~ ^[0-9]+(,[0-9]+)*$ ]]; then
            # Check if all numbers are valid
            for num in $(echo "$nums" | sed -e 's/,/ /g'); do
                if [ "$num" -gt 0 ] && [ "$num" -le "$line_count" ]; then
                    :
                else
                    echo  -e "\033[31mInvalid input. Please try again.\033[0m"
                    continue 2
                fi
            done
        else
            echo  -e "\033[31mInvalid input. Please try again.\033[0m"
            continue
        fi
        break
    done

    # Get codes for selected numbers
    codes=()
    for num in $(echo "$nums" | sed -e 's/,/ /g'); do
        if [[ "$num" =~ ^[0-9]+$ ]]; then
            # Get code for single number
            code=$(get_cheat $num)
            codes+=("$code")
        elif [[ "$num" =~ ^[0-9]+-[0-9]+$ ]]; then
            # Get codes for range of numbers
            start=$(echo "$num" | cut -d- -f1)
            end=$(echo "$num" | cut -d- -f2)
            while [ "$start" -le "$end" ]; do
                code=$(get_cheat $start)
                codes+=("$code")
                start=$((start + 1))
            done
        fi
    done

    # Prompt user to select loop or once
    read -p "Run loop? (y/n) [n]: " loop
    case "$loop" in
    y | Y)
        # Run loop
        run_loop
        ;;
    *)
        # Run once
        run_once
        ;;
    esac
}

# Function to run adb command in a loop
run_loop() {
    read -p "Enter interval (seconds): " interval

    for code in "${codes[@]}"; do
        while :; do
            adb shell input text "$code"
            sleep "$interval"
        done
    done
}

# Function to run adb command once
run_once() {
    sleep "$wait_time"
    for code in "${codes[@]}"; do
        echo -e "\033[32mrunning code:\033[31m $code\033[0m"
        adb shell input text "$code"
        sleep "3"
    done
}

# Display data
display_table

# Main loop
while :; do
    # prompt user to select a code
    select_code
done
