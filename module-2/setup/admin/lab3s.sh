#!/bin/bash

# Lab 3: Control Cloud Shell #2

# Set speed
SPEED=45
bold=$(tput bold)
normal=$(tput sgr0)

color='\e[1;32m' # green
nc='\e[0m'

echo -e "\n"
echo "${bold}*** Lab 3: Control Walk Through Cloud Shell Window #2 ***${normal}"
echo -e "\n"

# Inspect Grafana
echo "${bold}Inspect Grafana incoming requests by source and destination${normal}"
echo "${bold}Use Cloud Shell Web Prview to port 3000 and check the Central and West Service Dashboard${normal}"
read -p ''

# Appy 50-50 Rule
echo -e "\n"
echo "${bold}Apply frontend VIRTUALSERVICE rule to send 50% traffic to prod 50% traffic to canary${normal}"
read -p ''
echo -e "${color}$ istioctl replace -f ~/advanced-kubernetes-workshop/services/manifests/frontend-vs-50prod-50canary.yml --context gke-central${nc}" | pv -qL $SPEED
istioctl replace -f ~/advanced-kubernetes-workshop/services/manifests/frontend-vs-50prod-50canary.yml --context gke-central

# Inspect 50-50 VirtualService rule
echo -e "\n"
echo "${bold}Inspect the new frontend VIRTUALSERVICE rule${normal}"
read -p ''
echo -e "${color}$ istioctl get virtualservice frontend -n production --context gke-central -o yaml${nc}" | pv -qL $SPEED
istioctl get virtualservice frontend -n production --context gke-central -o yaml

# Inspect Grafana
echo -e "\n"
echo "${bold}Inspect Grafana incoming requests by source and destination${normal}"
echo "${bold}Inspect the frontend and the backend services${normal}"
read -p ''

# Backend destinationrule for prod to prod and canary to canary
echo -e "\n"
echo "${bold}Apply backend VIRTUALSERVICE rule to send frontend prod to backend prod and frontend canary to backend canary${normal}"
read -p ''
echo -e "${color}$ istioctl replace -f ~/advanced-kubernetes-workshop/services/manifests/backend-vs-can-to-can-prod-to-prod.yml --context gke-central${nc}" | pv -qL $SPEED
istioctl replace -f ~/advanced-kubernetes-workshop/services/manifests/backend-vs-can-to-can-prod-to-prod.yml --context gke-central

# Inspect the new backend virtualservice
echo -e "\n"
echo "${bold}Inspect the new backend VIRTUALSERVICE rule${normal}"
read -p ''
echo -e "${color}$ istioctl get virtualservice backend -n production --context gke-central -o yaml${nc}" | pv -qL $SPEED
istioctl get virtualservice backend -n production --context gke-central -o yaml

# Inspect Grafana
echo -e "\n"
echo "${bold}Inspect Grafana incoming requests by source and destination${normal}"
echo "${bold}Inspect the frontend and the backend services${normal}"
read -p ''

# Send frontend all to prod
echo -e "\n"
echo "${bold}Send all incoming traffic to frontend production${normal}"
read -p ''
echo -e "${color}$ istioctl replace -f ~/advanced-kubernetes-workshop/services/manifests/frontend-vs-all-to-prod.yml --context gke-central${nc}" | pv -qL $SPEED
istioctl replace -f ~/advanced-kubernetes-workshop/services/manifests/frontend-vs-all-to-prod.yml --context gke-central

# Inspect the new frontend virtualservice
echo -e "\n"
echo "${bold}Inspect the new frontend VIRTUALSERVICE rule${normal}"
read -p ''
echo -e "${color}$ istioctl get virtualservice frontend -n production --context gke-central -o yaml${nc}" | pv -qL $SPEED
istioctl get virtualservice frontend -n production --context gke-central -o yaml

# Inspect Grafana
echo -e "\n"
echo "${bold}Inspect Grafana incoming requests by source and destination${normal}"
echo "${bold}Inspect the frontend and the backend services${normal}"
read -p ''

# Send frontend all to canary
echo -e "\n"
echo "${bold}Send all incoming traffic to frontend canary${normal}"
read -p ''
echo -e "${color}$ istioctl replace -f ~/advanced-kubernetes-workshop/services/manifests/frontend-vs-all-to-canary.yml --context gke-central${nc}" | pv -qL $SPEED
istioctl replace -f ~/advanced-kubernetes-workshop/services/manifests/frontend-vs-all-to-canary.yml --context gke-central

# Inspect the new frontend virtualservice
echo -e "\n"
echo "${bold}Inspect the new frontend VIRTUALSERVICE rule${normal}"
read -p ''
echo -e "${color}$ istioctl get virtualservice frontend -n production --context gke-central -o yaml${nc}" | pv -qL $SPEED
istioctl get virtualservice frontend -n production --context gke-central -o yaml

# Inspect Grafana
echo -e "\n"
echo "${bold}Inspect Grafana incoming requests by source and destination${normal}"
echo "${bold}Inspect the frontend and the backend services${normal}"
read -p ''

# Reset frontend and backend virtualservices
echo -e "\n"
echo "${bold}Reset frontend and backend VIRTUALSERVICE rule${normal}"
read -p ''
echo -e "${color}$ istioctl replace -f ~/advanced-kubernetes-workshop/services/manifests/myapp-vs-base.yml --context gke-central${nc}" | pv -qL $SPEED
istioctl replace -f ~/advanced-kubernetes-workshop/services/manifests/myapp-vs-base.yml --context gke-central

# Rate Limit - frontend production to 75 rps and frontend canary to 20 per 5 secs
echo -e "\n"
echo "${bold}Rate limit - frontend prod to 75 req and frontend canary to 20 req per 5 secs${normal}"
read -p ''
echo -e "${color}$ istioctl create -f ~/advanced-kubernetes-workshop/lb/rate-limit-frontend.yaml --context gke-central${nc}" | pv -qL $SPEED
istioctl create -f ~/advanced-kubernetes-workshop/lb/rate-limit-frontend.yaml --context gke-central

# Inspect memquota
echo -e "\n"
echo "${bold}Inspect memquota${normal}"
read -p ''
echo -e "${color}$ kubectl get memquota -n istio-system --context gke-central -o yaml${nc}" | pv -qL $SPEED
kubectl get memquota -n istio-system --context gke-central -o yaml

# Inspect Grafana
echo -e "\n"
echo "${bold}Inspect Grafana incoming requests by source and destination${normal}"
echo "${bold}Inspect the frontend and the backend services${normal}"
read -p ''

# Delete rate limit rule
echo -e "\n"
echo "${bold}Delete the rate limit rule${normal}"
read -p ''
echo -e "${color}$ istioctl delete -f ~/advanced-kubernetes-workshop/lb/rate-limit-frontend.yaml --context gke-central${nc}" | pv -qL $SPEED
istioctl delete -f ~/advanced-kubernetes-workshop/lb/rate-limit-frontend.yaml --context gke-central

# Configure backend circuit breaker
echo -e "\n"
echo "${bold}Configure backend circuit breaker through a new backend DESTINATIONRULE${normal}"
read -p ''
echo -e "${color}$ istioctl replace -f ~/advanced-kubernetes-workshop/lb/circuit-breaker-backend.yml --context gke-central${nc}" | pv -qL $SPEED
istioctl replace -f ~/advanced-kubernetes-workshop/lb/circuit-breaker-backend.yml --context gke-central

# Inspect backend DESTINATIONRULE
echo -e "\n"
echo "${bold}Inspect the new backend DESTINATIONRULE${normal}"
read -p ''
echo -e "${color}$ istioctl get destinationrule backend -n production --context gke-central -o yaml${nc}" | pv -qL $SPEED
istioctl get destinationrule backend -n production --context gke-central -o yaml

# Inspect Grafana
echo -e "\n"
echo "${bold}Inspect Grafana incoming requests by source and destination${normal}"
echo "${bold}Inspect the frontend and the backend services${normal}"
read -p ''

# Check circuit breaker
echo -e "\n"
echo "${bold}Inspect traffic caught by the circuit breaker${normal}"
read -p ''
echo -e "${color}$ kubectl exec -it $FRONTEND_POD -n production --context gke-central -c istio-proxy  -- sh -c 'curl localhost:15000/stats' | grep  \"||backend.production\" | grep pending${nc}" | pv -qL $SPEED
export FRONTEND_POD=$(kubectl get pods -l app=frontend -n production --context gke-central | awk 'NR == 3 {print $1}')
kubectl exec -it $FRONTEND_POD -n production --context gke-central -c istio-proxy  -- sh -c 'curl localhost:15000/stats' | grep  "||backend.production" | grep pending

# Reset backend DESTINATIONRULE
echo -e "\n"
echo "${bold}Reset the backend DESTINATIONRULE${normal}"
read -p ''
echo -e "${color}$ istioctl create -f ~/advanced-kubernetes-workshop/lb/backend-destination-rule.yml --context gke-central${nc}" | pv -qL $SPEED
istioctl delete -f ~/advanced-kubernetes-workshop/lb/circuit-breaker-backend.yml --context gke-central
istioctl create -f ~/advanced-kubernetes-workshop/lb/backend-destination-rule.yml --context gke-central

# Inspect the security meshpolicy
echo -e "\n"
echo "${bold}Inspect the MESHPOLICY for mTLS${normal}"
read -p ''
echo -e "${color}$ istioctl get meshpolicy -n production --context gke-central -o yaml${nc}" | pv -qL $SPEED
istioctl get meshpolicy -n production --context gke-central -o yaml

# Verify mTLS configs for frontend and backend
echo -e "\n"
echo "${bold}Verify mTLS configs for frontend and backend services${normal}"
read -p ''
echo -e "${color}$ istioctl authn tls-check frontend.production.svc.cluster.local --context gke-central${nc}" | pv -qL $SPEED
echo -e "${color}$ istioctl authn tls-check backend.production.svc.cluster.local --context gke-central${nc}" | pv -qL $SPEED
istioctl authn tls-check frontend.production.svc.cluster.local --context gke-central
istioctl authn tls-check backend.production.svc.cluster.local --context gke-central

# Verify mTLS configs for frontend and backend in the DESTINATIONRULES
echo -e "\n"
echo "${bold}Verify mTLS configs for frontend and backend in the DESTINATIONRULES${normal}"
read -p ''
echo -e "${color}$ istioctl get destinationrule frontend -n production --context gke-central -o yaml${nc}" | pv -qL $SPEED
echo -e "${color}$ istioctl get destinationrule backend -n production --context gke-central -o yaml${nc}" | pv -qL $SPEED
istioctl get destinationrule frontend -n production --context gke-central -o yaml
istioctl get destinationrule backend -n production --context gke-central -o yaml

# Inspect frontend service certs in the istio-proxy
echo -e "\n"
echo "${bold}Inspect frontend service certs in the istio-proxy${normal}"
read -p ''
echo -e "${color}$ kubectl exec $FRONTEND_POD -n production --context gke-central -c istio-proxy -- ls /etc/certs${nc}" | pv -qL $SPEED
export FRONTEND_POD=$(kubectl get pods -l app=frontend -n production --context gke-central | awk 'NR == 3 {print $1}')
kubectl exec $FRONTEND_POD -n production --context gke-central -c istio-proxy -- ls /etc/certs

# Check the validity of the frontend certs
echo -e "\n"
echo "${bold}Inspect the validity of the frontend certs${normal}"
read -p ''
echo -e "${color}$ kubectl exec $FRONTEND_POD -n production --context gke-central -c istio-proxy -- cat /etc/certs/cert-chain.pem  | openssl x509 -text -noout  | grep Validity -A 2${nc}" | pv -qL $SPEED
kubectl exec $FRONTEND_POD -n production --context gke-central -c istio-proxy -- cat /etc/certs/cert-chain.pem  | openssl x509 -text -noout  | grep Validity -A 2

# Inspect frontend service service account
echo -e "\n"
echo "${bold}Inspect frontend service service account${normal}"
read -p ''
echo -e "${color}$ kubectl exec $FRONTEND_POD -n production --context gke-central -c istio-proxy -- cat /etc/certs/cert-chain.pem  | openssl x509 -text -noout  | grep 'Subject Alternative Name' -A 1${nc}" | pv -qL $SPEED
kubectl exec $FRONTEND_POD -n production --context gke-central -c istio-proxy -- cat /etc/certs/cert-chain.pem  | openssl x509 -text -noout  | grep 'Subject Alternative Name' -A 1

# Confirm backend staging service allows both mTLS and plain text traffic
echo -e "\n"
echo "${bold}Confirm backend staging service allows both mTLS and plain text traffic${normal}"
read -p ''
echo -e "${color}$ istioctl get policy -n staging --context gke-central -o yaml${nc}" | pv -qL $SPEED
istioctl get policy -n staging --context gke-central -o yaml

# Confirm backend.staging test job does not have an istio-proxy
echo -e "\n"
echo "${bold}Confirm backend.staging test job does not have an istio-proxy${normal}"
read -p ''
echo -e "${color}$ kubectl describe job -n staging --context gke-central${nc}" | pv -qL $SPEED
kubectl describe job -n staging --context gke-central

# Global load balancing
echo -e "\n"
echo "${bold}Before configuring global load balancing, finish the spinnaker pipelines${normal}"
read -p ''

# Create the NGINX configmap
echo -e "\n"
echo "${bold}Configure the NGINX configmap${normal}"
read -p ''
export GKE_ONE_ISTIO_GATEWAY=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[0].ip}" --context gke-central)
export GKE_TWO_ISTIO_GATEWAY=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[0].ip}" --context gke-west)
echo -e "${color}$ sed -e s/CLUSTER1_INGRESS_IP/$GKE_ONE_ISTIO_GATEWAY\ weight=1/g -e s/CLUSTER2_INGRESS_IP/$GKE_TWO_ISTIO_GATEWAY\ weight=1/g glb-configmap-var.yaml > ~/advanced-kubernetes-workshop/lb/glb-configmap.yaml${nc}" | pv -qL $SPEED
kubectx gke-spinnaker
cd ~/advanced-kubernetes-workshop/lb
sed -e s/CLUSTER1_INGRESS_IP/$GKE_ONE_ISTIO_GATEWAY\ weight=1/g -e s/CLUSTER2_INGRESS_IP/$GKE_TWO_ISTIO_GATEWAY\ weight=1/g ~/advanced-kubernetes-workshop/lb/glb-configmap-var.yaml > ~/advanced-kubernetes-workshop/lb/glb-configmap.yaml

# Confirm the NGINX configmap
echo -e "\n"
echo "${bold}Confirm the NGINX configmap${normal}"
read -p ''
echo -e "${color}$ cat ~/advanced-kubernetes-workshop/lb/glb-configmap.yaml${nc}" | pv -qL $SPEED
cat ~/advanced-kubernetes-workshop/lb/glb-configmap.yaml

# Apply the NGINX configmap
echo -e "\n"
echo "${bold}Apply the NGINX configmap${normal}"
read -p ''
echo -e "${color}$ kubectl apply -f ~/advanced-kubernetes-workshop/lb/glb-configmap.yaml${nc}" | pv -qL $SPEED
kubectl apply -f ~/advanced-kubernetes-workshop/lb/glb-configmap.yaml

# Create NGINX deployment and service
echo -e "\n"
echo "${bold}Create NGINX deployment and service${normal}"
read -p ''
echo -e "${color}$ kubectl apply -f ~/advanced-kubernetes-workshop/lb/nginx-dep.yaml${nc}" | pv -qL $SPEED
echo -e "${color}$ kubectl apply -f ~/advanced-kubernetes-workshop/lb/nginx-svc.yaml${nc}" | pv -qL $SPEED
kubectl apply -f ~/advanced-kubernetes-workshop/lb/nginx-dep.yaml
kubectl apply -f ~/advanced-kubernetes-workshop/lb/nginx-svc.yaml

# Get the NGINX service loadbalancer IP address
echo -e "\n"
echo "${bold}Get the NGINX service loadbalancer IP address${normal}"
read -p ''
echo -e "${color}$ kubectl get service global-lb-nginx -w${nc}" | pv -qL $SPEED
kubectl get service global-lb-nginx -w

# Send traffic to the NGINX loadbalancer IP address
echo -e "\n"
echo "${bold}Send traffic to the NGINX loadbalancer IP address${normal}"
read -p ''
export GLB_IP=$(kubectl get service global-lb-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo -e "${color}$ for i in 'seq 1 20'; do html2text http://$GLB_IP | grep gke; done${nc}" | pv -qL $SPEED
for i in `seq 1 20`; do html2text http://$GLB_IP | grep gke; done

# Change the NGINX configmap to send more traffic to gke-west vs gke-central
echo -e "\n"
echo "${bold}Change the NGINX configmap to send more traffic to gke-west vs gke-central${normal}"
read -p ''
echo -e "${color}$ sed -e s/CLUSTER1_INGRESS_IP/$GKE_ONE_ISTIO_GATEWAY\ weight=1/g -e s/CLUSTER2_INGRESS_IP/$GKE_TWO_ISTIO_GATEWAY\ weight=4/g ~/advanced-kubernetes-workshop/lb/glb-configmap-var.yaml > ~/advanced-kubernetes-workshop/lb/glb-configmap-2.yaml${nc}" | pv -qL $SPEED
echo -e "${color}$ kubectl delete -f ~/advanced-kubernetes-workshop/lb/glb-configmap.yaml${nc}" | pv -qL $SPEED
echo -e "${color}$ kubectl delete -f ~/advanced-kubernetes-workshop/lb/nginx-dep.yaml${nc}" | pv -qL $SPEED
echo -e "${color}$ kubectl apply -f ~/advanced-kubernetes-workshop/lb/glb-configmap-2.yaml${nc}" | pv -qL $SPEED
echo -e "${color}$ kubectl apply -f ~/advanced-kubernetes-workshop/lb/nginx-dep.yaml${nc}" | pv -qL $SPEED
sed -e s/CLUSTER1_INGRESS_IP/$GKE_ONE_ISTIO_GATEWAY\ weight=1/g -e s/CLUSTER2_INGRESS_IP/$GKE_TWO_ISTIO_GATEWAY\ weight=4/g ~/advanced-kubernetes-workshop/lb/glb-configmap-var.yaml > ~/advanced-kubernetes-workshop/lb/glb-configmap-2.yaml
kubectl delete -f ~/advanced-kubernetes-workshop/lb/glb-configmap.yaml
kubectl delete -f ~/advanced-kubernetes-workshop/lb/nginx-dep.yaml
kubectl apply -f ~/advanced-kubernetes-workshop/lb/glb-configmap-2.yaml
kubectl apply -f ~/advanced-kubernetes-workshop/lb/nginx-dep.yaml

# Inspect the new NGINX configmap
echo -e "\n"
echo "${bold}Inspect the new NGINX configmap${normal}"
read -p ''
echo -e "${color}$ kubectl get configmap nginx --context gke-spinnaker -o yaml | head -7${nc}" | pv -qL $SPEED
kubectl get configmap nginx --context gke-spinnaker -o yaml | head -7

# Send traffic to the NGINX loadbalancer IP address
echo -e "\n"
echo "${bold}Send traffic to the NGINX loadbalancer IP address${normal}"
read -p ''
echo -e "${color}$ for i in 'seq 1 20'; do html2text http://$GLB_IP | grep gke; done${nc}" | pv -qL $SPEED
for i in `seq 1 20`; do html2text http://$GLB_IP | grep gke; done

# Stop fortio
echo -e "\n"
echo "${bold}Stop the fortio traffic generator in Cloud Shell window #1${normal}"
read -p ''

# Generate traffic to the NGINX loadbalancer IP address
echo -e "\n"
echo "${bold}Generate traffic to the NGINX loadbalancer IP address and inspect Grafana${normal}"
read -p ''
echo -e "${color}$ fortio.sh 30m http://$GLB_IP${nc}" | pv -qL $SPEED
fortio.sh 30m http://$GLB_IP

