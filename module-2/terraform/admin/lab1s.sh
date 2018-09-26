#!/bin/bash

# Lab 1 Cloud Shell #2

# Set speed
SPEED=40
bold=$(tput bold)
normal=$(tput sgr0)

color='\e[1;32m' # green
nc='\e[0m'

echo -e "\n"
echo "${bold}*** Lab 1: Build Walk Through - Cloud Shell Window #2 ***${normal}"
echo -e "\n"

echo "${bold}Confirm frontend-dev deployed in dev namespace${normal}"
read -p ''
echo -e "${color}$ kubectl get deploy -n dev --context gke-central${nc}" | pv -qL $SPEED
kubectl get deploy -n dev --context gke-central

# Get frontend-dev service external IP address
echo -e "\n"
echo "${bold}Get frontend-dev service external IP address${normal}"
read -p ''
echo -e "${color}$ kubectl get svc -n dev --context gke-central${nc}" | pv -qL $SPEED
kubectl get svc -n dev --context gke-central

# Open Chrome tab with frontend-dev external IP address
echo -e "\n"
echo "${bold}Open frontend-dev in an incognito Chrome tab via the external IP address${normal}"
read -p ''
echo "${bold}You should see YELLOW background${normal}"

# Change background color from YELLOW to GREEN
echo -e "\n"
echo "${bold}Change the background color from YELLOW to GREEN.  Switch to Cloud Shell # 1 and inspect skaffold${normal}"
read -p ''
echo -e "${color}$ sed -i -e s/yellow/green/g $HOME/advanced-kubernetes-workshop/services/frontend/content/index.html${nc}" | pv -qL $SPEED
sed -i -e s/yellow/green/g $HOME/advanced-kubernetes-workshop/services/frontend/content/index.html

# After inspecting skaffold rebuild and redeploy, confirm background color changed to GREEN
echo -e "\n"
echo "${bold}Upon change, Skaffold rebuilds the new image in GCR repo and redeploys the manifest files automatically${normal}"
echo "${bold}Inspect the index.html file and confirm the background color changed${normal}"
read -p ''
echo -e "${color}$ cat $HOME/advanced-kubernetes-workshop/services/frontend/content/index.html${nc}" | pv -qL $SPEED
cat $HOME/advanced-kubernetes-workshop/services/frontend/content/index.html

# Refresh the Chrome tab and confirm frontend-dev background is GREEN
echo -e "\n"
echo "${bold}Refresh the Chrome tab and confirm frontend-dev background is GREEN${normal}"
echo -e "\n"
echo "${bold}Get the ingress IP addresses for the production frontend${normal}"
read -p ''
echo -e "${color}$ get-ingress.sh${nc}" | pv -qL $SPEED
get-ingress.sh

# Check frontend prod background color should be YELLOW
echo "${bold}Open frontend production in an incognito Chrome tab via the external IP address${normal}"
echo "${bold}Confirm background color is YELLOW${normal}"
echo -e "\n"

# Stop skaffold
echo "${bold}Switch to Cloud Shell window #1 (skaffold window) and exit by pressing CTRL-C${normal}"

# After exiting skaffold, confirm frontend-dev is removed
echo -e "\n"
echo "${bold}After exiting skaffold, confirm frontend-dev deployment is successfully removed${normal}"
read -p ''
echo -e "${color}$ kubectl get pods -n dev --context gke-central${nc}" | pv -qL $SPEED
kubectl get pods -n dev --context gke-central
