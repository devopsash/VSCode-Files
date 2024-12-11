#!/bin/bash

# Disk speed test script for Ubuntu 20.04

# Temporary file for testing
temp_file="/tmp/disk_speed_test.tmp"

# Block size for testing (1 GB)
block_size=1G

# Number of blocks
count=1

# Test write speed
echo "Testing write speed..."
write_speed=$(dd if=/dev/zero of=$temp_file bs=$block_size count=$count oflag=direct 2>&1 | grep -oP "\d+(\.\d+)? (?=MB/s|GB/s)")

# Test read speed
echo "Testing read speed..."
read_speed=$(dd if=$temp_file of=/dev/null bs=$block_size count=$count iflag=direct 2>&1 | grep -oP "\d+(\.\d+)? (?=MB/s|GB/s)")

# Clean up the temporary file
rm -f $temp_file

# Output results
echo "Write speed: $write_speed MB/s"
echo "Read speed: $read_speed MB/s"
