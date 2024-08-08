#!/usr/bin/env python3
################################################################################
# Script Name:   parse_logs.py
# Description:   Script for parsing performance logs.
# Author:        Matej Bašić
# Email:         mbasic2@algebra.hr
# Created Date:  2024-06-16
# Last Modified: 2024-06-20
# Version:       1.2
#
#
# Notes:
#   This script will filter out the bandwidth information from the iperf logs.
#   Once done with sorting, the script will output bandwidth information
#   to a MySQL database.
#
#
#   This script will parse latency logs from netperf and store them in
#   a MySQL database
#
# History:
#   2024-06-16 - Initial version
#   2024-06-20 - Added TEST_OPTIMIZATIONS parameter
#   2024-06-21 - Convert the script to python; add output to MySQL
################################################################################

# Name the environment you are testing
ACTIVE_TEST_ENVIRONMENT = "cni-flannel"

# Listing all the test optimization levels
TEST_OPTIMIZATIONS = []

# Listing all the test configurations for which the logs will be processed
TEST_CONFIGURATIONS = []

# Listing all the MTU values used in the tests
TEST_MTU_VALUES = []

# Listing all the packet size used in the tests
TEST_PACKET_SIZES = []

# Listing all the protocols used
TEST_PROTOCOLS = []

# Listing all the environments tested
TEST_ENVIRONMENTS = []

# Change this value according to your needs
TEST_LOG_DIRECTORY = "../logs/k8s/cni-flannel"

# Change this value according to your needs
PARSED_LOG_DIRECTORY = "../logs/parsed"

### Change these values according to your needs
DB_HOST = "mysql"
DB_PORT = "3306"
DB_USERNAME = "grafana_user"
DB_PASSWORD = "grafana_user_password"
DB_NAME = "cni_performance_testing"

import os
import glob
import time
import mysql.connector

def convertMbitToGbit(bandwidth_line):
    if "Mbit" in bandwidth_line:
        values =  bandwidth_line.replace('M', " M").split()
        return (round(float(values[0])/1000, 4))    
    if "Gbit" in bandwidth_line:
        values = bandwidth_line.split()
        return (round(float(values[0]), 4))

# Establish a new connection towards the database
db_connection = None
db_connection = mysql.connector.connect(
    host=DB_HOST,
    user=DB_USERNAME,
    password=DB_PASSWORD,
    database=DB_NAME,
    port=DB_PORT
)

db_cursor = db_connection.cursor()

# Get all values for TEST_OPTIMIZATIONS from the database
db_query = ("SELECT * FROM testing_optimization_levels")
db_cursor.execute(db_query)
test_optim = db_cursor.fetchall()
for test_optimization in test_optim:
    temp_optim = {}
    temp_optim['id'] = test_optimization[0]
    temp_optim['name'] = test_optimization[1]
    TEST_OPTIMIZATIONS.append(temp_optim)

# Get all values for TEST_CONFIGURATIONS from the database
db_query = ("SELECT * FROM testing_configurations")
db_cursor.execute(db_query)
test_config = db_cursor.fetchall()
for test_conf in test_config:
    temp_config = {}
    temp_config['id'] = test_conf[0]
    temp_config['name'] = test_conf[1]
    TEST_CONFIGURATIONS.append(temp_config)

# Get all values for TEST_MTU_VALUES from the database
db_query = ("SELECT * FROM testing_mtu_values")
db_cursor.execute(db_query)
testing_mtu_values = db_cursor.fetchall()
for mtu_value in testing_mtu_values:
    temp_mtu_value = {}
    temp_mtu_value['id'] = mtu_value[0]
    temp_mtu_value['name'] = mtu_value[1]
    TEST_MTU_VALUES.append(temp_mtu_value)

# Get all values for TEST_PACKET_SIZES from the database
db_query = ("SELECT * FROM testing_packet_sizes")
db_cursor.execute(db_query)
testing_packet_sizes = db_cursor.fetchall()
for packet_size in testing_packet_sizes:
    temp_packet_size = {}
    temp_packet_size['id'] = packet_size[0]
    temp_packet_size['name'] = packet_size[1]
    TEST_PACKET_SIZES.append(temp_packet_size)

# Get all values for TEST_PROTOCOLS from the database
db_query = ("SELECT * FROM testing_protocols")
db_cursor.execute(db_query)
testing_protocols = db_cursor.fetchall()
for protocol in testing_protocols:
    temp_protocol = {}
    temp_protocol['id'] = protocol[0]
    temp_protocol['name'] = protocol[1]
    TEST_PROTOCOLS.append(temp_protocol)

# Get all values for TEST_ENVIRONMENTS from the database
db_query = ("SELECT * FROM testing_environments")
db_cursor.execute(db_query)
testing_environments = db_cursor.fetchall()
for env in testing_environments:
    temp_env = {}
    temp_env['id'] = env[0]
    temp_env['name'] = env[1]
    TEST_ENVIRONMENTS.append(temp_env)

for test_optimization in TEST_OPTIMIZATIONS:
    for test_configuration in TEST_CONFIGURATIONS:
        
        bandwidth_logs_directory = f"{TEST_LOG_DIRECTORY}/{test_optimization['name']}/{test_configuration['name']}/bandwidth"
        for protocol in TEST_PROTOCOLS:
            search_pattern = os.path.join(bandwidth_logs_directory, f"*{protocol['name']}*")
            proto_bandwidth_logs_files = glob.glob(search_pattern)

            for bandwidth_log_file in proto_bandwidth_logs_files:
                print(f"Parsing file: {bandwidth_log_file}")
                # From the filename, get the mtu
                log_file_mtu = bandwidth_log_file.split('/')[-1].split('-')[-4]
                # From the filename, get the packet size
                log_file_packet_size = bandwidth_log_file.split('/')[-1].split('-')[-2]
                # From the file, get bandwidth
                with open(bandwidth_log_file, 'r') as file:
                    lines = file.readlines()

                    bandwidth_line = lines[-4].strip()
                    bandwidth = ' '.join(bandwidth_line.split()[6:8])
                    bandwidth_converted = convertMbitToGbit(bandwidth)
                    # Prepare data for table
                    bandwidth_final = bandwidth_converted
                    optimization_level_final = test_optimization['id']
                    configuration_level_final = test_configuration['id']
                    protocol_final = protocol['id']
                    mtu_final = next((mtu['id'] for mtu in TEST_MTU_VALUES if mtu['name'] == int(log_file_mtu)), None)
                    packet_size_final = next((packet_size['id'] for packet_size in TEST_PACKET_SIZES if packet_size['name'] == int(log_file_packet_size)), None)
                    environment_final = next((env['id'] for env in TEST_ENVIRONMENTS if env['name'] == ACTIVE_TEST_ENVIRONMENT), None)
                    print(f"############### Data is ready to be added to the database ###############")
                    print(f"Bandwidth: {bandwidth_final}")
                    print(f"Optimization level: {test_optimization['name']} -> ID: {optimization_level_final}")
                    print(f"Configuration level: {test_configuration['name']} -> ID: {configuration_level_final}")
                    print(f"Protocol: {protocol['name']} -> ID: {protocol_final}")
                    print(f"MTU: {log_file_mtu} -> ID: {mtu_final}")
                    print(f"Packet size: {log_file_packet_size} -> ID: {packet_size_final}")
                    print(f"Environment: {ACTIVE_TEST_ENVIRONMENT} -> {environment_final}")
                    #time.sleep(0.5)

                    db_query = (
                        "INSERT INTO test_runs_bandwidth (network_bandwidth, optimization_level_id, configuration_id, protocol_id, mtu_value_id, packet_size_id, testing_environment_id)"
                        "VALUES (%s, %s, %s, %s, %s, %s, %s)" 
                    )
                    db_cursor.execute(db_query, (bandwidth_final, optimization_level_final, configuration_level_final, protocol_final, mtu_final, packet_size_final, environment_final))
                    db_connection.commit()

        # LATENCY
        latency_logs_directory = f"{TEST_LOG_DIRECTORY}/{test_optimization['name']}/{test_configuration['name']}/latency"

        for protocol in TEST_PROTOCOLS:
            search_pattern = os.path.join(latency_logs_directory, f"*{protocol['name']}*")
            proto_latency_logs_files = glob.glob(search_pattern)

            for latency_log_file in proto_latency_logs_files:
                print(f"Parsing file: {latency_log_file}")
                # From the filename, get the mtu
                log_file_mtu = latency_log_file.split('/')[-1].split('-')[-2]
                # From the file, get latency
                with open(latency_log_file, 'r') as file:
                    lines = file.readlines()
                    latency_line = lines[-1].strip()
                    min_latency, mean_latency, max_latency, stddev_latency, transfer_rate = latency_line.split(',')
                    optimization_level_final = test_optimization['id']
                    configuration_level_final = test_configuration['id']
                    protocol_final = protocol['id']
                    mtu_final = next((mtu['id'] for mtu in TEST_MTU_VALUES if mtu['name'] == int(log_file_mtu)), None)
                    environment_final = next((env['id'] for env in TEST_ENVIRONMENTS if env['name'] == ACTIVE_TEST_ENVIRONMENT), None)
                    print(f"############### Data is ready to be added to the database ###############")
                    print(f"Min latency: {min_latency}")
                    print(f"Mean latency: {mean_latency}")
                    print(f"Max latency: {max_latency}")
                    print(f"Stddev latency: {stddev_latency}")
                    print(f"Optimization level: {test_optimization['name']} -> ID: {optimization_level_final}")
                    print(f"Configuration level: {test_configuration['name']} -> ID: {configuration_level_final}")
                    print(f"Protocol: {protocol['name']} -> ID: {protocol_final}")
                    print(f"MTU: {log_file_mtu} -> ID: {mtu_final}")
                    print(f"Environment: {ACTIVE_TEST_ENVIRONMENT} -> {environment_final}")
                    #time.sleep(1)

                    db_query = (
                        "INSERT INTO test_runs_latency (minimum_latency, maximum_latency, mean_latency, stddev_latency, optimization_level_id, configuration_id, protocol_id, mtu_value_id, testing_environment_id)"
                        "VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)" 
                    )
                    db_cursor.execute(db_query, (min_latency, max_latency, mean_latency, stddev_latency, optimization_level_final, configuration_level_final, protocol_final, mtu_final, environment_final))
                    db_connection.commit()


# Close the connection
db_cursor.close()
db_connection.close()