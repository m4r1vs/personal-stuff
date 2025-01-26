#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 <directory1> <directory2>"
  exit 1
}

# Ensure two arguments are provided
if [ "$#" -ne 2 ]; then
  usage
fi

DIR1="$1"
DIR2="$2"

# Check if both arguments are directories
if [[ ! -d "$DIR1" || ! -d "$DIR2" ]]; then
  echo "Both arguments must be directories."
  exit 1
fi

# Recursively compare the directories
echo "Comparing directories: $DIR1 and $DIR2"

diff -r "$DIR1" "$DIR2" | while IFS= read -r line; do
  echo "$line"
done
