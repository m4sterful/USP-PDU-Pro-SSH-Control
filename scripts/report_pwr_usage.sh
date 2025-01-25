#!/bin/ash

# Define the API URL base
API_URL_BASE="https://<your uptime kuma URL>/api/push/#######"

# Execute the command and capture the output
OUTPUT=$(/bin/lcm-ctrl -t dump)

# Extract outlet_used and outlet_available using grep and awk
OUTLET_USED=$(echo "$OUTPUT" | grep -o '"outlet_used": [0-9.]*' | awk -F ': ' '{print $2}')
OUTLET_AVAILABLE=$(echo "$OUTPUT" | grep -o '"outlet_available": [0-9]*' | awk -F ': ' '{print $2}')

# Convert outlet_used to watts using awk for floating-point arithmetic
OUTLET_USED_W=$(awk "BEGIN { printf \"%.2f\", $OUTLET_USED/1000 }")
OUTLET_AVAILABLE_W=$(awk "BEGIN { printf \"%.2f\", $OUTLET_AVAILABLE/1000 }")

# Determine the status and message based on outlet_used
if [ "$OUTLET_USED" -lt 1000000 ]; then
    STATUS="up"
else
    STATUS="down"
fi

# Construct the API URL after calculating variables
API_URL="${API_URL_BASE}?status=${STATUS}&msg=${OUTLET_USED_W}W%20/%20${OUTLET_AVAILABLE_W}W"

# Send the HTTP request
curl -s "$API_URL"
