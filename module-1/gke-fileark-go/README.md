# fileark

The fileark project demonstrates how to access Google Cloud Platform (GCP) services using a Service Account without downloading, 
and therefore taking responsibility for managing, the service account's keys. It consists of a single microservice that accepts 
files via an HTTP POST request and writes them to a specified Google Cloud Storage (GCS) bucket.

![fileark architecture diagram]
(https://github.com/GoogleCloudPlatform/gke-fileark-go/fileark-demo-architecture.png)

## Getting Started

These instructions tell you how to build the fileark microservice container using Google Container Builder and get it deployed to a Google Kubernetes Engine (GKE) cluster.

You'll need access to a GKE cluster with Helm installed. Unless you choose to work in the GCP Cloud Shell you'll also need the GCP SDK installed on your laptop or workstation.

* [Google Cloud Platform SDK](https://cloud.google.com/sdk/downloads "GCP SDK")

You'll need to create a GCP Service Account for ```fileark``` to use when accessing Google Cloud Storage. You can use the commands below to create the necessary service account.

```
export PROJECT_ID=$(gcloud config get-value project)
export CLUSTER_SERVICE_ACCOUNT=$(gcloud container clusters describe <gke-cluster-name> --format="value(nodeConfig.serviceAccount)")
export FILEARK_NM=$(openssl rand -hex 10)
gcloud iam service-accounts create ${FILEARK_NM} --display-name "File Archiver"
export SERVICE_ACCOUNT=$(gcloud iam service-accounts list --filter="displayName:File Archiver" --format="value(email)")
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member serviceAccount:${SERVICE_ACCOUNT} \
  --role roles/storage.objectCreator
gcloud iam service-accounts add-iam-policy-binding ${SERVICE_ACCOUNT} \
  --member "serviceAccount:${CLUSTER_SERVICE_ACCOUNT}
  --role roles/iam.serviceAccountTokenCreator
```

Finally, you have to create a GCS bucket for fileark to use

```
export FILEARK_BUCKET="${PROJECT_ID}-fileark-bucket"
gsutil mb gs://${FILEARK_BUCKET}
```

## Building

To build the fileark microservice container just type

```
make image.build
```

You can look in the resulting image.build file to see what happened.

## Deployment

Use the following commands to modify the fileark deployment descriptor for your environment.

```
cp fileark.yaml.tmpl fileark.yaml
sed -i s/MY_PROJECT_ID/${CLOUD_SHELL_PROJECT}/g fileark.yaml
sed -i s/ARCHIVE_BUCKET/my-archive-bucket-${CLOUD_SHELL_PROJECT}/g fileark.yaml
sed -i s/MY_SERVICE_ACCOUNT/${FILEARK_SA}/g fileark.yaml
```

To deploy fileark use:

```
kubectl apply -f fileark.yaml
```

## Using fileark

The ```fileark``` service listens for HTTP POST requests on port 8080. When it receives a request it copies
the file from the body of the request and then uploads it to the GCS bucket specified at install time. When
uploading the file ```fileark``` acts as the service account you specified at install time. 

The simplest way to use ```fileark``` is to create a local tunnel to the fileark pod in GKE

```
export FILEARK_POD=$kubectl get po -l app=fileark -o jsonpath='{.items[*].metadata.name}')
kubectl port-forward ${FILEARK_POD} 8080:8080
```

Then you can use ```curl``` to archive files

```
curl -F 'data=@<path to local file>' http://localhost:8080/receive
```
