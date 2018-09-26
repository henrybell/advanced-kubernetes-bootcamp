#!/bin/bash

# Export GKE cluster regions
export ONE=REGION1
export TWO=REGION2

# Copy the dashboard json to the Halyard pod home dir
kubectl cp ~/advanced-kubernetes-workshop/terraform/dashboard.json default/spin-spinnaker-halyard-0:/home/spinnaker/. --context gke-spinnaker

# Get the IP addresses of ONE and TWO Prometheus and Spinnaker Grafana
export PROM_ONE=$(kubectl get pods -o wide -n istio-system --context gke-$ONE | grep prometheus | awk '{print $6}')
export PROM_TWO=$(kubectl get pods -o wide -n istio-system --context gke-$TWO | grep prometheus | awk '{print $6}')
export GRAFANA_ONE=$(kubectl get pods -o wide -n istio-system --context gke-$ONE | grep grafana | awk '{print $6}')
export GRAFANA_TWO=$(kubectl get pods -o wide -n istio-system --context gke-$TWO | grep grafana | awk '{print $6}')
export GRAFANA_SPINNAKER=$(kubectl get pods -o wide -n istio-system --context gke-spinnaker | grep grafana | awk '{print $6}')

### For GKE-Spinnaker
# Add ONE Prometheus Datasource to Spinnaker Grafana
kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c "curl -X POST -H \"Content-Type: application/json\" -d '{\"name\":\"Prometheus-$ONE\",\"type\":\"prometheus\",\"url\":\"http://$PROM_ONE:9090\",\"access\":\"proxy\",\"basicAuth\":false,\"jsonData\": {\"timeInterval\": \"5s\"}}' http://$GRAFANA_SPINNAKER:3000/api/datasources
"

# Add TWO Prometheus Datasource to Spinnaker Grafana
kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c "curl -X POST -H \"Content-Type: application/json\" -d '{\"name\":\"Prometheus-$TWO\",\"type\":\"prometheus\",\"url\":\"http://$PROM_TWO:9090\",\"access\":\"proxy\",\"basicAuth\":false,\"jsonData\": {\"timeInterval\": \"5s\"}}' http://$GRAFANA_SPINNAKER:3000/api/datasources
"

# Add new dashboard to Spinnaker Grafana
kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c "curl -X POST -H \"Content-Type: application/json\" -d @\"/home/spinnaker/dashboard.json\" http://$GRAFANA_SPINNAKER:3000/api/dashboards/db"


### For GKE-Central
# Add ONE Prometheus Datasource to Spinnaker Grafana
kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c "curl -X POST -H \"Content-Type: application/json\" -d '{\"name\":\"Prometheus-$ONE\",\"type\":\"prometheus\",\"url\":\"http://$PROM_ONE:9090\",\"access\":\"proxy\",\"basicAuth\":false,\"jsonData\": {\"timeInterval\": \"5s\"}}' http://$GRAFANA_ONE:3000/api/datasources
"

# Add TWO Prometheus Datasource to Spinnaker Grafana
kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c "curl -X POST -H \"Content-Type: application/json\" -d '{\"name\":\"Prometheus-$TWO\",\"type\":\"prometheus\",\"url\":\"http://$PROM_TWO:9090\",\"access\":\"proxy\",\"basicAuth\":false,\"jsonData\": {\"timeInterval\": \"5s\"}}' http://$GRAFANA_ONE:3000/api/datasources
"

# Add new dashboard to Spinnaker Grafana
kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c "curl -X POST -H \"Content-Type: application/json\" -d @\"/home/spinnaker/dashboard.json\" http://$GRAFANA_ONE:3000/api/dashboards/db"



### For GKE-West
# Add ONE Prometheus Datasource to Spinnaker Grafana
kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c "curl -X POST -H \"Content-Type: application/json\" -d '{\"name\":\"Prometheus-$ONE\",\"type\":\"prometheus\",\"url\":\"http://$PROM_ONE:9090\",\"access\":\"proxy\",\"basicAuth\":false,\"jsonData\": {\"timeInterval\": \"5s\"}}' http://$GRAFANA_TWO:3000/api/datasources
"

# Add TWO Prometheus Datasource to Spinnaker Grafana
kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c "curl -X POST -H \"Content-Type: application/json\" -d '{\"name\":\"Prometheus-$TWO\",\"type\":\"prometheus\",\"url\":\"http://$PROM_TWO:9090\",\"access\":\"proxy\",\"basicAuth\":false,\"jsonData\": {\"timeInterval\": \"5s\"}}' http://$GRAFANA_TWO:3000/api/datasources
"

# Add new dashboard to Spinnaker Grafana
kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c "curl -X POST -H \"Content-Type: application/json\" -d @\"/home/spinnaker/dashboard.json\" http://$GRAFANA_TWO:3000/api/dashboards/db"

