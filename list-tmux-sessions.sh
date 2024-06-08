#!/bin/bash

# Get the current session name
current_session=$(tmux display-message -p '#S')

# Initialize an empty string to hold the output
output=""

# List all tmux sessions and their windows in the desired format
while read -r session; do
  while read -r line; do
    # Extract the session ID and window name
    session_id=$(echo "$line" | awk -F: '{print $1}')
    window_id=$(echo "$line" | awk -F: '{print $3}')
    window_name=$(echo "$line" | awk -F: '{print $2}')

    # Remove the dollar sign from the session ID
    clean_session_id=$(echo "$session_id" | sed 's/\$//g')

    pane_path=$(tmux display-message -t $clean_session_id:$window_id -p "#{pane_current_path}" | sed "s|^/home/$USER|~|")
    pane_title=$(tmux display-message -t $clean_session_id:$window_id -p "#{pane_title}" | sed "s|^/home/$USER|~|")

    if [[ "$pane_title" == "marius-thinkpad" ]]; then
      pane_title="$window_name"
      pane_path=" @ $pane_path"
    else
      pane_path=""
      pane_title=$(echo $pane_title | sed "s/- NVIM/- /g")
    fi

    # Check if this is the current session
    if [[ "$clean_session_id" == "$current_session" ]]; then
      # Highlight the current session
      output+="<span color='#ee8000'>${pane_title}${pane_path}</span><br/>"
    else
      output+="<span color='#008e2f'>${pane_title}${pane_path}</span><br/>"
    fi
  done < <(tmux list-windows -t "$session" -F '#{session_id}:#{window_name}')
done < <(tmux list-sessions -F '#S')

# Print the final output
echo "$output"
