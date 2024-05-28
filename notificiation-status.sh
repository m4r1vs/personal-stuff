#!/bin/bash

if dunstctl is-paused | grep -q "true"; then
  echo "󰂛"
else
  echo ""
fi
