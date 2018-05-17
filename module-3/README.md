# Module 3 - Observability

## Prerequisites

* A running Kubernetes Engine cluster
* [Stackdriver Kubernetes Monitoring](https://cloud.google.com/monitoring/kubernetes-engine/installing) enabled for that cluster
* [Prometheus](https://cloud.google.com/monitoring/kubernetes-engine/prometheus) installed
* istio installed in the cluster
* The [Sock Shop](https://microservices-demo.github.io/) application installed

## Monitoring & Alerting

This lab draws heavily from the [StackDriver: Quick start](https://qwiklabs.com/focuses/559?locale=en&parent=catalog) lab.

1. Create Stackdriver account
2. Explore metrics from the GKE cluster
3. Create a logs-based metric
4. Create a simple StackDriver dashboard with the main metrics of the cluster
5. Create an alert when the number of pods is above a given limit
6. Run a simple `kubectl` command to increase the number of pods and trigger the alert

## Debugging

This lab draws heavily from the [APM with StackDriver](https://events.qwiklab.com/labs/742/edit#step1) lab.

1. Discover the bug in the application
2. Go through Traces
3. Find the error in Error Reporting
4. View the error in Logging
5. Take a Snapshot to understand the bug
6. Add a Logpoint and observe the logs in Logging
