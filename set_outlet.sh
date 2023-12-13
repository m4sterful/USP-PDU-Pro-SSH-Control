#!/bin/ash

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <outlet_number> <state>"
    echo "state can be 'enabled' or 'disabled'"
    exit 1
fi

OUTLET_NUMBER=$1
NEW_STATE=$2
FILE="/var/run/powerd.conf"

# Validate the outlet number
if ! [[ $OUTLET_NUMBER =~ ^[0-9]+$ ]]; then
    echo "Error: Outlet number must be an integer."
    exit 1
fi

# Validate the new state
if [ "$NEW_STATE" != "enabled" ] && [ "$NEW_STATE" != "disabled" ]; then
    echo "Error: State must be 'enabled' or 'disabled'."
    exit 1
fi

# Update the file
sed -i "/outlet.${OUTLET_NUMBER}.relay_state=/c\outlet.${OUTLET_NUMBER}.relay_state=${NEW_STATE}" $FILE

if [ $? -eq 0 ]; then
    echo "Outlet $OUTLET_NUMBER state updated to $NEW_STATE."
else
    echo "Error: Failed to update the state of outlet $OUTLET_NUMBER."
fi
