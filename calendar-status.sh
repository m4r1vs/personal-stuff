#!/bin/bash

# exit if no internet connection
if ! ping google.com -c 1 &> /dev/null; then
  echo "GCAL: No internet connection."
  exit 1
fi

current_time=$(date +'%Y-%m-%dT%H:%M:%S')
end_time=$(date -d "$current_time 1 hour" +'%Y-%m-%dT%H:%M:%S')

# Run gcalcli and capture its output
agenda_output=$(gcalcli agenda "$current_time" "$end_time" --details calendar --tsv --calendar mniveri@cc.systems)

# Check if the output contains the target string
if echo "$agenda_output" | grep -q "mniveri@cc.systems"; then
  IFS=$'\t'
  read -ra array <<< "$agenda_output"
  unset IFS
  echo "%{F#008e2f}󰃭%{F-} Um ${array[1]} Uhr: %{F#EE8000}${array[4]}%{F-}" # Print the output if found
else
  echo "" # Print an empty string if not found
fi
