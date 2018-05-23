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
 * In StackDriver, go to Resources > Kubernetes and explore the system
 metrics for the clusters here.
 * In StackDriver, go to Resources > Metrics Explorer
 * In "Resource type", choose `k8s_container`. In "Metric", choose
  `kubernetes.io/container/cpu/core_usage_time`.
 * Still in Metrics Explorer, change the "Metric" to
 `external.googleapis.com/prometheus/request_duration_seconds`, and group by
 `service`.
3. Create a logs-based metric
 * Go to StackDriver Logging
 * Filter for logs with the following filter:
```
resource.type="k8s_container"
resource.labels.location="us-west1-c"
resource.labels.cluster_name="bootcamp-west"
resource.labels.namespace_name="sock-shop"
textPayload:Health
```
 * Click on "Create Metric" and choose the name `sock-shop-healthchecks`
 * Back in the Metrics Explorer, look for the metric
 `logging.googleapis.com/user/sock-shop-healthchecks`
4. Create a simple StackDriver dashboard with the main metrics of the cluster
 * In the Dashboard menu, click on "Create Dashboard"
 * Click on "Add Chart"
 * Add a chart for healthchecks
 * Add a chart for the request duration monitored by Prometheus
 * Add a chart for the CPU usage of the "front-end" container
5. Create an alert when the CPU usage of "front-end" is too high
 * In Alerting, create a new Policy, opt-in for the new UI
 * Create an alert when the "front-end" container uses more than 100ms/s CPU
6. From your VM, run the following command: `hey -z 5m http://35.197.58.160/`

## Debugging

This lab draws heavily from the [APM with StackDriver](https://events.qwiklab.com/labs/742/edit#step1) lab.

1. Discover the bug in the application
2. Go through Traces
3. Find the error in Error Reporting
4. View the error in Logging
5. Take a Snapshot to understand the bug
6. Add a Logpoint and observe the logs in Logging
