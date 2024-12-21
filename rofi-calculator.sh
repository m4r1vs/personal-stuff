#!/bin/bash

if [ ! -z "$@" ]; then
  # input=$(echo "$@" | sed 's/[[:space:]]*//g')
  input=$(echo "$@")

  SKIP_WOLFRAM=0

  if [ "$input" == "Copied!" ] || [ "$input" == "Goodbye" ]; then
    exit 1
  fi

  if [ $(tr -dc ' ' <<< "$input" | wc -c) -gt 0 ]; then

    first_word=$(echo "$input" | head -n1 | cut -d " " -f1)
    second_word=$(echo "$input" | head -n1 | cut -d " " -f2)

    if [ "$first_word" == "Copy" ] && [ "$second_word" == "Result:" ]; then
      echo -n $input | sed 's/Copy Result: //' | wl-copy > /dev/null
      notify-send "Copied Result"
      exit 0
    fi

    if [ "$first_word" == "Type" ] && [ "$second_word" == "Result:" ]; then
      to_be_typed=$(echo -n $input | sed 's/Type Result: //')
      coproc (sleep 0.01 && wtype $to_be_typed > /dev/null 2>&1)
      exit 0
    fi

    if [ "$first_word" == "Ask" ] && [ "$second_word" == "Again:" ]; then
      echo "Goodbye"
      to_be_typed=$(echo -n $input | sed 's/Ask Again: //')
      wtype $to_be_typed
      exit 0
    fi

    # Set SKIP_WOLFRAM for specific first words
    if [ "$first_word" == "How" ] || [ "$first_word" == "paste" ] || [ "$first_word" == "Paste" ] || [ "$first_word" == "." ]; then
      SKIP_WOLFRAM=1
    fi
  fi

  APPID="5H4A34-8PTG87GH54"

  RESPONSE="Wolfram|Alpha did not understand your input"

  if [ $SKIP_WOLFRAM -eq 0 ]; then
    RESPONSE=$(curl -s "https://api.wolframalpha.com/v1/result?appid=$APPID&units=metric&" --data-urlencode "i=$*")
  fi
  # echo "Type Result: $RESPONSE"

  # Remove next if you are fine with text only api, and don't want to see any images
  if [ "$RESPONSE" == "No short answer available" ]; then
    notify-send "There is no short answer. I'm opening the website for you..."
    coproc (xdg-open "https://wolframalpha.com/input?i=$*" > /dev/null 2>&1)
    killall rofi
    GPT_RESPONSE=$(/home/mn/.local/share/mise/installs/bun/latest/bin/bun run /home/mn/code/personal-stuff/totoro/index.ts "Im currently looking at the answer to '$*' on WolframAlpha. Do not query it yourself. Just tell me something about it.")
    dunstify -h string:x-dunst-stack-tag:totoro-assistant -a Totoro -t 0 "$GPT_RESPONSE"
    exit 0
  elif [ "$RESPONSE" == "Wolfram|Alpha did not understand your input" ]; then
    notify-send "Wait, let me query OpenAI..."
    killall rofi
    GPT_RESPONSE=$(/home/mn/.local/share/mise/installs/bun/latest/bin/bun run /home/mn/code/personal-stuff/totoro/index.ts "$*")
    dunstify -h string:x-dunst-stack-tag:totoro-assistant -a Totoro -t 0 "$GPT_RESPONSE"
    # coproc (xdg-open "https://chatgpt.com/?q=$*" > /dev/null 2>&1)
    # exit 0
  else
    echo "Copy Result: $RESPONSE"
    echo "Ask Again: $RESPONSE"
    echo "Type Result: $RESPONSE"
  fi
fi
