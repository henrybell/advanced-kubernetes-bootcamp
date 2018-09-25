#!/bin/bash -xe

metadata_value() {
  curl --retry 5 -sfH "Metadata-Flavor: Google" \
       "http://metadata/computeMetadata/v1/$1"
}

DEPLOYMENT_NAME=`metadata_value "instance/attributes/deployment"`

apt-get update
apt-get install -y git kubectl psmisc

# Add Bash completion for gcloud
echo 'source /usr/share/google-cloud-sdk/completion.bash.inc' >> /etc/profile

export PATH=$PATH:/usr/local/go/bin
export GOPATH=/root/go
export HOME=/root
cd ${HOME}

# Install Go
GO_VERSION=1.10.2
wget https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz
tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile

# Install hey https://github.com/rakyll/hey
go get -u github.com/rakyll/hey
cp /root/go/bin/hey /usr/local/bin

# Install Helm
HELM_VERSION=2.9.1
wget https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz
tar zxfv helm-v${HELM_VERSION}-linux-amd64.tar.gz
cp linux-amd64/helm /usr/local/bin
cat > tiller-rbac.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
EOF

# Install kctx & kns
git clone https://github.com/ahmetb/kubectx
cp kubectx/kube* /usr/local/bin

# Install kubectl aliases
cd $HOME
git clone https://github.com/ahmetb/kubectl-aliases.git
echo "[ -f ~/kubectl-aliases/.kubectl_aliases ] && source ~/kubectl-aliases/.kubectl_aliases" >> $HOME/.bashrc
source ~/.bashrc


# Install kube ps1
cd $HOME
git clone https://github.com/jonmosco/kube-ps1.git
echo 'export KUBE_PS1_SYMBOL_ENABLE=false' >> ~/.bashrc
echo 'source $HOME/kube-ps1/kube-ps1.sh' >> ~/.bashrc
export VAR="PS1='[\W \$(kube_ps1)]\$ '"
echo $VAR >> ~/.bashrc
source $HOME/.bashrc

# Create application frontend
git clone https://github.com/ameer00/advanced-kubernetes-bootcamp-1.git ~/advanced-kubernetes-bootcamp 
cd $HOME/advanced-kubernetes-bootcamp/module-2/services/frontend
export PROJECT=$(gcloud info --format='value(config.project)')
gcloud builds submit -q --tag gcr.io/$PROJECT/frontend .
cd $HOME


# Create application backend
cd $HOME/advanced-kubernetes-bootcamp/module-2/services/backend
export PROJECT=$(gcloud info --format='value(config.project)')
gcloud builds submit -q --tag gcr.io/$PROJECT/backend .
cd $HOME


# Prometheus resources to install in the clusters
wget -O prom-rbac.yml https://storage.googleapis.com/stackdriver-prometheus-documentation/rbac-setup.yml
wget https://storage.googleapis.com/stackdriver-prometheus-documentation/prometheus-service.yml

# Download Sock Shop App
curl --retry 5 -sfH "Metadata-Flavor: Google" \
     "http://metadata/computeMetadata/v1/instance/attributes/sock-shop" > sock-shop.yaml

WORKLOAD_FILTER="resourceLabels.purpose=workloads AND resourceLabels.deployment=${DEPLOYMENT_NAME}"
WORKLOAD_CLUSTERS=$(gcloud container clusters list --format 'csv[no-heading](name,zone)' --filter="${WORKLOAD_FILTER}")
for CLUSTER_INFO in ${WORKLOAD_CLUSTERS}; do
    CLUSTER_INFO_ARRAY=(${CLUSTER_INFO//,/ })

    # Wait until cluster is running
    until gcloud container clusters describe ${CLUSTER_INFO_ARRAY[0]} --zone ${CLUSTER_INFO_ARRAY[1]} --format 'value(status)' | grep -m 1 "RUNNING"; do sleep 10 ; done

    # Get credentials for setting client as admin
    gcloud container clusters get-credentials ${CLUSTER_INFO_ARRAY[0]} --zone ${CLUSTER_INFO_ARRAY[1]}
    export PROJECT=$(gcloud info --format='value(config.project)')
    kubectx gke-${CLUSTER_INFO_ARRAY[1]:3:-3}="gke_"$PROJECT"_"${CLUSTER_INFO_ARRAY[1]}_${CLUSTER_INFO_ARRAY[0]}
    kubectl create clusterrolebinding client-cluster-admin-binding --clusterrole=cluster-admin --user=client
    # Needed for Spinnaker to be able to authenticate to the API
    export CLOUDSDK_CONTAINER_USE_CLIENT_CERTIFICATE=True
    gcloud container clusters get-credentials ${CLUSTER_INFO_ARRAY[0]} --zone ${CLUSTER_INFO_ARRAY[1]}

    # Install Prometheus
    export PROJECT=$(gcloud info --format='value(config.project)')
    kubectl apply -f prom-rbac.yml --as=admin --as-group=system:masters
    cp prometheus-service.yml prom-${CLUSTER_INFO_ARRAY[0]}.yml
    sed -i "s/_stackdriver_project_id: .*/_stackdriver_project_id: '${PROJECT}'/g" prom-${CLUSTER_INFO_ARRAY[0]}.yml
    sed -i "s/_kubernetes_cluster_name: .*/_kubernetes_cluster_name: '${CLUSTER_INFO_ARRAY[0]}'/g" prom-${CLUSTER_INFO_ARRAY[0]}.yml
    sed -i "s/_kubernetes_location: .*/_kubernetes_location: '${CLUSTER_INFO_ARRAY[1]}'/g" prom-${CLUSTER_INFO_ARRAY[0]}.yml
    kubectl apply -f prom-${CLUSTER_INFO_ARRAY[0]}.yml

    kubectl apply -f tiller-rbac.yaml
    helm init --service-account tiller
    # Wait for tiller to be running
    until timeout 10 helm version; do sleep 10; done

    # Install Istio
    export ISTIO_VERSION=1.0.2
    curl -L https://git.io/getLatestIstio | sh -
    pushd istio-${ISTIO_VERSION}/
    kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml
    helm install -n istio --namespace=istio-system install/kubernetes/helm/istio --set kiali.enabled=true --set tracing.enabled=true --set global.mtls.enabled=true --set grafana.enabled=true --set servicegraph.enabled=true
    export PATH=$PATH:$HOME/istio-$ISTIO_VERSION/bin
    popd
    kubectl label namespace default istio-injection=enabled
done

SOCKSHOP_FILTER="resourceLabels.purpose=workloads AND resourceLabels.deployment=${DEPLOYMENT_NAME} AND resourceLabels.sock-shop=installed"
SOCKSHOP_CLUSTERS=$(gcloud container clusters list --format 'csv[no-heading](name,zone)' --filter="${SOCKSHOP_FILTER}")
for CLUSTER_INFO in ${SOCKSHOP_CLUSTERS}; do
    CLUSTER_INFO_ARRAY=(${CLUSTER_INFO//,/ })
    # Wait until cluster is running
    until gcloud container clusters describe ${CLUSTER_INFO_ARRAY[0]} --zone ${CLUSTER_INFO_ARRAY[1]} --format 'value(status)' | grep -m 1 "RUNNING"; do sleep 10 ; done
    gcloud container clusters get-credentials ${CLUSTER_INFO_ARRAY[0]} --zone ${CLUSTER_INFO_ARRAY[1]}

    kubectl apply -f sock-shop.yaml
done

# Configure Spinnaker
SPINNAKER_FILTER="resourceLabels.purpose=spinnaker AND resourceLabels.deployment=${DEPLOYMENT_NAME}"
SPINNAKER_CLUSTERS=$(gcloud container clusters list --format 'csv[no-heading](name,zone)' --filter="${SPINNAKER_FILTER}")
for CLUSTER_INFO in ${SPINNAKER_CLUSTERS}; do
    CLUSTER_INFO_ARRAY=(${CLUSTER_INFO//,/ })
    gcloud container clusters get-credentials ${CLUSTER_INFO_ARRAY[0]} --zone ${CLUSTER_INFO_ARRAY[1]}
    export PROJECT=$(gcloud info --format='value(config.project)')
    kubectx gke-spinnaker="gke_"$PROJECT"_"${CLUSTER_INFO_ARRAY[1]}_${CLUSTER_INFO_ARRAY[0]}
    kubectl apply -f tiller-rbac.yaml
    helm init --service-account tiller
    # Wait for tiller to be running
    until timeout 10 helm version; do sleep 10; done

    # Create Spinnaker service account and assign it roles/owner role.
    gcloud iam service-accounts create spinnaker-sa-${DEPLOYMENT_NAME} --display-name spinnaker-sa-${DEPLOYMENT_NAME}
    export SPINNAKER_SA_EMAIL=$(gcloud iam service-accounts list \
        --filter="displayName:spinnaker-sa-${DEPLOYMENT_NAME}" \
        --format='value(email)')
    export PROJECT=$(gcloud info --format='value(config.project)')

    # Move this to DM template
    gcloud projects add-iam-policy-binding ${PROJECT} --role roles/owner --member serviceAccount:${SPINNAKER_SA_EMAIL}
    gcloud iam service-accounts keys create spinnaker-key.json --iam-account ${SPINNAKER_SA_EMAIL}
    export BUCKET=${PROJECT}-${DEPLOYMENT_NAME}
    export BUCKET_CONFIG=${PROJECT}-spinnaker
    gsutil mb -c regional -l us-central1 gs://${BUCKET}
    gsutil mb -c regional -l us-central1 gs://${BUCKET_CONFIG}
    
    # Setup Spinnaker GCS bucket
	export PROJECT=$(gcloud info --format='value(config.project)')
	export JSON=$(cat $HOME/spinnaker-key.json)
	
	# Store application manifests in GCS bucket
	export PROJECT=$(gcloud info --format='value(config.project)')
	sed -e s/PROJECT_ID/$PROJECT/g $HOME/advanced-kubernetes-bootcamp/module-2/services/manifests/frontend.yml | gsutil cp - gs://$PROJECT-spinnaker/manifests/frontend.yml
	sed -e s/PROJECT_ID/$PROJECT/g $HOME/advanced-kubernetes-bootcamp/module-2/services/manifests/backend.yml | gsutil cp - gs://$PROJECT-spinnaker/manifests/backend.yml


	# Make GCR repo public for all users
	export PROJECT=$(gcloud info --format='value(config.project)')
	gsutil iam ch allUsers:objectViewer gs://artifacts.$PROJECT.appspot.com
	
	# Create PubSub topic for GCR
	export PROJECT=$(gcloud info --format='value(config.project)')
	export GCR_SUB=my-gcr-sub
	export GCR_TOPIC="projects/${PROJECT}/topics/gcr"
	gcloud pubsub topics create projects/${PROJECT}/topics/gcr
	gcloud beta pubsub subscriptions create $GCR_SUB --topic $GCR_TOPIC

	# Create PubSub topic for GCS
	export PROJECT=$(gcloud info --format='value(config.project)')
	export GCS_SUB=my-gcs-sub
	export GCS_TOPIC=spin-gcs-topic
	export BUCKET=$PROJECT-spinnaker
	gcloud beta pubsub topics create $GCS_TOPIC
	gcloud beta pubsub subscriptions create $GCS_SUB --topic $GCS_TOPIC
	gsutil notification create -t $GCS_TOPIC -f json gs://${BUCKET}

	cat > $HOME/spinconfig.yaml <<EOF
minio:
  enabled: false
gcs:
  enabled: true
  project: $PROJECT
  bucket: "$BUCKET"
  jsonKey: '$JSON'
EOF

    helm install -n adv-k8s stable/spinnaker -f $HOME/spinconfig.yaml --timeout 600
done

# Signal completion to waiter
HOSTNAME=$(hostname)
gcloud beta runtime-config configs variables set \
            success/${HOSTNAME} --config-name ${HOSTNAME}-config
