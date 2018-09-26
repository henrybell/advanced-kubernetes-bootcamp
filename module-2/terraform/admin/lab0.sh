#!/bin/bash

# Check clusters exist

# Set speed
SPEED=40
bold=$(tput bold)
normal=$(tput sgr0)

color='\e[1;32m' # green
nc='\e[0m'

echo -e "\n"
echo "${bold}*** Lab 0: Setup Walk Through ***${normal}"
echo -e "\n"

echo "${bold}Check clusters exist${normal}"
echo -e "${color}$ kubectx${nc}" | pv -qL $SPEED
kubectx 

# : <<'END'

# Check Istio installation
echo -e "\n"
echo "${bold}Check Istio is installed on GKE-West cluster${normal}"
read -p ''
echo -e "${color}$ kubectl get deployments -n istio-system --context gke-west${nc}" | pv -qL $SPEED ;kubectl get deployments -n istio-system --context gke-west

echo -e "\n"
echo "${bold}Check Istio is installed on GKE-Central cluster${normal}"
read -p ''
echo -e "${color}$ kubectl get deployments -n istio-system --context gke-central${nc}" | pv -qL $SPEED ;kubectl get deployments -n istio-system --context gke-central


# Check Spinnaker Installation
echo -e "\n"
echo "${bold}Check Spinnaker is installed on GKE-Spinnaker cluster${normal}"
read -p ''
echo -e "${color}$ kubectl get deployments --context gke-spinnaker${nc}" | pv -qL $SPEED; kubectl get deployments --context gke-spinnaker

# Check ISTIO-INJECTION is enabled on GKE-West and GKE_Central
echo -e "\n"
echo "${bold}Check ISTIO-INJECTION is enabled on GKE-Central cluster${normal}"
read -p ''
echo -e "${color}$ kubectl get namespace -L istio-injection --context gke-central${nc}" | pv -qL $SPEED; kubectl get namespace -L istio-injection --context gke-central

echo -e "\n"
echo "${bold}Check ISTIO-INJECTION is enabled on GKE-West cluster${normal}"
read -p ''
echo -e "${color}$ kubectl get namespace -L istio-injection --context gke-west${nc}" | pv -qL $SPEED; kubectl get namespace -L istio-injection --context gke-west


# Check appliation is installed on all three namespaces on both GKE-West and GKE-Central clusters

echo -e "\n"
echo "${bold}Check Application is installed on GKE-Central cluster in production, staging and dev namespaces${normal}"
read -p ''
echo -e "${color}$ kubectl get all -n production --context gke-central${nc}" | pv -qL $SPEED; kubectl get all -n production --context gke-central

read -p ''
echo -e "${color}$ kubectl get all -n staging --context gke-central${nc}" | pv -qL $SPEED; kubectl get all -n staging --context gke-central

read -p ''
echo -e "${color}$ kubectl get all -n dev --context gke-central${nc}" | pv -qL $SPEED; kubectl get all -n dev --context gke-central

echo -e "\n"
echo "${bold}Check Application is installed on GKE-West cluster in production, staging and dev namespaces${normal}"
read -p ''
echo -e "${color}$ kubectl get all -n production --context gke-west${nc}" | pv -qL $SPEED; kubectl get all -n production --context gke-west

read -p ''
echo -e "${color}$ kubectl get all -n staging --context gke-west${nc}" | pv -qL $SPEED; kubectl get all -n staging --context gke-west

read -p ''
echo -e "${color}$ kubectl get all -n dev --context gke-west${nc}" | pv -qL $SPEED; kubectl get all -n dev --context gke-west

# Check GCR Images
echo -e "\n"
echo "${bold}Check container images in Container Registry (GCR.io)${normal}"
read -p ''
echo -e "${color}$ gcloud container images list${nc}" | pv -qL $SPEED; gcloud container images list

# Check GCS Manifests
echo -e "\n"
echo "${bold}Check Kubernetes manifests or YAML files in Cloud Storage bucket (GCS)${normal}"
read -p ''
echo -e "${color}$ export PROJECT=\$(gcloud info --format='value(config.project)')\n$ gsutil ls gs://$PROJECT-spinnaker/manifests${nc}" | pv -qL $SPEED
export PROJECT=$(gcloud info --format='value(config.project)')
gsutil ls gs://$PROJECT-spinnaker/manifests

# Check PubSub Topics
echo -e "\n"
echo "${bold}Check Cloud PubSub topics i.e. for publishers (the pub in pubsub)${normal}"
read -p ''
echo -e "${color}$ gcloud pubsub topics list${nc}" | pv -qL $SPEED; gcloud pubsub topics list

# Check PubSub Subscriptions
echo -e "\n"
echo "${bold}Check Cloud PubSub subscriptions i.e. for subscribers (the sub in pubsub)${normal}"
read -p ''
echo -e "${color}$ gcloud pubsub subscriptions list${nc}" | pv -qL $SPEED; gcloud pubsub subscriptions list

# END

# Run connect.sh script
echo -e "\n"
echo "${bold}Open ports to Spinnaker, Grafana, Prometheus, Jaeger and ServiceGraph${normal}"
read -p ''
echo -e "${color}$ connect.sh${nc}" | pv -qL $SPEED; connect.sh



