#!/bin/bash

################################################################################
# Script Name:   run_all_tests.sh
# Description:   Script for running all network performance tests.
# Author:        Matej Bašić
# Email:         mbasic2@algebra.hr
# Created Date:  2024-06-17
# Last Modified: 2024-06-17
# Version:       1.0
#
#
# Notes:
#   This script can be used to run all tests defined in test_optimization
#   and test_configuration directories.
#
#   Make sure to verify setup and cleanup scripts for each optimization / 
#   configuration
#
# History:
#   2024-06-17 - Initial version
################################################################################

# Listing all the test optimization levels
TEST_OPTIMIZATIONS=("1-default_settings" "2-kernel_optimizations" "3-nic_optimizations" "4-tuned_acc_performance" "5-tuned_hcp_compute" "6-tuned_latency_performance" "7-tuned_network_latency" "8-tuned_network_throughput")

# Listing all the test configurations 
TEST_CONFIGURATIONS=("1-gigabit" "10-gigabit" "10-gigabit-lag" "fiber-to-fiber" "local")

# Define either operating-system or kubernetes testing
TEST_ENVIRONMENT="kubernetes"

# Define BANDWIDTH_SERVER -> endpoint to which the tests are pointed
BANDWIDTH_SERVER="172.16.21.2"

# Define LATENCY_SERVER -> endpoint to which the tests are pointed
LATENCY_SERVER="172.16.21.2"

for optimization in ${TEST_OPTIMIZATIONS[@]};
do
    ansible-playbook -i inventory test_optimization/$optimization/setup.yml ; 

    for configuration in ${TEST_CONFIGURATIONS[@]};
    do
        ansible-playbook -i inventory tests/test_cleanup.yml ; 
        ansible-playbook -i inventory test_configuration/$configuration/test.yml --extra-vars "bandwidth_server=$BANDWIDTH_SERVER" --extra-vars "latency_server=$LATENCY_SERVER" --extra-vars "test_optimization=$optimization" --extra-vars "test_environment=$TEST_ENVIRONMENT"; 
    done

    ansible-playbook -i inventory test_optimization/$optimization/cleanup.yml ; 
done
