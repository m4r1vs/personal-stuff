#!/bin/bash

# Get the current session name
current_session=$(tmux display-message -p '#S')

# Initialize an empty string to hold the output
already_printed=0

print_current_window() {
  line=$1
  session_id=$(echo "$line" | awk -F: '{print $1}')
  window_name=$(echo "$line" | awk -F: '{print $2}')
  window_id=$(echo "$line" | awk -F: '{print $3}')

  clean_session_id=$(echo "$session_id" | sed 's/\$//g')
  clean_window_id=$(echo "$window_id" | sed 's/\$//g')

  panes=$(tmux list-panes -t $clean_session_id:$window_id | wc -l)

  pane_path=$(tmux display-message -t $clean_session_id:$window_id -p "#{pane_current_path}" | sed "s|^/home/$USER|~|")
  pane_title=$(tmux display-message -t $clean_session_id:$window_id -p "#{pane_title}" | sed "s|^/home/$USER|~|")

  if [[ "$pane_title" == "marius-thinkpad" ]]; then
    if [[ "$window_name" == "zsh" ]]; then
      pane_title=""
      pane_path="<span> </span> $pane_path"
    elif [[ "$window_name" == "node" ]]; then
      pane_title=""
      pane_path="<span> </span> $pane_path"
    else
      pane_title="$window_name"
      pane_path=" @ $pane_path"
    fi
  else
    pane_path=""

    if [[ $pane_title == *"- NVIM" ]]; then
      pane_title=$(echo $pane_title | sed "s/- NVIM//")
      pane_title="<span font='JetBrainsMono Nerd Font 13'> </span> $pane_title"
    fi
  fi

  pane_titles=""
  pane_paths=""

  result="${pane_title}${pane_path}"

  if [ "$panes" -gt 1 ]; then

    result=""

    # Iterate over panes in the window and append their titles and paths
    while read -r pane_info; do
      # Extract pane title and path
      pane_path=$(echo "$pane_info" | awk -F: '{print $1}' | sed "s|^/home/$USER|~|")
      pane_title=$(echo "$pane_info" | awk -F: '{print $2}')
      pane_cmd=$(echo "$pane_info" | awk -F: '{print $3}')

      if [[ "$pane_title" == "marius-thinkpad" ]]; then
        if [[ "$pane_cmd" == "zsh" ]]; then
          pane_title=""
          pane_path="<span> </span> $pane_path"
        elif [[ "$pane_cmd" == "node" ]]; then
          pane_title=""
          pane_path="<span> </span> $pane_path"
        else
          pane_title="$pane_cmd"
          pane_path=" @ $pane_path"
        fi
      else
        pane_path=""

        if [[ $pane_title == *"- NVIM" ]]; then
          pane_title=$(echo $pane_title | sed "s/- NVIM//")
          pane_title="<span font='JetBrainsMono Nerd Font 13'> </span> $pane_title"
        fi
      fi

      # Append pane title and path
      result+="${pane_title}${pane_path} <span color='#6e767e'>󰇙</span> "
    done < <(tmux list-panes -t "$clean_session_id:$window_id" -F '#{pane_current_path}:#{pane_title}:#{pane_current_command}')
    result="${result%????????????????????????????????}"
  fi

  # Check if this is the current session
  if [[ "$clean_session_id" == "$current_session" ]]; then
    # Highlight the current session
    echo "<span color='#ee8000'>$(echo $result | sed 's/ / /g')</span>"
  else
    echo "<span color='#008e2f'>$(echo $result)</span>"
  fi
}

# List all tmux sessions and their windows in the desired format
while read -r session; do
  while read -r line; do
    print_current_window $line
  done < <(tmux list-windows -t "$session" -F '#{session_id}:#{window_name}:#{window_id}')
done < <(tmux list-sessions -F '#S')

wait
