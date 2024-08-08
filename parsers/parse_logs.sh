#!/bin/bash

################################################################################
# Script Name:   parse_logs.sh
# Description:   Script for parsing Bitrate info from performance logs.
# Author:        Matej Bašić
# Email:         mbasic2@algebra.hr
# Created Date:  2024-06-16
# Last Modified: 2024-06-20
# Version:       1.1
#
#
# Notes:
#   This script will first filter out only last 3 lines of the bandwith test
#   log file. The only information that will be used from the file is 
#   the Bitrate in the 6th column of the file.
#
#   The script will output the results for each test configuration into a 
#   separate file for both TCP and UDP tests.
#
#
# History:
#   2024-06-16 - Initial version
#   2024-06-20 - Added TEST_OPTIMIZATIONS parameter
################################################################################

# Listing all the test optimization levels
TEST_OPTIMIZATIONS=("1-default_settings" "2-kernel_optimizations" "3-nic_optimizations" "4-tuned_acc_performance" "5-tuned_hpc_compute" "6-tuned_latency_performance" "7-tuned_network_latency" "8-tuned_network_throughput")

# Listing all the test configurations for which the logs will be processed
TEST_CONFIGURATIONS=("1-gigabit" "10-gigabit" "10-gigabit-lag" "fiber-to-fiber" "local")

# Listing all the MTU values used in the tests
TEST_MTU_VALUES=("1500" "9000")

# Listing all the packet size used in the tests
TEST_PACKET_SIZES=("64" "512" "1472" "9000" "15000")

# Change this value according to your needs
TEST_LOG_DIRECTORY="../logs/doktnet01/testing_results"

# Change this value according to your needs
PARSED_LOG_DIRECTORY="../logs/parsed"

# Loop through all the TEST_OPTIMIZATION levels
# For each OPTIMIZATION level, loop through each of the TEST_CONFIGURATIONS
# For each CONFIGURATIOM level, take the 6th column in the 3rd last line from the bandwith logs
for test_optimization in ${TEST_OPTIMIZATIONS[@]};
do
    for test_configuration in ${TEST_CONFIGURATIONS[@]};
    do
        bandwith_logs_directory="${TEST_LOG_DIRECTORY}/${test_optimization}/${test_configuration}/bandwith"
        # Create the bandwith_logs_directory
        mkdir -p "${PARSED_LOG_DIRECTORY}/${test_optimization}/${test_configuration}/bandwith"

        # Find all the protocol specific logs
        for protocol in "tcp" "udp";
        do 
            proto_bandwith_logs_files=$(find $bandwith_logs_directory -name "*${protocol}*" -print)
            for bandwith_log_file in ${proto_bandwith_logs_files[@]};
            do 
                # From the filename, get the mtu
                log_file_mtu=$(echo $bandwith_log_file | rev | cut -d '/' -f1 | rev | cut -d '-' -f3)
                # From the filename, get the packet size
                log_file_packet_size=$(echo $bandwith_log_file | rev | cut -d '/' -f1 | rev | cut -d '-' -f5 )
                # From the file get bandwith
                BANDWITH=$(tail -n4 ${bandwith_log_file} | head -n1 | awk '{print $7 $8}')
                echo $BANDWITH >> "${PARSED_LOG_DIRECTORY}/${test_optimization}/${test_configuration}/bandwith/${protocol}-mtu-${log_file_mtu}-packet-${log_file_packet_size}.log"
                echo "PROTO: ${protocol} - ${bandwith_log_file} - MTU: ${log_file_mtu} - packet: ${log_file_packet_size}"
            done
        done
        
        latency_logs_directory="${TEST_LOG_DIRECTORY}/${test_optimization}/${test_configuration}/latency"
        # Create the latency_logs_directory
        mkdir -p "${PARSED_LOG_DIRECTORY}/${test_optimization}/${test_configuration}/latency"

        # Find all the protocol specific logs
        for protocol in "tcp" "udp";
        do
            proto_latency_logs_files=$(find $latency_logs_directory -name "*${protocol}*" -print)
            for latency_log_file in ${proto_latency_logs_files[@]};
            do
                # From the filename, get the mtu
                log_file_mtu=$(echo $latency_log_file | rev | cut -d '/' -f1 | rev | cut -d '-' -f3)
                # From the filename, get the packet size
                log_file_packet_size=$(echo $latency_log_file | rev | cut -d '/' -f1 | rev | cut -d '-' -f5 )
                # From the file get latency
                LATENCY=$(tail -n4 ${latency_log_file} | head -n1 | awk '{print $7 $8}')
                # Save the latency to specific log file
                echo $LATENCY >> "${PARSED_LOG_DIRECTORY}/${test_optimization}/${test_configuration}/latency/${protocol}-mtu-${log_file_mtu}-packet-${log_file_packet_size}.log"
                echo "PROTO: ${protocol} - ${latency_log_file} - MTU: ${log_file_mtu} - packet: ${log_file_packet_size}"
            done
        done
    done
done