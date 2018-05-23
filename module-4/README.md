# Module 4 - Extending Kubernetes

[![button](http://gstatic.com/cloudssh/images/open-btn.png)](https://console.cloud.google.com/cloudshell/open?git_repo=https://github.com/henrybell/advanced-kubernetes-bootcamp&page=editor&tutorial=module-4/README.md)

## Prerequisites

* A running Kubernetes Engine cluster
* Stackdriver Kubernetes Monitoring enabled for that cluster
* istio installed in the cluster
* The [Sock Shop](https://microservices-demo.github.io/) application installed

## Install Elasticsearch Operator

Configure kubectl for the us-west cluster:

```
kubectx gke-west
```

Install the [Elasticsearch Operator](https://github.com/upmc-enterprises/elasticsearch-operator)

```
kubectl create clusterrolebinding default-admin --clusterrole=cluster-admin --user=$(gcloud config get-value account)
kubectl create ns operator
kubectl create -n operator -f operator/controller.yaml
```

## Create the Elasticsearch cluster with Cerebro and Kibana

Create namespace for the Elasticsearch cluster:

```
kubectl create ns elasticsearch
```

Add bucket permissions to cluster service account:

```
SA_EMAIL=$(kubectl -n elasticsearch run shell --rm --restart=Never -it --image google/cloud-sdk --command /usr/bin/curl -- -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email)

PROJECT=$(gcloud config get-value project)

gcloud projects add-iam-policy-binding ${PROJECT} \
  --role roles/storage.admin --member serviceAccount:${SA_EMAIL}
```

Create the Elasticsearch cluster:

```
BUCKET=$(gcloud config get-value project)-es
gsutil mb gs://${BUCKET}

sed -e "s/__SNAPSHOT_BUCKET__/${BUCKET}/g" operator/example-es-cluster.template.yaml > operator/example-es-cluster.yaml

kubectl create -n elasticsearch -f operator/example-es-cluster.yaml
```

## Inspect the resources created by the operator

List all of the child resources created by the operator and owned by the Custom Resource:

```
kubectl -n elasticsearch get cronjobs,deploy,po,sts,cm,svc,secrets,pv,pvc
```

Check the properties of the Custom Resource:

```
kubectl -n elasticsearch describe elasticsearchcluster example-es-cluster
```

## Ingest data from the Sock Shop

Run script to ingest data from the Sock Shop MySQL database into Elasticsearch using Logstash:

```
operator/ingest_data.sh
```

> The script will exit after ingesting the data and display: `INFO: Ingest complete!`

Open port forward for Cerebo dashboard:

```
POD=""
until [[ -n "${POD}" ]]; do POD=$(kubectl get pods -n elasticsearch --field-selector=status.phase==Running -l name=cerebro-example-es-cluster -o jsonpath="{.items[].metadata.name}"); echo "Waiting for Cerebro pod..."; sleep 2; done

kubectl port-forward -n elasticsearch $POD 9000 >> /dev/null &
```

`walkthrough spotlight-pointer devshell-web-preview-button "Open Web Preview and change port to 9000"`

Wait for all 3 nodes to join the cluster in the Cerebro dashboard.

## Resize Cluster

Add another datanode to the cluster:

```
sed 's/data-node-replicas: .*/data-node-replicas: 4/g' operator/example-es-cluster.yaml | kubectl apply -n elasticsearch -f -
```

The Custom Resource is now patched with 4 requested data nodes which updates the `StatefulSet` created by the operator.

In the Cerebro dashboard, wait for the number of data nodes to increase to 4, and 9 total nodes.

## Snapshots

In the Cerebro Cluster, navigate to the snapshot browser and verify that a snapshot was taken every 2 minutes.

Examine the `cronjob` resource created by the operator:

```
kubectl -n elasticsearch describe cronjob elastic-example-es-cluster-snapshot
```

## Kibana

Kibana was also installed automatically by the operator. 

Open the Kibana UI by creating another local port-forward:

```
POD=""
until [[ -n "${POD}" ]]; do POD=$(kubectl get pods -n elasticsearch --field-selector=status.phase==Running -l name=kibana-example-es-cluster -o jsonpath="{.items[].metadata.name}"); echo "Waiting for Kibana pod..."; sleep 2; done

kubectl port-forward -n elasticsearch $POD 5601 >> /dev/null &
```

`walkthrough spotlight-pointer devshell-web-preview-button "Open Web Preview and change port to 5601"`

Configure the index pattern in Kibana for the `socks*` index:

1. Navigate to `Management` -> `Index Patterns`
2. In the `Index pattern` box, enter `socks*` and click `Next step`
3. From the `Time Filter field name` dropdown, select `@timestamp` and click `Create index pattern`

Browse the ingested data from the `Discover` view on the left hand side.

## Upgrades

TBD: Waiting on https://github.com/upmc-enterprises/elasticsearch-operator/issues/17

## Delete the cluster

```
kubectl -n elasticsearch delete elasticsearchcluster example-es-cluster
kubectl delete ns elasticsearch
```

## Creating a Metacontroller

In this section you will create and deploy a custom resource definition (CRD) and a controller to verify image names in deployments. If the image names pass a regular expression pattern, the deployment is created, otherwise it is rejected.

This controller uses the [CompositeController interface from metacontroller](https://github.com/GoogleCloudPlatform/metacontroller#compositecontroller) to implement a simple operator in Python with very little code compared to the previous elasticsearch-operator.

## Install the metacontroller:

```
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/metacontroller/master/manifests/metacontroller-rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/metacontroller/master/manifests/metacontroller.yaml
```

Verify that the Metacontroller is installed in the `metacontroller` namespace:

```
kubectl -n metacontroller get pods
```

## Deploy the Secure Deployments Controller

Install Skaffold:

```
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && chmod +x skaffold && sudo mv skaffold /usr/local/bin
```

Update manifests with your project info:

```
cd metacontroller

export GOOGLE_PROJECT=$(gcloud config get-value project)
sed -i.old "s/__GOOGLE_PROJECT__/${GOOGLE_PROJECT}/g" controller.yaml secure-deployment.yaml
```

Deploy the custom secure deployment controller:

```
skaffold run
```

> This is a complete operator in less than 50 lines of Python!

Verify contoller is running:

```
kubectl -n metacontroller get pods -l app=securedeployment-controller
```

## Create the Custom Resource

```
kubectl apply -f secure-deployment.yaml
```

Inspect the custom resource and verify that the checks passed:

```
kubectl -n sock-shop describe securedeployment catalogue-db
```

Expected output:

```yaml
Status:
  Failed:
  Passed:
    catalogue-db: gcr.io/stackdriver-microservices-demo/catalogue-db
```

Verify that the child deployment was created:

```
kubectl -n sock-shop get deploy catalogue-db
```

## Verify that non-matching images are rejected

Rename the image used in the deployment:

```
sed -i.old 's|image: gcr.io/stackdriver-microservices-demo/catalogue-db|image: docker.io/weaveworksdemos/catalogue-db|g' secure-deployment.yaml
kubectl apply -f secure-deployment.yaml
```

Check the status of the secure deployment:

```
kubectl -n sock-shop describe securedeploy catalogue-db
```

Expected output:

```yaml
Status:
  Failed:
    catalogue-db: docker.io/weaveworksdemos/catalogue-db
  Passed:
```

> Note: The check failed, so the deployment was not updated.

## Update the controller

Change the controller so that it accepts the new image pattern:

```
sed -i.old 's|gcr.io/stackdriver-microservices-demo|docker.io/weaveworksdemos|g' app.py
```

Redeploy the controller:

```
skaffold run
```

Recreate the secure deployment:

```
kubectl -n sock-shop delete securedeploy catalogue-db
kubectl apply -f secure-deployment.yaml
```

Verify that the image check passed:

```
kubectl -n sock-shop describe securedeploy catalogue-db
```

Expected output:

```yaml
Status:
  Failed:
  Passed:
    catalogue-db: docker.io/weaveworksdemos/catalogue-db
```

Verify the `catalogue-db` pod is now using the new image:

```
kubectl -n sock-shop get pod -l name=catalogue-db -o jsonpath='{.items[].spec.containers[].image}'
```