#!/bin/bash

# Define regions for GKE clusters
export ONE=central
export TWO=west

# Set speed, bold and color variables
SPEED=40
bold=$(tput bold)
normal=$(tput sgr0)
color='\e[1;32m' # green
nc='\e[0m'

# Create bin path
echo "${bold}Creating local ~/bin folder...${normal}"
cd $HOME
mkdir bin
PATH=$PATH:$HOME/bin/
cp $HOME/advanced-kubernetes-workshop/terraform/connect.sh $HOME/bin/.
chmod +x $HOME/bin/connect.sh
sed -i -e s/ONE/$ONE/g -e s/TWO/$TWO/g $HOME/bin/connect.sh
cp $HOME/advanced-kubernetes-workshop/services/frontend/get-ingress.sh $HOME/bin/.
chmod +x $HOME/bin/get-ingress.sh
sed -i -e s/ONE/$ONE/g -e s/TWO/$TWO/g $HOME/bin/get-ingress.sh
cp $HOME/advanced-kubernetes-workshop/terraform/fortio.sh $HOME/bin/.
chmod +x $HOME/bin/fortio.sh 
echo "********************************************************************************"

# Create SSH key
mkdir .ssh
ssh-keygen -t rsa -N "" -f .ssh/id_rsa &> /dev/null

# Install kubectx/kubens
echo "${bold}Installing kubectx for easy cluster context switching...${normal}"
sudo git clone https://github.com/ahmetb/kubectx $HOME/kubectx
sudo ln -s $HOME/kubectx/kubectx $HOME/bin/kubectx
sudo ln -s $HOME/kubectx/kubens $HOME/bin/kubens
echo "********************************************************************************"

# Install kubectl aliases
echo "${bold}Installing kubectl_aliases...${normal}"
cd $HOME
git clone https://github.com/ahmetb/kubectl-aliases.git
echo "[ -f ~/kubectl-aliases/.kubectl_aliases ] && source ~/kubectl-aliases/.kubectl_aliases" >> $HOME/.bashrc
source ~/.bashrc
echo "********************************************************************************"

# Install Helm
echo "${bold}Installing helm...${normal}"
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh &> /dev/null
cp /usr/local/bin/helm $HOME/bin/
echo "********************************************************************************"

# Install hey
echo "${bold}Installing hey...${normal}"
go get -u github.com/rakyll/hey
echo "********************************************************************************"

# Install html2text
echo "${bold}Installing html2text...${normal}"
sudo pip install html2text
cp /usr/local/bin/html2text $HOME/bin/
echo "********************************************************************************"

# Install pv
sudo apt-get update &> /dev/null
sudo apt-get install pv &> /dev/null
cp /usr/bin/pv $HOME/bin/

# Install terraform
echo "${bold}Installing terraform...${normal}"
cd $HOME
mkdir terraform11
cd terraform11
sudo apt-get install unzip
wget https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip
unzip terraform_0.11.7_linux_amd64.zip
mv terraform $HOME/bin/.
cd $HOME
rm -rf terraform11
echo "********************************************************************************"

# Install krompt
cd $HOME
cat $HOME/advanced-kubernetes-workshop/terraform/krompt.txt >> $HOME/.bashrc
source $HOME/.bashrc

# Create Terraform service account
echo "${bold}Creating GCP service account for Terraform...${normal}"
gcloud iam service-accounts create terraform --display-name terraform-sa
export TERRAFORM_SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:terraform-sa" \
    --format='value(email)')
echo "********************************************************************************"

# Create Spinnaker service account
echo "${bold}Creating GCP service account for Spinnaker...${normal}"
gcloud iam service-accounts create spinnaker --display-name spinnaker-service-account
export SPINNAKER_SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:spinnaker-service-account" \
    --format='value(email)')
echo "********************************************************************************"

# Get email for the GCE default service account
export GCE_EMAIL=$(gcloud iam service-accounts list --format='value(email)' | grep compute)
export PROJECT=$(gcloud info --format='value(config.project)')
echo $(gcloud info --format='value(config.project)') >> $HOME/project.txt

# Give Terraform SA and GCE default SA roles/owner IAM permissions
echo "${bold}Creating GCP IAM role bindings for terraform and spinnaker service accounts...${normal}"
gcloud projects add-iam-policy-binding $PROJECT --role roles/owner --member serviceAccount:$TERRAFORM_SA_EMAIL
gcloud projects add-iam-policy-binding $PROJECT --role roles/owner --member serviceAccount:$SPINNAKER_SA_EMAIL
gcloud projects add-iam-policy-binding $PROJECT --role roles/owner --member serviceAccount:$GCE_EMAIL
gcloud projects add-iam-policy-binding $PROJECT --role roles/owner --member user:$(gcloud config list account --format "value(core.account)")
echo "********************************************************************************"

# Get creds for Terraform SA
echo "${bold}Creating credentials for terraform service account...${normal}"
gcloud iam service-accounts keys create $HOME/advanced-kubernetes-workshop/terraform/credentials.json --iam-account $TERRAFORM_SA_EMAIL
# sed -i -e s/PROJECTID/$PROJECT/g $HOME/advanced-kubernetes-workshop/terraform/main.tf
echo "********************************************************************************"

# Get creds for Spinnaker SA
echo "${bold}Creating credentials for spinnaker service account...${normal}"
gcloud iam service-accounts keys create $HOME/advanced-kubernetes-workshop/terraform/spinnaker-service-account.json --iam-account $SPINNAKER_SA_EMAIL
echo "********************************************************************************"

# Download Istio
echo "${bold}Downloading Istio...${normal}"
cd $HOME
export ISTIO_VERSION=1.0.2
curl -L https://git.io/getLatestIstio | ISTIO_VERSION=$ISTIO_VERSION sh -
cd istio-$ISTIO_VERSION
export PATH=$PATH:$HOME/istio-$ISTIO_VERSION/bin
cp $HOME/istio-$ISTIO_VERSION/bin/istioctl $HOME/bin/.
echo "********************************************************************************"

# Preparing GCR
echo "${bold}Enabling Google Cloud Resource Manager APIs...${normal}"
gcloud services enable cloudresourcemanager.googleapis.com
echo "********************************************************************************"

# Preparing Skaffold
echo "${bold}Preparing skaffold...${normal}"
export PROJECT=$(gcloud info --format='value(config.project)')
sed -i -e s/PROJECT_ID/$PROJECT/g $HOME/advanced-kubernetes-workshop/services/frontend/skaffold.yaml
sed -i -e s/PROJECT_ID/$PROJECT/g $HOME/advanced-kubernetes-workshop/services/frontend/k8s-frontend-dev.yml
echo "********************************************************************************"

# Create application frontend
echo "${bold}Creating frontend service container in gcr.io...${normal}"
cd $HOME/advanced-kubernetes-workshop/services/frontend
export PROJECT=$(gcloud info --format='value(config.project)')
gcloud builds submit -q --tag gcr.io/$PROJECT/frontend .
cd $HOME
echo "********************************************************************************"

# Create application backend
echo "${bold}Creating backend service container in gcr.io...${normal}"
cd $HOME/advanced-kubernetes-workshop/services/backend
export PROJECT=$(gcloud info --format='value(config.project)')
gcloud builds submit -q --tag gcr.io/$PROJECT/backend .
cd $HOME
echo "********************************************************************************"

# Create application frontend-dev
echo "${bold}Creating frontend-dev service container in gcr.io...${normal}"
cd $HOME/advanced-kubernetes-workshop/services/frontend
export PROJECT=$(gcloud info --format='value(config.project)')
gcloud builds submit -q --tag gcr.io/$PROJECT/frontend-dev .
cd $HOME
echo "********************************************************************************"

# Create application backend-dev
echo "${bold}Creating backend-dev service container in gcr.io...${normal}"
cd $HOME/advanced-kubernetes-workshop/services/backend
export PROJECT=$(gcloud info --format='value(config.project)')
gcloud builds submit -q --tag gcr.io/$PROJECT/backend-dev .
cd $HOME
echo "********************************************************************************"

# Create GCS bucket for Spinnaker artifacts i,e. k8s manifests and config
echo "${bold}Creating GCS buckets for spinnaker artifacts and configs...${normal}"
export PROJECT=$(gcloud info --format='value(config.project)')
export BUCKET=$PROJECT-spinnaker
gsutil mb gs://$BUCKET
gsutil mb gs://$PROJECT-spinnaker-config
echo "********************************************************************************"

# Setup Spinnaker GCS bucket
echo "${bold}Configuring spinnaker...${normal}"
export PROJECT=$(gcloud info --format='value(config.project)')
export JSON=$(cat $HOME/advanced-kubernetes-workshop/terraform/spinnaker-service-account.json)
echo "********************************************************************************"

cat > $HOME/advanced-kubernetes-workshop/terraform/spinconfig.yaml <<EOF
minio:
  enabled: false
gcs:
  enabled: true
  project: $PROJECT
  bucket: "$PROJECT-spinnaker-config"
  jsonKey: '$JSON'
EOF

# Store application manifests in GCS bucket
echo "${bold}Uploading kubernetes manifests in GCS bucket...${normal}"
export PROJECT=$(gcloud info --format='value(config.project)')
sed -e s/PROJECT_ID/$PROJECT/g $HOME/advanced-kubernetes-workshop/services/manifests/frontend.yml | gsutil cp - gs://$PROJECT-spinnaker/manifests/frontend.yml
sed -e s/PROJECT_ID/$PROJECT/g $HOME/advanced-kubernetes-workshop/services/manifests/backend.yml | gsutil cp - gs://$PROJECT-spinnaker/manifests/backend.yml
echo "********************************************************************************"

# Make GCR repo public for all users
export PROJECT=$(gcloud info --format='value(config.project)')
gsutil iam ch allUsers:objectViewer gs://artifacts.$PROJECT.appspot.com


# Create PubSub topic for GCR
echo "${bold}Creating Cloud PubSub topic for GCR...${normal}"
export PROJECT=$(gcloud info --format='value(config.project)')
export GCR_SUB=my-gcr-sub
export GCR_TOPIC="projects/${PROJECT}/topics/gcr"
gcloud pubsub topics create projects/${PROJECT}/topics/gcr
gcloud beta pubsub subscriptions create $GCR_SUB --topic $GCR_TOPIC
echo "********************************************************************************"

# Create PubSub topic for GCS
echo "${bold}Creating Cloud PubSub topic for GCS...${normal}"
export PROJECT=$(gcloud info --format='value(config.project)')
export GCS_SUB=my-gcs-sub
export GCS_TOPIC=spin-gcs-topic
export BUCKET=$PROJECT-spinnaker
gcloud beta pubsub topics create $GCS_TOPIC
gcloud beta pubsub subscriptions create $GCS_SUB --topic $GCS_TOPIC
gsutil notification create -t $GCS_TOPIC -f json gs://${BUCKET}
echo "********************************************************************************"

# Kick off terraform script
echo "${bold}Start terraform script...${normal}"
export PROJECT=$(gcloud info --format='value(config.project)')
cd $HOME/advanced-kubernetes-workshop/terraform
sed -i -e s/PROJECTID/$PROJECT/g $HOME/advanced-kubernetes-workshop/terraform/main.tf
terraform init
terraform apply -auto-approve
