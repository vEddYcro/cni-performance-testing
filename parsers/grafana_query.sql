SELECT 
                testing_optimization_levels.name AS 'Optimization Level',
                AVG(CASE WHEN testing_configurations.name = '1-gigabit' THEN test_runs_bandwidth.network_bandwidth END) AS '1-gigabit',
                AVG(CASE WHEN testing_configurations.name = '10-gigabit' THEN test_runs_bandwidth.network_bandwidth END) AS '10-gigabit',
                AVG(CASE WHEN testing_configurations.name = '10-gigabit-lag' THEN test_runs_bandwidth.network_bandwidth END) AS '10-gigabit-lag',
                AVG(CASE WHEN testing_configurations.name = 'fiber-to-fiber' THEN test_runs_bandwidth.network_bandwidth END) AS 'Fiber-To-Fiber',
                AVG(CASE WHEN testing_configurations.name = 'local' THEN test_runs_bandwidth.network_bandwidth END) AS 'Local'
FROM            test_runs_bandwidth
JOIN            testing_optimization_levels ON test_runs_bandwidth.optimization_level_id = testing_optimization_levels.id
JOIN            testing_configurations ON test_runs_bandwidth.configuration_id = testing_configurations.id
JOIN            testing_protocols ON test_runs_bandwidth.protocol_id = testing_protocols.id
JOIN            testing_mtu_values ON test_runs_bandwidth.mtu_value_id = testing_mtu_values.id
JOIN            testing_packet_sizes ON test_runs_bandwidth.packet_size_id = testing_packet_sizes.id
WHERE           testing_protocols.name = "tcp" 
AND             testing_mtu_values.value = "1500"
AND             testing_packet_sizes.size = "1472"
GROUP BY        testing_optimization_levels.name



