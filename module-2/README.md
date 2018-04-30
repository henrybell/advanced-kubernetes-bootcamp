# Operations and Best Practices

![Module-2. Lab Diagram](https://github.com/henrybell/advanced-kubernetes-bootcamp/blob/master/module-2/diagrams/lab-diag.png)*Module-2. Lab Diagram*

# Lab Outline

**Total estimated time: 1 hr 30 mins**

## Kubernetes Multicluster Architecture (35 mins)

+  Deploy two Kubernetes Engine clusters (10 mins)

    +  Use gcloud

+  Install Istio on both clusters (5 mins)

    +  Use latest release artifacts (0.8 and onwards will have LTS)
    +  For using _Ingress_ and _RouteRules_ later in the lab

+  Install and configure Spinnaker on one of the Kubernetes Engine cluster (20 mins)

    +  Create service accounts and GCS buckets
    +  Create secret with kubeconfig
    +  Create spinnaker config
    +  Use helm charts by Vic (chart deployment takes about 10 mins)

## Application lifecycle management (35 mins)

+  Configure a simple _Deploy_ pipeline in Spinnaker to deploy a web app to both clusters

    +  Upload web app to Container Registry with tag v1.0.0 (5 mins)
    +  Deploy Canary > Test Canary > Manual Judgement > Deploy to Prod (5 mins)
    +  Triggered via version tag (v.*) from Container Registry

+  Manually deploy pipeline for v1.0.0 to both clusters (10 mins)
+  Trigger the _Deploy_ pipeline by updating the version tag to v1.0.1 in Container Registry (15 mins)

## Routing and Load Balancing traffic to multiple clusters (20 mins)

+  Load balance traffic using an NGINX load balancer to both clusters (10 mins)

    +  NGINX LB needs to run outside of the two clusters
    +  It can run in a separate (third) cluster using ConfigMaps for load-balancer.conf file
    +  Expose NGINX as Type:LoadBalancer for Client access

+  Use _RouteRules_ to route traffic between _prod_ and _canary_ releases within each cluster (10 mins)

    +  Separate traffic between prod and canary

        +  By weights
        +  By device (for example all mobile go to canary)

# Presentations

Dependent upon labs

# Lab Materials and Useful Links

[Multicloud TAW - Modules 2, 3, 4, and 5](https://docs.google.com/document/d/1FnNiKuS5K6J8Lct2qStQ1N8r8gR3snc7TaDzPDgIODw/edit) 
[Multicloud Workshop Presentation](https://docs.google.com/presentation/d/1gLWKMZr9U6AqtjyxH2LFE7m03ZWFnjjrarj4nS7_s6c/edit#slide=id.g2dfddef4d5_0_1435)  
[Continuous Delivery with Spinnaker on Kubernetes Engine](https://cloud.google.com/solutions/continuous-delivery-spinnaker-kubernetes-engine)
[Istio Route Rules](https://istio.io/docs/concepts/traffic-management/rules-configuration.html)
