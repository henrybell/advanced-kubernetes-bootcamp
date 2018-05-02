# Lab Guide
## Repo
Get all files associated with this workshop by cloning the following repo.
```
git clone https://github.com/henrybell/advanced-kubernetes-bootcamp.git
```
## Tools
Install kubectx/kubens
```
mkdir bin
export PATH=$PATH:~/bin/
sudo git clone https://github.com/ahmetb/kubectx ~/kubectx
sudo ln -s ~/kubectx/kubectx ~/bin/kubectx
sudo ln -s ~/kubectx/kubens ~/bin/kubens
```
Install helm
```
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
```
## Install Kubernetes Engine Clusters
Set default zone.
```
gcloud config set compute/zone us-west1-a
```
Create 3 Kubernetes Engine clusters.  Cluster-3 needs to be 3 nodes with n1-standard-2 due to Spinnaker compute requirements.  Cluster-1 and 2 run the applications and cluster-3 runs Spinnaker, NGINX global load balancer and Container Registry.
```
gcloud container clusters create cluster-1 --async --num-nodes 2 --cluster-version=1.9.6-gke.1
gcloud container clusters create cluster-2 --async --num-nodes 2 --cluster-version=1.9.6-gke.1
gcloud container clusters create cluster-3 --async --machine-type=n1-standard-2 --cluster-version=1.9.6-gke.1
```
Create kubeconfig for all three clusters.
```
gcloud container clusters get-credentials cluster-1 --zone us-west1-a --project $(gcloud info --format='value(config.project)')
gcloud container clusters get-credentials cluster-2 --zone us-west1-a --project $(gcloud info --format='value(config.project)')
gcloud container clusters get-credentials cluster-3 --zone us-west1-a --project $(gcloud info --format='value(config.project)')
```
Rename cluster context for easy switching.
```
kubectx cluster-1=gke_$(gcloud info --format='value(config.project)')_us-west1-a_cluster-1
kubectx cluster-2=gke_$(gcloud info --format='value(config.project)')_us-west1-a_cluster-2
kubectx cluster-3=gke_$(gcloud info --format='value(config.project)')_us-west1-a_cluster-3
```
Check new context names
```
kubectx
```
_Output_
```
cluster-1
cluster-2
cluster-3
```
Current context is highlighted.
## Install Istio on all three clusters
Download istio nightly build for 0.8 (should be released by bootcamp)
```
mkdir istio8
cd istio8
wget https://storage.googleapis.com/istio-prerelease/daily-build/release-0.8-20180425-19-12/istio-release-0.8-20180425-19-12-linux.tar.gz
tar -xzvf istio-release-0.8-20180425-19-12-linux.tar.gz
cd istio-release-0.8-20180425-19-12/
```
Install Istio to all three clusters via helm
_Cluster-1_
```
kubectx cluster-1
kubectl create clusterrolebinding user-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account)
kubectl create serviceaccount tiller --namespace kube-system
kubectl create clusterrolebinding tiller-admin-binding --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account=tiller
```
After tiller is installed, Install Istio via helm chart with sidecar injector as shown below.
```
helm install --namespace=istio-system --set sidecar-injector.enabled=true install/kubernetes/helm/istio
```
_Cluster-2_
```
kubectx cluster-2
kubectl create clusterrolebinding user-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account)
kubectl create serviceaccount tiller --namespace kube-system
kubectl create clusterrolebinding tiller-admin-binding --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account=tiller
```
After tiller is installed, Install Istio via helm chart with sidecar injector as shown below.
```
helm install --namespace=istio-system --set sidecar-injector.enabled=true install/kubernetes/helm/istio
```
_Cluster-3_
```
kubectx cluster-3
kubectl create clusterrolebinding user-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account)
kubectl create serviceaccount tiller --namespace kube-system
kubectl create clusterrolebinding tiller-admin-binding --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account=tiller
```
After tiller is installed, Install Istio via helm chart with sidecar injector as shown below.
```
helm install --namespace=istio-system --set sidecar-injector.enabled=true install/kubernetes/helm/istio
```
Activate sidecar injector for default namespace on both cluster-1 and cluster-2
```
kubectl label namespace default istio-injection=enabled --context cluster-1
kubectl label namespace default istio-injection=enabled --context cluster-2
```
Confirm _ISTIO-INJECTION_ is enabled on both cluster-1 and cluster-2
```
kubectl get namespace -L istio-injection --context cluster-1
kubectl get namespace -L istio-injection --context cluster-2
```
## Install Spinnaker on cluster-3
Switch to cluster-3 context
```
kubectx cluster-3
```
Create spinnaker service account and assign it storage admin role.
```
gcloud iam service-accounts create spinnaker-sa --display-name spinnaker-sa
export SPINNAKER_SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:spinnaker-sa" \
    --format='value(email)')
export PROJECT=$(gcloud info --format='value(config.project)')
gcloud projects add-iam-policy-binding $PROJECT --role roles/storage.admin --member serviceAccount:$SPINNAKER_SA_EMAIL
```
Create the service account key
```
cd ~/advanced-kubernetes-bootcamp/module-2
gcloud iam service-accounts keys create spinnaker-key.json --iam-account $SPINNAKER_SA_EMAIL
```
Create a Cloud Storage bucket for Spinnaker
```
export BUCKET=$PROJECT-spinnaker-conf
gsutil mb -c regional -l us-west1 gs://$BUCKET
```
Clone the Spinnaker git repo and build
```
git clone https://github.com/viglesiasce/charts -b mcs
cd charts/stable/spinnaker
helm dep build
```
Grant user `client` cluster admin role and create Client Certs for cluster-1 and cluster-2
```
kubectl create clusterrolebinding client-cluster-admin-binding --clusterrole=cluster-admin --user=client --context cluster-1
kubectl create clusterrolebinding client-cluster-admin-binding --clusterrole=cluster-admin --user=client --context cluster-2
CLOUDSDK_CONTAINER_USE_CLIENT_CERTIFICATE=True gcloud container clusters get-credentials cluster-1 --zone us-west1-a
CLOUDSDK_CONTAINER_USE_CLIENT_CERTIFICATE=True gcloud container clusters get-credentials cluster-2 --zone us-west1-a
```
Ensure that client certs are present in the kubeconfig file
```
cat ~/.kube/config
```
Output should show `client-certificate-data` and `client-key-data` under the user stanza for cluster-1 and cluster-2 contexts.
Create a secret from the kubeconfig file for Spinnaker
```
kubectx cluster-3
kubectl create secret generic --from-file=config=$HOME/.kube/config mc-taw-spinnaker-kubeconfig
```
Create configuration for the Spinnaker config YAML.
Define variables
```
cd ~/advanced-kubernetes-bootcamp/module-2
export SA_JSON=$(cat spinnaker-key.json)
export BUCKET=$PROJECT-spinnaker-conf
export CL1_CONTEXT="gke_"$PROJECT"_us-west1-a_cluster-1"
export CL2_CONTEXT="gke_"$PROJECT"_us-west1-a_cluster-2"
```
Create the config file
```
cd charts/stable/spinnaker
cat > spinnaker-config.yaml <<EOF
storageBucket: $BUCKET
kubeConfig:
  enabled: true
  contexts:
  - $CL1_CONTEXT
  - $CL2_CONTEXT
gcs:
  enabled: true
  project: $PROJECT
  jsonKey: '$SA_JSON'



# Disable minio the default
minio:
  enabled: false



# Configure your Docker registries here
accounts:
- name: gcr
  address: https://gcr.io
  username: _json_key
  password: '$SA_JSON'
  email: 1234@5678.com 
EOF
```
Ensure the file has the correct values for the `SA_JSON` and `BUCKET` variables.
```
cat spinnaker-config.yaml
```
Install Spinnaker.  _This step could take up to 10 minutes (hence the timeout of 600 seconds below)_
```
helm install -n mc-taw . -f spinnaker-config.yaml --timeout 600
```
Expose the DECK (Spinnaker GUI) pod.
```
export DECK_POD=$(kubectl get pods --namespace default -l "component=deck" -o jsonpath="{.items[0].metadata.name}" --context cluster-3) 
kubectl port-forward --namespace default $DECK_POD 8080:9000 --context cluster-3 >> /dev/null &
```
Access the Spinnaker GUI using the Cloud Shell Preview

You get the Spinnaker GUi with the following header

Create an app in Spinnaker named `myapp`

To avoid having to enter the information manually in the UI, use the Kubernetes command-line interface to create load balancers (or Clusters) and Ingresss (or Security Groups) for your services. Alternatively, you can perform this operation in the Spinnaker UI.
```
kubectx cluster-1
kubectl apply -f ~/advanced-kubernetes-bootcamp/module-2/cl1-k8s
kubectx cluster-2
kubectl apply -f ~/advanced-kubernetes-bootcamp/module-2/cl2-k8s
```
## Prepare Container Registry
Pull a simple webserver to simulate an application.  We can use hightowerlabs `webserver` (which takes an arg for index.html explained a bit later in the workshop).  Also, pull `busyboxplus` to simulate canary testing during our pipeline deployment.
```
gcloud docker -- pull gcr.io/hightowerlabs/server:0.0.1
gcloud docker -- pull radial/busyboxplus
```
Define vars with image IDs for the two images
```
export WEB_IMAGE_ID=$(docker images gcr.io/hightowerlabs/server --format "{{.ID}}")
export BUSYBOX_IMAGE_ID=$(docker images radial/busyboxplus --format "{{.ID}}")
export PROJECT=$(gcloud info --format='value(config.project)')
```
Tag and push both images to Container Registry
```
docker tag $WEB_IMAGE_ID gcr.io/$PROJECT/web-server:v1.0.0
gcloud docker -- push gcr.io/$PROJECT/web-server:v1.0.0
docker tag $BUSYBOX_IMAGE_ID gcr.io/$PROJECT/busyboxplus
gcloud docker -- push gcr.io/$PROJECT/busyboxplus
```
Confirm both images are present in Container Registry
```
gcloud container images list
```
_Output_
```
NAME
gcr.io/qwiklabs-gcp-28ba43f03d974ba6/busyboxplus
gcr.io/qwiklabs-gcp-28ba43f03d974ba6/web-server
```
##Manually deploying Spinnaker pipelines
Deploy pipeline via JSON
```
cd ~/advanced-kubernetes-bootcamp/module-2/spinnaker
export GCP_ZONE=us-west1-a
sed -e s/PROJECT/$PROJECT/g -e s/GCP_ZONE/$GCP_ZONE/g pipeline.json | curl -d@- -X \
    POST --header "Content-Type: application/json" --header \
    "Accept: /" http://localhost:8080/gate/pipelines
```
Click on Pipeline and click Configure > Deploy to inspect it.


The Deploy pipeline deploys canary to both clusters (cluster-1 and cluster-2), it then tests the canaries.  There is a manual judgement stage prompting a user to proceed.  After the user hits proceed, application is deployed to both clusters in production.
Click on individual stages in the pipeline to inspect them in detail.
In `Configuration` stage, we use version tag to trigger the pipeline.  Every time the version is changed on the image, the pipeline is automatically triggered.
`Deploy` stages are Kubernetes Deployments, with Services and Ingresses created in the previous section..
For Test stages, we do a simple `curl` to our web-server app and ensure liveness.
`Deploy to Production` is a manual judgement stage.
Run the pipeline manually from the GUI.  Clink on Pipeline link, and then the Start Manual Execution button.  

Each rectangle represents a stage in the pipeline.  Click on various stages to get more details on steps being performed.

Once at the manual judgement stage, pause!
DO NOT HIT CONTINUE YET!!
Click on Clusters to see v1.0.0 pods deployed as canaries to both clusters.

We see one pod (represented as a single rectangle) deployed in both clusters.  Green color represents healthy status.  You can also confirm this in the clusters using kubectl commands.
Ensure both pods are exposed via Istio ingress in each cluster.
Click on Security Groups.  Click on the application in both clusters and then Status dropdown from the right hand details box.

You see the ingress IP address for both cluster.
Curl both IPs to see the environment (canary or prod) and version of the application.  For example.
```
curl 35.185.215.157
```
_Output_
```
myapp-canary-cl1-v1.0.0
```
## Globally load balance client traffic to both clusters
For this workshop, we use NGINX load balancer to direct traffic to the web application running in both clusters.  In production environments, you can use a third party provider for this service.  CloudFlare, Akamai or backplane.io are few of the companies that provide this functionality.  
Store the ingress IP addresses for the two clusters in variables
```
export CLUSTER1_INGRESS_IP=$(kubectl get ingress myapp-cl1-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}' --context cluster-1)
export CLUSTER2_INGRESS_IP=$(kubectl get ingress myapp-cl2-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}' --context cluster-2)
```
We can use cluster-3 for global load balancing.  
Create the NGINX configmap in cluster-3
```
kubectx cluster-3
cd ~/advanced-kubernetes-bootcamp/module-2/lb
sed -e s/CLUSTER1_INGRESS_IP/$CLUSTER1_INGRESS_IP\ weight=1/g -e s/CLUSTER2_INGRESS_IP/$CLUSTER2_INGRESS_IP\ weight=1/g glb-configmap-var.yaml > glb-configmap.yaml
```
Confirm that the Ingress IP addresses are in the output file.
```
cat glb-configmap.yaml
```
Apply the configmap
```
kubectl apply -f glb-configmap.yaml
```
Create the NGINX deployment and service
```
kubectl apply -f nginx-dep.yaml
kubectl apply -f nginx-svc.yaml
```
Ensure that the `global-lb-nginx` Service has a public IP address.  You can run the following commands a few times or watch it using the `- w` option in the command line.
```
kubectl get service global-lb-nginx
```
Once you have the public IP address, store it in a variable and do a for loop curl.
```
export GLB_IP=$(kubectl get service global-lb-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
for i in `seq 1 20`; do curl $GLB_IP; done
```
Traffic to the 2 canary pods is being split 50/50.  This ratio can be controlled by the `weight` field in the ConfigMap we generated earlier.
Adjust the `weight` fields in the ConfigMap.  Apply the new configmap and deployment.
```
sed -e s/CLUSTER1_INGRESS_IP/$CLUSTER1_INGRESS_IP\ weight=1/g -e s/CLUSTER2_INGRESS_IP/$CLUSTER2_INGRESS_IP\ weight=4/g glb-configmap-var.yaml > glb-configmap-2.yaml
kubectl delete -f glb-configmap.yaml
kubectl delete -f nginx-dep.yaml
kubectl apply -f glb-configmap-2.yaml
kubectl apply -f nginx-dep.yaml
```
Do a for loop curl on the `GLB_IP` and you can see more traffic going to cluster-2.
```
for i in `seq 1 20`; do curl $GLB_IP; done
```
## Triggering application updates in Spinnaker
Return to the Spinnaker GUI and finish deploying the pipeline by hitting continue on the manual judgement stage.
Click on Pipelines and click Continue on the manual judgement phase.

After the pipeline completes, click on Clusters.  In addition to the single canary pod, you can see 4 pods of v1.0.0 running in production in both clusters.

You can now update the application by updating the version number from `v1.0.0` to `v1.0.1` in Container Registry.  This simulates application update and triggers the Deploy pipeline.
```
gcloud docker -- pull gcr.io/$PROJECT/web-server:v1.0.0
MYAPP_IMAGE_ID=$(docker images gcr.io/$PROJECT/web-server --format "{{.ID}}")
docker tag $MYAPP_IMAGE_ID gcr.io/$PROJECT/web-server:v1.0.1
gcloud docker -- push gcr.io/$PROJECT/web-server:v1.0.1
```
Click on Pipelines and refresh the page if needed.  You can see the pipeline being triggered.
STOP at the manual judgement stage.
DO NOT HIT CONTINUE!

Click on Clusters.  You can see one canary pod of `v1.0.1` and four production pods of `v1.0.0` running in both clusters.

## Traffic Management with Istio
By default, traffic gets evenly split to all pods within a service.  The service has 5 pods total.  One pod is running the newer canary version v1.0.1 and four pods are running the production version v1.0.0.
Do a for loop curl on Ingress IP addresses for cluster-1 and cluster-2.
```
for i in `seq 1 20`; do curl $CLUSTER1_INGRESS_IP; done
for i in `seq 1 20`; do curl $CLUSTER2_INGRESS_IP; done
```
You can see about about 20% of the traffic going to v1.0.1 (canary) and 80% to production v1.0.0.
We can use Istio to manipulate traffic inside the cluster.
We can use:
`RouteRules` to direct traffic to different versions of the service.
Rate Limit based on number of connections
### Controlling traffic to production and canary releases
