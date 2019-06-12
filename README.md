# Monitor routers with prometheus

Following are instructions for using prometheus / grafana to monitor a Kubernetes cluster 
that is running [Apache Qpid Dispatch Router](https://qpid.apache.org/components/dispatch-router/index.html).

#### Note
These examples are provided for developers to quickly get started with monitoring the dispatch router and are not intended for use in production environments.

## Prerequisites / assumptions

You will need access to a Kubernetes cluster running a deployment of the router. See [qdr-operator](https://github.com/interconnectedcloud/qdr-operator) for instructions on how to install the qdr-operator into your cluster.

These instruction will only setup monitoring of the routers in the cluster. It will not monitor any user applications that connect to those routers.

This guide assumes you are using a project named 'myproject'. If not, change all namespace definitions to your current project name.

## Router network

After the qdr-operator is installed, the router network used in this example is deployed using:

```console
$ cat <<EOF | kubectl create -f -
apiVersion: interconnectedcloud.github.io/v1alpha1
kind: Interconnect
metadata:
  name: example-interconnect
spec:
  deploymentPlan:
    image: quay.io/interconnectedcloud/qdrouterd:1.7.0
    role: interior
    size: 3
    placement: Any
EOF
```

After the network is available, create a route to the router's console:

```
kubectl apply -f expose-interconnect.yaml
```

You should now be able to use the route on the example-interconnect service to view the interconnect console.

## Deploy prometheus / grafana

Run the deploy-monitoring script: 
```
$ ./deploy-monitoring.sh
```

This script will deploy prometheus, alertmanager, and an example alerting rule.
Once those are ready, it will deploy grafana and a sample dashboard using a configmap.
