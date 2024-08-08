# Use the official Ubuntu base image
FROM ubuntu:24.04

# Set environment variables to non-interactive to avoid user input prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install iperf3 and netperf
RUN apt-get update && \
    apt-get install -y iperf3 netperf && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Expose the ports commonly used by iperf3 and netperf
EXPOSE 8080 9090

# Default command to run when the container starts
CMD ["bash"]
