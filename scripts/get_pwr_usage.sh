#!/bin/ash

# Execute the command and capture the output
OUTPUT=$(./lcm-ctrl -t dump)

# Extract outlet_used and outlet_available using grep and awk
OUTLET_USED=$(echo "$OUTPUT" | grep -o '"outlet_used": [0-9]*' | awk -F ':' '{print $2}')
OUTLET_AVAILABLE=$(echo "$OUTPUT" | grep -o '"outlet_available": [0-9]*' | awk -F ':' '{print $2}')

# Convert values to watts
OUTLET_USED_W=$(echo "$OUTLET_USED" | awk '{print $1/1000}')
OUTLET_AVAILABLE_W=$(echo "$OUTLET_AVAILABLE" | awk '{print $1/1000}')

# Print the values
echo "${OUTLET_USED_W}W / ${OUTLET_AVAILABLE_W}W"
