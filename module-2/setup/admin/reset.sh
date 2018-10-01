# get PROJECT ID
export PROJECT=$(gcloud info --format='value(config.project)')

# Reset terraform main.tf
sed -i -e s/$PROJECT/PROJECTID/g ~/advanced-kubernetes-workshop/terraform/main.tf

# Reset Skaffold skaffold.yaml
sed -i -e s/$PROJECT/PROJECT_ID/g ~/advanced-kubernetes-workshop/services/frontend/skaffold.yaml

# Reset Skaffold k8s-frontend-dev
sed -i -e s/$PROJECT/PROJECT_ID/g ~/advanced-kubernetes-workshop/services/frontend/k8s-frontend-dev.yml

# Reset frontend BG color back to yellow
sed -i -e s/green/yellow/g $HOME/advanced-kubernetes-workshop/services/frontend/content/index.html

# Reset backend delay to no delay
cp $HOME/advanced-kubernetes-workshop/services/backend/main.go_orig $HOME/advanced-kubernetes-workshop/services/backend/main.go

# Remove creds from terraform folder
rm ~/advanced-kubernetes-workshop/terraform/credentials.json
rm ~/advanced-kubernetes-workshop/terraform/spinnaker-service-account.json

# Remove terraform state from terraform folder
rm ~/advanced-kubernetes-workshop/terraform/terraform*
rm -rf ~/advanced-kubernetes-workshop/terraform/.terraform

# Remove Spinconfig file
rm ~/advanced-kubernetes-workshop/terraform/spinconfig.yaml