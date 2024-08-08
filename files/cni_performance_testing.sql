-- Create the database
CREATE DATABASE IF NOT EXISTS cni_performance_testing;

-- Switch to the database
USE cni_performance_testing;

-- Create the 'testing_optimization_levels' table and add entries
CREATE TABLE testing_optimization_levels (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

INSERT INTO testing_optimization_levels (name) VALUES 
('1-default_settings'),
('2-kernel_optimizations'),
('3-nic_optimizations'),
('4-tuned_acc_performance'),
('5-tuned_hcp_compute'),
('6-tuned_latency_performance'),
('7-tuned_network_latency'),
('8-tuned_network_throughput');

-- Create the 'testing_configurations' table and add entries
CREATE TABLE testing_configurations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

INSERT INTO testing_configurations (name) VALUES 
('1-gigabit'),
('10-gigabit'),
('10-gigabit-lag'),
('fiber-to-fiber'),
('local');

-- Create the 'testing_environments' table and add entries
CREATE TABLE testing_environments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

INSERT INTO testing_environments (name) VALUES 
('operating-system'),
('cni-antrea'),
('cni-cilium'),
('cni-flannel'),
('cni-calico');

-- Create the 'testing_protocols' table and add entries
CREATE TABLE testing_protocols (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

INSERT INTO testing_protocols (name) VALUES 
('tcp'),
('udp');

-- Create the 'testing_mtu_values' table and add entries
CREATE TABLE testing_mtu_values (
    id INT AUTO_INCREMENT PRIMARY KEY,
    value INT NOT NULL
);

INSERT INTO testing_mtu_values (value) VALUES 
(1500),
(9000);

-- Create the 'testing_packet_sizes' table and add entries
CREATE TABLE testing_packet_sizes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    size INT NOT NULL
);

INSERT INTO testing_packet_sizes (size) VALUES 
(64),
(512),
(1472),
(9000),
(15000);

-- Create the 'test_runs_bandwidth' table to connect all other tables
CREATE TABLE test_runs_bandwidth (
    id INT AUTO_INCREMENT PRIMARY KEY,
    network_bandwidth FLOAT(4) NOT NULL,
    optimization_level_id INT NOT NULL,
    configuration_id INT NOT NULL,
    protocol_id INT NOT NULL,
    mtu_value_id INT NOT NULL,
    packet_size_id INT NOT NULL,
    testing_environment_id INT NOT NULL,
    FOREIGN KEY (optimization_level_id) REFERENCES testing_optimization_levels(id),
    FOREIGN KEY (configuration_id) REFERENCES testing_configurations(id),
    FOREIGN KEY (protocol_id) REFERENCES testing_protocols(id),
    FOREIGN KEY (mtu_value_id) REFERENCES testing_mtu_values(id),
    FOREIGN KEY (packet_size_id) REFERENCES testing_packet_sizes(id),
    FOREIGN KEY (testing_environment_id) REFERENCES testing_environments(id)
);


-- Create the 'test_runs_latency' table to connect all other tables
CREATE TABLE test_runs_latency (
    id INT AUTO_INCREMENT PRIMARY KEY,
    minimum_latency FLOAT(4) NOT NULL,
    mean_latency FLOAT(4) NOT NULL,
    maximum_latency FLOAT(4) NOT NULL,
    stddev_latency FLOAT(4) NOT NULL,
    optimization_level_id INT NOT NULL,
    configuration_id INT NOT NULL,
    protocol_id INT NOT NULL,
    mtu_value_id INT NOT NULL,
    testing_environment_id INT NOT NULL,
    FOREIGN KEY (optimization_level_id) REFERENCES testing_optimization_levels(id),
    FOREIGN KEY (configuration_id) REFERENCES testing_configurations(id),
    FOREIGN KEY (protocol_id) REFERENCES testing_protocols(id),
    FOREIGN KEY (mtu_value_id) REFERENCES testing_mtu_values(id),
    FOREIGN KEY (testing_environment_id) REFERENCES testing_environments(id)
);