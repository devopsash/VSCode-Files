#!/bin/bash

CSV="instances.csv"
RHEL_CMD="sudo subscription-manager identity"

tail -n +2 "$CSV" | while IFS=',' read -r ZONE NAME OS_VERSION; do
  # Check if OS is RHEL
  if [[ "$OS_VERSION" == rhel* ]]; then
    echo "Connecting to $NAME ($OS_VERSION) in $ZONE ..."
    gcloud compute ssh "$NAME" --zone="$ZONE" --command="$RHEL_CMD"
  else
    echo "Skipping $NAME: Not a RHEL VM (found $OS_VERSION)"
  fi
done
