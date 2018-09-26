# Variables

# Main variables
variable "region" { default = "us-central1" }
variable "project" { default = "PROJECTID" }
variable "credentials" { default = "./credentials.json" }
variable "vpc" { default = "k8s" }

# gke-one
variable "gke-one-name" { default = "gke-central" }
variable "gke-one-zone" { default = "us-central1-f" }
variable "network" { default = "default" }
variable "min_master_version" { default = "1.10" }
variable "machine_type" { default = "n1-standard-4" }
variable "image_type" { default = "cos" }

# gke-two
variable "gke-two-name" { default = "gke-west" }
variable "gke-two-zone" { default = "us-west1-b" }

# gke-spinnaker
variable "gke-spinnaker-name" { default = "gke-spinnaker" }
variable "gke-spinnaker-zone" { default = "us-central1-f" }

# for grafana spinnaker
variable "grafana-region-1" { default = "central" }
variable "grafana-region-2" { default = "west" }

# Istio version
variable "istio-ver" { default = "1.0.2" }

// Configure the Google Cloud provider
provider "google" {
 version = "~> 1.13"
 credentials = "${file("${var.credentials}")}"
 project     = "${var.project}" 
 region      = "${var.region}"
}

# Configure VPC
resource "google_compute_network" "vpc" {
 name                    = "${var.vpc}"
 project		         = "${var.project}"
 auto_create_subnetworks = "false"
}

# Create firewall rule to allow all for k8s internally
resource "google_compute_firewall" "allow-all-k8s" {
  name    = "allow-all-k8s"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "all"
  }
  source_ranges = ["10.0.0.0/12"]
}


# Create subnets-one
variable "one_node_ip_cidr" { default = "10.0.0.0/16"}
variable "one_pod_ip_cidr"  { default = "10.1.0.0/16" }
variable "one_svc1_ip_cidr" { default = "10.2.0.0/16" }
variable "one_subnet_count" { default = 2 }

resource "google_compute_subnetwork" "subnet-one" {
 count              = "${var.one_subnet_count}"
 name               = "subnet-${count.index}"
 project            = "${var.project}"
 ip_cidr_range      = "${cidrsubnet(var.one_node_ip_cidr, 4, count.index)}"
 network            = "${var.vpc}"
 region             = "${var.region}"
 secondary_ip_range = {
      range_name    = "one-pod-${replace(replace(cidrsubnet(var.one_pod_ip_cidr, 4, count.index), ".", "-"), "/", "-")}"
      ip_cidr_range = "${cidrsubnet(var.one_pod_ip_cidr, 4, count.index)}"
  }
 secondary_ip_range = {
      range_name    = "one-svc1-${replace(replace(cidrsubnet(var.one_svc1_ip_cidr, 4, count.index), ".", "-"), "/", "-")}"
      ip_cidr_range = "${cidrsubnet(var.one_svc1_ip_cidr, 4, count.index)}"
  }
 depends_on = ["google_compute_network.vpc"]
}

# Create subnets-two
variable "region-two" { default = "us-west1" }
variable "two_node_ip_cidr" { default = "10.10.0.0/16"}
variable "two_pod_ip_cidr"  { default = "10.11.0.0/16" }
variable "two_svc1_ip_cidr" { default = "10.12.0.0/16" }
variable "two_subnet_count" { default = 2 }

resource "google_compute_subnetwork" "subnet-two" {
 count              = "${var.two_subnet_count}"
 name               = "subnet-${count.index}"
 project            = "${var.project}"
 ip_cidr_range      = "${cidrsubnet(var.two_node_ip_cidr, 4, count.index)}"
 network            = "${var.vpc}"
 region             = "${var.region-two}"
 secondary_ip_range = {
      range_name    = "two-pod-${replace(replace(cidrsubnet(var.two_pod_ip_cidr, 4, count.index), ".", "-"), "/", "-")}"
      ip_cidr_range = "${cidrsubnet(var.two_pod_ip_cidr, 4, count.index)}"
  }
 secondary_ip_range = {
      range_name    = "two-svc1-${replace(replace(cidrsubnet(var.two_svc1_ip_cidr, 4, count.index), ".", "-"), "/", "-")}"
      ip_cidr_range = "${cidrsubnet(var.two_svc1_ip_cidr, 4, count.index)}"
  }
 depends_on = ["google_compute_network.vpc"]
}

resource "google_container_cluster" "gke-one" {
  name                    = "${var.gke-one-name}"
  zone                    = "${var.gke-one-zone}"
  network                 = "${var.vpc}"
  min_master_version	  = "${var.min_master_version}"
  initial_node_count      = 4
  subnetwork	          = "${element(google_compute_subnetwork.subnet-one.*.self_link, 0)}"
  logging_service	= "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  ip_allocation_policy {
  	cluster_secondary_range_name  = "one-pod-${replace(replace(cidrsubnet(var.one_pod_ip_cidr, 4, 0), ".", "-"), "/", "-")}"
    services_secondary_range_name = "one-svc1-${replace(replace(cidrsubnet(var.one_svc1_ip_cidr, 4, 0), ".", "-"), "/", "-")}"
  }
  node_config {
    machine_type          = "${var.machine_type}"
    image_type            = "${var.image_type}"
  }
   depends_on = ["google_compute_subnetwork.subnet-one"]
}

resource "null_resource" "gke-one-cluster" {
   provisioner "local-exec" {
        command = "gcloud container clusters get-credentials ${google_container_cluster.gke-one.name} --zone ${google_container_cluster.gke-one.zone} --project ${google_container_cluster.gke-one.project}"
      }
   provisioner "local-exec" {
        command = "kubectx ${google_container_cluster.gke-one.name}=\"gke_\"${google_container_cluster.gke-one.project}\"_\"${google_container_cluster.gke-one.zone}\"_\"${google_container_cluster.gke-one.name}"
      }
   provisioner "local-exec" {
        command = "kubectl create clusterrolebinding user-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account) --context ${google_container_cluster.gke-one.name}"
      }
   provisioner "local-exec" {
        command = "kubectl create serviceaccount tiller --namespace kube-system --context ${google_container_cluster.gke-one.name}"
      }
   provisioner "local-exec" {
        command = "kubectl create clusterrolebinding tiller-admin-binding --clusterrole=cluster-admin --serviceaccount=kube-system:tiller --context ${google_container_cluster.gke-one.name}"
      }
   provisioner "local-exec" {
        command = "helm init --service-account=tiller --kube-context ${google_container_cluster.gke-one.name}"
      }
   provisioner "local-exec" {
        command = "sleep 60; helm install ~/istio-${var.istio-ver}/install/kubernetes/helm/istio --name istio --namespace istio-system --set kiali.enabled=true --set tracing.enabled=true --set global.mtls.enabled=true --set grafana.enabled=true --set servicegraph.enabled=true --kube-context ${google_container_cluster.gke-one.name}"
      }
   provisioner "local-exec" {
        command = "kubectl label namespace default istio-injection=enabled --context ${google_container_cluster.gke-one.name}"
      }
   provisioner "local-exec" {
        command = "kubectl apply -f ~/advanced-kubernetes-workshop/spinnaker/sa.yaml --context ${google_container_cluster.gke-one.name}"
      }
   provisioner "local-exec" {
        command = "kubectl config set-credentials ${google_container_cluster.gke-one.name}-token-user --token $(kubectl get secret --context ${google_container_cluster.gke-one.name} $(kubectl get serviceaccount spinnaker-service-account --context ${google_container_cluster.gke-one.name} -n spinnaker -o jsonpath='{.secrets[0].name}') -n spinnaker -o jsonpath='{.data.token}' | base64 --decode)"
      }
   provisioner "local-exec" {
        command = "kubectl config set-context ${google_container_cluster.gke-one.name} --user ${google_container_cluster.gke-one.name}-token-user"
      }
   depends_on = ["google_container_cluster.gke-one"]
}

resource "google_container_cluster" "gke-two" {
  name                    = "${var.gke-two-name}"
  zone                    = "${var.gke-two-zone}"
  network                 = "${var.vpc}"
  min_master_version	  = "${var.min_master_version}"
  initial_node_count      = 4
  subnetwork	          = "${element(google_compute_subnetwork.subnet-two.*.self_link, 0)}"
  logging_service	= "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  ip_allocation_policy {
  	cluster_secondary_range_name  = "two-pod-${replace(replace(cidrsubnet(var.two_pod_ip_cidr, 4, 0), ".", "-"), "/", "-")}"
    services_secondary_range_name = "two-svc1-${replace(replace(cidrsubnet(var.two_svc1_ip_cidr, 4, 0), ".", "-"), "/", "-")}"
  }
  node_config {
    machine_type          = "${var.machine_type}"
    image_type            = "${var.image_type}"
  }
   depends_on = ["google_compute_subnetwork.subnet-two"]
}

resource "null_resource" "gke-two-cluster" {
   provisioner "local-exec" {
        command = "gcloud container clusters get-credentials ${google_container_cluster.gke-two.name} --zone ${google_container_cluster.gke-two.zone} --project ${google_container_cluster.gke-two.project}"
      }
   provisioner "local-exec" {
        command = "kubectx ${google_container_cluster.gke-two.name}=\"gke_\"${google_container_cluster.gke-two.project}\"_\"${google_container_cluster.gke-two.zone}\"_\"${google_container_cluster.gke-two.name}"
      }
   provisioner "local-exec" {
        command = "kubectl create clusterrolebinding user-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account) --context ${google_container_cluster.gke-two.name}"
      }
   provisioner "local-exec" {
        command = "kubectl create serviceaccount tiller --namespace kube-system --context ${google_container_cluster.gke-two.name}"
      }
   provisioner "local-exec" {
        command = "kubectl create clusterrolebinding tiller-admin-binding --clusterrole=cluster-admin --serviceaccount=kube-system:tiller --context ${google_container_cluster.gke-two.name}"
      }
   provisioner "local-exec" {
        command = "helm init --service-account=tiller --kube-context ${google_container_cluster.gke-two.name}"
      }
   provisioner "local-exec" {
        command = "sleep 60; helm install ~/istio-${var.istio-ver}/install/kubernetes/helm/istio --name istio --namespace istio-system --set kiali.enabled=true --set tracing.enabled=true --set global.mtls.enabled=true --set grafana.enabled=true --set servicegraph.enabled=true --kube-context ${google_container_cluster.gke-two.name}"
      }
   provisioner "local-exec" {
        command = "kubectl label namespace default istio-injection=enabled --context ${google_container_cluster.gke-two.name}"
      }
   provisioner "local-exec" {
        command = "kubectl apply -f ~/advanced-kubernetes-workshop/spinnaker/sa.yaml --context ${google_container_cluster.gke-two.name}"
      }
   provisioner "local-exec" {
        command = "kubectl config set-credentials ${google_container_cluster.gke-two.name}-token-user --token $(kubectl get secret --context ${google_container_cluster.gke-two.name} $(kubectl get serviceaccount spinnaker-service-account --context ${google_container_cluster.gke-two.name} -n spinnaker -o jsonpath='{.secrets[0].name}') -n spinnaker -o jsonpath='{.data.token}' | base64 --decode)"
      }
   provisioner "local-exec" {
        command = "kubectl config set-context ${google_container_cluster.gke-two.name} --user ${google_container_cluster.gke-two.name}-token-user"
      }
   depends_on = ["google_container_cluster.gke-two", "null_resource.gke-one-cluster"]
}

resource "google_container_cluster" "gke-spinnaker" {
  name                    = "${var.gke-spinnaker-name}"
  zone                    = "${var.gke-spinnaker-zone}"
  min_master_version	  = "${var.min_master_version}"
  network                 = "${var.vpc}"
  initial_node_count      = 4
  subnetwork	          = "${element(google_compute_subnetwork.subnet-one.*.self_link, 1)}"
  logging_service	= "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"  
  ip_allocation_policy {
  	cluster_secondary_range_name  = "one-pod-${replace(replace(cidrsubnet(var.one_pod_ip_cidr, 4, 1), ".", "-"), "/", "-")}"
    services_secondary_range_name = "one-svc1-${replace(replace(cidrsubnet(var.one_svc1_ip_cidr, 4, 1), ".", "-"), "/", "-")}"
  }
  node_config {
    machine_type          = "${var.machine_type}"
    image_type            = "${var.image_type}"
  }
   depends_on = ["google_compute_subnetwork.subnet-one"]
}

resource "null_resource" "gke-spinnaker-cluster" {
   provisioner "local-exec" {
        command = "gcloud container clusters get-credentials ${google_container_cluster.gke-spinnaker.name} --zone ${google_container_cluster.gke-spinnaker.zone} --project ${google_container_cluster.gke-spinnaker.project}"
      }
   provisioner "local-exec" {
        command = "kubectx ${google_container_cluster.gke-spinnaker.name}=\"gke_\"${google_container_cluster.gke-spinnaker.project}\"_\"${google_container_cluster.gke-spinnaker.zone}\"_\"${google_container_cluster.gke-spinnaker.name}"
      }
   provisioner "local-exec" {
        command = "kubectl create clusterrolebinding user-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account) --context ${google_container_cluster.gke-spinnaker.name}"
      }
   provisioner "local-exec" {
        command = "kubectl create serviceaccount tiller --namespace kube-system --context ${google_container_cluster.gke-spinnaker.name}"
      }
   provisioner "local-exec" {
        command = "kubectl create clusterrolebinding tiller-admin-binding --clusterrole=cluster-admin --serviceaccount=kube-system:tiller --context ${google_container_cluster.gke-spinnaker.name}"
      }
   provisioner "local-exec" {
        command = "helm init --service-account=tiller --kube-context ${google_container_cluster.gke-spinnaker.name}"
      }
   provisioner "local-exec" {
        command = "sleep 60; helm install -n spin stable/spinnaker -f ~/advanced-kubernetes-workshop/terraform/spinconfig.yaml --timeout=600 --kube-context ${google_container_cluster.gke-spinnaker.name}"
      }
   provisioner "local-exec" {
        command = "helm install ~/istio-${var.istio-ver}/install/kubernetes/helm/istio --name istio --namespace istio-system --set kiali.enabled=true --set tracing.enabled=true --set global.mtls.enabled=true --set grafana.enabled=true --set servicegraph.enabled=true --kube-context ${google_container_cluster.gke-spinnaker.name}"
      }
      provisioner "local-exec" {
        command = "kubectl apply -f ~/istio-${var.istio-ver}/samples/httpbin/sample-client/fortio-deploy.yaml --context ${google_container_cluster.gke-spinnaker.name}"
      }
   provisioner "local-exec" {
        command = "kubectl apply -f ~/advanced-kubernetes-workshop/spinnaker/sa.yaml --context ${google_container_cluster.gke-spinnaker.name}"
      }
   provisioner "local-exec" {
        command = "kubectl config set-credentials gke-spinnaker-token-user --token $(kubectl get secret --context gke-spinnaker $(kubectl get serviceaccount spinnaker-service-account --context gke-spinnaker -n spinnaker -o jsonpath='{.secrets[0].name}') -n spinnaker -o jsonpath='{.data.token}' | base64 --decode)"
      }
   provisioner "local-exec" {
        command = "kubectl config set-context gke-spinnaker --user gke-spinnaker-token-user"
      }
   depends_on = ["google_container_cluster.gke-spinnaker","null_resource.gke-two-cluster"]
}

resource "null_resource" "local-exec-1" {
   provisioner "local-exec" {
        command = "sed -e s/REGION1/${var.grafana-region-1}/g -e s/REGION2/${var.grafana-region-2}/g ~/advanced-kubernetes-workshop/terraform/grafana.sh | sh -"
      }
   provisioner "local-exec" {
        command = "kubectl apply -f ~/advanced-kubernetes-workshop/services/manifests/namespaces.yml --context ${google_container_cluster.gke-one.name}"
      }
   provisioner "local-exec" {
        command = "kubectl label namespace staging istio-injection=enabled --context ${google_container_cluster.gke-one.name}"
      }
   provisioner "local-exec" {
        command = "kubectl label namespace production istio-injection=enabled --context ${google_container_cluster.gke-one.name}"
      }
   provisioner "local-exec" {
        command = "sed -e s/PROJECT_ID/${google_container_cluster.gke-one.project}/g ~/advanced-kubernetes-workshop/services/manifests/seeding.yml | kubectl apply -f - --context ${google_container_cluster.gke-one.name}"
      }
   provisioner "local-exec" {
        command = "sed -e s/PROJECT_ID/${google_container_cluster.gke-one.project}/g ~/advanced-kubernetes-workshop/services/manifests/app-backend-dev.yml | kubectl apply -f -  --context ${google_container_cluster.gke-one.name}"
      }
   provisioner "local-exec" {
        command = "kubectl apply -f ~/advanced-kubernetes-workshop/services/manifests/namespaces.yml --context ${google_container_cluster.gke-two.name}"
      }
   provisioner "local-exec" {
        command = "kubectl label namespace staging istio-injection=enabled --context ${google_container_cluster.gke-two.name}"
      }
   provisioner "local-exec" {
        command = "kubectl label namespace production istio-injection=enabled --context ${google_container_cluster.gke-two.name}"
      }
   provisioner "local-exec" {
        command = "sed -e s/PROJECT_ID/${google_container_cluster.gke-one.project}/g ~/advanced-kubernetes-workshop/services/manifests/seeding.yml | kubectl apply -f - --context ${google_container_cluster.gke-two.name}"
      }
   provisioner "local-exec" {
        command = "sed -e s/PROJECT_ID/${google_container_cluster.gke-one.project}/g ~/advanced-kubernetes-workshop/services/manifests/app-backend-dev.yml | kubectl apply -f -  --context ${google_container_cluster.gke-two.name}"
      }
  provisioner "local-exec" {
    command = "kubectl cp ~/advanced-kubernetes-workshop/terraform/spinnaker-service-account.json default/spin-spinnaker-halyard-0:/home/spinnaker/. --context ${google_container_cluster.gke-spinnaker.name}"
  }
  provisioner "local-exec" {
    command = "kubectl cp ~/project.txt default/spin-spinnaker-halyard-0:/home/spinnaker/. --context ${google_container_cluster.gke-spinnaker.name}"
  }
  provisioner "local-exec" {
    command = "kubectl cp ~/.kube/config default/spin-spinnaker-halyard-0:/home/spinnaker/.kube/. --context ${google_container_cluster.gke-spinnaker.name}"
  }
  provisioner "local-exec" {
    command = "kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c \"kubectl config use-context ${google_container_cluster.gke-spinnaker.name}\""
  }
  provisioner "local-exec" {
    command = "kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c \"hal config provider kubernetes account add ${google_container_cluster.gke-one.name} --provider-version v2 --context ${google_container_cluster.gke-one.name}\""
  }
  provisioner "local-exec" {
    command = "kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c \"hal config provider kubernetes account add ${google_container_cluster.gke-two.name} --provider-version v2 --context ${google_container_cluster.gke-two.name}\""
  }
  provisioner "local-exec" {
    command = "kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c \"hal config features edit --artifacts true\""
  }
  provisioner "local-exec" {
    command = "kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c \"hal config artifact gcs account add spinnaker-service-account --json-path /home/spinnaker/spinnaker-service-account.json\""
  }
  provisioner "local-exec" {
    command = "kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c \"hal config artifact gcs enable\""
  }
  provisioner "local-exec" {
    command = "kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c \"hal config provider docker-registry enable\""
  }
  provisioner "local-exec" {
    command = "kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c \"hal config provider docker-registry account add gcr-registry --address gcr.io --username _json_key --password-file /home/spinnaker/spinnaker-service-account.json\""
  }
  provisioner "local-exec" {
    command = "kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c \"hal config pubsub google enable\""
  }
  provisioner "local-exec" {
    command = "kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c \"hal config pubsub google subscription add gcr-google-pubsub --subscription-name my-gcr-sub --json-path /home/spinnaker/spinnaker-service-account.json --project $(cat ~/project.txt) --message-format GCR\""
  }
  provisioner "local-exec" {
    command = "kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c \"hal config pubsub google subscription add gcs-google-pubsub --subscription-name my-gcs-sub --json-path /home/spinnaker/spinnaker-service-account.json --project $(cat ~/project.txt) --message-format GCS\""
  }
  provisioner "local-exec" {
    command = "kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c \"hal deploy apply\""
  }
  depends_on = ["null_resource.gke-one-cluster","null_resource.gke-two-cluster","null_resource.gke-spinnaker-cluster"]
}

### Add readiness tests for: clusters, cluster rename, GCS bucket, GCR two images, PubSub topiubscs/scription, istio installs and setting, spinnaker install