#!/usr/bin/env bash

export GKE_ONE_ISTIO_GATEWAY=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[0].ip}" --context gke-ONE)
export GKE_TWO_ISTIO_GATEWAY=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[0].ip}" --context gke-TWO)

echo "gke-ONE ingress gateway: " 
echo "$GKE_ONE_ISTIO_GATEWAY"

echo""

echo "gke-TWO ingress gateway: " 
echo "$GKE_TWO_ISTIO_GATEWAY"

echo ""
