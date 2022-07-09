#!/bin/bash

DOCKER_COMPOSE_VERSION=v2.6.0

BLUE="\033[0;34m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m" 

INSTALL_ESSENTIALS(){
    echo -e "${BLUE}Installing essentials${NC}"
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common 
    apt-get install -y net-tools
}


INSTALL_MONGODB() {
    

    {   
        printf "${YELLOW}Adding MongoDB public keys...${NC}\n"
        curl  --no-progress-meter -fsSL  https://www.mongodb.org/static/pgp/server-5.0.asc |  apt-key add -

    } || {

        printf "${YELLOW}curl cannot be found installing curl .${NC}\n"
        apt install curl -y
        curl  --no-progress-meter -fsSL  https://www.mongodb.org/static/pgp/server-5.0.asc |  apt-key add -
    }
   
    touch /etc/apt/sources.list.d/mongodb-org-5.0.list
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" |  tee /etc/apt/sources.list.d/mongodb-org-5.0.list
    apt update
    printf "${YELLOW}Installing MongoDB...${NC}\n"
    apt install -y mongodb-org

    {
        printf "${YELLOW}Starting MongoDB...${NC}\n"
        systemctl start mongod

    } || {
        printf "${YELLOW}Reloading system daemon...${NC}\n"
        systemctl daemon-reload
    } 
    
    systemctl enable mongod

    {
        printf "${YELLOW}Checking MongoDB version...${NC}\n"
        mongod --version
    } || {
        printf "${YELLOW}There is an issue while checking version of mongodb...${NC}\n"
        printf "${YELLOW}Please check manually...${NC}\n"
        exit 1
    }

}
INSTALL_NODEJS() {
    printf "${YELLOW}Installing NPM...${NC}\n"
    curl  --no-progress-meter  -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    apt install nodejs
}



INSTALL_DOCKER_COMPOSE() {
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

INSTALL_DOCKER_ENGINE() {
    printf "${YELLOW}Installing Docker...${NC}\n"
    curl  --no-progress-meter  -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    printf "${YELLOW}Adding $USER to docker group...\n"
    usermod -aG docker $USER
    printf "${YELLOW} Enabling docker service...\n"
    systemctl enable docker
    printf "${YELLOW} Starting docker service...${NC}\n"
    systemctl start docker
    rm get-docker.sh
}

CONFIGURE_DOCKER_ENGINE() {
    printf "${YELLOW} Stopping docker service...${NC}\n"
    systemctl stop docker
    cp /tmp/docker.service /lib/systemd/system/docker.service
    systemctl daemon-reload
    systemctl restart docker
}

INSTALL_KUBERNETES(){
    printf "${YELLOW}Installing kubernetes...${NC}\n"
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
    deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
    apt-get update
    apt-get install -y kubelet kubeadm kubernetes-cni
    printf "${GREEN} Kubernetes is installed...${NC}\n"
}

CONFIGURE_KUBERNETES(){
    printf "${YELLOW}Configuring kubernetes...${NC}\n"
    sudo su root
    rm /etc/containerd/config.toml
    systemctl restart containerd 
    local_ipaddress=$(ip -o -4 route show to default | awk '{print $3}' | cut -d. -f1-3)
    subnet=".0/16"
    kubeadm init --pod-network-cidr=$local_ipaddress$subnet
    su mrturkmen
    sudo mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    sudo su root 
    wget https://github.com/flannel-io/flannel/releases/download/v0.18.1/flanneld-amd64
    mv flanneld-amd64 /usr/bin/flanneld
    su mrturkmen
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
}




RUN_EXERCISE_2() {
    docker-compose -f /home/mrturkmen/docker-compose.yml up -d 
    rm -rf ~/exercise-2/.env
}

RUN_EXERCISE_3() {
    cd /home/mrturkmen/exercise-3
    docker-compose -f /home/mrturkmen/exercise-3/docker-compose.yml up -d
}

# required for exercise-1 submission

# INSTALL_NODEJS
#INSTALL_MONGODB # removed since exercise-2 deploys it as docker image


# required for exercise-2 submission 
INSTALL_ESSENTIALS
INSTALL_DOCKER_ENGINE
CONFIGURE_DOCKER_ENGINE
INSTALL_DOCKER_COMPOSE 
# RUN_APPLICATION
# RUN_EXERCISE_3
INSTALL_KUBERNETES
CONFIGURE_KUBERNETES