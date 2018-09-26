#!/bin/bash

# Lab 2

# Set speed
SPEED=45
bold=$(tput bold)
normal=$(tput sgr0)

color='\e[1;32m' # green
nc='\e[0m'

echo -e "\n"
echo "${bold}*** Lab 2: Deploy Walk Through ***${normal}"
echo -e "\n"

# Open ports
echo "${bold}Open ports to Spinnaker, Grafana, Prometheus, Jaeger and ServiceGraph${normal}"
read -p ''
echo -e "${color}$ connect.sh${nc}" | pv -qL $SPEED; connect.sh

# Open Spinnaker GUI
echo -e "\n"
echo "${bold}Open Spinnaker GUI on port 8080 using Cloud Shell Web Preview${normal}"

# Get frontend-dev service external IP address
echo -e "\n"
echo "${bold}Deploy spinnaker pipelines for GKE-Central and GKE-West clusters${normal}"
read -p ''
echo -e "${color}$ sed -e s/PROJECT_ID/$PROJECT_ID/g -e s/APP_NAME/$APP_NAME/g -e s/REGION1/Central/g -e s/ONE/central/g ~/advanced-kubernetes-workshop/spinnaker/pipe-one.json | curl -d@- -X     POST --header "Content-Type: application/json" --header     "Accept: /" http://localhost:8080/gate/pipelines${nc}" | pv -qL $SPEED
echo -e "${color}$ sed -e s/PROJECT_ID/$PROJECT_ID/g -e s/APP_NAME/$APP_NAME/g -e s/REGION2/West/g -e s/TWO/west/g ~/advanced-kubernetes-workshop/spinnaker/pipe-two.json | curl -d@- -X     POST --header "Content-Type: application/json" --header     "Accept: /" http://localhost:8080/gate/pipelines${nc}" | pv -qL $SPEED
export PROJECT_ID=$(gcloud info --format='value(config.project)')
export PROJECT=$(gcloud info --format='value(config.project)')
export APP_NAME=myapp
sed -e s/PROJECT_ID/$PROJECT_ID/g -e s/APP_NAME/$APP_NAME/g -e s/REGION1/Central/g -e s/ONE/central/g ~/advanced-kubernetes-workshop/spinnaker/pipe-one.json | curl -d@- -X     POST --header "Content-Type: application/json" --header     "Accept: /" http://localhost:8080/gate/pipelines
sed -e s/PROJECT_ID/$PROJECT_ID/g -e s/APP_NAME/$APP_NAME/g -e s/REGION2/West/g -e s/TWO/west/g ~/advanced-kubernetes-workshop/spinnaker/pipe-two.json | curl -d@- -X     POST --header "Content-Type: application/json" --header     "Accept: /" http://localhost:8080/gate/pipelines
echo -e "\n"
echo "${bold}Confirm the pipelines are deployed in Spinnaker${normal}"

# Build and trigger Spinnaker pipelines
echo "${bold}Build new new frontend image and trigger Spinnaker pipelines${normal}"
read -p ''
echo -e "${color}$ cd ~/advanced-kubernetes-workshop/services/frontend/; ./build.sh${nc}" | pv -qL $SPEED
cd ~/advanced-kubernetes-workshop/services/frontend/; ./build.sh







