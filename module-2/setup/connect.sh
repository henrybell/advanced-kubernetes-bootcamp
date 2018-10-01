#!/usr/bin/env bash

# Expose DECK POD on Port 8080 for Spinnaker frontend
DECK_PORT=8080
DECK_POD=$(kubectl get po --namespace default -l "cluster=spin-deck" \
  -o jsonpath="{.items[0].metadata.name}" --context gke-spinnaker)

EXISTING_PID_8080=$(sudo netstat -nlp | grep $DECK_PORT | awk '{print $7}' | cut -f1 -d '/')

if [ -n "$EXISTING_PID_8080" ]; then
  echo "PID $EXISTING_PID_8080 already listening... restarting port-forward"
  kill $EXISTING_PID_8080
  sleep 5
fi

kubectl port-forward $DECK_POD $DECK_PORT:9000 -n default --context gke-spinnaker >> /dev/null &

echo "Spinnaker Deck Port opened on $DECK_PORT"


# Expose PROMETHEUS POD on Port 9090 (1) and 9091 (2)
PROM_PORT_1=9090
PROM_PORT_2=9091
PROM_POD_1=$(kubectl get po --namespace istio-system -l "app=prometheus" \
  -o jsonpath="{.items[0].metadata.name}" --context gke-ONE)
PROM_POD_2=$(kubectl get po --namespace istio-system -l "app=prometheus" \
  -o jsonpath="{.items[0].metadata.name}" --context gke-TWO)

EXISTING_PID_9090=$(sudo netstat -nlp | grep $PROM_PORT_1 | awk '{print $7}' | cut -f1 -d '/')
EXISTING_PID_9091=$(sudo netstat -nlp | grep $PROM_PORT_2 | awk '{print $7}' | cut -f1 -d '/')

if [ -n "$EXISTING_PID_9090" ]; then
  echo "PID $EXISTING_PID_9090 already listening... restarting port-forward"
  kill $EXISTING_PID_9090
  sleep 5
fi
if [ -n "$EXISTING_PID_9091" ]; then
  echo "PID $EXISTING_PID_9091 already listening... restarting port-forward"
  kill $EXISTING_PID_9091
  sleep 5
fi

kubectl port-forward $PROM_POD_1 $PROM_PORT_1:9090 -n istio-system --context gke-ONE >> /dev/null &
echo "Prometheus Port opened on $PROM_PORT_1 for gke-ONE"

kubectl port-forward $PROM_POD_2 $PROM_PORT_2:9090 -n istio-system --context gke-TWO >> /dev/null &
echo "Prometheus Port opened on $PROM_PORT_2 for gke-TWO"

# Expose GRAFANA POD on Port 3000 (1) and 3001 (2)
GRAFANA_PORT_1=3000
GRAFANA_PORT_2=3001
#GRAFANA_PORT_3=4000
GRAFANA_POD_1=$(kubectl get po --namespace istio-system -l "app=grafana" \
  -o jsonpath="{.items[0].metadata.name}" --context gke-ONE)
GRAFANA_POD_2=$(kubectl get po --namespace istio-system -l "app=grafana" \
  -o jsonpath="{.items[0].metadata.name}" --context gke-TWO)
#GRAFANA_POD_3=$(kubectl get po --namespace istio-system -l "app=grafana" \
#  -o jsonpath="{.items[0].metadata.name}" --context gke-spinnaker)

EXISTING_PID_3000=$(sudo netstat -nlp | grep $GRAFANA_PORT_1 | awk '{print $7}' | cut -f1 -d '/')
EXISTING_PID_3001=$(sudo netstat -nlp | grep $GRAFANA_PORT_2 | awk '{print $7}' | cut -f1 -d '/')
#EXISTING_PID_4000=$(sudo netstat -nlp | grep $GRAFANA_PORT_3 | awk '{print $7}' | cut -f1 -d '/')

if [ -n "$EXISTING_PID_3000" ]; then
  echo "PID $EXISTING_PID_3000 already listening... restarting port-forward"
  kill $EXISTING_PID_3000
  sleep 5
fi
if [ -n "$EXISTING_PID_3001" ]; then
  echo "PID $EXISTING_PID_3001 already listening... restarting port-forward"
  kill $EXISTING_PID_3001
  sleep 5
fi
#if [ -n "$EXISTING_PID_4000" ]; then
#  echo "PID $EXISTING_PID_4000 already listening... restarting port-forward"
#  kill $EXISTING_PID_4000
#  sleep 5
#fi

kubectl port-forward $GRAFANA_POD_1 $GRAFANA_PORT_1:3000 -n istio-system --context gke-ONE >> /dev/null &
echo "Grafana Port opened on $GRAFANA_PORT_1 for gke-ONE"

kubectl port-forward $GRAFANA_POD_2 $GRAFANA_PORT_2:3000 -n istio-system --context gke-TWO >> /dev/null &
echo "Grafana Port opened on $GRAFANA_PORT_2 for gke-TWO"

#kubectl port-forward $GRAFANA_POD_3 $GRAFANA_PORT_3:3000 -n istio-system --context gke-spinnaker >> /dev/null &
#echo "Grafana Port opened on $GRAFANA_PORT_3 for gke-spinnaker"


# Expose JAEGER POD on Port 16686 (1) and 16687 (2)
JAEGER_PORT_1=16686
JAEGER_PORT_2=16687
JAEGER_PORT_3=32439
JAEGER_POD_1=$(kubectl get po --namespace istio-system -l "app=jaeger" \
  -o jsonpath="{.items[0].metadata.name}" --context gke-ONE)
JAEGER_POD_2=$(kubectl get po --namespace istio-system -l "app=jaeger" \
  -o jsonpath="{.items[0].metadata.name}" --context gke-TWO)

EXISTING_PID_16686=$(sudo netstat -nlp | grep $JAEGER_PORT_1 | awk '{print $7}' | cut -f1 -d '/')
EXISTING_PID_32439=$(sudo netstat -nlp | grep $JAEGER_PORT_3 | awk '{print $7}' | cut -f1 -d '/')
EXISTING_PID_16687=$(sudo netstat -nlp | grep $JAEGER_PORT_2 | awk '{print $7}' | cut -f1 -d '/')

if [ -n "$EXISTING_PID_16686" ]; then
  echo "PID $EXISTING_PID_16686 already listening... restarting port-forward"
  kill $EXISTING_PID_16686
  sleep 5
fi
if [ -n "$EXISTING_PID_16687" ]; then
  echo "PID $EXISTING_PID_16687 already listening... restarting port-forward"
  kill $EXISTING_PID_16687
  sleep 5
fi
if [ -n "$EXISTING_PID_32439" ]; then
  echo "PID $EXISTING_PID_32439 already listening... restarting port-forward"
  kill $EXISTING_PID_32439
  sleep 5
fi

kubectl port-forward $JAEGER_POD_1 $JAEGER_PORT_1:16686 -n istio-system --context gke-ONE >> /dev/null &
echo "Jaeger Port opened on $JAEGER_PORT_1 for gke-ONE"

kubectl port-forward $JAEGER_POD_1 $JAEGER_PORT_3:16686 -n istio-system --context gke-ONE >> /dev/null &
echo "Jaeger Port opened on $JAEGER_PORT_3 for gke-ONE"

kubectl port-forward $JAEGER_POD_2 $JAEGER_PORT_2:16686 -n istio-system --context gke-TWO >> /dev/null &
echo "Jaeger Port opened on $JAEGER_PORT_2 for gke-TWO"

# Expose SERVICEGRAPH POD on Port 8088 (1) and 8089 (2)
SERVICEGRAPH_PORT_1=8088
SERVICEGRAPH_PORT_2=8089
SERVICEGRAPH_POD_1=$(kubectl get po --namespace istio-system -l "app=servicegraph" \
  -o jsonpath="{.items[0].metadata.name}" --context gke-ONE)
SERVICEGRAPH_POD_2=$(kubectl get po --namespace istio-system -l "app=servicegraph" \
  -o jsonpath="{.items[0].metadata.name}" --context gke-TWO)

EXISTING_PID_8088=$(sudo netstat -nlp | grep $SERVICEGRAPH_PORT_1 | awk '{print $7}' | cut -f1 -d '/')
EXISTING_PID_8089=$(sudo netstat -nlp | grep $SERVICEGRAPH_PORT_2 | awk '{print $7}' | cut -f1 -d '/')

if [ -n "$EXISTING_PID_8088" ]; then
  echo "PID $EXISTING_PID_8088 already listening... restarting port-forward"
  kill $EXISTING_PID_8088
  sleep 5
fi
if [ -n "$EXISTING_PID_8089" ]; then
  echo "PID $EXISTING_PID_8089 already listening... restarting port-forward"
  kill $EXISTING_PID_8089
  sleep 5
fi

kubectl port-forward $SERVICEGRAPH_POD_1 $SERVICEGRAPH_PORT_1:8088 -n istio-system --context gke-ONE >> /dev/null &
echo "Servicegraph Port opened on $SERVICEGRAPH_PORT_1 for gke-ONE"

kubectl port-forward $SERVICEGRAPH_POD_2 $SERVICEGRAPH_PORT_2:8088 -n istio-system --context gke-TWO >> /dev/null &
echo "Servicegraph Port opened on $SERVICEGRAPH_PORT_2 for gke-TWO"

# Expose KIALI POD on Port 20001 (1) and 20002 (2)
KIALI_PORT_1=20001
KIALI_PORT_2=20002
KIALI_POD_1=$(kubectl get po --namespace istio-system -l "app=kiali" \
  -o jsonpath="{.items[0].metadata.name}" --context gke-ONE)
KIALI_POD_2=$(kubectl get po --namespace istio-system -l "app=kiali" \
  -o jsonpath="{.items[0].metadata.name}" --context gke-TWO)

EXISTING_PID_20001=$(sudo netstat -nlp | grep $KIALI_PORT_1 | awk '{print $7}' | cut -f1 -d '/')
EXISTING_PID_20002=$(sudo netstat -nlp | grep $KIALI_PORT_2 | awk '{print $7}' | cut -f1 -d '/')

if [ -n "$EXISTING_PID_20001" ]; then
  echo "PID $EXISTING_PID_20001 already listening... restarting port-forward"
  kill $EXISTING_PID_20001
  sleep 5
fi
if [ -n "$EXISTING_PID_20002" ]; then
  echo "PID $EXISTING_PID_20002 already listening... restarting port-forward"
  kill $EXISTING_PID_20002
  sleep 5
fi

kubectl port-forward $KIALI_POD_1 $KIALI_PORT_1:20001 -n istio-system --context gke-ONE >> /dev/null &
echo "Kiali Port opened on $KIALI_PORT_1 for gke-ONE"

kubectl port-forward $KIALI_POD_2 $KIALI_PORT_2:20001 -n istio-system --context gke-TWO >> /dev/null &
echo "Kiali Port opened on $KIALI_PORT_2 for gke-TWO"
