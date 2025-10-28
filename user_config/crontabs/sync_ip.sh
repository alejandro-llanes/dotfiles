#!/bin/bash
# Description: Save ifconfig output to a file named after the hostname,
# then upload it to Google Drive using rclone, overwriting if it exists.

# Exit immediately if any command fails
set -e

# Get hostname
HOSTNAME=$(hostname)

# Define output file
OUTPUT_FILE="${HOSTNAME}.txt"

# Save ifconfig output
ifconfig > "$OUTPUT_FILE"

# Define remote destination (change 'gdrive:' to match your rclone remote name)
REMOTE="gdrive:/sync_ip"

# Upload file and overwrite if it exists
rclone copyto "$OUTPUT_FILE" "${REMOTE}/${OUTPUT_FILE}" --update --ignore-times --progress

# Optional: cleanup local file
# rm -f "$OUTPUT_FILE"

