#!/bin/bash 
local_ipaddress=$(ip -o -4 route show to default | awk '{print $3}' | cut -d. -f1-3 | awk '{print $1".0/16"}')
kubeadm init --pod-network-cidr=$local_ipaddress