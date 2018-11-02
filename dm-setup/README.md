# Advanced Kubernetes Bootcamp Initial Setup

## Quota

* CPU
  * us-central1 - 28
  * us-east1 - 12

## IAM

Ensure that the Deployment Manager Service Account
for your current project is an owner of the project where you'd like to create
the bootcamp resources (clusters, service accounts, etc):

    export PROJECT=$(gcloud config get-value project)
    export PROJECT_ID=$(gcloud projects list --filter id=${PROJECT} --format 'value(projectNumber)')
    export DM_SA_EMAIL=${PROJECT_ID}@cloudservices.gserviceaccount.com
    gcloud services enable deploymentmanager.googleapis.com runtimeconfig.googleapis.com
    gcloud projects add-iam-policy-binding $PROJECT --member=serviceAccount:${DM_SA_EMAIL} --role roles/owner

## Create Deployment

    gcloud deployment-manager deployments create --config workshop.yaml adv-bc-$(date +%s)

## Recreating the deployment

If you need to recreate the deployment (for development purposes) several times
in the same project, you need to manually delete the service accounts created
by the deployment after deleting it. Also delete the role bindings for those
service accounts.
