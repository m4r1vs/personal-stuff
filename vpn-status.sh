#!/bin/bash

# Check if there are any active VPN connections
if [ $(nmcli con show --active | grep -i VPN | wc -l) -gt 0 ]; then
  echo "󰖂"
else
  echo ""
fi
