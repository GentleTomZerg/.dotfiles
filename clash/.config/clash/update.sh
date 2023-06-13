#!/bin/bash

# Define the file where URLs will be stored
URL_FILE="$HOME/.config/clash/urls.txt"

# Check if the URL file exists, and if not, create it
if [ ! -f "$URL_FILE" ]; then
    touch "$URL_FILE"
fi

# List all used URLs
echo "Current URLs in file: "
if [ -s "$URL_FILE" ]; then
    cat "$URL_FILE"
else
  echo "urls.txt" > $URL_FILE
fi


# List all URLs in the file and prompt the user to choose one
echo "Choose a URL from the list below(press enter if you want to enter a new one):"
select URL in $(cat "$URL_FILE"); do
    if [[ -z $URL ]]; then
        break
    fi

    # Run subconverter with the chosen URL
    ~/.config/clash/subconverter.sh clash "$URL"

    break
done

# Prompt the user to enter a new URL if they didn't select one from the list
if [[ -z $URL ]]; then
    while true; do
        echo "Enter a new URL:"
        read NEW_URL

        # Check if the user provided a new URL
        if [[ -z $NEW_URL ]]; then
            echo "Please enter an valid url"
            continue
        fi

        # Check if the URL is already in the file
        if grep -q "$NEW_URL" "$URL_FILE"; then
            echo "URL already exists in file"
            continue
        fi

        # Add the new URL to the file
        echo "$NEW_URL" >> "$URL_FILE"

        URL=NEW_URL

        break
    done

    # Run subconverter with the new URL
    ~/.config/clash/subconverter.sh clash "$URL"
fi
