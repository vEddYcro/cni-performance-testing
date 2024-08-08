#!/bin/bash

# Listing all the test optimization levels
TEST_OPTIMIZATIONS=("1-default_settings" "2-kernel_optimizations" "3-nic_optimizations" "4-tuned_acc_performance" "5-tuned_hcp_compute" "6-tuned_latency_performance" "7-tuned_network_latency" "8-tuned_network_throughput")

# Listing all the test configurations 
TEST_CONFIGURATIONS=("1-gigabit" "10-gigabit" "10-gigabit-lag" "fiber-to-fiber" "local")

TEST_MTU=("1500" "9000")

TEST_PACKET_SIZE=("64" "512" "1472" "9000" "15000")

TEST_PROTOCOLS=("tcp" "udp")

TEST_ENVIRONMENT="cni-calico"

for optimization in ${TEST_OPTIMIZATIONS[@]};
do

    # Get bandwith test logs
    for configuration in ${TEST_CONFIGURATIONS[@]};
    do
        for mtu in ${TEST_MTU[@]};
        do
            for packet in ${TEST_PACKET_SIZE[@]};
            do
                tcp_pods=$(kubectl get pods -l mtu=$mtu,packet=$packet,optimization=$optimization,config=$configuration,protocol=tcp -o name)
                for pod in ${tcp_pods[@]};
                do
                    id=$(echo $pod | cut -d '-' -f4)
                    echo "Fetching" $pod "(Optimization:" $optimization ", configuration:" $configuration ")"
                    kubectl logs $pod >> ../logs/k8s/$TEST_ENVIRONMENT/$optimization/$configuration/bandwidth/tcp-mtu-$mtu-packet-$packet-$id.log
                done

                udp_pods=$(kubectl get pods -l mtu=$mtu,packet=$packet,optimization=$optimization,config=$configuration,protocol=udp -o name)
                for pod in ${udp_pods[@]};
                do
                    id=$(echo $pod | cut -d '-' -f4)
                    echo "Fetching" $pod "(Optimization:" $optimization ", configuration:" $configuration ")"
                    kubectl logs $pod >> ../logs/k8s/$TEST_ENVIRONMENT/$optimization/$configuration/bandwidth/udp-mtu-$mtu-packet-$packet-$id.log
                done
            done
        done
    done

    # Get latency test logs
    for configuration in ${TEST_CONFIGURATIONS[@]};
    do
        for mtu in ${TEST_MTU[@]};
        do
            tcp_lat_pods=$(kubectl get pods -l mtu=$mtu,optimization=$optimization,config=$configuration,protocol=tcp -o name | grep latency)
            for lat_pod in ${tcp_lat_pods[@]};
            do
                id=$(echo $lat_pod | cut -d '-' -f4)
                echo "Fetching" $lat_pod "  (Optimization:" $optimization ", configuration:" $configuration ")"
                kubectl logs $lat_pod >> ../logs/k8s/$TEST_ENVIRONMENT/$optimization/$configuration/latency/tcp-mtu-$mtu-$id.log
            done

            udp_lat_pods=$(kubectl get pods -l mtu=$mtu,optimization=$optimization,config=$configuration,protocol=udp -o name | grep latency)
            for lat_pod in ${udp_lat_pods[@]};
            do
                id=$(echo $lat_pod | cut -d '-' -f4)
                echo "Fetching" $lat_pod "  (Optimization:" $optimization ", configuration:" $configuration ")"
                kubectl logs $lat_pod >> ../logs/k8s/$TEST_ENVIRONMENT/$optimization/$configuration/latency/udp-mtu-$mtu-$id.log
            done
        done
    done

done