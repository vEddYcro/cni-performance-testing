We created this code for two reasons:

1. For a journal paper in the area of computer science
2. so that people worldwide, especially in the HPC space, can have a performance evaluation tool that can go through various iterations of network testing before putting the CNI plugin/configuration combo in HPC production.

This is important because there's a correlation between the CNI plugin, system configuration, network packet, and frame size, especially when dealing with distributed applications in HPC space. The code is designed to perform performance evaluations using two servers. In data center design, there's a familiar design process for compute clusters—you always use the same hosts as they represent the same amount of performance and, therefore, the same amount of QoS. The data this produces can be used to train AI/ML engines and further develop the methodology for X number of servers. 

The idea of this code is fairly straightforward, although the code certainly isn't. We have a set of tuned profiles (mostly built-in and two custom profiles). Our Ansible code goes through a loop that does TCP and UDP performance evaluations using iperf for bandwidth and netperf for bandwidth. It loops through all of these tuned profiles, TCP/UDP bandwidth, and latency tests for five different network package sizes and a set of frame sizes. Then, it saves its results to a database for a configurable number of runs (the default number of runs for TCP is 5, and the default number for UDP is 2. The number of runs can be changed in the code by changing the values of two parameters.

After the data gets saved to a database, we want to be able to display it in almost real-time. This is why our Ansible code contains code to deploy Grafana. This part of the process is semi-manual, as we have to connect to the Grafana UI and type in the IP address, username, password, and database information for the database we're using to store performance evaluation results. It's a simple wizard that is easy to do. Data gets averaged out across 5 TCP and 2 UDP runs.

The code also contains HELM charts to deploy CNI plugins (Antrea, Calico, Cilium, and Flannel). Ansible uses these charts to manage CNI deployment and has code to remove a CNI plugin automatically. Again, this has been done to automate everything—we see no reason, for example, that a scientist in HPC space should do all of this manually.

This code is part of a larger theme and paper that's already been published by MDPI Electronics. You can read that paper here:
https://www.mdpi.com/2079-9292/13/13/2651

Thank you for being interested in our code. Feel free to use it, modify it, or whatever. The code is heavily commented on, which should help with any modifications. We offer the code as-is without any guarantees.
