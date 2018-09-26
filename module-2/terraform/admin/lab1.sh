#!/bin/bash

# Lab 1 Cloud Shell #1

# Set speed
SPEED=40
bold=$(tput bold)
normal=$(tput sgr0)

color='\e[1;32m' # green
nc='\e[0m'

echo -e "\n"
echo "${bold}*** Lab 1: Build Walk Through - Cloud Shell Window #1 ***${normal}"
echo -e "\n"

echo "${bold}Check current dev namespace deployments${normal}"
echo -e "${color}$ kubectl get all -n dev --context gke-central${nc}" | pv -qL $SPEED
kubectl get all -n dev --context gke-central

# Inspect files for frontend
echo -e "\n"
echo "${bold}Inspect frontend app files${normal}"
read -p ''
echo -e "${color}$ cd ~/advanced-kubernetes-workshop/services/frontend/; ls -l${nc}" | pv -qL $SPEED
cd ~/advanced-kubernetes-workshop/services/frontend/; ls -al
 
# Inspect Dockerfile
echo -e "\n"
echo "${bold}Inspect frontend Dockerfile${normal}"
read -p ''
echo -e "${color}$ cat Dockerfile${nc}" | pv -qL $SPEED
cat Dockerfile

# Inspect skaffold.yaml
echo -e "\n"
echo "${bold}Inspect skaffold.yaml${normal}"
read -p ''
echo -e "${color}$ cat skaffold.yaml${nc}" | pv -qL $SPEED
cat skaffold.yaml

# Inspect frontend dev manifest file
echo -e "\n"
echo "${bold}Inspect frontend dev manifest file${normal}"
read -p ''
echo -e "${color}$ cat k8s-frontend-dev.yml${nc}" | pv -qL $SPEED
cat k8s-frontend-dev.yml

# Start skaffold dev
echo -e "\n"
echo "${bold}Start skaffold dev${normal}"
read -p ''
echo -e "${color}$ cd ~/advanced-kubernetes-workshop/services/frontend/; kubectx gke-central; skaffold dev${nc}" | pv -qL $SPEED
cd ~/advanced-kubernetes-workshop/services/frontend/; kubectx gke-central; skaffold dev


