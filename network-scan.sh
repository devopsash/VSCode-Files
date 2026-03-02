#!/bin/bash

# Check if nmap is installed
if ! command -v nmap &> /dev/null; then
    echo "Error: nmap is not installed. Install it with 'sudo apt install nmap'."
    exit 1
fi

# Check for root privileges (Required for OS detection -O)
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root (sudo) for OS detection."
   exit 1
fi

# Get user input
read -p "Enter the VLAN/Subnet (e.g., 192.168.1.0/24): " TARGET

if [[ -z "$TARGET" ]]; then
    echo "No target specified. Exiting."
    exit 1
fi

# Create filename with timestamp
TIMESTAMP=$(date +"%Y-%m-%d_%H%M")
FILENAME="inventory_${TIMESTAMP}.csv"

echo "--- Starting Deep Scan on $TARGET ---"
echo "IP,DNS_Hostname,State,OS_Name,Open_Ports,Scan_Timestamp" > "$FILENAME"

# Temporary file to store raw nmap output
TEMP_FILE=$(mktemp)

# Run Nmap
# -O: OS Detection, -sV: Service Version, -F: Fast Scan
# -oX: XML output is the most reliable for parsing complex data
nmap -O -sV -F "$TARGET" -oX "$TEMP_FILE" > /dev/null

# Extract data using basic grep/sed (Simplified version of your Python logic)
# Note: For production, using 'xmlstarlet' to parse the XML is more robust.
while read -r line; do
    if [[ $line == *"address addr="* ]]; then
        IP=$(echo "$line" | cut -d'"' -f2)
        
        # 1. DNS Hostname
        DNS_NAME=$(host "$IP" | awk '{print $NF}' | sed 's/\.$//')
        if [[ "$DNS_NAME" == *"reached"* || "$DNS_NAME" == *"found"* ]]; then DNS_NAME="No DNS Record"; fi
        
        # 2. OS Detection (Searching the XML for the best match)
        OS=$(grep -A 5 "addr=\"$IP\"" "$TEMP_FILE" | grep "osmatch name=" | head -1 | cut -d'"' -f2)
        if [[ -z "$OS" ]]; then OS="Unknown"; fi
        
        # 3. State
        STATE="up" # If it's in the list, it responded
        
        # 4. Ports
        PORTS=$(grep -A 20 "addr=\"$IP\"" "$TEMP_FILE" | grep "portid=" | sed 's/.*portid="\([^"]*\)".*name="\([^"]*\)".*/\1\/\2/' | tr '\n' '|' | sed 's/|$//')
        
        # Append to CSV
        echo "$IP,$DNS_NAME,$STATE,\"$OS\",\"$PORTS\",$(date +"%Y-%m-%d %H:%M:%S")" >> "$FILENAME"
        echo "Analyzed $IP..."
    fi
done < <(grep "address addr=" "$TEMP_FILE")

rm "$TEMP_FILE"

echo -e "\n--- Scan Complete ---"
echo "Results exported to: $FILENAME"
