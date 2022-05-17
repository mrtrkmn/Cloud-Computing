#!/bin/bash

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

# required for exercise-1 submission

INSTALL_NODEJS
INSTALL_MONGODB