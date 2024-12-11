#!/bin/bash

# Disk speed and IOPS test script for Ubuntu 20.04

# Temporary file for testing
temp_file="/tmp/disk_speed_test.tmp"

# Block size for sequential read/write tests (1 GB)
block_size=1G

# Block size for IOPS test (4 KB)
iops_block_size=4K

# Number of blocks for sequential tests
count=1

# Number of blocks for IOPS test
io_count=10000

# Test write speed
echo "Testing write speed..."
write_speed=$(dd if=/dev/zero of=$temp_file bs=$block_size count=$count oflag=direct 2>&1 | grep -oP "\d+(\.\d+)? (?=MB/s|GB/s)")

# Test read speed
echo "Testing read speed..."
read_speed=$(dd if=$temp_file of=/dev/null bs=$block_size count=$count iflag=direct 2>&1 | grep -oP "\d+(\.\d+)? (?=MB/s|GB/s)")

# Test IOPS for write operations
echo "Testing IOPS for write operations..."
iops_write=$(dd if=/dev/zero of=$temp_file bs=$iops_block_size count=$io_count oflag=direct 2>&1 | grep -oP "\d+(\.\d+)? (?=MB/s|GB/s)")
write_iops=$(echo "$iops_write * 1024 / 4" | bc)

# Test IOPS for read operations
echo "Testing IOPS for read operations..."
iops_read=$(dd if=$temp_file of=/dev/null bs=$iops_block_size count=$io_count iflag=direct 2>&1 | grep -oP "\d+(\.\d+)? (?=MB/s|GB/s)")
read_iops=$(echo "$iops_read * 1024 / 4" | bc)

# Clean up the temporary file
rm -f $temp_file

# Output results
echo "Write speed: $write_speed MB/s"
echo "Read speed: $read_speed MB/s"
echo "Write IOPS: $write_iops"
echo "Read IOPS: $read_iops"
