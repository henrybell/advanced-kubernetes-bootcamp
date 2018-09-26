#!/bin/bash

# Lab 3: Control

# Set speed
SPEED=45
bold=$(tput bold)
normal=$(tput sgr0)

color='\e[1;32m' # green
nc='\e[0m'

echo -e "\n"
echo "${bold}*** Lab 3: Control Walk Through Cloud Shell #1 ***${normal}"
echo -e "\n"

# Ensure pipeline has deployed to canary
echo "${bold}Ensure pipelines have deployed canary to production${normal}"
read -p ''

# Inspect GATEWAY for the frontend production service
echo -e "\n"
echo "${bold}Inspect GATEWAY for the frontend production service${normal}"
read -p ''
echo -e "${color}$ istioctl get gateway -n production --context gke-central -o yaml${nc}" | pv -qL $SPEED
istioctl get gateway -n production --context gke-central -o yaml
echo -e "\n"

# Inspect VIRTUALSERVICE for the frontend production service
echo "${bold}Inspect VIRTUALSERVICE for the frontend production service${normal}"
read -p ''
echo -e "${color}$ istioctl get virtualservice frontend -n production --context gke-central -o yaml${nc}" | pv -qL $SPEED
istioctl get virtualservice frontend -n production --context gke-central -o yaml
echo -e "\n"

# Inspect DESTINATIONRULE for the frontend production service
echo "${bold}Inspect DESTINATIONRULE for the frontend production service${normal}"
read -p ''
echo -e "${color}$ istioctl get destinationrule frontend -n production --context gke-central -o yaml${nc}" | pv -qL $SPEED
istioctl get destinationrule frontend -n production --context gke-central -o yaml
echo -e "\n"

# Inspect deployments in the production namespace
echo "${bold}Inspect deployments in the production namespace${normal}"
read -p ''
echo -e "${color}$ kubectl get deploy -n production --context gke-central${nc}" | pv -qL $SPEED
kubectl get deploy -n production --context gke-central
echo -e "\n"

# Get ingress IP for the production frontend
echo "${bold}Get the ingress IP addresses for production frontend${normal}"
read -p ''
echo -e "${color}$ get-ingress.sh${nc}" | pv -qL $SPEED
get-ingress.sh
echo -e "\n"

# Generate some traffic to frontend production using fortio
echo "${bold}Generate some traffic to frontend production using fortio${normal}"
echo "${bold}While traffic is being generated, open a new Cloud Shell window${normal}"
read -p ''
export GKE_ONE_ISTIO_GATEWAY=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[0].ip}" --context gke-central)
echo -e "${color}$ fortio.sh 30m http://$GKE_ONE_ISTIO_GATEWAY${nc}" | pv -qL $SPEED
fortio.sh 30m http://$GKE_ONE_ISTIO_GATEWAY







