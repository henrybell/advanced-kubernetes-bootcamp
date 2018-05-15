# Advanced Kubernetes Bootcamp Initial Setup

## IAM

Ensure that the Deployment Manager Service Account
for your current project is an owner of the project where you'd like to create
the bootcamp resources (clusters, service accounts, etc):

    export PROJECT=$(gcloud config get-value project)
    export PROJECT_ID=$(gcloud projects list --filter id=${PROJECT} --format 'value(projectNumber)')
    export DM_SA_EMAIL=${PROJECT_ID}@cloudservices.gserviceaccount.com
    gcloud projects add-iam-policy-binding $PROJECT --member=serviceAccount:${DM_SA_EMAIL} --role roles/owner
    gcloud services enable cloudresourcemanager.googleapis.com
    gcloud services enable iam.googleapis.com
    gcloud services enable cloudbuild.googleapis.com

## Create Deployment

    gcloud deployment-manager deployments create --config workshop.yaml adv-bc-$(date +%s)
