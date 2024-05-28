#!/bin/bash

# Check if Docker is active (by attempting to list containers)
if docker ps > /dev/null 2>&1; then
  # Get the number of running containers (suppress output)
  RUNNING_CONTAINERS=$(docker ps | wc -l)

  # Adjust for the header line in 'docker ps' output
  RUNNING_CONTAINERS=$((RUNNING_CONTAINERS - 1))

  # Output "yes (number of containers)"
  echo "$RUNNING_CONTAINERS"
else
  # Output "no" if the 'docker ps' command fails
  echo ""
fi
