#!/bin/bash

NAMESPACE=myproject
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Prometheus
kubectl apply -f $DIR/monitoring/alerting-interconnect.yaml -n $NAMESPACE
kubectl apply -f $DIR/monitoring/prometheus.yaml -n $NAMESPACE
kubectl apply -f $DIR/monitoring/alertmanager.yaml -n $NAMESPACE
kubectl expose service/prometheus -n $NAMESPACE

echo "Waiting for Prometheus server to be ready..."
kubectl rollout status deployment/prometheus -w -n $NAMESPACE
kubectl rollout status deployment/alertmanager -w -n $NAMESPACE
echo "...Prometheus server ready"

# Preparing Grafana datasource and dashboards
kubectl create configmap grafana-config \
    --from-file=datasource.yaml=$DIR/monitoring/dashboards/datasource.yaml \
    --from-file=grafana-dashboard-provider.yaml=$DIR/monitoring/grafana-dashboard-provider.yaml \
    --from-file=interconnect-dashboard.json=$DIR/monitoring/dashboards/interconnect-raw.json \
    -n $NAMESPACE

kubectl label configmap grafana-config app=interconnect

# Grafana
kubectl apply -f $DIR/monitoring/grafana.yaml -n $NAMESPACE
kubectl expose service/grafana -n $NAMESPACE

echo "Waiting for Grafana server to be ready..."
kubectl rollout status deployment/grafana -w -n $NAMESPACE
echo "...Grafana server ready"