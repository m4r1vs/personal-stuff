#!/bin/bash

if [ ! -z "$@" ]; then
  # input=$(echo "$@" | sed 's/[[:space:]]*//g')
  input=$(echo "$@")

  if [ "$input" == "Copied!" ] || [ "$input" == "Goodbye" ]; then
    exit 1
  fi
  
  if [ $(tr -dc ' ' <<<"$input" | wc -c) -gt 1 ]; then   

    first_word=$(echo "$input" | head -n1 | cut -d " " -f1)
    second_word=$(echo "$input" | head -n1 | cut -d " " -f2)
    third_word=$(echo "$input" | head -n1 | cut -d " " -f3) 

    if [ "$first_word" == "Copy" ] && [ "$second_word" == "Result:" ]; then 
      echo -n $input | sed 's/Copy Result: //' | xclip -f -i -selection "clipboard" &>/dev/null
      notify-send "Copied Result"
      exit 0
    fi

    if [ "$first_word" == "Type" ] && [ "$second_word" == "Result:" ]; then 
      to_be_typed=$(echo -n $input | sed 's/Type Result: //')
      coproc ( sleep 0.01 && xdotool type --clearmodifiers "$to_be_typed" > /dev/null  2>&1 )
      exit 0
    fi
    
    if [ "$first_word" == "Ask" ] && [ "$second_word" == "Again:" ]; then 
      echo "Goodbye"
      to_be_typed=$(echo -n $input | sed 's/Ask Again: //')
      xdotool type --clearmodifiers "$to_be_typed"
      exit 0
    fi
  fi

  APPID="5H4A34-8PTG87GH54"
  VIEWER="display"                             # Use `VIEWER="display"` from imagemagick if terminal does not support images
  BG="white"                                        # Transparent background
  FG="black"                                              # Match color to your terminal

  # RESPONSE=$(curl -s "https://api.wolframalpha.com/v1/result?appid=$APPID&units=metric&" --data-urlencode "i=$*" | tee /dev/tty)
  RESPONSE=$(curl -s "https://api.wolframalpha.com/v1/result?appid=$APPID&units=metric&" --data-urlencode "i=$*")

  # echo "Type Result: $RESPONSE"
  
  # Remove next if you are fine with text only api, and don't want to see any images
  if [ "$RESPONSE" == "No short answer available" ]; then
    coproc ( brave --new-window "https://wolframalpha.com/input?i=$*" > /dev/null  2>&1 )
    exit 0
  else
    echo "Copy Result: $RESPONSE"
    echo "Ask Again: $RESPONSE"
    echo "Type Result: $RESPONSE"
    echo "Goodbye"
  fi
fi
