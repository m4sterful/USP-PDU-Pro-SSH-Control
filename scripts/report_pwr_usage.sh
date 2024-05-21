#!/bin/ash

## add a push monitor to your uptime monitor to report current power usage every few minutes. Save to /etc/persistent/report_pwr_usage.sh and Add this to cron with */5 * * * * /etc/persistent/report_pwr_usage.sh to run every 5 minutes

# Define the API URL
API_URL="https://<your uptime kuma URL>/api/push/#######?status=${STATUS}&msg=${OUTLET_USED_W}W%20/%20${OUTLET_AVAILABLE_W}

# Execute the command and capture the output
OUTPUT=$(/bin/lcm-ctrl -t dump)

# Extract outlet_used and outlet_available using grep and awk
OUTLET_USED=$(echo "$OUTPUT" | grep -o '"outlet_used": [0-9.]*' | awk -F ': ' '{print $2}')
OUTLET_AVAILABLE=$(echo "$OUTPUT" | grep -o '"outlet_available": [0-9]*' | awk -F ':' '{print $2}')

# Convert outlet_used to watts using awk for floating-point arithmetic
OUTLET_USED_W=$(awk "BEGIN { printf \"%.2f\", $OUTLET_USED/1000 }")
OUTLET_AVAILABLE_W=$(echo "$OUTLET_AVAILABLE" | awk '{print $1/1000}')

# Determine the status and message based on outlet_used_w
if [ "$OUTLET_USED" -lt 1000000 ]; then
    STATUS="up"
else
    STATUS="down"
fi


# Send the HTTP request
curl -s "$API_URL"
